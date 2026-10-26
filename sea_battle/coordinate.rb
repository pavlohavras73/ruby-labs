# frozen_string_literal: true

require_relative "errors"

module SeaBattle
  # Координата клітинки поля. Рядок і стовпець зберігаються з нуля,
  # а користувач бачить їх як «A1»…«J10» (стовпець — літера, рядок — число).
  class Coordinate
    SIZE = 10
    LETTERS = ("A".."J").to_a.freeze
    # Українські літери на тих самих клавішах, що й латинські (для зручності введення)
    CYRILLIC_LETTERS = {
      "А" => "A", "В" => "B", "С" => "C", "Е" => "E", "Н" => "H"
    }.freeze
    FORMAT = /\A([A-J])\s*(10|[1-9])\z/

    attr_reader :row, :col

    def initialize(row, col)
      unless row.between?(0, SIZE - 1) && col.between?(0, SIZE - 1)
        raise InvalidCoordinateError, "Координата поза полем: рядок #{row + 1}, стовпець #{col + 1}"
      end

      @row = row
      @col = col
    end

    # Розбирає введення на кшталт «A5», «b10», «c 7»
    def self.parse(text)
      raise InvalidCoordinateError, "Порожнє введення. Приклад: A5" if text.nil? || text.strip.empty?

      normalized = text.strip.upcase.gsub(/[АВСЕН]/) { |letter| CYRILLIC_LETTERS[letter] }
      match = FORMAT.match(normalized)
      unless match
        raise InvalidCoordinateError,
              "Некоректні координати «#{text.strip}». Формат: літера A–J і число 1–10, наприклад A5 або J10"
      end

      new(match[2].to_i - 1, LETTERS.index(match[1]))
    end

    def self.all
      (0...SIZE).flat_map { |row| (0...SIZE).map { |col| new(row, col) } }
    end

    # Сусіди по горизонталі й вертикалі (для добивання корабля)
    def orthogonal_neighbours
      [[-1, 0], [1, 0], [0, -1], [0, 1]].filter_map { |dr, dc| offset(dr, dc) }
    end

    # Усі 8 сусідів, включно з діагоналями (кораблі не можуть торкатися навіть так)
    def surrounding
      [-1, 0, 1].product([-1, 0, 1]).reject { |dr, dc| dr.zero? && dc.zero? }
                .filter_map { |dr, dc| offset(dr, dc) }
    end

    def to_s
      "#{LETTERS[col]}#{row + 1}"
    end

    def ==(other)
      other.is_a?(Coordinate) && row == other.row && col == other.col
    end
    alias eql? ==

    def hash
      [row, col].hash
    end

    private

    def offset(delta_row, delta_col)
      new_row = row + delta_row
      new_col = col + delta_col
      return nil unless new_row.between?(0, SIZE - 1) && new_col.between?(0, SIZE - 1)

      Coordinate.new(new_row, new_col)
    end
  end
end
