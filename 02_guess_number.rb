# frozen_string_literal: true

# Завдання 2. Гра: Вгадай число
# Студент: Павло Гаврась, КС-31
# Викладач: Богдан Паршенцев

class GuessNumberGame
  attr_reader :target, :min, :max, :attempts

  def initialize(target: nil, min: 1, max: 100, random: Random.new)
    @min = min
    @max = max
    @target = target || random.rand(min..max)
    @attempts = 0
    @guessed = false
  end

  def guessed?
    @guessed
  end

  # Чистий метод перевірки числа (без консольного вводу/виводу).
  # Повертає:
  #   :too_low  — якщо загадане число більше
  #   :too_high — якщо загадане число менше
  #   :correct  — якщо число вгадано
  def evaluate(guess)
    unless (min..max).cover?(guess)
      raise ArgumentError, "Число #{guess} має бути в межах від #{min} до #{max}"
    end

    @attempts += 1

    if guess < @target
      :too_low
    elsif guess > @target
      :too_high
    else
      @guessed = true
      :correct
    end
  end

  # Ігровий цикл із консольним або тестовим IO
  def play_game(input: $stdin, output: $stdout)
    output.puts "=== Гра: Вгадай число ==="
    output.puts "Я загадав число від #{@min} до #{@max}. Спробуйте вгадати!"

    loop do
      output.print "Ваш варіант: "
      line = input.gets

      if line.nil?
        output.puts "\nГру перервано (кінець введення)."
        return false
      end

      raw = line.strip
      if raw.empty?
        output.puts "Помилка: введення не може бути порожнім. Введіть число від #{@min} до #{@max}."
        next
      end

      guess = Integer(raw, exception: false)
      if guess.nil?
        output.puts "Помилка: '#{raw}' не є цілим числом. Спробуйте ще раз."
        next
      end

      unless (min..max).cover?(guess)
        output.puts "Помилка: число #{guess} поза діапазоном (#{@min}..#{@max})."
        next
      end

      case evaluate(guess)
      when :too_low
        output.puts "більше"
      when :too_high
        output.puts "менше"
      when :correct
        output.puts "вгадано! Спроб: #{@attempts}."
        return true
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  target_override = ENV["TARGET_NUMBER"] ? Integer(ENV["TARGET_NUMBER"], exception: false) : nil
  game = GuessNumberGame.new(target: target_override)
  game.play_game
end
