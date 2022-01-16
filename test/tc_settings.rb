# coding: utf-8

require "test/unit"
require 'json'
require_relative "../lib/settings"

class TestSettings < Test::Unit::TestCase

  def test_settings()
    settings_file = File.join(File.dirname(__FILE__), '..', 'settings.yml.example')
    s = Settings.new(settings_file)

    assert_equal('http://localhost:8765/', s.ankiconnect)
    assert_equal('/Users/jeff/Library/Application Support/Anki2/User 1/collection.media/', s.media_file)
    assert_equal('Spanish::01_Spanish_Vocab', s.deck('esp'))
    assert_equal('Conchita', s.voice('esp'))
  end
  
end
