defmodule Aoc2019.Day07Test do
  use ExUnit.Case

  import Aoc2019.Day07

  test "part 1 is solved correctly" do
    assert solve_part_one() == 43812
  end

  test "part 2 is solved correctly" do
    assert solve_part_two() == 59_597_414
  end

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

  test "feedback programs are executed correctly" do
    {_phase_setting, thruster_signal} =
      with_computed_feedback_thruster_signal(
        [9, 8, 7, 6, 5],
        "3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5"
      )

    assert thruster_signal == 139_629_729

    {_phase_setting, thruster_signal} =
      with_computed_feedback_thruster_signal(
        [9, 7, 8, 5, 6],
        "3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10"
      )

    assert thruster_signal == 18_216
  end
end
