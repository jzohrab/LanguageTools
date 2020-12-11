# coding: utf-8
# Read L1/L2 file, weave to form stuff.
# file is split by '---', L2 is on top, L1 on bottom.
#
# Sample call:
#
#   ruby [thisfile].rb sample.txt deu
#


require 'date'
require 'net/http'
require 'json'
require_relative './lib/Polly'

# Generated audio files have an incremented value in the filename to disambiguate.
$idnum = 0


# Remove cruft from text file lines.
def cleanLines(s)
  s.split("\n").
    map { |s| s.strip }.
    select { |s| s != "" }.
    select { |s| s !~ /^#/ }
end


# Get L2 and L1 data from file
def getL2L1Data(baseid, lang, fname)
  content = File.read(fname)
  foreign, native = content.split(/^---+/).map { |s| cleanLines(s) }
  raise "Unequal src, translation lengths" if (native.size != foreign.size)

  # Base data
  # Assumption: field names
  data = native.zip(foreign).map do |n, f|
    $idnum += 1
    id = "#{baseid}_#{$idnum}"
    {
      native_text: n,
      native_file: "#{id}_eng.mp3",
      target_text: f,
      target_file: "#{id}_#{lang}.mp3",
      ID: id
    }
  end
  data
end


def getSettingsFor(lang)
  case lang
  when 'esp' then
    return {
      # Assumption
      deck: 'Spanish::Goldlist',
      voice: 'Conchita'  # Luisa, Enrique
    }
  when 'deu' then
    return {
      # Assumption
      deck: 'German::Audio',
      voice: 'Vicki'  # Marlene, Hans
    }
  else
    raise "Bad lang code, should be esp or deu"
  end
end


def getPollyData(data, voiceL1, voiceL2)
  voicedata = []
  voicedata += data.map do |d|
    {
      text: d[:native_text],
      voice_id: voiceL1,
      filename: File.join(AUDIO_OUTFOLDER, d[:native_file])
    }
  end

  voicedata += data.map do |d|
    {
      text: d[:target_text],
      voice_id: voiceL2,
      filename: File.join(AUDIO_OUTFOLDER, d[:target_file])
    }
  end

  return voicedata
end


def move_audio_files_to_Anki_folder()
  FileUtils.mv Dir.glob(File.join(AUDIO_OUTFOLDER, '*.mp3')), MEDIA_FOLDER
end


def createAnkiConnectPostBody(data, deck)
  noteData = data.map do |d|
    {
      deckName: deck,
      # Assumption: model name
      modelName: "Audio",
      fields: {
        native_text: d[:native_text],
        native_audio: "[sound:#{d[:native_file]}]",
        target_text: d[:target_text],
        target_audio: "[sound:#{d[:target_file]}]",
        ID: d[:ID]
      }
    }
  end

  return {
    action: "addNotes",
    version: 6,
    params: {
      notes: noteData
    }
  }
end


def post_notes_to_AnkiConnect(data)
  uri = URI('http://localhost:8765/')
  http = Net::HTTP.new(uri.host, uri.port)
  puts uri.path
  req = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
  req.body = data.to_json
  res = http.request(req)
  puts "response #{res.body}"
rescue => e
  puts "failed #{e}"
end


# Cards are given an ID, use date/time as start of ID unless specified.
baseid = Time.now.strftime("%Y%m%d_%H%M%S")
baseid = ARGV[0] unless ARGV[0].nil?


# Assumption: folder name
MEDIA_FOLDER = '/Users/jeff/Library/Application Support/Anki2/User 1/collection.media/'

AUDIO_OUTFOLDER = File.join(__dir__, 'audio')
Dir.mkdir(audio_outfolder) unless Dir.exist?(AUDIO_OUTFOLDER)


files = []
Dir.chdir('text') do |d|
  files = Dir.glob('**/*.txt')
end

files = files.map do |f|
  {
    file: File.join('text', f),
    lang: f.split('/')[0],
    moveto: File.join('text-done', f)
  }
end
puts files.inspect


files.each do |f|
  fname = f[:file]
  lang = f[:lang]

  settings = getSettingsFor(lang)
  data = getL2L1Data(baseid, lang, fname)

  puts "Generating sound files in #{AUDIO_OUTFOLDER}"
  voice = settings[:voice]
  voicedata = getPollyData(data, 'Matthew', voice)
  Polly.bulk_create_mp3(voicedata)

  puts "Moving files to #{MEDIA_FOLDER}"
  move_audio_files_to_Anki_folder()

  puts "Posting cards to AnkiConnect"
  deck = settings[:deck]
  postdata = createAnkiConnectPostBody(data, deck)
  post_notes_to_AnkiConnect(postdata)

  puts "Moving file to done"
  FileUtils.mv fname, f[:moveto]

  puts "Done #{fname}."
end
