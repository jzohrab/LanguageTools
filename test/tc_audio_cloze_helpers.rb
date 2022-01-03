# coding: utf-8

require "test/unit"
require_relative "../lib/AudioClozeHelpers"

class TestAudioClozeHelpers < Test::Unit::TestCase

  def check_q(text, expected)
    assert_equal(expected, AudioClozeHelpers.get_question(text))
  end

  def check_a(text, expected)
    assert_equal(expected, AudioClozeHelpers.get_answer(text))
  end

  def test_questions_and_answers()
    check_q("qA *q1|h1* ok.", "h1.  qA ___ ok.")
    check_q("qB *q1* ok.", "qB ___ ok.")
    check_q("qC *q1a q1b|h1* ok.", "h1.  qC ___ ___ ok.")
    check_q("qD *q1b q1b* ok.", "qD ___ ___ ok.")
    check_q("qE q1 ok.", "qE q1 ok.")
    check_q("qF *q1|h1*, *q2|h2* *q3* ok.", "h1, h2.  qF ___, ___ ___ ok.")
    check_q("qG *q1|h1*, *q2* *q3 q3b|h3* ok.", "h1, h3.  qG ___, ___ ___ ___ ok.")
    check_q("qH *q1, q1b|h1*, *q2, q2b* *q3 q3b|h3* ok.", "h1, h3.  qH ___ ___, ___ ___ ___ ___ ok.")
    check_q("qI *check ßäüö|h1* here.", "h1.  qI ___ ___ here.")

    check_a("aA *q1|h1* ok.", "aA q1 ok.")
    check_a("aB *q1* ok.", "aB q1 ok.")
    check_a("aC q1 ok.", "aC q1 ok.")
    check_a("aD *q1|h1*, *q2|h2* ok.", "aD q1, q2 ok.")
    check_a("aE *q1|h1*, *q2* *q3|h3* ok.", "aE q1, q2 q3 ok.")
    check_a("aF *q1 q1b|h1*, *q2 q2b* *q3 q3b|h3* ok.", "aF q1 q1b, q2 q2b q3 q3b ok.")
    check_a("aI *check ßäüö|h1* here.", "aI check ßäüö here.")
  end

  # Sometimes it's good to 'fake' cloze something ...
  def test_empty_cloze()
    check_q('X prefieren ** caminar.', 'X prefieren ___ caminar.')
    check_a('X prefieren ** caminar.', 'X prefieren caminar.')

    check_q('X prefieren *|hi* caminar.', 'hi.  X prefieren ___ caminar.')
    check_a('X prefieren *|hi* caminar.', 'X prefieren caminar.')

    check_q('X prefieren *|* caminar.', 'X prefieren ___ caminar.')
    check_a('X prefieren *|* caminar.', 'X prefieren caminar.')
  end
end
