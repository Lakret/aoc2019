defmodule Aoc2019.Day15 do
  import Aoc2019

  alias Aoc2019.Intcode

  @spec solve_part_one() :: non_neg_integer()
  def solve_part_one() do
    {steps_taken, _location_map} = flood_fill()
    steps_taken
  end

  @spec solve_part_two :: non_neg_integer()
  def solve_part_two() do
    {_steps_taken, location_map} = flood_fill(false)
    {steps_taken, _oxygenated} = flood_with_oxygen(location_map)
    steps_taken - 1
  end

  # Helpers

  @type status_raw :: 0..2
  @type status :: :wall | :ok | :target

  @type direction_input :: 1..4
  @type direction :: :n | :s | :w | :e

  @type position :: {x :: integer(), y :: integer()}
  @type location_map :: %{position() => status()}

  @type thread_state :: {status, Intcode.input_cont()}
  @type thread_states_with_pos :: [{thread_state(), position()}]

  @possible_directions ~w(n s w e)a

  @spec flood_with_oxygen(location_map()) :: {steps_taken :: non_neg_integer(), MapSet.t()}
  def flood_with_oxygen(location_map) do
    {oxygenator_position, :target} = Enum.find(location_map, fn {_position, status} -> status == :target end)
    init_threads_with_position = Enum.map(@possible_directions, &move_on_map(&1, oxygenator_position, location_map))
    oxygenated = MapSet.new([oxygenator_position])

    advance_fill_oxygen(init_threads_with_position, 1, location_map, oxygenated)
  end

  @spec advance_fill_oxygen([{position(), status()}], non_neg_integer(), location_map(), MapSet.t()) ::
          {steps_taken :: non_neg_integer(), oxygenated :: MapSet.t()}
  def advance_fill_oxygen(positions_to_status, steps_taken, location_map, oxygenated) do
    threads_count = length(positions_to_status)

    oxygenated =
      Enum.reduce(positions_to_status, oxygenated, fn {position, _status}, oxygenated ->
        MapSet.put(oxygenated, position)
      end)

    if threads_count == 0 do
      {steps_taken, oxygenated}
    else
      positions_to_status =
        Enum.flat_map(positions_to_status, fn
          {_position, :wall} ->
            []

          {position, _} ->
            Enum.reject(@possible_directions, fn direction ->
              MapSet.member?(oxygenated, new_position(position, direction))
            end)
            |> Enum.map(&move_on_map(&1, position, location_map))
        end)

      advance_fill_oxygen(positions_to_status, steps_taken + 1, location_map, oxygenated)
    end
  end

  @spec move_on_map(direction(), position(), location_map()) :: {position(), status()}
  def move_on_map(direction, position, location_map) do
    position = new_position(position, direction)
    {position, Map.fetch!(location_map, position)}
  end

  @spec flood_fill(boolean()) :: {steps_taken :: non_neg_integer(), location_map()}
  def flood_fill(terminate_on_target_hit \\ true) do
    init_threads_with_position = Enum.map(@possible_directions, &move_with_position(&1))

    advance_fill(init_threads_with_position, 1, %{}, terminate_on_target_hit)
  end

  @spec advance_fill(thread_states_with_pos(), non_neg_integer(), location_map(), boolean()) ::
          {steps_taken :: non_neg_integer(), location_map()}
  def advance_fill(thread_states_with_pos, steps_taken, location_map, terminate_on_target_hit) do
    threads_count = length(thread_states_with_pos)

    if (terminate_on_target_hit && target_hit?(thread_states_with_pos)) || threads_count == 0 do
      location_map = update_location_map(location_map, thread_states_with_pos)

      {steps_taken, location_map}
    else
      thread_states_with_pos =
        Enum.flat_map(thread_states_with_pos, fn
          {{:wall, _input_cont}, _position} ->
            []

          {{_, input_cont}, position} ->
            case location_map[position] do
              :wall ->
                []

              _ ->
                Enum.reject(@possible_directions, fn direction ->
                  Map.has_key?(location_map, new_position(position, direction))
                end)
                |> Enum.map(&move_with_position(&1, input_cont, position))
            end
        end)

      location_map = update_location_map(location_map, thread_states_with_pos)

      advance_fill(thread_states_with_pos, steps_taken + 1, location_map, terminate_on_target_hit)
    end
  end

  @spec target_hit?(thread_states_with_pos()) :: boolean
  def target_hit?(thread_states_with_position) do
    Enum.any?(thread_states_with_position, fn
      {{:target, _}, _} -> true
      _ -> false
    end)
  end

  @spec update_location_map(location_map(), thread_states_with_pos()) :: location_map()
  def update_location_map(location_map, thread_states_with_pos) do
    Enum.reduce(thread_states_with_pos, location_map, fn {{status, _cont}, position}, location_map ->
      Map.put(location_map, position, status)
    end)
  end

  @spec new_position(position(), direction()) :: position()
  def new_position({x, y}, direction) do
    case direction do
      :n -> {x, y + 1}
      :s -> {x, y - 1}
      :e -> {x + 1, y}
      :w -> {x - 1, y}
    end
  end

  @spec move_with_position(direction, Intcode.input_cont() | nil, position()) :: {thread_state(), position()}
  def move_with_position(direction, cont \\ nil, position \\ {0, 0}) do
    thread_state = move_stepwise(direction, cont)
    position = new_position(position, direction)

    {thread_state, position}
  end

  @spec move_stepwise(direction, Intcode.input_cont() | nil) :: thread_state()
  def move_stepwise(direction, cont \\ nil) do
    direction = encode_direction(direction)

    yield_state =
      case cont do
        nil -> read_input(15) |> Intcode.execute_program_with_io_adapter([], :yield, :yield)
        input_cont when is_function(input_cont) -> input_cont.(direction)
      end

    {output, input_cont} =
      case yield_state do
        {:input, _state, input_cont} ->
          {:output, output, _state, output_cont} = input_cont.(direction)
          {:input, _state, input_cont} = output_cont.()
          {output, input_cont}

        {:output, output, _state, output_cont} ->
          {:input, _state, input_cont} = output_cont.()
          {output, input_cont}
      end

    {decode_status(output), input_cont}
  end

  @spec decode_status(status_raw()) :: status()
  def decode_status(status) when is_integer(status) do
    case status do
      0 -> :wall
      1 -> :ok
      2 -> :target
    end
  end

  @spec encode_direction(direction()) :: direction_input()
  def encode_direction(direction) when is_atom(direction) do
    case direction do
      :n -> 1
      :s -> 2
      :w -> 3
      :e -> 4
    end
  end
end
