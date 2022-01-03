# coding: utf-8

require "test/unit"
require 'json'
require_relative "../lib/audio_cloze"
require_relative "./fake_polly"

class TestAudioCloze < Test::Unit::TestCase

  def test_constructor
    # Sanity check only
    ac = AudioCloze.new("hi *a|b*")
    assert_equal('b.  hi ___', ac.front, 'question')
    assert_equal('hi a', ac.back, 'answer')
  end

  def test_constructor_empty_hint
    # Sanity check only
    ac = AudioCloze.new("hi *a|*")
    assert_equal('hi ___', ac.front, 'question, empty hint')
    assert_equal('hi a', ac.back, 'answer')
  end

  def test_constructor_no_cloze
    # Sanity check only
    ac = AudioCloze.new("hi")
    assert_equal('hi', ac.back, 'answer')
    assert_true(ac.front.nil?, "nil question but got #{ac.front}")
  end

  def test_possible
    assert_true(AudioCloze.possible?('hi *there*'), 'single cloze')
    assert_true(AudioCloze.possible?('hi *there|hint*'), 'single cloze with hint')
    assert_true(AudioCloze.possible?('hi **'), 'empty cloze')
    assert_false(AudioCloze.possible?('hi'), 'No cloze')
    assert_false(AudioCloze.possible?(''), 'no sentence')
    assert_false(AudioCloze.possible?(nil), 'nil sentence')
  end


  def test_load_synth
    ac1 = AudioCloze.new("hi")
    ac2 = AudioCloze.new("hi *a|b*")

    tp = FakePolly.new()
    [ ac1, ac2 ].reduce(tp) { |t, a| a.load_synth(t); t }
    assert_equal('rootdir/1: hi; rootdir/2: b.  hi ___; rootdir/3: hi a', tp.data())
  end


  def test_get_json
    ac1 = AudioCloze.new("hi")
    ac2 = AudioCloze.new("hi *a|b*")

    tp = FakePolly.new()
    [ ac1, ac2 ].reduce(tp) { |t, a| a.load_synth(t); t }
    assert_equal('rootdir/1: hi; rootdir/2: b.  hi ___; rootdir/3: hi a', tp.data())

    base = {
      deckName: 'deck',
      modelName: "Audio_cloze",
      options: { allowDuplicate: true },
      tags: []
    }

    expected_ac1 = {
      fields: {
        Back: 'hi',
        Back_audio: '[sound:1]'
      }
    }
    assert_equal(base.merge(expected_ac1), ac1.json('deck'), 'ac1')

    expected_ac2 = {
      fields: {
        Back: 'hi a',
        Back_audio: '[sound:3]',
        Front: 'b.  hi ___',
        Front_audio: '[sound:2]',
      }
    }
    assert_equal(base.merge(expected_ac2), ac2.json('deck'), 'ac2')

  end
  
end
