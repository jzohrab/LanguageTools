# AudioCloze takes a voice synth object, and asks it to build the
# list of things to synthesize.
class FakePolly
  def initialize()
    @nextFilename = 0
    @data = []
  end

  def next_filename()
    @nextFilename += 1
    File.join('rootdir', @nextFilename.to_s)
  end

  def add_data(filename, text)
    @data.push({ :f => filename, :t => text })
  end

  def data()
    @data.map { |d| "#{d[:f]}: #{d[:t]}" }.join('; ')
  end
end
