# frozen_string_literal: true

# Запуск усіх тестів практичних робіт
# Студент: Павло Гаврась, КС-31

Dir[File.expand_path("test_*.rb", __dir__)].sort.each do |test_file|
  require test_file
end
