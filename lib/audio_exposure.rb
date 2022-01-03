# coding: utf-8

class AudioExposure

  # True if we can make an AudioExposure from the text.
  def self.possible?(text)
    return !text.nil?
  end
  
  def initialize(text)
    @front = text
  end

  def front()
    @front
  end

  # Build list of things to synthesize.
  def load_synth(t)

    # Add item to list, and return new filename.
    def load_text(t, text)
      return nil if text.nil?
      f = t.next_filename()
      t.add_data(f, text)
      return f
    end

    @front_file = load_text(t, @front)
  end

  def sound_file(f)
    parts = File.split(f)
    "[sound:#{parts[-1]}]"
  end

  # Return json rep for insert into anki via ankiconnect.
  def json(deck)

    fielddata = {
      Front: @front,
      Front_audio: sound_file(@front_file)
    }

    {
      deckName: deck,
      # Assumption: model name
      modelName: "Audio_Exposure",
      fields: fielddata,
      options: { allowDuplicate: true },
      tags: []
    }

  end

end
