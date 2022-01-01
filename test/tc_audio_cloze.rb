# coding: utf-8

require "test/unit"
require 'json'
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
    assert_equal('hi', ac.answer, 'answer')
    assert_true(ac.question.nil?, "nil question but got #{ac.question}")
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
      File.join('rootdir', @nextFilename.to_s)
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
    assert_equal('rootdir/1: hi; rootdir/2: b.  hi ___; rootdir/3: hi a', tp.data())
  end


  def test_get_json
    ac1 = AudioCloze.new("hi")
    ac2 = AudioCloze.new("hi *a|b*")

    tp = TestPolly.new()
    [ ac1, ac2 ].reduce(tp) { |t, a| a.load_synth(t); t }
    assert_equal('rootdir/1: hi; rootdir/2: b.  hi ___; rootdir/3: hi a', tp.data())

    base = {
      deckName: 'deck',
      modelName: "Cloze_audio",
      options: { allowDuplicate: true },
      tags: []
    }

    expected_ac1 = {
      fields: {
        Sentence_full: 'hi',
        Sentence_audio: '[sound:1]'
      }
    }
    assert_equal(base.merge(expected_ac1), ac1.json('deck'), 'ac1')

    expected_ac2 = {
      fields: {
        Sentence_full: 'hi a',
        Sentence_audio: '[sound:3]',
        Sentence_with_blank: 'b.  hi ___',
        Sentence_with_blank_audio: '[sound:2]',
      }
    }
    assert_equal(base.merge(expected_ac2), ac2.json('deck'), 'ac2')

  end
  
end
