# frozen_string_literal: true

# Завдання 3. Гра: Камінь, ножиці, папір
# Студент: Павло Гаврась, КС-31
# Викладач: Богдан Паршенцев

class RockPaperScissorsGame
  # Правила перемоги: ключ перемагає значення (без ланцюжка if)
  RULES = {
    rock: :scissors,
    scissors: :paper,
    paper: :rock
  }.freeze

  MOVE_NAMES = {
    rock: "Камінь",
    scissors: "Ножиці",
    paper: "Папір"
  }.freeze

  INPUT_MAP = {
    "1" => :rock, "камінь" => :rock, "к" => :rock, "rock" => :rock, "r" => :rock,
    "2" => :scissors, "ножиці" => :scissors, "н" => :scissors, "scissors" => :scissors, "s" => :scissors,
    "3" => :paper, "папір" => :paper, "п" => :paper, "paper" => :paper, "p" => :paper
  }.freeze

  EXIT_COMMANDS = %w[0 вихід exit q quit].freeze

  attr_reader :stats

  def initialize(random: Random.new)
    @random = random
    @stats = {
      player_wins: 0,
      computer_wins: 0,
      draws: 0,
      total_rounds: 0
    }
  end

  # Визначає результат раунду: :player_win, :computer_win або :draw
  def determine_winner(player_move, computer_move)
    return :draw if player_move == computer_move

    RULES[player_move] == computer_move ? :player_win : :computer_win
  end

  # Генерує випадковий хід комп'ютера
  def random_computer_move
    RULES.keys.sample(random: @random)
  end

  # Зіграти один раунд і оновити статистику (чиста логіка без вводу з клавіатури)
  def play_round(player_move, computer_move = random_computer_move)
    unless RULES.key?(player_move)
      raise ArgumentError, "Невідомий хід гравця: #{player_move.inspect}"
    end
    unless RULES.key?(computer_move)
      raise ArgumentError, "Невідомий хід комп'ютера: #{computer_move.inspect}"
    end

    result = determine_winner(player_move, computer_move)
    @stats[:total_rounds] += 1

    case result
    when :player_win
      @stats[:player_wins] += 1
    when :computer_win
      @stats[:computer_wins] += 1
    when :draw
      @stats[:draws] += 1
    end

    {
      result: result,
      player_move: player_move,
      computer_move: computer_move,
      stats: @stats.dup
    }
  end

  # Консольний ігровий цикл
  def play(input: $stdin, output: $stdout)
    output.puts "=== Гра: Камінь, ножиці, папір ==="
    output.puts "Оберіть хід: 1 - Камінь, 2 - Ножиці, 3 - Папір (або 0 для виходу)"

    loop do
      output.print "\nВаш вибір (1-3 або назва): "
      line = input.gets

      if line.nil?
        output.puts "\nГру завершено (кінець введення)."
        break
      end

      raw = line.strip.downcase
      if raw.empty?
        output.puts "Помилка: введення не може бути порожнім. Введіть 1, 2, 3 або 0."
        next
      end

      if EXIT_COMMANDS.include?(raw)
        output.puts "Вихід з гри. Дякуємо за гру!"
        break
      end

      player_move = INPUT_MAP[raw]
      unless player_move
        output.puts "Помилка: невідомий варіант '#{line.strip}'. Введіть 1 (Камінь), 2 (Ножиці), 3 (Папір) або 0 (Вихід)."
        next
      end

      round_data = play_round(player_move)
      print_round_summary(round_data, output)
      print_stats(output)
    end

    output.puts "\n--- Фінальний рахунок ---"
    print_stats(output)
  end

  private

  def print_round_summary(round_data, output)
    output.puts MOVE_NAMES[round_data[:player_move]]
    output.puts "Вибір комп'ютера: #{MOVE_NAMES[round_data[:computer_move]]}"

    message = case round_data[:result]
              when :player_win   then "Ви перемогли!"
              when :computer_win then "Комп'ютер переміг!"
              when :draw         then "Нічия!"
              end
    output.puts message
  end

  def print_stats(output)
    output.puts format(
      "Статистика: Перемог гравця: %d | Перемог комп'ютера: %d | Нічиїх: %d | Всього раундів: %d",
      @stats[:player_wins],
      @stats[:computer_wins],
      @stats[:draws],
      @stats[:total_rounds]
    )
  end
end

if __FILE__ == $PROGRAM_NAME
  game = RockPaperScissorsGame.new
  game.play
end
