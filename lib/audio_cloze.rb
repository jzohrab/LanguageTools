# coding: utf-8

require_relative './AudioClozeHelpers'

class AudioCloze

  # True if we can make an AudioCloze from the text.
  def self.possible?(text)
    return false unless !text.nil?
    q = AudioClozeHelpers.get_question(text)
    a = AudioClozeHelpers.get_answer(text)
    return (q != a)
  end
  
  def initialize(text)
    @text = text
    @front = AudioClozeHelpers.get_question(text)
    @back = AudioClozeHelpers.get_answer(text)
    raise "Same front and back" if (@front == @back)
  end

  def front()
    @front
  end

  def back()
    @back
  end

  # Build list of things to synthesize.
  def load_synth(t)

    # Add item to list, and return new filename.
    def load_text(t, text)
      f = t.next_filename()
      t.add_data(f, text)
      return f
    end

    @front_file = load_text(t, @front)
    @back_file = load_text(t, @back)
  end

  def sound_file(f)
    parts = File.split(f)
    "[sound:#{parts[-1]}]"
  end

  # Return json rep for insert into anki via ankiconnect.
  def json(deck)

    fielddata = {
      Front: @front,
      Front_audio: sound_file(@front_file),
      Back: @back,
      Back_audio: sound_file(@back_file)
    }

    {
      deckName: deck,
      # Assumption: model name
      modelName: "Audio_cloze",
      fields: fielddata,
      options: { allowDuplicate: true },
      tags: []
    }

  end

end
