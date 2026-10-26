# frozen_string_literal: true

require "minitest/autorun"
require "stringio"
require "tmpdir"
require_relative "../sea_battle/menu"

module SeaBattleTestHelpers
  def coord(text)
    SeaBattle::Coordinate.parse(text)
  end

  def ship(*cells)
    SeaBattle::Ship.new(cells.map { |cell| coord(cell) })
  end
end

class TestSeaBattleCoordinate < Minitest::Test
  include SeaBattleTestHelpers

  def test_parse_valid_inputs
    assert_equal [0, 0], [coord("A1").row, coord("A1").col]
    assert_equal [9, 9], [coord("j10").row, coord("j10").col]
    assert_equal [6, 2], [coord(" c 7 ").row, coord(" c 7 ").col]
    assert_equal coord("A5"), coord("А5") # кирилична «А»
  end

  def test_parse_invalid_inputs_raise_custom_error
    ["", "   ", "K5", "A11", "A0", "5A", "AA", "A-1", nil].each do |input|
      assert_raises(SeaBattle::InvalidCoordinateError, "очікувалась помилка для #{input.inspect}") { coord(input) }
    end
  end

  def test_custom_errors_share_base_class
    assert_operator SeaBattle::InvalidCoordinateError, :<, SeaBattle::Error
    assert_operator SeaBattle::AlreadyShotError, :<, SeaBattle::Error
    assert_operator SeaBattle::PlacementError, :<, SeaBattle::Error
    assert_operator SeaBattle::Error, :<, StandardError
  end

  def test_neighbours_respect_borders
    assert_equal 3, coord("A1").surrounding.size
    assert_equal 8, coord("E5").surrounding.size
    assert_equal 2, coord("J10").orthogonal_neighbours.size
  end

  def test_to_s_round_trip
    SeaBattle::Coordinate.all.each { |c| assert_equal c, coord(c.to_s) }
  end
end

class TestSeaBattleShipAndBoard < Minitest::Test
  include SeaBattleTestHelpers

  def test_ship_must_be_straight_and_contiguous
    assert_raises(SeaBattle::PlacementError) { ship("A1", "B2") }
    assert_raises(SeaBattle::PlacementError) { ship("A1", "C1") }
    assert_equal 3, ship("B2", "B3", "B4").size
  end

  def test_overlapping_ship_is_rejected
    board = SeaBattle::Board.new
    board.place_ship(ship("C3", "D3", "E3"))
    assert_raises(SeaBattle::PlacementError) { board.place_ship(ship("D2", "D3")) }
  end

  def test_touching_by_side_and_diagonal_is_rejected
    board = SeaBattle::Board.new
    board.place_ship(ship("C3", "D3"))
    assert_raises(SeaBattle::PlacementError) { board.place_ship(ship("C4")) }   # бік
    assert_raises(SeaBattle::PlacementError) { board.place_ship(ship("E4")) }   # діагональ
    board.place_ship(ship("F3"))                                               # через клітинку — можна
    assert_equal 2, board.ships.size
  end

  def test_random_fleet_follows_rules
    50.times do |seed|
      board = SeaBattle::Board.random(random: Random.new(seed))
      assert_equal SeaBattle::Board::FLEET.sort, board.ships.map(&:size).sort
      board.ships.combination(2).each do |a, b|
        touching = a.cells.any? { |cell| b.cells.include?(cell) || cell.surrounding.any? { |n| b.cells.include?(n) } }
        refute touching, "кораблі торкаються (seed #{seed})"
      end
    end
  end

  def test_shot_results_and_repeat_shot
    board = SeaBattle::Board.new
    board.place_ship(ship("B2", "B3"))
    assert_equal :miss, board.receive_shot(coord("E5"))[:result]
    assert_equal :hit, board.receive_shot(coord("B2"))[:result]
    assert_equal :sunk, board.receive_shot(coord("B3"))[:result]
    assert board.all_sunk?
    assert_raises(SeaBattle::AlreadyShotError) { board.receive_shot(coord("E5")) }
  end

  def test_cells_around_sunk_ship_are_marked_as_misses
    board = SeaBattle::Board.new
    board.place_ship(ship("A1"))
    board.receive_shot(coord("A1"))
    %w[A2 B1 B2].each { |cell| assert_equal :miss, board.cell_status(coord(cell), reveal_ships: false) }
  end

  def test_enemy_ships_are_hidden
    board = SeaBattle::Board.new
    board.place_ship(ship("D4"))
    assert_equal :ship, board.cell_status(coord("D4"), reveal_ships: true)
    assert_equal :unknown, board.cell_status(coord("D4"), reveal_ships: false)
  end
end

class TestSeaBattleComputer < Minitest::Test
  include SeaBattleTestHelpers

  def test_computer_never_repeats_shots_and_finishes_fleet
    20.times do |seed|
      random = Random.new(seed)
      board = SeaBattle::Board.random(random: random)
      computer = SeaBattle::ComputerPlayer.new(random: random)
      shots = []
      until board.all_sunk?
        target = computer.next_shot(board)
        refute board.shot_at?(target), "повторний постріл у #{target} (seed #{seed})"
        shots << target
        computer.remember(target, board.receive_shot(target)[:result])
      end
      assert_equal shots.size, shots.uniq.size
      assert_operator shots.size, :<=, 100
    end
  end

  def test_computer_finishes_off_after_hit
    board = SeaBattle::Board.new
    board.place_ship(ship("E5", "F5", "G5"))
    computer = SeaBattle::ComputerPlayer.new(random: Random.new(1))
    board.receive_shot(coord("E5"))
    computer.remember(coord("E5"), :hit)
    assert_includes coord("E5").orthogonal_neighbours, computer.next_shot(board)
  end
end

class TestSeaBattleStatistics < Minitest::Test
  def test_statistics_are_saved_between_runs
    Dir.mktmpdir do |dir|
      path = File.join(dir, "stats.json")
      stats = SeaBattle::Statistics.new(path: path)
      stats.record_win!
      stats.record_loss!
      stats.record_win!
      reloaded = SeaBattle::Statistics.new(path: path)
      assert_equal [2, 1, 3, 67], [reloaded.wins, reloaded.losses, reloaded.games, reloaded.win_rate]
    end
  end

  def test_corrupted_statistics_file_does_not_crash
    Dir.mktmpdir do |dir|
      path = File.join(dir, "stats.json")
      File.write(path, "{not json")
      stats = SeaBattle::Statistics.new(path: path)
      assert_equal 0, stats.games
    end
  end
end

class TestSeaBattleGameAndMenu < Minitest::Test
  def test_full_game_with_garbage_input_does_not_crash
    shots = SeaBattle::Coordinate.all.map(&:to_s)
    script = (["", "zz", "K1", "A11"] + shots.flat_map { |cell| [cell, cell] }).join("\n") + "\n"
    output = StringIO.new
    game = SeaBattle::Game.new(input: StringIO.new(script), output: output, random: Random.new(7))
    winner = game.play
    assert_includes %i[player computer], winner
    assert_match(/Некоректні координати/, output.string)
    assert_match(/Порожнє введення/, output.string)
  end

  def test_end_of_input_counts_as_surrender
    game = SeaBattle::Game.new(input: StringIO.new(""), output: StringIO.new, random: Random.new(3))
    assert_equal :surrender, game.play
  end

  def test_menu_rules_stats_unknown_option_and_game
    stats = SeaBattle::Statistics.new(path: nil)
    output = StringIO.new
    input = StringIO.new("2\n3\n9\n1\nздатися\n0\n")
    SeaBattle::Menu.new(input: input, output: output, random: Random.new(5), statistics: stats).run
    assert_match(/Правила гри/, output.string)
    assert_match(/Невідомий пункт «9»/, output.string)
    assert_equal 1, stats.losses
    assert_match(/До побачення/, output.string)
  end
end
