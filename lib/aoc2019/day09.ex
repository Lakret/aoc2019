defmodule Aoc2019.Day09 do
  import Aoc2019

  alias Aoc2019.Intcode

  @spec solve_part_one() :: Intcode.value()
  def solve_part_one() do
    %{outputs: [boost_keycode]} = read_input(9) |> Intcode.execute_program([1])

    boost_keycode
  end

  @spec solve_part_two() :: Intcode.value()
  def solve_part_two() do
    %{outputs: [coordinate_of_distress_signal]} = read_input(9) |> Intcode.execute_program([2])

    coordinate_of_distress_signal
  end
end
