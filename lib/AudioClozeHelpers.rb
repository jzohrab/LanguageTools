# coding: utf-8

class AudioClozeHelpers

  def self.get_question(text)
    clozeRe = /\*(.*?)\*/
    if (text !~ clozeRe)
      return text
    end

    clozes = text.scan(clozeRe)

    hints = clozes.
              map { |s| s[0].split('|') }.
              map { |a| a[1] }.
              select { |e| !e.nil? }

    question = text.gsub(clozeRe, '___')
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
  end

  def check_a(text, expected)
    a = AudioClozeHelpers.get_answer(text)
    if (a != expected) then
      puts expected
      puts a
      raise a
    end
  end

  check_q("A *q1|h1* ok.", "h1.  A ___ ok.")
  check_q("B *q1* ok.", "B ___ ok.")
  # check_q("C *q1a q1b|h1* ok.", "h1.  C ___ ___ ok.")
  # check_q("D *q1b q1b* ok.", "D ___ ___ ok.")
  check_q("E q1 ok.", "E q1 ok.")
  check_q("F *q1|h1*, *q2|h2* ok.", "h1, h2.  F ___, ___ ok.")
  # check_q("G *q1|h1*, *q2* *q3 q3b|h3* ok.", "h1, h3.  G ___, ___ ___ ___ ok.")

  check_a("A *q1|h1* ok.", "A q1 ok.")
  check_a("B *q1* ok.", "B q1 ok.")
  check_a("C q1 ok.", "C q1 ok.")
  check_a("D *q1|h1*, *q2|h2* ok.", "D q1, q2 ok.")
  check_a("E *q1|h1*, *q2* *q3|h3* ok.", "E q1, q2 q3 ok.")
  check_a("F *q1 q1b|h1*, *q2 q2b* *q3 q3b|h3* ok.", "F q1 q1b, q2 q2b q3 q3b ok.")
end
