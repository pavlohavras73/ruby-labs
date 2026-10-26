# frozen_string_literal: true

require_relative "coordinate"

module SeaBattle
  # Комп'ютерний суперник: «полювання» випадковими пострілами,
  # після влучання — «добивання» сусідніх клітинок. Ніколи не стріляє двічі в одну клітинку.
  class ComputerPlayer
    def initialize(random: Random.new)
      @random = random
      @available = Coordinate.all
      @targets = []
      @current_hits = []
    end

    # Обирає координату наступного пострілу по полю суперника
    def next_shot(enemy_board)
      forget_already_shot(enemy_board)

      @targets.reject! { |target| enemy_board.shot_at?(target) }
      choice = @targets.shift || @available.sample(random: @random)
      raise Error, "Комп'ютеру нікуди стріляти" unless choice

      @available.delete(choice)
      choice
    end

    # Отримує результат пострілу, щоб спланувати наступні
    def remember(coordinate, result)
      case result
      when :hit
        @current_hits << coordinate
        plan_targets
      when :sunk
        @current_hits.clear
        @targets.clear
      end
    end

    private

    # Клітинки навколо знищених кораблів поле вже позначило промахами — прибираємо їх
    def forget_already_shot(enemy_board)
      @available.reject! { |coordinate| enemy_board.shot_at?(coordinate) }
    end

    # Якщо влучань два і більше — напрямок відомий, стріляємо лише вздовж лінії
    def plan_targets
      candidates = @current_hits.flat_map(&:orthogonal_neighbours).uniq
      candidates.select! { |cell| on_ship_line?(cell) } if @current_hits.size > 1
      @targets = candidates.select { |cell| @available.include?(cell) }.shuffle(random: @random)
    end

    def on_ship_line?(cell)
      if @current_hits.map(&:row).uniq.size == 1
        cell.row == @current_hits.first.row
      else
        cell.col == @current_hits.first.col
      end
    end
  end
end
