# frozen_string_literal: true

require "minitest/autorun"
require_relative "../01_word_stats"

class TestWordStats < Minitest::Test
  def test_example_from_task
    text = "Ruby is fun and ruby is powerful"
    stats = word_stats(text)

    assert_equal 7, stats[:words]
    assert_equal "powerful", stats[:longest]
    assert_equal 5, stats[:unique]
  end

  def test_punctuation_stripping
    text = "Ruby, is fun! And ruby... is powerful?"
    stats = word_stats(text)

    assert_equal 7, stats[:words]
    assert_equal "powerful", stats[:longest]
    assert_equal 5, stats[:unique]
  end

  def test_empty_string
    stats = word_stats("")

    assert_equal 0, stats[:words]
    assert_equal "—", stats[:longest]
    assert_equal 0, stats[:unique]
    assert_equal "0 слів, найдовше: —, унікальних: 0", format_word_stats(stats)
  end

  def test_nil_input
    stats = word_stats(nil)

    assert_equal 0, stats[:words]
    assert_equal "—", stats[:longest]
    assert_equal 0, stats[:unique]
    assert_equal "0 слів, найдовше: —, унікальних: 0", format_word_stats(stats)
  end

  def test_whitespace_only
    stats = word_stats("   \t  \n  ")

    assert_equal 0, stats[:words]
    assert_equal "—", stats[:longest]
    assert_equal 0, stats[:unique]
    assert_equal "0 слів, найдовше: —, унікальних: 0", format_word_stats(stats)
  end

  def test_ukrainian_text
    text = "Сонце світить яскраво, і сонце гріє землю!"
    stats = word_stats(text)

    # Слова: Сонце, світить, яскраво, і, сонце, гріє, землю -> 7 слів
    # Унікальні (без регістру): сонце, світить, яскраво, і, гріє, землю -> 6 слів
    # Найдовше: "світить" або "яскраво" (по 7 літер) -> перше "світить"
    assert_equal 7, stats[:words]
    assert_equal "світить", stats[:longest]
    assert_equal 6, stats[:unique]
  end

  def test_words_with_apostrophe_and_hyphen
    text = "м'яч темно-синій м'яч"
    stats = word_stats(text)

    assert_equal 3, stats[:words]
    assert_equal "темно-синій", stats[:longest]
    assert_equal 2, stats[:unique]
  end

  def test_format_word_stats
    stats = { words: 7, longest: "powerful", unique: 5 }
    expected = "7 слів, найдовше: powerful, унікальних: 5"
    assert_equal expected, format_word_stats(stats)
  end
end
