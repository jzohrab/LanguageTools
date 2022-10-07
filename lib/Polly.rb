# coding: utf-8
# Simple wrapper for AWS polly and SDK
# ref https://docs.aws.amazon.com/sdk-for-ruby/v3/developer-guide/polly-example-synthesize-speech.html

require 'aws-sdk-polly'


class Polly

  def self.list_voices(lang_code)
    args = {
      engine: "standard",
      # see lang codes at https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/Polly/Client.html
      language_code: lang_code,
      include_additional_language_codes: false,
    }
    polly = Aws::Polly::Client.new
    resp = polly.describe_voices(args)
    ret = resp.voices.map do |v|
      { voice_id: v.id, gender: v.gender }
    end
    ret
  end
  
  def self.create_ssml_text(text)
    # If a sentence ends with underline-punctuation,
    # remove the punctuation b/c the AWS text-to-voice
    # says the punctuation.

    # If the sentence contains '__', sometimes AWS polly says
    # 'guion bajo', etc ... so make it three underscores.
    tmp = text.
            gsub(/_[.?!]/, '_').
            gsub('__', '___').
            gsub(/\w_+\w/, '<amazon:breath/>')
    "<speak>#{tmp}</speak>"
  end

  def self.create_mp3(text, voice_id, filename)
    polly = Aws::Polly::Client.new
    args = {
      text_type: 'ssml',
      output_format: 'mp3',
      text: self.create_ssml_text(text),
      voice_id: voice_id,
      sample_rate: '16000',
    }
    resp = polly.synthesize_speech(args)
    
    IO.copy_stream(resp.audio_stream, filename)
  end

  def self.bulk_create_mp3(data)

    start_time = Time.now

    # Don't mutate the arg passed in.
    #
    # Reversing so that lookups are done in the order they're passed
    # in (this is not necessary at all, but I want the lookup order to
    # _approximately match the order of the words in the source file.)
    data_queue = data.dup.reverse

    thread_count = 20
    dict = {}
    mutex = Mutex.new

    thread_count.times.map {
      Thread.new(data_queue) do |data_queue|
        while d = mutex.synchronize { data_queue.pop }
          f = d[:filename]
          # puts "  ... start #{f}"
          self.create_mp3(d[:text], d[:voice_id], f)
          mutex.synchronize do
            puts "  ... #{f}"
          end
        end
      end
    }.each(&:join)

    puts "Done"
  end
  
end

if __FILE__ == $0
  # puts ARGV.inspect

  option = "voices"
  if ARGV.size != 0 then
    option = ARGV[0]
  end

  case option
  when 'voices' then
    print "Enter language code (e.g., es-ES, fr-FR): "
    lang_code = STDIN.gets().strip()
    puts "Listing voices for #{lang_code}:"
    puts Polly.list_voices(lang_code).inspect
  when 'test' then
    puts "Generating sample files:"
    Polly.create_mp3("¿Hola, qué tal?", "Enrique", "testing.mp3")
    data = [
      { text: "Tengo un gato negro.", voice_id: "Enrique", filename: "1_gato.mp3" },
      { text: "I have a black cat.", voice_id: "Matthew", filename: "1_cat.mp3" }
    ]
    voices = 'Salli,Matthew,Joey'.split(',')  # There are other voices.
    voices.each do |v|
      data << { text: "#{v} says I have a black cat.", voice_id: v, filename: "1_cat_#{v}.mp3" }
    end
    Polly.bulk_create_mp3(data)
  when 'pauses' then
    Polly.create_mp3("Haben Sie Probleme mit ___ _____?", "Vicki", "p_breath.mp3")
    Polly.create_mp3("Haben Sie Probleme mit Ihren Zähnen?", "Vicki", "p_actual.mp3")
  else
    puts "Unknown option, 'voices' or 'test' only"
  end
    
end
