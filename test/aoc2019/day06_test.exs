defmodule Aoc2019.Day16Test do
  use ExUnit.Case

  import Aoc2019.Day06

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
      "B" => %{orbits: ["COM"]},
      "C" => %{orbits: ["B"]},
      "D" => %{orbits: ["C"]},
      "E" => %{orbits: ["D"]},
      "F" => %{orbits: ["E"]},
      "G" => %{orbits: ["B"]},
      "H" => %{orbits: ["G"]},
      "I" => %{orbits: ["D"]},
      "J" => %{orbits: ["E"]},
      "K" => %{orbits: ["J"]},
      "L" => %{orbits: ["K"]}
    }

    assert actual == expected
  end
end
