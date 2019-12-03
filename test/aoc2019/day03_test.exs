defmodule Aoc2019.Day03Test do
  use ExUnit.Case
  import Aoc2019.Day03

  doctest Aoc2019.Day03

  @path1 [right: 8, up: 5, left: 5, down: 3]
  @path2 [up: 7, right: 6, down: 4, left: 4]

  @path1_trace [
    {1, 0},
    {2, 0},
    {3, 0},
    {4, 0},
    {5, 0},
    {6, 0},
    {7, 0},
    {8, 0},
    {8, 1},
    {8, 2},
    {8, 3},
    {8, 4},
    {8, 5},
    {7, 5},
    {6, 5},
    {5, 5},
    {4, 5},
    {3, 5},
    {3, 4},
    {3, 3},
    {3, 2}
  ]

  test "path is parsed correctly" do
    path = "R8,U5,L5,D3"

    assert parse_path(path) == @path1
  end

  test "trace_path works" do
    actual_trace = trace_path(@path1)

    assert actual_trace == @path1_trace
  end

  test "find_intersections works" do
    actual =
      Enum.map([@path1, @path2], &trace_path/1)
      |> find_intersections()

    expected = MapSet.new([{3, 3}, {6, 5}])
    assert actual == expected
  end

  test "find_intersection_closest_to_the_port works" do
    {distance, intersection} = find_intersection_closest_to_the_port([@path1, @path2])

    expected_distance_and_intersection = {6, {3, 3}}
    assert {distance, intersection} == expected_distance_and_intersection

    path1 = parse_path("R75,D30,R83,U83,L12,D49,R71,U7,L72")
    path2 = parse_path("U62,R66,U55,R34,D71,R55,D58,R83")
    {distance, _intersection} = find_intersection_closest_to_the_port([path1, path2])

    expected_distance = 159
    assert distance == expected_distance

    path1 = parse_path("R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51")
    path2 = parse_path("U98,R91,D20,R16,D67,R40,U7,R15,U6,R7")
    {distance, _intersection} = find_intersection_closest_to_the_port([path1, path2])

    expected_distance = 135
    assert distance == expected_distance
  end

  test "part 1 is solved correctly" do
    assert solve_part_one() == 293
  end
end
