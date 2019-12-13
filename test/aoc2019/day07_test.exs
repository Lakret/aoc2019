defmodule Aoc2019.Day07Test do
  use ExUnit.Case

  import Aoc2019.Day07

  test "part 1 is solved correctly" do
    assert solve_part_one() == 43812
  end

  # test "part 2 is solved correctly" do
  #   assert solve_part_two() == 0
  # end

  test "finds optimal phase settings for example amplifier programs" do
    {phase_setting, thruster_signal} =
      find_best_phase_setting_and_thruster_signal("3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0")

    assert phase_setting == [4, 3, 2, 1, 0]
    assert thruster_signal == 43210

    {phase_setting, thruster_signal} =
      find_best_phase_setting_and_thruster_signal(
        "3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0"
      )

    assert phase_setting == [0, 1, 2, 3, 4]
    assert thruster_signal == 54321

    {phase_setting, thruster_signal} =
      find_best_phase_setting_and_thruster_signal(
        "3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0"
      )

    assert phase_setting == [1, 0, 4, 3, 2]
    assert thruster_signal == 65210
  end
end
