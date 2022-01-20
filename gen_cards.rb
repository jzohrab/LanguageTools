# coding: utf-8
# Read cloze file (with #lang directive at the top),
# and generate cloze audio cards, posting to ankiconnect.
#
# Sample call:
#
#   ruby [thisfile].rb cloze.txt
#
# Can add 'TEST' environment variable to test-gen a file, not actually post anything:
#


require 'date'
require 'net/http'
require 'json'
require_relative './lib/audio_cloze'
require_relative './lib/audio_q_a'
require_relative './lib/audio_exposure'
require_relative './lib/settings'
require_relative './lib/Polly'
require_relative './lib/AudioClozeHelpers'

def getLangCode(fname)
  # eg. "#deu" or "#esp", placed at top of the file.
  content = File.read(fname)
  firstline = content.split("\n")[0]
  return firstline.gsub(/ /, '').gsub('#', '')
end


# Remove cruft from text file lines.
def cleanLines(s)
  s.split("\n").
    map { |s| s.strip }.
    select { |s| s != "" }.
    select { |s| s !~ /^#/ }
end


def get_cards(file)
  lines = cleanLines(File.read(file))
  cards = lines.map do |s|
    c = nil
    if AudioCloze.possible?(s) then
      c = AudioCloze.new(s)
    elsif AudioQA.possible?(s) then
      c = AudioQA.new(s)
    else
      c = AudioExposure.new(s)
    end
    c
  end
  return cards
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
    ret = File.join(@outdir, f)
    # puts "Got file: #{ret}"
    return ret
  end

  def add_data(filename, text)
    @data.push({ :f => filename, :t => text })
  end

  def data()
    @data
  end
end


##########################################
# Main

settings_file = File.join(File.dirname(__FILE__), 'settings.yml')
settings = Settings.new(settings_file)

# Assumption: folder name
MEDIA_FOLDER = settings.media_file

file = ARGV[0]
raise "Missing file name" if file.nil?
raise "Missing file #{file}" unless File.exist?(file)

lang = getLangCode(file)
deck = settings.deck(lang)
voice = settings.voice(lang)

cards = get_cards(file)

flist = FileList.new(MEDIA_FOLDER)
cards.reduce(flist) { |t, a| a.load_synth(t); t }

voicedata = flist.data.map do |f|
  {
    text: f[:t],
    voice_id: voice,
    filename: f[:f]
  }
end

postdata = createAnkiConnectPostBody(cards, deck)

if !ENV['TEST'].nil? then
  puts "\nData to post:"
  puts JSON.pretty_generate(postdata)
  puts "\nVoice cards to generate:"
  puts JSON.pretty_generate(voicedata)
  puts "\n\nQUITTING."
  return
end

Polly.bulk_create_mp3(voicedata)
post_notes_to_AnkiConnect(postdata)
