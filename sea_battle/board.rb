# frozen_string_literal: true

require_relative "errors"
require_relative "coordinate"
require_relative "ship"

module SeaBattle
  # Ігрове поле 10×10: кораблі та результати пострілів по ньому.
  class Board
    # 1 корабель на 4 клітинки, 2 — на 3, 3 — на 2, 4 — на 1
    FLEET = [4, 3, 3, 2, 2, 2, 1, 1, 1, 1].freeze
    MAX_PLACEMENT_ATTEMPTS = 1000

    attr_reader :ships

    def initialize
      @ships = []
      @shots = {} # Coordinate => :miss / :hit
    end

    # Автоматично розставляє весь флот за правилами
    def self.random(random: Random.new)
      board = new
      FLEET.each { |size| board.place_randomly(size, random: random) }
      board
    end

    def place_ship(ship)
      unless can_place?(ship.cells)
        raise PlacementError, "Корабель #{ship.cells.map(&:to_s).join('-')} перетинається з іншим або торкається його"
      end

      @ships << ship
      ship
    end

    def place_randomly(size, random:)
      MAX_PLACEMENT_ATTEMPTS.times do
        cells = random_cells(size, random)
        next unless cells && can_place?(cells)

        return place_ship(Ship.new(cells))
      end
      raise PlacementError, "Не вдалося розмістити корабель на #{size} клітинки"
    end

    # Постріл по полю. Повертає { result: :miss / :hit / :sunk, ship: … }
    def receive_shot(coordinate)
      raise AlreadyShotError, "Ви вже стріляли в #{coordinate}. Оберіть іншу клітинку" if shot_at?(coordinate)

      ship = ship_at(coordinate)
      unless ship
        @shots[coordinate] = :miss
        return { result: :miss, ship: nil }
      end

      ship.hit!(coordinate)
      @shots[coordinate] = :hit
      return { result: :hit, ship: ship } unless ship.sunk?

      mark_around_sunk(ship)
      { result: :sunk, ship: ship }
    end

    def shot_at?(coordinate)
      @shots.key?(coordinate)
    end

    def all_sunk?
      ships.all?(&:sunk?)
    end

    def ships_left
      ships.count { |ship| !ship.sunk? }
    end

    # Що показувати в клітинці: :ship, :hit, :miss або :unknown.
    # Кораблі суперника не видно (reveal_ships: false).
    def cell_status(coordinate, reveal_ships:)
      return @shots[coordinate] if shot_at?(coordinate)
      return :ship if reveal_ships && ship_at(coordinate)

      :unknown
    end

    private

    def ship_at(coordinate)
      ships.find { |ship| ship.occupies?(coordinate) }
    end

    # Клітинки вільні, якщо ні вони, ні їхні сусіди (включно з діагональними) не зайняті
    def can_place?(cells)
      cells.none? do |cell|
        ship_at(cell) || cell.surrounding.any? { |neighbour| ship_at(neighbour) }
      end
    end

    def random_cells(size, random)
      horizontal = random.rand(2).zero?
      row = random.rand(Coordinate::SIZE - (horizontal ? 0 : size - 1))
      col = random.rand(Coordinate::SIZE - (horizontal ? size - 1 : 0))
      Array.new(size) { |i| horizontal ? Coordinate.new(row, col + i) : Coordinate.new(row + i, col) }
    end

    # Після знищення корабля клітинки навколо гарантовано порожні — позначаємо їх промахами
    def mark_around_sunk(ship)
      ship.cells.flat_map(&:surrounding).uniq.each do |neighbour|
        @shots[neighbour] = :miss unless shot_at?(neighbour)
      end
    end
  end
end
