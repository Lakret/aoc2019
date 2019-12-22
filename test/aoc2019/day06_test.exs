defmodule Aoc2019.Day16Test do
  use ExUnit.Case

  import Aoc2019.Day06

  test "part 1 is solved correctly" do
    assert solve_part_one() == 301_100
  end

  @test_orbits """
  COM)B
  B)C
  C)D
  D)E
  E)F
  B)G
  G)H
  D)I
  E)J
  J)K
  K)L
  """

  test "parsing works" do
    actual = parse(@test_orbits)

    expected = %{
      "B" => ["COM"],
      "C" => ["B"],
      "D" => ["C"],
      "E" => ["D"],
      "F" => ["E"],
      "G" => ["B"],
      "H" => ["G"],
      "I" => ["D"],
      "J" => ["E"],
      "K" => ["J"],
      "L" => ["K"]
    }

    assert actual == expected
  end

  test "all_orbits works" do
    orbits = parse(@test_orbits) |> all_orbits()

    assert {"B", "COM"} in orbits
    assert {"C", "COM"} in orbits
    assert {"D", "COM"} in orbits
    assert {"D", "B"} in orbits
    assert {"B", "D"} not in orbits
    assert {"COM", "B"} not in orbits

    assert MapSet.size(orbits) == 42
  end
end
