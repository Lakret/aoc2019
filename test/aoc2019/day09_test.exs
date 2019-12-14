defmodule Aoc2019.Day09Test do
  use ExUnit.Case

  import Aoc2019.Day09

  alias Aoc2019.Intcode

  test "part 1 is solved correctly" do
    assert solve_part_one() == 2_350_741_403
  end

  test "part 2 is solved correctly" do
    assert solve_part_two() == 53088
  end

  test "quine with relative mode addresses works" do
    quine = "109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99"
    state = Intcode.execute_program(quine)

    returned_quine = state.outputs |> Enum.map(&to_string/1) |> Enum.join(",")
    assert returned_quine == quine
  end

  test "16 digit number is returned from test program" do
    test_program = "1102,34915192,34915192,7,4,7,99,0"
    %{outputs: [n]} = Intcode.execute_program(test_program)

    assert String.length(to_string(n)) == 16
  end

  test "large number in the middle is returned by test program" do
    test_program = "104,1125899906842624,99"
    %{outputs: [n]} = Intcode.execute_program(test_program)

    assert n == 1_125_899_906_842_624
  end
end
