# coding: utf-8

require_relative './AudioClozeHelpers'

class AudioCloze

  def initialize(text)
    @text = text
    @question = AudioClozeHelpers.get_question(text)
    @answer = AudioClozeHelpers.get_answer(text)
    if (@answer == @question) then
      @answer = nil
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

end
