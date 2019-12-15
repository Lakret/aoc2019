defmodule Aoc2019.Day14Test do
  use ExUnit.Case

  import Aoc2019.Day14

  test "part 1 is solved correctly" do
    assert solve_part_one() == 504_284
  end

  test "part 2 is solved correctly" do
    assert solve_part_two() != 0
  end

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

  test "more complex examples are solved" do
    {total_ore, _unused} =
      parse_reactions("""
      157 ORE => 5 NZVS
      165 ORE => 6 DCFZ
      44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL
      12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ
      179 ORE => 7 PSHF
      177 ORE => 5 HKGWZ
      7 DCFZ, 7 PSHF => 2 XJWVT
      165 ORE => 2 GPVTF
      3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT
      """)
      |> find_total_ore("FUEL", 1)

    assert total_ore == 13312

    {total_ore, _unused} =
      parse_reactions("""
      2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG
      17 NVRVD, 3 JNWZP => 8 VPVL
      53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL
      22 VJHF, 37 MNCFX => 5 FWMGM
      139 ORE => 4 NVRVD
      144 ORE => 7 JNWZP
      5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC
      5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV
      145 ORE => 6 MNCFX
      1 NVRVD => 8 CXFTF
      1 VJHF, 6 MNCFX => 4 RFSQX
      176 ORE => 6 VJHF
      """)
      |> find_total_ore("FUEL", 1)

    assert total_ore == 180_697

    {total_ore, _unused} =
      parse_reactions("""
      171 ORE => 8 CNZTR
      7 ZLQW, 3 BMBT, 9 XCVML, 26 XMNCP, 1 WPTQ, 2 MZWV, 1 RJRHP => 4 PLWSL
      114 ORE => 4 BHXH
      14 VRPVC => 6 BMBT
      6 BHXH, 18 KTJDG, 12 WPTQ, 7 PLWSL, 31 FHTLT, 37 ZDVW => 1 FUEL
      6 WPTQ, 2 BMBT, 8 ZLQW, 18 KTJDG, 1 XMNCP, 6 MZWV, 1 RJRHP => 6 FHTLT
      15 XDBXC, 2 LTCX, 1 VRPVC => 6 ZLQW
      13 WPTQ, 10 LTCX, 3 RJRHP, 14 XMNCP, 2 MZWV, 1 ZLQW => 1 ZDVW
      5 BMBT => 4 WPTQ
      189 ORE => 9 KTJDG
      1 MZWV, 17 XDBXC, 3 XCVML => 2 XMNCP
      12 VRPVC, 27 CNZTR => 2 XDBXC
      15 KTJDG, 12 BHXH => 5 XCVML
      3 BHXH, 2 VRPVC => 7 MZWV
      121 ORE => 7 VRPVC
      7 XCVML => 6 RJRHP
      5 BHXH, 4 VRPVC => 5 LTCX
      """)
      |> find_total_ore("FUEL", 1)

    assert total_ore == 2_210_736
  end
end
