defmodule Aoc2019.Day04Test do
  use ExUnit.Case
  import Aoc2019.Day04

  @tag :expensive
  test "part 1 is solved correctly" do
    assert solve_part_one() == 1625
  end

  test "password? is correct" do
    assert password?(111_111)
    assert !password?(223_450)
    assert !password?(123_789)
  end

  @tag :expensive
  test "part 2 is solved correctly" do
    assert solve_part_two() == 1111
  end

  test "stricter_password? is correct" do
    assert stricter_password?(112_233)
    assert !stricter_password?(123_444)
    assert stricter_password?(111_122)
  end
end
