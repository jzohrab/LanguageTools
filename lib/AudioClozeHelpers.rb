# coding: utf-8

class AudioClozeHelpers

  def self.get_question(text)
    # Below ugly re gets the question part, and the optional hint
    # part, in array of arrays.  e.g.
    # "F *q1|h1*, *q2|h2* *q3* ok." =>
    # [["q1", "h1"], ["q2", "h2"], ["q3", nil]]
    clozeRe = /\*(?<answer>.*?)(?:\|(?<hint>.*?))?\*/
    if (text !~ clozeRe)
      return text
    end

    # :scan tip from
    # https://stackoverflow.com/questions/80357/
    #   how-to-match-all-occurrences-of-a-regex
    ms = text.to_enum(:scan, clozeRe).map { Regexp.last_match }

    question = text
    ms.each do |m|
      a = m[:answer]
      a = 'placeholder' if a == ''
      # Doing "a.gsub(/\w+/, '___')" to replace 'words' with
      # underscores doesn't work for international char sets.
      # There should be a way to solve this "properly", but
      # for now I'll just split on spaces and assume that each
      # element is a word.
      # blanks = a.gsub(/\w+/, '___')
      blanks = a.gsub(/\s+/, ' ').split(' ').
                 map { |s| '___' }.join(' ')
      question = question.gsub(m[0], blanks)
    end

    hints = ms.map { |m| m[:hint] }.select { |h| !h.nil? }.select { |h| h != '' }
    if (hints.size > 0) then
      question = "#{hints.join(', ')}.  #{question}"
    end

    return question
  end
  
  def self.get_answer(text)
    clozeRe = /\*(.*?)(\|.*?)?\*/
    if (text !~ clozeRe)
      return text
    end
    question = text.gsub(clozeRe, '\1').gsub(/\s+/, ' ')
    return question
  end

end
