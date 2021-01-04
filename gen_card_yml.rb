# coding: utf-8
# Generate yml for cards, for subsequent editing.
#
# Sample call:
#
#   ruby [thisfile].rb file.txt
#


require 'date'
require 'yaml'

# Generated audio files have an incremented value in the filename to disambiguate.
$idnum = 0

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

def getYml(line)
  clozeRe = /\*(.*?)\*/
  cloze = line.match(clozeRe)[1]
  blanks = cloze.gsub(/[^ ]/, '__').gsub(/_____+/, '____')

  return {
    word: cloze,
    waudio: getAudioFilename(),
    article: nil,
    plural: nil,
    paudio: getAudioFilename(),
    blanks: line.gsub(clozeRe, blanks),
    baudio: getAudioFilename(),
    sentence: line.gsub(clozeRe, cloze),
    saudio: getAudioFilename()
  }
end

file = ARGV[0]
raise "Missing file name" if file.nil?
raise "Missing file #{file}" unless File.exist?(file)

lines = cleanLines(File.read(file))
yml = lines.map { |s| getYml(s) }
# puts yml.inspect

File.open("#{file}.yml", 'w') { |f| f.write yml.to_yaml.gsub(/^-/m, "\n-") }
