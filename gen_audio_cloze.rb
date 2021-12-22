# coding: utf-8
# Read cloze file (with #lang directive at the top),
# and generate cloze audio cards, posting to ankiconnect.
#
# Sample call:
#
#   ruby [thisfile].rb cloze.txt
#


require 'date'
require 'net/http'
require 'json'
require_relative './lib/audio_cloze'
require_relative './lib/Polly'
require_relative './lib/AudioClozeHelpers'

# Generated audio files have an incremented value in the filename to disambiguate.
$idnum = 0

def getLangCode(fname)
  # eg. "#deu" or "#esp", placed at top of the file.
  content = File.read(fname)
  firstline = content.split("\n")[0]
  return firstline.gsub(/ /, '').gsub('#', '')
end


def getSettingsFor(lang)
  case lang
  when 'esp' then
    return {
      # Assumption
      deck: 'Spanish::01_Spanish_Vocab',
      voice: 'Conchita'  # Luisa, Enrique
    }
  when 'deu' then
    return {
      # Assumption
      deck: 'German::01_German_Vocab',
      voice: 'Vicki'  # Marlene, Hans
    }
  else
    raise "First line of file should contain lang code esp or deu, got #{lang}"
  end
end

# Remove cruft from text file lines.
def cleanLines(s)
  s.split("\n").
    map { |s| s.strip }.
    select { |s| s != "" }.
    select { |s| s !~ /^#/ }
end

def getAudioFilename()
  baseid = Time.now.strftime("%Y%m%d_%H%M%S")
  $idnum += 1
  "#{baseid}_#{$idnum}.mp3"
end

# Der Hund *des Kindes|das Kind*. => das Kind.  Der Hund ___ _____.; Der Hund des Kindes.
def getClozes(lines)
  lines.map do |text|
    qtext = AudioClozeHelpers.get_question(text)
    qfile = getAudioFilename()
    atext = AudioClozeHelpers.get_answer(text)
    afile = getAudioFilename()

    # If the answer and question are the same then don't bother with the question,
    # as this is just an "exposure card" with no corresponding question card.
    if (qtext == atext) then
      qtext = nil
      qfile = nil
    end
    {
      q: qtext,
      qaudio: qfile,
      a: atext,
      aaudio: afile
    }
  end
end


def move_audio_files_to_Anki_folder()
  FileUtils.mv Dir.glob(File.join(AUDIO_OUTFOLDER, '*.mp3')), MEDIA_FOLDER
end


def createAnkiConnectPostBody(data, deck)
  return {
    action: "addNotes",
    version: 6,
    params: {
      notes: data.map { |d| d.json(deck) }
    }
  }
end


def post_notes_to_AnkiConnect(data)
  uri = URI('http://localhost:8765/')
  http = Net::HTTP.new(uri.host, uri.port)
  puts uri.path
  req = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
  req.body = data.to_json
  puts JSON.pretty_generate(data)
  puts "request body: #{req.body}"
  res = http.request(req)
  puts "response body: #{res.body}"
  puts "Response:"
  puts res.inspect
rescue => e
  puts "failed #{e}"
end


# Assumption: folder name
MEDIA_FOLDER = '/Users/jeff/Library/Application Support/Anki2/User 1/collection.media/'

AUDIO_OUTFOLDER = File.join(__dir__, 'audio')
Dir.mkdir(audio_outfolder) unless Dir.exist?(AUDIO_OUTFOLDER)


file = ARGV[0]
raise "Missing file name" if file.nil?
raise "Missing file #{file}" unless File.exist?(file)

lang = getLangCode(file)
settings = getSettingsFor(lang)
lines = cleanLines(File.read(file))
clozes = lines.map { |s| AudioCloze.new(s) }

# List builder of text to synthesize.
class FileList
  def initialize(outdir)
    @nextFilename = 0
    @data = []
    @outdir = outdir
    @baseid = Time.now.strftime("%Y%m%d_%H%M%S")
  end

  def next_filename()
    @nextFilename += 1
    f = "#{@baseid}_#{@nextFilename}.mp3"
    return File.join(@outdir, f)
  end

  def add_data(filename, text)
    @data.push({ :f => filename, :t => text })
  end

  def data()
    @data
  end
end

flist = FileList.new(AUDIO_OUTFOLDER)
clozes.reduce(flist) { |t, a| a.load_synth(t); t }
voicedata = flist.data.map do |f|
  {
    text: f[:t],
    voice_id: settings[:voice],
    filename: f[:f]
  }
end
postdata = createAnkiConnectPostBody(clozes, settings[:deck])

# puts clozes.inspect
# puts flist.inspect
# puts voicedata.inspect
# puts postdata.inspect

# puts "\n\nQUITTING ..."
# return

Polly.bulk_create_mp3(voicedata)
post_notes_to_AnkiConnect(postdata)
