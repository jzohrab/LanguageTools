# coding: utf-8
# Read L1/L2 file, weave to form stuff.
# file is split by '---', L2 is on top, L1 on bottom.
#
# Sample call:
#
#   ruby [thisfile].rb sample.txt deu
#


require 'yaml'
require 'net/http'
require 'json'
require_relative './lib/Polly'

# Assumption: folder name
MEDIA_FOLDER = '/Users/jeff/Library/Application Support/Anki2/User 1/collection.media/'

AUDIO_OUTFOLDER = File.join(__dir__, 'audio')
Dir.mkdir(audio_outfolder) unless Dir.exist?(AUDIO_OUTFOLDER)


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
    raise "Bad lang code, should be esp or deu"
  end
end


def getPollyData(data, voice)
  # puts data.inspect
  pairs = []
  data.each do |d|
    if (!d[:word].nil?) then
      tmp = d[:word]
      tmp = "#{d[:article]} #{tmp}" if (!d[:article].nil?)
      pairs += [ [ tmp, d[:waudio] ] ]
    end

    # puts '-' * 20
    [
      [ :plural, :paudio ],
      [ :blanks, :baudio ],
      [ :sentence, :saudio ]
    ].each do |fa|
      # puts fa.inspect
      # puts '---'
      pairs += [ [ d[fa[0]], d[fa[1]] ] ] if (!d[fa[0]].nil?)
    end
    # puts '-' * 20
  end
  # puts '=' * 20
  # puts pairs.inspect
  # puts '=' * 20
  voicedata = pairs.map do |pair|
    {
      text: pair[0],
      voice_id: voice,
      filename: File.join(AUDIO_OUTFOLDER, pair[1])
    }
  end

  # puts voicedata.inspect

  return voicedata
end


def move_audio_files_to_Anki_folder()
  FileUtils.mv Dir.glob(File.join(AUDIO_OUTFOLDER, '*.mp3')), MEDIA_FOLDER
end

def sound(fname)
  "[sound:#{fname}]"
end

def createAnkiConnectPostBody(data, deck)
  noteData = data.map do |d|
    {
      deckName: deck,
      # Assumption: model name
      modelName: "Basic_vocab",
      fields: {
        Word: d[:word],
        Word_Audio: sound(d[:waudio]),
        Sentence_with_blank: d[:blanks],
        Sentence_with_blank_audio: sound(d[:baudio]),
        Sentence_full: d[:sentence],
        Sentence_Audio: sound(d[:saudio])
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
  begin
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
end

fname = ARGV[0]
lang = ARGV[1]

settings = getSettingsFor(lang)
data = YAML.load_file(fname)

puts "Generating sound files in #{AUDIO_OUTFOLDER}"
voice = settings[:voice]
# puts data.inspect
voicedata = getPollyData(data, voice)
# puts voicedata.inspect
Polly.bulk_create_mp3(voicedata)

puts "Moving files to #{MEDIA_FOLDER}"
move_audio_files_to_Anki_folder()

puts "Posting cards to AnkiConnect"
deck = settings[:deck]
postdata = createAnkiConnectPostBody(data, deck)
post_notes_to_AnkiConnect(postdata)

puts "Done #{fname}."
