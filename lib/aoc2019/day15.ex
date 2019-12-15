defmodule Aoc2019.Day15 do
  import Aoc2019

  alias Aoc2019.Intcode

  @spec solve_part_one() :: Intcode.value()
  def solve_part_one() do
    flood_fill()
  end

  # Helpers

  @type status_raw :: 0..2
  @type status :: :wall | :ok | :target

  @type direction_input :: 1..4
  @type direction :: :n | :s | :w | :e

  @type position :: {x :: integer(), y :: integer()}
  @type location_map :: %{position() => status()}

  @type thread_state :: {status, Intcode.input_cont()}

  @possible_directions ~w(n s w e)a

  def flood_fill() do
    init_threads_with_position = Enum.map(@possible_directions, &move_with_position(&1))

    advance_fill(init_threads_with_position, 1, %{})
  end

  def advance_fill(thread_states_with_pos, steps_taken, location_map) do
    # threads_count = length(thread_states_with_pos)
    # map_locations = Map.keys(location_map) |> length()
    # IO.puts("steps_taken: #{steps_taken}, threads count: #{threads_count}, map locations: #{map_locations}")

    if target_hit?(thread_states_with_pos) do
      steps_taken
    else
      thread_states_with_pos =
        Enum.flat_map(thread_states_with_pos, fn
          {{:wall, _input_cont}, _position} ->
            []

          {{:ok, input_cont}, position} ->
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

      location_map =
        Enum.reduce(thread_states_with_pos, location_map, fn {{status, _cont}, position}, location_map ->
          Map.put(location_map, position, status)
        end)

      advance_fill(thread_states_with_pos, steps_taken + 1, location_map)
    end
  end

  @spec target_hit?([{thread_state(), position()}]) :: boolean
  def target_hit?(thread_states_with_position) do
    Enum.any?(thread_states_with_position, fn
      {{:target, _}, _} -> true
      _ -> false
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

  def move_manually() do
    read_input(15)
    |> Intcode.execute_program_with_io_adapter(
      [],
      fn ->
        direction =
          case IO.gets("next move?\n") |> String.trim() do
            "n" -> 1
            "s" -> 2
            "w" -> 3
            "e" -> 4
            "stop" -> raise "Movement program stopped."
          end

        direction
      end,
      fn status ->
        status = decode_status(status)
        IO.puts("#{status}")
      end
    )
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
