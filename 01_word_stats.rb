# frozen_string_literal: true

# Завдання 1. word_stats
# Студент: Павло Гаврась, КС-31
# Викладач: Богдан Паршенцев

# Обчислює статистику слів у тексті:
# - загальну кількість слів;
# - найдовше слово (перше знайдене, якщо однакової довжини);
# - кількість унікальних слів (без урахування регістру).
#
# Розділові знаки не вважаються частиною слова ("fun," -> "fun").
# Порожній рядок або nil обробляються коректно без помилок.
def word_stats(text)
  # Виділяємо слова (літери й цифри, включно з апострофами та дефісами всередині слів)
  words = text.to_s.scan(/[\p{L}\p{N}]+(?:['-][\p{L}\p{N}]+)*/)

  longest_word = words.max_by(&:length) || "—"
  unique_count = words.map(&:downcase).uniq.size

  {
    words: words.size,
    longest: longest_word,
    unique: unique_count
  }
end

# Форматує отриману статистику у зручний для читання рядок
def format_word_stats(stats)
  longest_display = stats[:longest].to_s.empty? ? "—" : stats[:longest]
  "#{stats[:words]} слів, найдовше: #{longest_display}, унікальних: #{stats[:unique]}"
end

# Інтерактивний запуск з консолі
if __FILE__ == $PROGRAM_NAME
  puts "=== Аналіз тексту (word_stats) ==="
  print "Введіть рядок тексту: "
  input = gets

  if input.nil?
    puts "\nВведення скасовано."
  else
    stats = word_stats(input)
    puts "Результат: #{format_word_stats(stats)}"
  end
end
