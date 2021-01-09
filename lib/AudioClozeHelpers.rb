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
      blanks = a.gsub(/\w+/, '___')
      question = question.gsub(m[0], blanks)
    end

    hints = ms.map { |m| m[:hint] }.select { |h| !h.nil? }
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
    question = text.gsub(clozeRe, '\1')
    return question
  end

end

if __FILE__ == $0
  # puts ARGV.inspect

  def check_q(text, expected)
    q = AudioClozeHelpers.get_question(text)
    if (q != expected) then
      puts expected
      puts q
      raise q
    end
    puts q
  end

  def check_a(text, expected)
    a = AudioClozeHelpers.get_answer(text)
    if (a != expected) then
      puts expected
      puts a
      raise a
    end
    puts a
  end

  check_q("qA *q1|h1* ok.", "h1.  qA ___ ok.")
  check_q("qB *q1* ok.", "qB ___ ok.")
  check_q("qC *q1a q1b|h1* ok.", "h1.  qC ___ ___ ok.")
  check_q("qD *q1b q1b* ok.", "qD ___ ___ ok.")
  check_q("qE q1 ok.", "qE q1 ok.")
  check_q("qF *q1|h1*, *q2|h2* *q3* ok.", "h1, h2.  qF ___, ___ ___ ok.")
  check_q("qG *q1|h1*, *q2* *q3 q3b|h3* ok.", "h1, h3.  qG ___, ___ ___ ___ ok.")
  check_q("qH *q1, q1b|h1*, *q2, q2b* *q3 q3b|h3* ok.", "h1, h3.  qH ___, ___, ___, ___ ___ ___ ok.")

  check_a("aA *q1|h1* ok.", "aA q1 ok.")
  check_a("aB *q1* ok.", "aB q1 ok.")
  check_a("aC q1 ok.", "aC q1 ok.")
  check_a("aD *q1|h1*, *q2|h2* ok.", "aD q1, q2 ok.")
  check_a("aE *q1|h1*, *q2* *q3|h3* ok.", "aE q1, q2 q3 ok.")
  check_a("aF *q1 q1b|h1*, *q2 q2b* *q3 q3b|h3* ok.", "aF q1 q1b, q2 q2b q3 q3b ok.")

  puts "OK."
end
