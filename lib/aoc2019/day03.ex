defmodule Aoc2019.Day03 do
  import Aoc2019

  @type direction :: :up | :down | :left | :right
  @type step :: {direction, integer()}
  @type path :: [step]

  @type coord :: {integer(), integer()}
  @type path_trace :: [coord()]
  @type intersections :: [coord()]

  @type distance :: non_neg_integer()

  @type steps_taken :: non_neg_integer()
  @type coords_to_min_steps :: %{coord() => steps_taken()}
  @type steps_taken_and_intersection :: {steps_taken(), coord()}

  @spec solve_part_one :: distance()
  def solve_part_one() do
    {distance, _intersection} =
      read_input(3)
      |> String.split()
      |> Enum.map(&parse_path/1)
      |> find_intersection_closest_to_the_port()

    distance
  end

  @spec solve_part_two :: steps_taken()
  def solve_part_two() do
    {combined_steps, _intersection} =
      read_input(3)
      |> String.split()
      |> Enum.map(&parse_path/1)
      |> find_minimum_combined_steps_intersection()

    combined_steps
  end

  # Helpers

  @spec find_intersection_closest_to_the_port(paths :: [path()]) :: {distance(), coord()}
  def find_intersection_closest_to_the_port(paths) when is_list(paths) do
    Enum.map(paths, &trace_path/1)
    |> find_intersections()
    |> Enum.map(fn intersection -> {manhattan_distance_from_port(intersection), intersection} end)
    |> Enum.sort(fn {dist1, _intersection1}, {dist2, _intersection2} -> dist1 < dist2 end)
    |> hd()
  end

  @spec find_minimum_combined_steps_intersection([path()]) :: steps_taken_and_intersection()
  def find_minimum_combined_steps_intersection(paths) when is_list(paths) do
    calculate_minimum_combined_steps_for_each_intersection(paths)
    |> Enum.sort(fn {steps_taken1, _intersection1}, {steps_taken2, _intersection2} -> steps_taken1 < steps_taken2 end)
    |> hd()
  end

  @spec calculate_minimum_combined_steps_for_each_intersection([path()]) :: [steps_taken_and_intersection()]
  def calculate_minimum_combined_steps_for_each_intersection(paths) when is_list(paths) do
    coords_to_min_steps_maps = Enum.map(paths, &trace_coords_to_min_steps/1)

    Enum.map(coords_to_min_steps_maps, &Map.keys/1)
    |> find_intersections()
    |> Enum.map(fn intersection ->
      minimum_combined_steps =
        Enum.map(coords_to_min_steps_maps, &Map.fetch!(&1, intersection))
        |> Enum.sum()

      {minimum_combined_steps, intersection}
    end)
  end

  @spec trace_coords_to_min_steps(path()) :: coords_to_min_steps()
  def trace_coords_to_min_steps(path) when is_list(path) do
    {_position, coords_to_min_steps, _steps_taken} =
      Enum.reduce(path, {{0, 0}, %{}, 0}, fn step, {position, coords_to_min_steps, steps_taken} ->
        coords_with_steps_taken = perform_step(step, position) |> Enum.with_index(steps_taken + 1)

        coords_to_min_steps =
          Enum.reduce(coords_with_steps_taken, coords_to_min_steps, fn {coord, steps_taken}, coords_to_min_steps ->
            Map.put_new(coords_to_min_steps, coord, steps_taken)
          end)

        {position, steps_taken} = List.last(coords_with_steps_taken)

        {position, coords_to_min_steps, steps_taken}
      end)

    coords_to_min_steps
  end

  @spec parse_path(path :: String.t()) :: path()
  def parse_path(path) when is_binary(path) do
    String.split(path, ",") |> Enum.map(&parse_step/1)
  end

  @spec parse_step(step :: String.t()) :: step
  def parse_step("R" <> distance), do: {:right, parse_distance(distance)}
  def parse_step("L" <> distance), do: {:left, parse_distance(distance)}
  def parse_step("U" <> distance), do: {:up, parse_distance(distance)}
  def parse_step("D" <> distance), do: {:down, parse_distance(distance)}

  @spec parse_distance(distance :: String.t()) :: integer()
  def parse_distance(distance) do
    {int, ""} = Integer.parse(distance)
    int
  end

  @spec trace_path(path()) :: path_trace()
  def trace_path(path) when is_list(path) do
    {_position, trace} =
      Enum.reduce(path, {{0, 0}, []}, fn step, {position, trace} ->
        new_trace_elements = perform_step(step, position)

        position = List.last(new_trace_elements)
        trace = trace ++ new_trace_elements

        {position, trace}
      end)

    trace
  end

  @spec perform_step(step(), coord()) :: [coord()]
  def perform_step({direction, distance}, position) do
    Stream.unfold(position, fn position ->
      position = move(position, direction)
      {position, position}
    end)
    |> Stream.take(distance)
    |> Enum.to_list()
  end

  @spec move(coord(), direction()) :: coord()
  def move({x, y}, :up), do: {x, y + 1}
  def move({x, y}, :down), do: {x, y - 1}
  def move({x, y}, :right), do: {x + 1, y}
  def move({x, y}, :left), do: {x - 1, y}

  @spec find_intersections([path_trace()]) :: intersections()
  def find_intersections(path_traces) do
    [path1_coords | rest] = Enum.map(path_traces, &MapSet.new/1)

    Enum.reduce(rest, path1_coords, &MapSet.intersection/2)
  end

  @spec manhattan_distance_from_port(coord()) :: distance()
  def manhattan_distance_from_port({x, y}) when is_integer(x) and is_integer(y) do
    :erlang.abs(x) + :erlang.abs(y)
  end
end
