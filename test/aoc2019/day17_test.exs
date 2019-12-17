defmodule Aoc2019.Day17Test do
  use ExUnit.Case

  alias Aoc2019.Day17

  test "solves part one correctly" do
    assert Day17.solve_part_one() == 2508
  end

  test "solves part two correctly" do
    assert Day17.solve_part_two() == 799_463
  end

  @simple_example '..#..........\n..#..........\n#######...###\n#.#...#...#.#\n#############\n..#...#...#..\n..#####...^..\n\n'

  test "calculates sum of alignments correctly for simple example" do
    view = Day17.parse(@simple_example)
    assert Day17.sum_of_alignments(view) == 76
  end
end
