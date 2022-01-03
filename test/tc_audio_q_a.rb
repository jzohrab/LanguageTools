# coding: utf-8

require "test/unit"
require 'json'
require_relative "../lib/audio_q_a"
require_relative "./fake_polly"

class TestAudioQA < Test::Unit::TestCase

  def test_constructor
    # Sanity check only
    ac = AudioQA.new("q|a")
    assert_equal('q', ac.front, 'question')
    assert_equal('a', ac.back, 'answer')
  end

  def test_possible
    assert_true(AudioQA.possible?('hi|there'), 'front, back')
    assert_true(AudioQA.possible?('hi|there, stuff'), 'ok')
    assert_false(AudioQA.possible?('hi|'), 'empty answer not allowed')
    assert_false(AudioQA.possible?('hi|there|stuff'), 'too many splits, no good')
    assert_false(AudioQA.possible?('hi'), 'no q/a')
    assert_false(AudioQA.possible?(''), 'no sentence')
    assert_false(AudioQA.possible?(nil), 'nil sentence')
  end


  def test_load_synth
    ac1 = AudioQA.new("hi|there")
    ac2 = AudioQA.new("and|goodbye")

    tp = FakePolly.new()
    [ ac1, ac2 ].reduce(tp) { |t, a| a.load_synth(t); t }
    assert_equal('rootdir/1: hi; rootdir/2: there; rootdir/3: and; rootdir/4: goodbye', tp.data())
  end


  def test_get_json
    ac1 = AudioQA.new("hi|there")
    ac2 = AudioQA.new("and|goodbye")

    tp = FakePolly.new()
    [ ac1, ac2 ].reduce(tp) { |t, a| a.load_synth(t); t }

    base = {
      deckName: 'deck',
      modelName: "Audio_Q_A",
      options: { allowDuplicate: true },
      tags: []
    }

    expected_ac1 = {
      fields: {
        Front: 'hi',
        Front_audio: '[sound:1]',
        Back: 'there',
        Back_audio: '[sound:2]'
      }
    }
    assert_equal(base.merge(expected_ac1), ac1.json('deck'), 'ac1')

    expected_ac2 = {
      fields: {
        Front: 'and',
        Front_audio: '[sound:3]',
        Back: 'goodbye',
        Back_audio: '[sound:4]'
      }
    }
    assert_equal(base.merge(expected_ac2), ac2.json('deck'), 'ac2')

  end
  
end
