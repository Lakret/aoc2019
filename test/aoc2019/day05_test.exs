defmodule Aoc2019.Day05Test do
  use ExUnit.Case

  import Aoc2019.Day05

  alias Aoc2019.Intcode

  test "part 1 is solved correctly" do
    assert solve_part_one() == 4_601_506
  end

  test "part 2 is solved correctly" do
    assert solve_part_two() == 5_525_561
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

  test "comparisons work" do
    is_equal_to_8_program = "3,9,8,9,10,9,4,9,99,-1,8"

    executed_program = Intcode.execute_program(is_equal_to_8_program, [8])
    assert executed_program.outputs == [1]

    executed_program = Intcode.execute_program(is_equal_to_8_program, [9])
    assert executed_program.outputs == [0]

    less_than_8_program = "3,9,7,9,10,9,4,9,99,-1,8"

    executed_program = Intcode.execute_program(less_than_8_program, [-56])
    assert executed_program.outputs == [1]

    executed_program = Intcode.execute_program(less_than_8_program, [8])
    assert executed_program.outputs == [0]

    executed_program = Intcode.execute_program(less_than_8_program, [80])
    assert executed_program.outputs == [0]

    is_equal_to_8_immediate_program = "3,3,1108,-1,8,3,4,3,99"

    executed_program = Intcode.execute_program(is_equal_to_8_immediate_program, [8])
    assert executed_program.outputs == [1]

    executed_program = Intcode.execute_program(is_equal_to_8_immediate_program, [9])
    assert executed_program.outputs == [0]

    less_than_8_immediate_program = "3,3,1107,-1,8,3,4,3,99"

    executed_program = Intcode.execute_program(less_than_8_immediate_program, [-56])
    assert executed_program.outputs == [1]

    executed_program = Intcode.execute_program(less_than_8_immediate_program, [8])
    assert executed_program.outputs == [0]

    executed_program = Intcode.execute_program(less_than_8_immediate_program, [80])
    assert executed_program.outputs == [0]
  end

  test "jumps work" do
    non_zero_position_program = "3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9"

    executed_program = Intcode.execute_program(non_zero_position_program, [8])
    assert executed_program.outputs == [1]

    executed_program = Intcode.execute_program(non_zero_position_program, [0])
    assert executed_program.outputs == [0]

    non_zero_immediate_program = "3,3,1105,-1,9,1101,0,0,12,4,12,99,1"

    executed_program = Intcode.execute_program(non_zero_immediate_program, [8])
    assert executed_program.outputs == [1]

    executed_program = Intcode.execute_program(non_zero_immediate_program, [0])
    assert executed_program.outputs == [0]
  end

  test "part2 test works" do
    program =
      "3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31," <>
        "1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104," <>
        "999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99"

    executed_program = Intcode.execute_program(program, [7])
    assert executed_program.outputs == [999]

    executed_program = Intcode.execute_program(program, [8])
    assert executed_program.outputs == [1000]

    executed_program = Intcode.execute_program(program, [9])
    assert executed_program.outputs == [1001]
  end
end
