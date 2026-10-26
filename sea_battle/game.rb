# frozen_string_literal: true

require_relative "errors"
require_relative "coordinate"
require_relative "board"
require_relative "computer_player"
require_relative "renderer"

module SeaBattle
  # Одна партія: гравець проти комп'ютера.
  # Хто влучив — стріляє ще раз (класичне правило), промах передає хід.
  class Game
    SURRENDER_COMMANDS = %w[здатися здаюсь surrender q вихід exit].freeze
    RESULT_MESSAGES = {
      miss: "Промах.",
      hit: "Влучання!",
      sunk: "Корабель знищено!"
    }.freeze

    attr_reader :winner

    def initialize(input:, output:, random: Random.new)
      @input = input
      @output = output
      @player_board = Board.random(random: random)
      @computer_board = Board.random(random: random)
      @computer = ComputerPlayer.new(random: random)
      @renderer = Renderer.new(output)
      @winner = nil
    end

    # Повертає :player, :computer або :surrender (вихід посеред гри / кінець введення)
    def play
      @output.puts "\nКораблі розставлено. Вводьте координати пострілу (наприклад, B7). «здатися» — завершити партію."
      loop do
        player_turn
        break if @winner

        computer_turn
        break if @winner
      end
      announce
      @winner
    end

    private

    def player_turn
      loop do
        @renderer.boards(@player_board, @computer_board)
        coordinate = ask_coordinate
        return if @winner

        result = @computer_board.receive_shot(coordinate)[:result]
        @output.puts "Ваш постріл #{coordinate}: #{RESULT_MESSAGES[result]}"
        if @computer_board.all_sunk?
          @winner = :player
          return
        end
        return if result == :miss
      end
    end

    def computer_turn
      loop do
        coordinate = @computer.next_shot(@player_board)
        result = @player_board.receive_shot(coordinate)[:result]
        @computer.remember(coordinate, result)
        @output.puts "Комп'ютер стріляє в #{coordinate}: #{RESULT_MESSAGES[result]}"
        if @player_board.all_sunk?
          @winner = :computer
          return
        end
        return if result == :miss
      end
    end

    # Питає координату, доки не буде коректної. Помилки введення не завершують програму.
    def ask_coordinate
      loop do
        @output.print "\nВаш постріл: "
        line = @input.gets
        if line.nil? || SURRENDER_COMMANDS.include?(line.strip.downcase)
          @winner = :surrender
          return nil
        end

        begin
          coordinate = Coordinate.parse(line)
          raise AlreadyShotError, "Ви вже стріляли в #{coordinate}. Оберіть іншу клітинку" if @computer_board.shot_at?(coordinate)

          return coordinate
        rescue InvalidCoordinateError, AlreadyShotError => e
          @output.puts "Помилка: #{e.message}"
        end
      end
    end

    def announce
      @renderer.boards(@player_board, @computer_board) unless @winner == :surrender
      message = case @winner
                when :player then "Вітаємо! Ви знищили весь флот комп'ютера."
                when :computer then "Поразка: комп'ютер знищив усі ваші кораблі."
                else "Партію перервано. Вона зараховується як поразка."
                end
      @output.puts "\n#{message}"
    end
  end
end
