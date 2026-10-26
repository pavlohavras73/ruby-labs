# frozen_string_literal: true

require_relative "errors"

module SeaBattle
  # Корабель — набір клітинок у ряд. Знає, куди в нього влучили і чи він знищений.
  class Ship
    attr_reader :cells

    def initialize(cells)
      raise PlacementError, "Корабель не може бути порожнім" if cells.empty?
      raise PlacementError, "Клітинки корабля мають стояти в один ряд" unless straight_line?(cells)

      @cells = cells.freeze
      @hits = []
    end

    def size
      cells.size
    end

    def occupies?(coordinate)
      cells.include?(coordinate)
    end

    def hit!(coordinate)
      raise ArgumentError, "#{coordinate} не належить кораблю" unless occupies?(coordinate)

      @hits << coordinate unless @hits.include?(coordinate)
    end

    def sunk?
      @hits.size == size
    end

    private

    def straight_line?(cells)
      rows = cells.map(&:row).uniq
      cols = cells.map(&:col).uniq
      return true if cells.size == 1

      if rows.size == 1
        consecutive?(cells.map(&:col))
      elsif cols.size == 1
        consecutive?(cells.map(&:row))
      else
        false
      end
    end

    def consecutive?(numbers)
      sorted = numbers.sort
      sorted.each_cons(2).all? { |a, b| b == a + 1 }
    end
  end
end
