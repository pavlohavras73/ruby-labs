# frozen_string_literal: true

# Завдання 6. Консольна гра «Морський бій» (гравець проти комп'ютера)
# Студент: Павло Гаврась, КС-31
# Викладач: Богдан Паршенцев
#
# Код розділено на модулі в папці sea_battle/:
#   errors.rb          — власні класи помилок
#   coordinate.rb      — координата клітинки та розбір введення «A5»
#   ship.rb            — корабель
#   board.rb           — поле, розстановка флоту, обробка пострілів
#   computer_player.rb — алгоритм пострілів комп'ютера
#   statistics.rb      — статистика перемог і поразок (JSON-файл)
#   renderer.rb        — виведення полів у консоль
#   game.rb            — одна партія
#   menu.rb            — головне меню

require_relative "sea_battle/menu"

if __FILE__ == $PROGRAM_NAME
  begin
    SeaBattle::Menu.new.run
  rescue Interrupt
    puts "\nГру перервано (Ctrl+C). До побачення!"
  end
end
