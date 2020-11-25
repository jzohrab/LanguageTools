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

# Assumption: folder name
MEDIA_FOLDER = '/Users/jeff/Library/Application Support/Anki2/User 1/collection.media/'

AUDIO_OUTFOLDER = File.join(__dir__, 'audio')
Dir.mkdir(audio_outfolder) unless Dir.exist?(AUDIO_OUTFOLDER)

fname = ARGV[0]
raise "Missing file" if fname.nil? || !File.exist?(fname)

lang = ARGV[1]

# Destination deck
deck = ''
# Voice to use for generation
voice = ''

case lang
when 'esp' then
  # Assumption
  deck = 'Spanish::Goldlist'
  voice = 'Conchita'  # Luisa, Enrique
when 'deu' then
  raise 'Fix the german settings'
# deck = 'german'
# voice = 'Vicki'  # Marlene, Hans
else
  raise "Bad lang code, should be esp or deu"
end

# Cards are given an ID, use date/time as start of ID unless specified.
baseid = Time.now.strftime("%Y%m%d_%H%M%S")
baseid = ARGV[2] unless ARGV[2].nil?

# Remove cruft from text file lines.
def cleanLines(s)
  s.split("\n").
    map { |s| s.strip }.
    select { |s| s != "" }.
    select { |s| s !~ /^#/ }
end

content = File.read(fname)
foreign, native = content.split(/^---+/).map { |s| cleanLines(s) }
raise "Unequal src, translation lengths" if (native.size != foreign.size)

# Base data
# Assumption: field names
idnum = 0
data = native.zip(foreign).map do |n, f|
  idnum += 1
  id = "#{baseid}_#{idnum}"
  {
    native_text: n,
    native_file: "#{id}_eng.mp3",
    target_text: f,
    target_file: "#{id}_#{lang}.mp3",
    ID: id
  }
end

# puts data.inspect

# Generate files
puts "Generating sound files in #{AUDIO_OUTFOLDER}"

voicedata = []
voicedata += data.map do |d|
  {
    text: d[:native_text],
    voice_id: 'Matthew',
    filename: File.join(AUDIO_OUTFOLDER, d[:native_file])
  }
end

voicedata += data.map do |d|
  {
    text: d[:target_text],
    voice_id: voice,
    filename: File.join(AUDIO_OUTFOLDER, d[:target_file])
  }
end

Polly.bulk_create_mp3(voicedata)

# Generate part of data structure

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

def move_audio_files_to_Anki_folder()
  FileUtils.mv Dir.glob(File.join(AUDIO_OUTFOLDER, '*.mp3')), MEDIA_FOLDER
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

postdata = {
  action: "addNotes",
  version: 6,
  params: {
    notes: noteData
  }
}

puts "Moving files to #{MEDIA_FOLDER}"
move_audio_files_to_Anki_folder()
puts "Posting cards to AnkiConnect"
post_notes_to_AnkiConnect(postdata)

puts "Done."
