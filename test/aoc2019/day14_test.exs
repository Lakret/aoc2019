defmodule Aoc2019.Day14Test do
  use ExUnit.Case

  import Aoc2019.Day14

  # 577_601 is wrong
  # 439699 is too low
  test "part 1 is solved correctly" do
    assert solve_part_one() == 504_284
  end

  # test "part 2 is solved correctly" do
  #   assert solve_part_two() == 394
  # end

  @simple_reactions_raw """
  10 ORE => 10 A
  1 ORE => 1 B
  7 A, 1 B => 1 C
  7 A, 1 C => 1 D
  7 A, 1 D => 1 E
  7 A, 1 E => 1 FUEL
  """

  @simple_reactions %{
    "A" => %{reagents: [{"ORE", 10}], yield: 10},
    "B" => %{reagents: [{"ORE", 1}], yield: 1},
    "C" => %{reagents: [{"A", 7}, {"B", 1}], yield: 1},
    "D" => %{reagents: [{"A", 7}, {"C", 1}], yield: 1},
    "E" => %{reagents: [{"A", 7}, {"D", 1}], yield: 1},
    "FUEL" => %{reagents: [{"A", 7}, {"E", 1}], yield: 1}
  }

  test "reactions are parsed correctly" do
    assert parse_reactions(@simple_reactions_raw) == @simple_reactions
  end

  test "simple reactions ore calculation is correct" do
    assert find_total_ore(@simple_reactions, "A", 30) == {30, %{"A" => 0}}
    assert find_total_ore(@simple_reactions, "A", 28) == {30, %{"A" => 2}}
    assert find_total_ore(@simple_reactions, "A", 20) == {20, %{"A" => 0}}

    assert find_total_ore(@simple_reactions, "FUEL", 1) ==
             {31, %{"A" => 2, "B" => 0, "C" => 0, "D" => 0, "E" => 0, "FUEL" => 0}}
  end
end
