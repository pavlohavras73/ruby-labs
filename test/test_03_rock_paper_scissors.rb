# frozen_string_literal: true

require "minitest/autorun"
require "stringio"
require_relative "../03_rock_paper_scissors"

class TestRockPaperScissorsGame < Minitest::Test
  def setup
    @game = RockPaperScissorsGame.new
  end

  def test_rules_structure
    expected_rules = { rock: :scissors, scissors: :paper, paper: :rock }
    assert_equal expected_rules, RockPaperScissorsGame::RULES
  end

  def test_player_wins_combinations
    assert_equal :player_win, @game.determine_winner(:rock, :scissors)
    assert_equal :player_win, @game.determine_winner(:scissors, :paper)
    assert_equal :player_win, @game.determine_winner(:paper, :rock)
  end

  def test_computer_wins_combinations
    assert_equal :computer_win, @game.determine_winner(:scissors, :rock)
    assert_equal :computer_win, @game.determine_winner(:paper, :scissors)
    assert_equal :computer_win, @game.determine_winner(:rock, :paper)
  end

  def test_draw_combinations
    assert_equal :draw, @game.determine_winner(:rock, :rock)
    assert_equal :draw, @game.determine_winner(:scissors, :scissors)
    assert_equal :draw, @game.determine_winner(:paper, :paper)
  end

  def test_stats_tracking_after_rounds
    round1 = @game.play_round(:rock, :scissors)
    assert_equal :player_win, round1[:result]
    assert_equal({ player_wins: 1, computer_wins: 0, draws: 0, total_rounds: 1 }, @game.stats)

    round2 = @game.play_round(:rock, :paper)
    assert_equal :computer_win, round2[:result]
    assert_equal({ player_wins: 1, computer_wins: 1, draws: 0, total_rounds: 2 }, @game.stats)

    round3 = @game.play_round(:rock, :rock)
    assert_equal :draw, round3[:result]
    assert_equal({ player_wins: 1, computer_wins: 1, draws: 1, total_rounds: 3 }, @game.stats)
  end

  def test_invalid_moves_raise_error
    assert_raises(ArgumentError) { @game.play_round(:invalid, :rock) }
    assert_raises(ArgumentError) { @game.play_round(:rock, :invalid) }
  end

  def test_play_io_simulation
    # Фіксуємо вибір комп'ютера за допомогою Random з seed або моку
    fake_random = Random.new(42)
    game = RockPaperScissorsGame.new(random: fake_random)

    # Введення: порожній рядок, помилкове слово, хід 1 (камінь), вихід
    input = StringIO.new("  \nневідомо\n1\n0\n")
    output = StringIO.new

    game.play(input: input, output: output)
    out_text = output.string

    assert_includes out_text, "Помилка: введення не може бути порожнім"
    assert_includes out_text, "Помилка: невідомий варіант 'невідомо'"
    assert_includes out_text, "Камінь"
    assert_includes out_text, "Вибір комп'ютера:"
    assert_includes out_text, "Статистика: Перемог гравця:"
    assert_includes out_text, "Вихід з гри. Дякуємо за гру!"
    assert_equal 1, game.stats[:total_rounds]
  end
end
