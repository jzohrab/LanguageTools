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
  
end
