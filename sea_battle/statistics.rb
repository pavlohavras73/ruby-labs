# frozen_string_literal: true

require "json"

module SeaBattle
  # Статистика перемог і поразок. Зберігається у JSON-файлі між запусками програми.
  class Statistics
    DEFAULT_PATH = File.expand_path("~/.sea_battle_stats.json")

    attr_reader :wins, :losses

    def initialize(path: DEFAULT_PATH)
      @path = path
      @wins = 0
      @losses = 0
      load
    end

    def record_win!
      @wins += 1
      save
    end

    def record_loss!
      @losses += 1
      save
    end

    def games
      wins + losses
    end

    def win_rate
      return 0 if games.zero?

      (wins * 100.0 / games).round
    end

    def to_s
      "Ігор: #{games} | Перемог: #{wins} | Поразок: #{losses} | Відсоток перемог: #{win_rate}%"
    end

    private

    def load
      return if @path.nil? || !File.exist?(@path)

      data = JSON.parse(File.read(@path))
      @wins = Integer(data.fetch("wins", 0))
      @losses = Integer(data.fetch("losses", 0))
    rescue JSON::ParserError, ArgumentError, TypeError, SystemCallError
      # Пошкоджений або недоступний файл не повинен ламати гру — починаємо з нуля
      @wins = 0
      @losses = 0
    end

    def save
      return if @path.nil?

      File.write(@path, JSON.generate({ "wins" => wins, "losses" => losses }))
    rescue SystemCallError => e
      warn "Не вдалося зберегти статистику: #{e.message}"
    end
  end
end
