defmodule Aoc2019.Day01Test do
  use ExUnit.Case
  import Aoc2019.Day01

  doctest Aoc2019.Day01

  test "part 1 is solved correctly" do
    assert solve_part_one() == 3_560_353
  end

  test "part 2 is solved correctly" do
    assert solve_part_two() == 5_337_642
  end
end
