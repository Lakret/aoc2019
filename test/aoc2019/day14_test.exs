defmodule Aoc2019.Day14Test do
  use ExUnit.Case

  alias Aoc2019.Day14

  test "part 1 is solved correctly" do
    assert Day14.solve_part_one() != 0
  end

  # test "part 2 is solved correctly" do
  #   assert Day14.solve_part_two() == 394
  # end

  test "reactions are parsed correctly" do
    reactions =
      Day14.parse_reactions("""
      10 ORE => 10 A
      1 ORE => 1 B
      7 A, 1 B => 1 C
      7 A, 1 C => 1 D
      7 A, 1 D => 1 E
      7 A, 1 E => 1 FUEL
      """)

    assert reactions == %{
             "A" => %{reagents: [{"ORE", 10}], yield: 10},
             "B" => %{reagents: [{"ORE", 1}], yield: 1},
             "C" => %{reagents: [{"A", 7}, {"B", 1}], yield: 1},
             "D" => %{reagents: [{"A", 7}, {"C", 1}], yield: 1},
             "E" => %{reagents: [{"A", 7}, {"D", 1}], yield: 1},
             "FUEL" => %{reagents: [{"A", 7}, {"E", 1}], yield: 1}
           }
  end
end
