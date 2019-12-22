defmodule Aoc2019.Day06 do
  import Aoc2019

  def solve_part_one() do
  end

  # Helpers

  @doc ~S"""
    import Aoc2019
    alias Aoc2019.Day06

    input = "
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
    "

    [directly] orbits relation:

    COM, B -> COM, C -> B, D -> C, E -> D, F -> E, G -> B, ...

    orbits relation is quasi-transitive, thus:

    D -(orbits)-> C, C -(orbits)-> B => D -(indirectly orbits)-> B

  """

  def parse(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&parse_relation/1)
    |> Enum.reduce(%{}, &add_to_graph/2)
  end

  # B)A => a directly orbits b
  def parse_relation(relation) do
    [b, a] = String.split(relation, ")")
    {a, b}
  end

  def add_to_graph({a, b}, graph) do
    Map.update(graph, a, %{orbits: [b]}, fn relations ->
      Map.put(relations, :orbits, [b | relations.orbits])
    end)
  end
end
