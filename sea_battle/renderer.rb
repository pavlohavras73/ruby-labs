# frozen_string_literal: true

require_relative "coordinate"

module SeaBattle
  # Виводить поля в консоль: своє (з кораблями) і поле суперника (без кораблів).
  class Renderer
    SYMBOLS = {
      ship: "■",
      hit: "X",
      miss: "•",
      unknown: "·"
    }.freeze
    GAP = "      "

    def initialize(output)
      @output = output
    end

    def boards(own_board, enemy_board)
      @output.puts
      @output.puts "#{'    Ваше поле'.ljust(header.length)}#{GAP}    Поле комп'ютера"
      @output.puts "#{header}#{GAP}#{header}"
      Coordinate::SIZE.times do |row|
        @output.puts "#{row_line(own_board, row, reveal_ships: true)}#{GAP}#{row_line(enemy_board, row, reveal_ships: false)}"
      end
      @output.puts "Позначення: #{SYMBOLS[:ship]} корабель  #{SYMBOLS[:hit]} влучання  " \
                   "#{SYMBOLS[:miss]} промах  #{SYMBOLS[:unknown]} невідомо"
    end

    private

    def header
      "    #{Coordinate::LETTERS.join(' ')}"
    end

    def row_line(board, row, reveal_ships:)
      cells = Coordinate::SIZE.times.map do |col|
        SYMBOLS[board.cell_status(Coordinate.new(row, col), reveal_ships: reveal_ships)]
      end
      "#{(row + 1).to_s.rjust(2)}  #{cells.join(' ')}"
    end
  end
end
