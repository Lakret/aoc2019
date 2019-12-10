defmodule Aoc2019.Day02 do
  import Aoc2019

  alias Aoc2019.Intcode

  @doc """
  # Task

  Before running the program, replace position 1 with the value 12 and replace position 2 with the value 2.

  What value is left at position 0 after the program halts?
  """
  @spec solve_part_one :: Intcode.value()
  def solve_part_one() do
    read_input(2)
    |> Intcode.parse_input()
    |> Intcode.parametrize_first_and_second_addresses(12, 2)
    |> Intcode.interpret()
    |> Intcode.get_result()
  end

  @doc """
  # Task

  Find the input noun and verb that cause the program to produce the output 19690720.

  What is 100 * noun + verb? (For example, if noun=12 and verb=2, the answer would be 1202.)

  Each of the two input values will be between 0 and 99, inclusive.
  """
  @spec solve_part_two() :: number()
  def solve_part_two() do
    program = read_input(2) |> Intcode.parse_input()

    {noun, verb} =
      try do
        for noun <- 0..99, verb <- 0..99 do
          result =
            Intcode.parametrize_first_and_second_addresses(program, noun, verb)
            |> Intcode.interpret()
            |> Intcode.get_result()

          if result == 19_690_720 do
            throw({noun, verb})
          end
        end
      catch
        {noun, verb} -> {noun, verb}
      end

    # corect noun and verb turned out to be: {64, 21}
    100 * noun + verb
  end
end
