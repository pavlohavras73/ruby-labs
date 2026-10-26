# frozen_string_literal: true

require_relative "game"
require_relative "statistics"

module SeaBattle
  # Головне меню: нова гра, правила, статистика, вихід.
  class Menu
    RULES_TEXT = <<~TEXT
      === Правила гри «Морський бій» ===
      • Поле 10×10: стовпці A–J, рядки 1–10. Постріл задається так: B7, J10.
      • У кожного гравця флот: 1 корабель на 4 клітинки, 2 — на 3, 3 — на 2, 4 — на 1.
        Кораблі розставляються автоматично і не торкаються один одного навіть кутами.
      • Ви стріляєте по полю комп'ютера, комп'ютер — по вашому.
      • Влучили — стріляєте ще раз. Промахнулися — хід переходить до суперника.
      • Після знищення корабля клітинки навколо нього позначаються промахами.
      • Перемагає той, хто першим знищить усі кораблі суперника.
      • Під час гри можна написати «здатися» — партія зарахується як поразка.
    TEXT

    def initialize(input: $stdin, output: $stdout, random: Random.new, statistics: Statistics.new)
      @input = input
      @output = output
      @random = random
      @statistics = statistics
    end

    def run
      @output.puts "=== Морський бій ==="
      loop do
        show_options
        choice = @input.gets
        break if choice.nil?

        case choice.strip
        when "1" then play_game
        when "2" then @output.puts "\n#{RULES_TEXT}"
        when "3" then @output.puts "\nСтатистика: #{@statistics}"
        when "0" then break
        else @output.puts "Невідомий пункт «#{choice.strip}». Введіть 1, 2, 3 або 0."
        end
      end
      @output.puts "До побачення! #{@statistics}"
    end

    private

    def show_options
      @output.puts "\n1 — Нова гра"
      @output.puts "2 — Правила"
      @output.puts "3 — Статистика"
      @output.puts "0 — Вихід"
      @output.print "Ваш вибір: "
    end

    def play_game
      winner = Game.new(input: @input, output: @output, random: @random).play
      winner == :player ? @statistics.record_win! : @statistics.record_loss!
      @output.puts "Статистика: #{@statistics}"
    end
  end
end
