# coding: utf-8

require_relative './AudioClozeHelpers'

class AudioCloze

  def initialize(text)
    @text = text
    @question = AudioClozeHelpers.get_question(text)
    @answer = AudioClozeHelpers.get_answer(text)
    if (@answer == @question) then
      @question = nil
    end
  end

  def question()
    @question
  end

  def answer()
    @answer
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

    @question_file = load_text(t, @question)
    @answer_file = load_text(t, @answer)
  end

  def sound_file(f)
    parts = File.split(f)
    "[sound:#{parts[-1]}]"
  end

  # Return json rep for insert into anki via ankiconnect.
  def json(deck)

    fielddata = {
      Sentence_full: @answer,
      Sentence_audio: sound_file(@answer_file)
    }

    if (@question) then
      extra = {
        Sentence_with_blank: @question,
        Sentence_with_blank_audio: sound_file(@question_file)
      }
      fielddata = fielddata.merge(extra)
    end

    {
      deckName: deck,
      # Assumption: model name
      modelName: "Cloze_audio",
      fields: fielddata,
      options: { allowDuplicate: true },
      tags: []
    }

  end

end
