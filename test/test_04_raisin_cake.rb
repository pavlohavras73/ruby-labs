# frozen_string_literal: true

require "minitest/autorun"
require_relative "../04_raisin_cake"

class TestRaisinCake < Minitest::Test
  def test_example_1_from_task
    cake = <<~CAKE
      .о......
      ......о.
      ....о...
      ..о.....
    CAKE

    expected = [
      ".о......",
      "......о.",
      "....о...",
      "..о....."
    ]

    result = cut(cake)
    assert_equal expected, result
  end

  def test_example_2_from_task
    # Зверніть увагу на друкарську помилку в п'ятому рядку оригінального завдання
    cake = <<~CAKE
      .о.о....
      ........
      ....о...
      ........
      ..... о..
      ........
    CAKE

    expected = [
      ".о\n..\n..\n..\n..\n..",
      ".о....\n......",
      "..о...\n......",
      "...о..\n......"
    ]

    result = cut(cake)
    assert_equal expected, result
  end

  def test_custom_two_slices
    cake = <<~CAKE
      .o..
      ..o.
    CAKE

    expected = [
      ".o..",
      "..o."
    ]

    result = cut(cake)
    assert_equal expected, result
  end

  def test_mixed_latin_and_cyrillic_raisins
    cake = <<~CAKE
      o.
      .о
    CAKE

    expected = [
      "o.",
      ".о"
    ]

    result = cut(cake)
    assert_equal expected, result
  end

  def test_area_not_divisible_returns_empty
    # Поле 3х3 (площа 9), 2 родзинки -> 9 не ділиться на 2
    cake = <<~CAKE
      o..
      ...
      ..o
    CAKE

    assert_equal [], cut(cake)
  end

  def test_less_than_two_raisins_returns_empty
    cake = <<~CAKE
      ....
      .o..
      ....
    CAKE

    assert_equal [], cut(cake)
  end

  def test_more_than_nine_raisins_returns_empty
    cake = <<~CAKE
      ooooo
      ooooo
    CAKE

    assert_equal [], cut(cake)
  end

  def test_impossible_cut_returns_empty
    # Розмір 2х3 (площа 6), 2 родзинки -> площа шматка 3
    # Можливі форми: 3х1 (містить 2 родзинки в першому рядку) або 1х3 (не вміщується по висоті)
    cake = <<~CAKE
      o.o
      ...
    CAKE

    assert_equal [], cut(cake)
  end

  def test_empty_or_invalid_cake_input
    assert_equal [], cut("")
    assert_equal [], cut(nil)
    assert_equal [], cut(["...", "...."]) # не прямокутний
  end
end
