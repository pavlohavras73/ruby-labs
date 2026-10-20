# frozen_string_literal: true

require "minitest/autorun"
require "stringio"
require_relative "../05_sudoku"

class TestSudokuGame < Minitest::Test
  def setup
    @game = SudokuGame.new
  end

  def test_initial_board_clues
    # Початкові підказки на дошці
    assert @game.initial_cell?(1, 1) # 1
    assert @game.initial_cell?(1, 3) # 3
    assert @game.initial_cell?(2, 4) # 2
    assert @game.initial_cell?(3, 1) # 2
    assert @game.initial_cell?(4, 2) # 3
    assert @game.initial_cell?(4, 4) # 1

    # Порожні клітинки не є початковими
    refute @game.initial_cell?(1, 2)
    refute @game.initial_cell?(1, 4)
  end

  def test_forbid_modifying_initial_cells
    valid, reason = @game.check_move(1, 1, 4)
    refute valid
    assert_includes reason, "є початковою"

    assert_raises(ArgumentError) { @game.make_move(1, 1, 4) }
    assert_equal 1, @game.errors_count
  end

  def test_row_duplicate_forbidden
    # У рядку 1 вже є 1 і 3
    valid, reason = @game.check_move(1, 2, 3)
    refute valid
    assert_includes reason, "вже є в рядку 1"

    assert_raises(ArgumentError) { @game.make_move(1, 2, 3) }
  end

  def test_column_duplicate_forbidden
    # У стовпці 3 вже є 3 (у рядку 1). Спробуємо поставити 3 у (3, 3)
    valid, reason = @game.check_move(3, 3, 3)
    refute valid
    assert_includes reason, "вже є в стовпці 3"

    assert_raises(ArgumentError) { @game.make_move(3, 3, 3) }
  end

  def test_block_duplicate_forbidden
    # У лівому верхньому блоці 2x2 клітинка (1, 1) = 1.
    # Спробуємо поставити 1 у вільну клітинку цього блоку (2, 2)
    valid, reason = @game.check_move(2, 2, 1)
    refute valid
    assert_includes reason, "блоці 2x2"

    assert_raises(ArgumentError) { @game.make_move(2, 2, 1) }
  end

  def test_out_of_range_arguments
    assert_raises(ArgumentError) { @game.make_move(0, 1, 1) }
    assert_raises(ArgumentError) { @game.make_move(1, 5, 1) }
    assert_raises(ArgumentError) { @game.make_move(1, 2, 9) }
  end

  def test_valid_move_and_undo
    assert_equal 0, @game.board[0][1] # (1, 2) спочатку порожня

    @game.make_move(1, 2, 2)
    assert_equal 2, @game.board[0][1]
    assert_equal 1, @game.moves_count

    # Скасування ходу
    assert @game.undo
    assert_equal 0, @game.board[0][1]
    assert_equal 1, @game.undos_count

    # Повторне скасування, коли історія порожня
    refute @game.undo
  end

  def test_hint_returns_correct_cell_and_value
    h = @game.hint
    refute_nil h
    assert_equal 1, h[:row]
    assert_equal 2, h[:col]
    assert_equal 2, h[:value]
  end

  def test_full_game_win
    refute @game.won?

    # Всі необхідні ходи для розв'язку
    moves = [
      [1, 2, 2], [1, 4, 4],
      [2, 1, 3], [2, 2, 4], [2, 3, 1],
      [3, 2, 1], [3, 3, 4], [3, 4, 3],
      [4, 1, 4], [4, 3, 2]
    ]

    moves.each do |r, c, v|
      @game.make_move(r, c, v)
    end

    assert @game.won?
    assert_equal 10, @game.moves_count
    assert_equal 0, @game.errors_count
  end

  def test_play_io_simulation
    game = SudokuGame.new
    # Послідовність команд: порожній рядок, невідома команда, хід з помилкою, правильний хід, підказка, скасування, статистика, вихід
    input = StringIO.new("  \nwrong\n1 1 2\n1 2 2\nh\nu\ns\nq\n")
    output = StringIO.new

    result = game.play(input: input, output: output)
    refute result # вийшли достроково через 'q'

    out_text = output.string
    assert_includes out_text, "=== Гра: Судоку 4x4 ==="
    assert_includes out_text, "Помилка: введення порожнє"
    assert_includes out_text, "Помилка: очікується 3 числа"
    assert_includes out_text, "Клітинка (1, 1) є початковою"
    assert_includes out_text, "Хід успішний: (1, 2) = 2"
    assert_includes out_text, "Підказка:"
    assert_includes out_text, "Останній хід скасовано."
    assert_includes out_text, "Статистика: успішних ходів:"
    assert_includes out_text, "Гру перервано користувачем."
  end
end
