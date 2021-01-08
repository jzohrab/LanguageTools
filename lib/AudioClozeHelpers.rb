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
  check_q("A *q1* ok.", "A ___ ok.")
  check_q("A q1 ok.", "A q1 ok.")
  check_q("A *q1|h1*, *q2|h2* ok.", "h1, h2.  A ___, ___ ok.")
  check_q("A *q1|h1*, *q2* *q3|h3* ok.", "h1, h3.  A ___, ___ ___ ok.")

  check_a("A *q1|h1* ok.", "A q1 ok.")
  check_a("A *q1* ok.", "A q1 ok.")
  check_a("A q1 ok.", "A q1 ok.")
  check_a("A *q1|h1*, *q2|h2* ok.", "A q1, q2 ok.")
  check_a("A *q1|h1*, *q2* *q3|h3* ok.", "A q1, q2 q3 ok.")
end
