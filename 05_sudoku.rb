# frozen_string_literal: true

# Завдання 5. Гра: Судоку 4x4
# Студент: Павло Гаврась, КС-31
# Викладач: Богдан Паршенцев

class SudokuGame
  # Початкове поле з єдиним коректним розв'язком (0 — порожня клітинка)
  DEFAULT_BOARD = [
    [1, 0, 3, 0],
    [0, 0, 0, 2],
    [2, 0, 0, 0],
    [0, 3, 0, 1]
  ].freeze

  GRID_SIZE = 4
  BLOCK_SIZE = 2
  VALID_RANGE = (1..GRID_SIZE)

  attr_reader :board, :initial_board, :moves_count, :errors_count, :undos_count

  def initialize(initial_board = nil)
    raw = initial_board || DEFAULT_BOARD
    @initial_board = raw.map(&:dup).freeze
    @board = raw.map(&:dup)
    @history = []
    @moves_count = 0
    @errors_count = 0
    @undos_count = 0
    @solution = solve_board(@initial_board.map(&:dup))
  end

  # Перевіряє, чи є клітинка початковою (фіксованою)
  def initial_cell?(row, col)
    validate_coords!(row, col)
    @initial_board[row - 1][col - 1] != 0
  end

  # Перевіряє, чи можна поставити число value у клітинку (row, col)
  # Повертає [true, nil] або [false, reason_message]
  def check_move(row, col, value)
    unless VALID_RANGE.cover?(row) && VALID_RANGE.cover?(col)
      return [false, "Рядок та стовпець мають бути в межах від 1 до #{GRID_SIZE}"]
    end
    unless VALID_RANGE.cover?(value)
      return [false, "Число має бути в межах від 1 до #{GRID_SIZE}"]
    end
    if initial_cell?(row, col)
      return [false, "Клітинка (#{row}, #{col}) є початковою, її не можна змінювати"]
    end

    r = row - 1
    c = col - 1

    # Перевірка рядка
    GRID_SIZE.times do |j|
      next if j == c
      return [false, "Число #{value} вже є в рядку #{row}"] if @board[r][j] == value
    end

    # Перевірка стовпця
    GRID_SIZE.times do |i|
      next if i == r
      return [false, "Число #{value} вже є в стовпці #{col}"] if @board[i][c] == value
    end

    # Перевірка блоку 2x2
    block_row = (r / BLOCK_SIZE) * BLOCK_SIZE
    block_col = (c / BLOCK_SIZE) * BLOCK_SIZE

    BLOCK_SIZE.times do |dr|
      BLOCK_SIZE.times do |dc|
        curr_r = block_row + dr
        curr_c = block_col + dc
        next if curr_r == r && curr_c == c

        return [false, "Число #{value} вже є у поточному блоці 2x2"] if @board[curr_r][curr_c] == value
      end
    end

    [true, nil]
  end

  def valid_move?(row, col, value)
    check_move(row, col, value).first
  end

  # Виконує хід. Якщо хід невалідний — викидає ArgumentError
  def make_move(row, col, value)
    valid, reason = check_move(row, col, value)
    unless valid
      @errors_count += 1
      raise ArgumentError, reason
    end

    r = row - 1
    c = col - 1
    prev_val = @board[r][c]

    @history << [r, c, prev_val]
    @board[r][c] = value
    @moves_count += 1
    true
  end

  # Скасування останнього ходу (undo)
  def undo
    return false if @history.empty?

    r, c, prev_val = @history.pop
    @board[r][c] = prev_val
    @undos_count += 1
    true
  end

  # Підказка: знаходить порожню або неправильну клітинку та повертає правильне значення
  def hint
    return nil unless @solution

    GRID_SIZE.times do |r|
      GRID_SIZE.times do |c|
        if @board[r][c] == 0 || @board[r][c] != @solution[r][c]
          return { row: r + 1, col: c + 1, value: @solution[r][c] }
        end
      end
    end
    nil
  end

  # Перевірка повної та коректної перемоги
  def won?
    GRID_SIZE.times do |r|
      GRID_SIZE.times do |c|
        val = @board[r][c]
        return false if val == 0
      end
    end

    # Перевіряємо кожен рядок, стовпець і блок на повний набір 1..4
    expected = (1..GRID_SIZE).to_a
    GRID_SIZE.times do |r|
      return false unless @board[r].sort == expected
    end

    GRID_SIZE.times do |c|
      col_vals = (0...GRID_SIZE).map { |r| @board[r][c] }
      return false unless col_vals.sort == expected
    end

    (0...GRID_SIZE).step(BLOCK_SIZE) do |br|
      (0...GRID_SIZE).step(BLOCK_SIZE) do |bc|
        block_vals = []
        BLOCK_SIZE.times do |dr|
          BLOCK_SIZE.times do |dc|
            block_vals << @board[br + dr][bc + dc]
          end
        end
        return false unless block_vals.sort == expected
      end
    end

    true
  end

  def stats
    {
      moves: @moves_count,
      errors: @errors_count,
      undos: @undos_count
    }
  end

  # Форматування поля для консолі
  def format_board
    sep = "  +-----+-----+"
    lines = []
    lines << "    1 2   3 4"
    lines << sep

    GRID_SIZE.times do |r|
      row_str = +"#{r + 1} | "
      GRID_SIZE.times do |c|
        val = @board[r][c]
        char = val.zero? ? "." : val.to_s
        row_str << char << " "
        row_str << "| " if c == 1
      end
      row_str << "|"
      lines << row_str
      lines << sep if r == 1 || r == 3
    end

    lines.join("\n")
  end

  # Консольний інтерфейс гри
  def play(input: $stdin, output: $stdout)
    output.puts "=== Гра: Судоку 4x4 ==="
    output.puts "Команди:"
    output.puts "  <рядок> <стовпець> <число> — зробити хід (наприклад: 1 2 4)"
    output.puts "  u / undo                   — скасувати останній хід"
    output.puts "  h / hint                   — отримати підказку"
    output.puts "  s / stats                  — показати статистику"
    output.puts "  q / exit                   — вийти з гри"
    output.puts

    loop do
      output.puts format_board
      output.print "\nВаш хід: "
      line = input.gets

      if line.nil?
        output.puts "\nГру завершено (кінець введення)."
        break
      end

      raw = line.strip.downcase
      if raw.empty?
        output.puts "Помилка: введення порожнє. Введіть хід або команду."
        next
      end

      case raw
      when "q", "exit", "quit", "вихід"
        output.puts "Гру перервано користувачем. До зустрічі!"
        break
      when "u", "undo", "відміна"
        if undo
          output.puts "Останній хід скасовано."
        else
          output.puts "Історія ходів порожня, нічого скасовувати."
        end
        next
      when "h", "hint", "підказка"
        h = hint
        if h
          output.puts "Підказка: у клітинку (#{h[:row]}, #{h[:col]}) поставте число #{h[:value]}."
        else
          output.puts "Поле вже повністю заповнене або підказка недоступна."
        end
        next
      when "s", "stats", "статистика"
        output.puts format(
          "Статистика: успішних ходів: %d | помилок: %d | скасувань: %d",
          @moves_count, @errors_count, @undos_count
        )
        next
      when "help", "довідка"
        output.puts "Введіть три числа через пробіл: рядок, стовпець, значення (від 1 до 4)."
        next
      end

      parts = raw.split(/[\s,]+/)
      unless parts.size == 3
        @errors_count += 1
        output.puts "Помилка: очікується 3 числа (рядок, стовпець, число). Наприклад: 1 2 4."
        next
      end

      row = Integer(parts[0], exception: false)
      col = Integer(parts[1], exception: false)
      val = Integer(parts[2], exception: false)

      if row.nil? || col.nil? || val.nil?
        @errors_count += 1
        output.puts "Помилка: всі параметри мають бути цілими числами від 1 до 4."
        next
      end

      valid, reason = check_move(row, col, val)
      if valid
        make_move(row, col, val)
        output.puts "Хід успішний: (#{row}, #{col}) = #{val}"

        if won?
          output.puts "\n" + format_board
          output.puts "\n🎉 Вітаємо! Ви успішно розв'язали Судоку!"
          output.puts format(
            "Підсумок: ходів: %d | помилок: %d | скасувань: %d",
            @moves_count, @errors_count, @undos_count
          )
          return true
        end
      else
        @errors_count += 1
        output.puts "Неприпустимий хід: #{reason}"
      end
    end

    false
  end

  private

  def validate_coords!(row, col)
    unless VALID_RANGE.cover?(row) && VALID_RANGE.cover?(col)
      raise ArgumentError, "Координати (#{row}, #{col}) мають бути в межах 1..#{GRID_SIZE}"
    end
  end

  # Розв'язувач для перевірки та підказок
  def solve_board(grid, r = 0, c = 0)
    return grid.map(&:dup) if r == GRID_SIZE

    nr = c == GRID_SIZE - 1 ? r + 1 : r
    nc = c == GRID_SIZE - 1 ? 0 : c + 1

    if grid[r][c] != 0
      solve_board(grid, nr, nc)
    else
      (1..GRID_SIZE).each do |v|
        if can_place_in_grid?(grid, r, c, v)
          grid[r][c] = v
          res = solve_board(grid, nr, nc)
          return res if res

          grid[r][c] = 0
        end
      end
      nil
    end
  end

  def can_place_in_grid?(grid, r, c, val)
    GRID_SIZE.times do |i|
      return false if grid[r][i] == val || grid[i][c] == val
    end

    br = (r / BLOCK_SIZE) * BLOCK_SIZE
    bc = (c / BLOCK_SIZE) * BLOCK_SIZE

    BLOCK_SIZE.times do |dr|
      BLOCK_SIZE.times do |dc|
        return false if grid[br + dr][bc + dc] == val
      end
    end

    true
  end
end

if __FILE__ == $PROGRAM_NAME
  game = SudokuGame.new
  game.play
end
