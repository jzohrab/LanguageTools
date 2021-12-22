# coding: utf-8

require "test/unit"
require_relative "../lib/audio_cloze"

class TestAudioCloze < Test::Unit::TestCase

  def test_constructor
    # Sanity check only
    ac = AudioCloze.new("hi *a|b*")
    assert_equal('b.  hi ___', ac.question, 'question')
    assert_equal('hi a', ac.answer, 'answer')
  end

  def test_constructor_no_cloze
    # Sanity check only
    ac = AudioCloze.new("hi")
    assert_equal('hi', ac.question, 'question')
    assert_true(ac.answer.nil?, "nil answer but got #{ac.answer}")
  end


  # AudioCloze takes a voice synth object, and asks it to build the
  # list of things to synthesize.
  class TestPolly
    def initialize()
      @nextFilename = 0
      @data = []
    end

    def next_filename()
      @nextFilename += 1
      @nextFilename
    end

    def add_data(filename, text)
      @data.push({ :f => filename, :t => text })
    end

    def data()
      @data.map { |d| "#{d[:f]}: #{d[:t]}" }.join('; ')
    end
  end


  def test_load_synth
    ac1 = AudioCloze.new("hi")
    ac2 = AudioCloze.new("hi *a|b*")

    tp = TestPolly.new()
    [ ac1, ac2 ].reduce(tp) { |t, a| a.load_synth(t); t }
    assert_equal('1: hi; 2: b.  hi ___; 3: hi a', tp.data())
  end

end
