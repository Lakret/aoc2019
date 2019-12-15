defmodule Aoc2019.Day15 do
  import Aoc2019

  alias Aoc2019.Intcode

  # @spec solve_part_one() :: Intcode.value()
  # def solve_part_one() do
  # end

  # Helpers

  @type status_raw :: 0..2
  @type status :: :ok | :target | :wall

  @type direction_input :: 1..4
  @type direction :: :n | :s | :w | :e

  def flood_fill() do
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
