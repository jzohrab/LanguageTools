# Get the text on the clipboard, and generate a Polly clip with it
# directly in Anki media folder, putting the name of the generated
# file on the mac clipboard so it can be pasted into a field.

# ref https://coderwall.com/p/qp2aha/ruby-pbcopy-and-pbpaste

require_relative './lib/Polly'

AUDIO_OUTFOLDER = File.join(__dir__, 'audio')
Dir.mkdir(audio_outfolder) unless Dir.exist?(AUDIO_OUTFOLDER)

content = `pbpaste`
puts content

def pbcopy(input)
  str = input.to_s
  IO.popen('pbcopy', 'w') { |f| f << str }
  str
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

lang = ARGV[0]
s = getSettingsFor(lang)

fname = Time.now.strftime("%Y%m%d_%H%M%S")
fname = "#{fname}.mp3"

puts "Generating #{fname} ..."
fpath = File.join(AUDIO_OUTFOLDER,fname)
Polly.create_mp3(content, s[:voice], fpath)
`afplay #{fpath}`

tmp = "[sound:#{fname}]"
pbcopy(tmp)
puts "\"#{tmp}\" placed on clipboard."
