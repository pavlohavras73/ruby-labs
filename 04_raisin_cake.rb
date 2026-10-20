# frozen_string_literal: true

# Завдання 4. Пиріг з родзинками (Cut the cake)
# Студент: Павло Гаврась, КС-31
# Викладач: Богдан Паршенцев

# Допустимі символи родзинок: латинська 'o' та кирилична 'о' (як у наданих прикладах)
RAISIN_CHARS = ["o", "о", "O", "О"].freeze

# Нормалізує та парсить вхідний пиріг у 2D-масив символів (рядків).
# Підтримує як багаторядковий рядок (String), так і масив рядків (Array).
# Видаляє зайві пробіли (наприклад, друкарську помилку '..... о..' з умови).
def parse_cake(cake)
  lines = cake.is_a?(Array) ? cake : cake.to_s.lines
  cleaned = lines.map(&:strip).reject(&:empty?)
  return [] if cleaned.empty?

  normalized = cleaned.map { |line| line.delete(" ") }
  width = normalized.first.length
  return [] unless normalized.all? { |line| line.length == width && width.positive? }

  normalized
end

# Знаходить координати першої вільної клітинки (зверху-вниз, зліва-направо)
def find_first_free(occupied, height, width)
  height.times do |r|
    width.times do |c|
      return [r, c] unless occupied[r][c]
    end
  end
  nil
end

# Перевіряє, чи всі клітинки прямокутника вільні
def rect_free?(occupied, row, col, width, height)
  height.times do |dr|
    width.times do |dc|
      return false if occupied[row + dr][col + dc]
    end
  end
  true
end

# Рахує кількість родзинок у заданому прямокутнику
def count_raisins(grid, row, col, width, height)
  count = 0
  height.times do |dr|
    width.times do |dc|
      count += 1 if RAISIN_CHARS.include?(grid[row + dr][col + dc])
    end
  end
  count
end

# Позначає клітинки прямокутника як зайняті (true) або вільні (false)
def mark_rect(occupied, row, col, width, height, value)
  height.times do |dr|
    width.times do |dc|
      occupied[row + dr][col + dc] = value
    end
  end
end

# Вирізає шматочок пирога за координатами як рядок із розділювачем "\n"
def extract_piece(grid, row, col, width, height)
  (row...(row + height)).map { |r| grid[r][col...(col + width)] }.join("\n")
end

# Рекурсивний бектрекінг:
# На кожному кроці беремо першу незаповнену клітинку зверху-зліва і пробуємо
# прямокутники потрібної площі, де рівно одна родзинка, ШИРШІ ПЕРШИМИ.
def solve_cake(grid, occupied, target_area, possible_rects, height, width)
  free_cell = find_first_free(occupied, height, width)
  return [] if free_cell.nil? # Усі клітинки успішно покриті

  start_r, start_c = free_cell

  possible_rects.each do |w, h|
    next if start_r + h > height || start_c + w > width
    next unless rect_free?(occupied, start_r, start_c, w, h)
    next unless count_raisins(grid, start_r, start_c, w, h) == 1

    mark_rect(occupied, start_r, start_c, w, h, true)
    sub_solution = solve_cake(grid, occupied, target_area, possible_rects, height, width)

    if sub_solution
      piece = extract_piece(grid, start_r, start_c, w, h)
      return [piece] + sub_solution
    end

    mark_rect(occupied, start_r, start_c, w, h, false)
  end

  nil
end

# Головний метод розрізання пирога:
# cake — рядок або масив рядків.
# Повертає масив шматків або порожній масив, якщо розв'язку немає / вхід некоректний.
def cut(cake)
  grid = parse_cake(cake)
  return [] if grid.empty?

  height = grid.length
  width = grid.first.length
  total_area = height * width

  # Підраховуємо загальну кількість родзинок
  total_raisins = 0
  height.times do |r|
    width.times do |c|
      total_raisins += 1 if RAISIN_CHARS.include?(grid[r][c])
    end
  end

  # За умовою: 2 <= кількість родзинок <= 9
  return [] if total_raisins < 2 || total_raisins > 9

  # Площа кожного шматочка має ділитися без остачі
  return [] unless (total_area % total_raisins).zero?

  target_area = total_area / total_raisins

  # Генеруємо всі можливі прямокутники потрібної площі (w, h), впорядковані: ШИРШІ ПЕРШИМИ
  possible_rects = (1..target_area).select do |w|
    (target_area % w).zero? && w <= width && (target_area / w) <= height
  end.map { |w| [w, target_area / w] }.sort_by { |w, _| -w }

  occupied = Array.new(height) { Array.new(width, false) }
  solve_cake(grid, occupied, target_area, possible_rects, height, width) || []
end

# Демонстрація виконання
if __FILE__ == $PROGRAM_NAME
  puts "=== Завдання 4: Пиріг з родзинками ==="

  ex1 = <<~CAKE
    .о......
    ......о.
    ....о...
    ..о.....
  CAKE

  puts "\n--- Приклад 1 з умови (4 горизонтальні смуги) ---"
  puts "Вхідний пиріг:\n#{ex1}"
  pieces1 = cut(ex1)
  puts "Кількість шматків: #{pieces1.size}"
  pieces1.each_with_index do |piece, idx|
    puts "Шматок #{idx + 1}:\n#{piece}"
  end

  ex2 = <<~CAKE
    .о.о....
    ........
    ....о...
    ........
    ..... о..
    ........
  CAKE

  puts "\n--- Приклад 2 з умови (різні форми: 2x6 і три 6x2) ---"
  puts "Вхідний пиріг:\n#{ex2}"
  pieces2 = cut(ex2)
  puts "Кількість шматків: #{pieces2.size}"
  pieces2.each_with_index do |piece, idx|
    puts "Шматок #{idx + 1}:\n#{piece}"
  end
end
