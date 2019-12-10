defmodule Aoc2019.Day05 do
  import Aoc2019

  alias Aoc2019.Intcode

  @spec solve_part_one() :: Intcode.value()
  def solve_part_one() do
    read_input(5)
    |> Intcode.execute_program([1])
    |> extract_diagnostic_code!()
  end

  @spec solve_part_two() :: Intcode.value()
  def solve_part_two() do
    read_input(5)
    |> Intcode.execute_program([5])
    |> extract_diagnostic_code!()
  end

  @spec extract_diagnostic_code!(Intcode.program()) :: non_neg_integer() | no_return()
  defp extract_diagnostic_code!(program) do
    [diagnostic_code] = program.outputs |> Enum.drop_while(&(&1 == 0))
    diagnostic_code
  end
end
