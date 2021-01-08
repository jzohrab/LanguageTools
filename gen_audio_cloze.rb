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
require_relative './lib/Polly'
require_relative './lib/AudioClozeHelpers'

# Generated audio files have an incremented value in the filename to disambiguate.
$idnum = 0

def getLangCode(fname)
  # Hardcode for now.  Later, get it from a directive at the top of the file,
  # eg. "#deu" or "#esp"
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
    {
      q: AudioClozeHelpers.get_question(text),
      qaudio: getAudioFilename(),
      a: AudioClozeHelpers.get_answer(text),
      aaudio: getAudioFilename()
    }
  end
end

def getPollyData(clozes, voice)
  voicedata = []
  voicedata += clozes.map do |d|
    {
      text: d[:q],
      voice_id: voice,
      filename: File.join(AUDIO_OUTFOLDER, d[:qaudio])
    }
  end

  voicedata += clozes.map do |d|
    {
      text: d[:a],
      voice_id: voice,
      filename: File.join(AUDIO_OUTFOLDER, d[:aaudio])
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
      modelName: "Cloze_audio",
      fields: {
        Sentence_with_blank: d[:q],
        Sentence_with_blank_audio: "[sound:#{d[:qaudio]}]",
        Sentence_full: d[:a],
        Sentence_Audio: "[sound:#{d[:aaudio]}]"
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

clozes = getClozes(lines)
puts clozes.inspect

voicedata = getPollyData(clozes, settings[:voice])
puts voicedata.inspect

Polly.bulk_create_mp3(voicedata)
move_audio_files_to_Anki_folder()

postdata = createAnkiConnectPostBody(clozes, settings[:deck])
post_notes_to_AnkiConnect(postdata)
