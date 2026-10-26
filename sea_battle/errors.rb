# frozen_string_literal: true

# Власні класи помилок гри «Морський бій».
# Усі наслідують SeaBattle::Error, тому ігровий цикл може перехопити їх одним rescue.
module SeaBattle
  class Error < StandardError; end

  # Некоректні координати: не той формат або за межами поля
  class InvalidCoordinateError < Error; end

  # Постріл у клітинку, куди вже стріляли
  class AlreadyShotError < Error; end

  # Корабель не можна поставити: виходить за межі, перетинається або торкається іншого
  class PlacementError < Error; end
end
