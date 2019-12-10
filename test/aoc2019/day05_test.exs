defmodule Aoc2019.Day05Test do
  use ExUnit.Case

  import Aoc2019.Day05

  alias Aoc2019.Intcode

  test "part 1 is solved correctly" do
    assert solve_part_one() == 0
  end

  test "opcode and parameter modes are parsed correctly" do
    {opcode, parameter_modes} = Intcode.parse_instruction(1002)
    assert opcode == 2
    assert parameter_modes == [0, 1]
  end

  test "program outputting its input works" do
    program = "3,0,4,0,99"

    executed_program = Intcode.execute_program(program, [54])

    assert executed_program.outputs == [54]

    executed_program = Intcode.execute_program(program, [-666])

    assert executed_program.outputs == [-666]
  end
end
