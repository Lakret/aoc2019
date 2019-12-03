defmodule Aoc2019.Day02Test do
  use ExUnit.Case
  import Aoc2019.Day02

  doctest Aoc2019.Day02

  test "interprets example programs correclty" do
    program = "1,9,10,3,2,3,11,0,99,30,40,50"
    actual = execute_program(program)

    expected = parse_input("3500,9,10,70,2,3,11,0,99,30,40,50")
    assert actual == expected

    actual = execute_program("1,0,0,0,99")
    expected = parse_input("2,0,0,0,99")
    assert actual == expected

    actual = execute_program("2,3,0,3,99")
    expected = parse_input("2,3,0,6,99")
    assert actual == expected

    actual = execute_program("2,4,4,5,99,0")
    expected = parse_input("2,4,4,5,99,9801")
    assert actual == expected

    actual = execute_program("1,1,1,4,99,5,6,0,99")
    expected = parse_input("30,1,1,4,2,5,6,0,99")
    assert actual == expected
  end

  test "part 1 is solved correctly" do
    assert solve_part_one() == 4_090_701
  end
end
