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

end
