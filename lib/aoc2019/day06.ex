defmodule Aoc2019.Day06 do
  import Aoc2019

  require Logger

  def solve_part_one() do
    read_input(6)
    |> parse()
    |> all_orbits()
    |> MapSet.size()
  end

  # Helpers

  @doc ~S"""
  Parses the direct orbits relations input. E.g., this input:

  ```
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
  ```

  denotes the following [directly] orbits relation:

  ```
  COM, B -> COM, C -> B, D -> C, E -> D, F -> E, G -> B, ...
  ```

  """
  def parse(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&parse_relation/1)
    |> Enum.reduce(%{}, &add_to_graph/2)
  end

  defp parse_relation(relation) do
    [b, a] = String.split(relation, ")")
    {a, b}
  end

  defp add_to_graph({a, b}, graph) do
    Map.update(graph, a, [b], fn relations ->
      [b | relations.orbits]
    end)
  end

  @doc """
  Returns a set of all direct & indirect orbits in `orbits` graph.

  Note that orbits relation is quasi-transitive, e.g.:

  ```
  D -(orbits)-> C, C -(orbits)-> B => D -(indirectly orbits)-> B
  ```
  """
  def all_orbits(orbits) do
    orbits
    |> Enum.with_index()
    |> Enum.reduce(MapSet.new(), fn {{a, bs}, idx}, all_orbits ->
      Logger.info("processing #{idx}")

      Enum.reduce(bs, all_orbits, fn b, all_orbits ->
        MapSet.put(all_orbits, {a, b})
        |> add_indirect_orbits(a, b, orbits)
      end)
    end)
  end

  defp add_indirect_orbits(all_orbits, a, b, orbits) do
    cs = orbits[b] || []
    Logger.debug("orbits[#{inspect(b)}] = #{inspect(cs)}")

    Enum.reduce(cs, all_orbits, fn c, all_orbits ->
      # if relation a -([indirectly] orbits)-> c has already been traced,
      # we don't need to re-trace it again.
      indirect_orbits_of_a_through_c = add_indirect_orbits(all_orbits, a, c, orbits)
      Logger.debug("adding #{a} -(indirectly orbits)-> #{c} relation, and tracing from #{a} through #{c}...")

      MapSet.put(all_orbits, {a, c})
      |> MapSet.union(indirect_orbits_of_a_through_c)
    end)
  end
end
