# coding: utf-8

class AudioClozeHelpers

  def self.get_matches(text)
    # Below ugly re gets the question part, and the optional hint
    # part, in array of arrays.  e.g.
    # "F *q1|h1*, *q2|h2* *q3* ok." =>
    # [["q1", "h1"], ["q2", "h2"], ["q3", nil]]
    clozeRe = /\[(?<answer>.*?)(?:\|(?<hint>.*?))?\]/

    # :scan tip from
    # https://stackoverflow.com/questions/80357/
    #   how-to-match-all-occurrences-of-a-regex
    return text.to_enum(:scan, clozeRe).map { Regexp.last_match }
  end

  def self.get_question(text)
    ms = self.get_matches(text)
    return text if ms.length == 0

    question = text
    ms.each do |m|
      question = question.gsub(m[0], '___')
    end

    hints = ms.map { |m| m[:hint] }.select { |h| !h.nil? }.select { |h| h != '' }
    if (hints.size > 0) then
      question = "#{hints.join(', ')}.  #{question}"
    end

    return question
  end
  
  def self.get_answer(text)
    ms = self.get_matches(text)
    return text if ms.length == 0

    answer = text
    ms.each do |m|
      answer = answer.gsub(m[0], m[:answer]).gsub(/\s+/, ' ')
    end

    # details = ms.map { |m| m[:details] }.select { |h| !h.nil? }.select { |h| h != '' }
    # if (details.size > 0) then
    #   answer = "#{details.join(', ')}.  #{answer}"
    # end

    return answer
  end

end
