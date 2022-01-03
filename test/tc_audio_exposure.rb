# coding: utf-8

require "test/unit"
require 'json'
require_relative "../lib/audio_exposure"
require_relative "./fake_polly"

class TestAudioExposure < Test::Unit::TestCase

  def test_constructor
    # Sanity check only
    ac = AudioExposure.new("f")
    assert_equal('f', ac.front, 'front')
  end

  def test_load_synth
    ac1 = AudioExposure.new("hi there")
    ac2 = AudioExposure.new("and goodbye")

    tp = FakePolly.new()
    [ ac1, ac2 ].reduce(tp) { |t, a| a.load_synth(t); t }
    assert_equal('rootdir/1: hi there; rootdir/2: and goodbye', tp.data())
  end


  def test_get_json
    ac1 = AudioExposure.new("hi there")
    ac2 = AudioExposure.new("and goodbye")

    tp = FakePolly.new()
    [ ac1, ac2 ].reduce(tp) { |t, a| a.load_synth(t); t }

    base = {
      deckName: 'deck',
      modelName: "Audio_Exposure",
      options: { allowDuplicate: true },
      tags: []
    }

    expected_ac1 = {
      fields: {
        Front: 'hi there',
        Front_audio: '[sound:1]'
      }
    }
    assert_equal(base.merge(expected_ac1), ac1.json('deck'), 'ac1')

    expected_ac2 = {
      fields: {
        Front: 'and goodbye',
        Front_audio: '[sound:2]'
      }
    }
    assert_equal(base.merge(expected_ac2), ac2.json('deck'), 'ac2')

  end
  
end
