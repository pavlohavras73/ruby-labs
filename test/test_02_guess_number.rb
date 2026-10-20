# frozen_string_literal: true

require "minitest/autorun"
require "stringio"
require_relative "../02_guess_number"

class TestGuessNumberGame < Minitest::Test
  def setup
    @game = GuessNumberGame.new(target: 50, min: 1, max: 100)
  end

  def test_initial_state
    assert_equal 50, @game.target
    assert_equal 1, @game.min
    assert_equal 100, @game.max
    assert_equal 0, @game.attempts
    refute @game.guessed?
  end

  def test_evaluation_too_low
    result = @game.evaluate(30)
    assert_equal :too_low, result
    assert_equal 1, @game.attempts
    refute @game.guessed?
  end

  def test_evaluation_too_high
    result = @game.evaluate(75)
    assert_equal :too_high, result
    assert_equal 1, @game.attempts
    refute @game.guessed?
  end

  def test_evaluation_correct
    result = @game.evaluate(50)
    assert_equal :correct, result
    assert_equal 1, @game.attempts
    assert @game.guessed?
  end

  def test_multiple_attempts_counter
    @game.evaluate(20)
    @game.evaluate(80)
    @game.evaluate(50)

    assert_equal 3, @game.attempts
    assert @game.guessed?
  end

  def test_evaluate_out_of_range_raises_error
    assert_raises(ArgumentError) { @game.evaluate(0) }
    assert_raises(ArgumentError) { @game.evaluate(101) }
  end

  def test_play_game_with_simulated_io
    game = GuessNumberGame.new(target: 42)
    # Послідовність: порожній рядок, не число, поза діапазоном, 20 (більше), 60 (менше), 42 (вгадано)
    input = StringIO.new("  \nabc\n105\n20\n60\n42\n")
    output = StringIO.new

    success = game.play_game(input: input, output: output)

    assert success
    assert_equal 3, game.attempts
    assert game.guessed?

    out_text = output.string
    assert_includes out_text, "Помилка: введення не може бути порожнім"
    assert_includes out_text, "Помилка: 'abc' не є цілим числом"
    assert_includes out_text, "Помилка: число 105 поза діапазоном"
    assert_includes out_text, "більше"
    assert_includes out_text, "менше"
    assert_includes out_text, "вгадано! Спроб: 3."
  end

  def test_play_game_eof_abort
    game = GuessNumberGame.new(target: 42)
    input = StringIO.new("") # миттєвий EOF
    output = StringIO.new

    success = game.play_game(input: input, output: output)

    refute success
    assert_includes output.string, "Гру перервано (кінець введення)."
  end
end
