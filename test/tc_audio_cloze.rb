# coding: utf-8

require "test/unit"
require 'json'
require_relative "../lib/audio_cloze"
require_relative "./fake_polly"

class TestAudioCloze < Test::Unit::TestCase

  def test_constructor
    # Sanity check only
    ac = AudioCloze.new("hi [a|b]")
    assert_equal('b.  hi ___', ac.front, 'question')
    assert_equal('hi a', ac.back, 'answer')
  end

  def test_hint_with_extra_detail_to_be_included_in_answer
    ac = AudioCloze.new("hi [word|hint|detail]")
    assert_equal('hint.  hi ___', ac.front, 'question')
    assert_equal('detail.  hi word', ac.back, 'answer')
  end

  def test_constructor_empty_hint
    # Sanity check only
    ac = AudioCloze.new("hi [a|]")
    assert_equal('hi ___', ac.front, 'question, empty hint')
    assert_equal('hi a', ac.back, 'answer')
  end

  def test_constructor_no_cloze_throws
    # Sanity check only
    assert_raise(RuntimeError) { AudioCloze.new("hi") }
  end

  def test_possible
    assert_true(AudioCloze.possible?('hi [there]'), 'single cloze')
    assert_true(AudioCloze.possible?('hi [there|hint]'), 'single cloze with hint')
    assert_true(AudioCloze.possible?('hi []'), 'empty cloze')
    assert_false(AudioCloze.possible?('hi'), 'No cloze')
    assert_false(AudioCloze.possible?(''), 'no sentence')
    assert_false(AudioCloze.possible?(nil), 'nil sentence')
  end

  def test_verify_sample_only()
    s = "Ayer, ella [sostuvo|tener una cosa de modo que no se caiga|sostener] un gato."
    ac = AudioCloze.new(s)
    front = "tener una cosa de modo que no se caiga.  Ayer, ella ___ un gato."
    back = "sostener.  Ayer, ella sostuvo un gato."
    assert_equal(front, ac.front, 'front')
    assert_equal(back, ac.back, 'back')
  end

  def test_load_synth
    ac2 = AudioCloze.new("hi [a|b]")

    tp = FakePolly.new()
    [ ac2 ].reduce(tp) { |t, a| a.load_synth(t); t }
    assert_equal('rootdir/1: b.  hi ___; rootdir/2: hi a', tp.data())
  end


  def test_get_json
    ac2 = AudioCloze.new("hi [a|b]")

    tp = FakePolly.new()
    [ ac2 ].reduce(tp) { |t, a| a.load_synth(t); t }
    assert_equal('rootdir/1: b.  hi ___; rootdir/2: hi a', tp.data())

    base = {
      deckName: 'deck',
      modelName: "Audio_cloze",
      options: { allowDuplicate: true },
      tags: []
    }

    expected_ac2 = {
      fields: {
        Back: 'hi a',
        Back_audio: '[sound:2]',
        Front: 'b.  hi ___',
        Front_audio: '[sound:1]',
      }
    }
    assert_equal(base.merge(expected_ac2), ac2.json('deck'), 'ac2')

  end
  
end
