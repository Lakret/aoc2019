defmodule Aoc2019.Day08Test do
  use ExUnit.Case

  import Aoc2019.Day08

  test "part 1 is solved correctly" do
    assert solve_part_one() == 1690
  end

  test "part 2 is solved correctly" do
    # answer is ZPZUB
    assert solve_part_two() ==
             String.trim_trailing("""
             □□□□■□□□■■□□□□■□■■□■□□□■■
             ■■■□■□■■□■■■■□■□■■□■□■■□■
             ■■□■■□■■□■■■□■■□■■□■□□□■■
             ■□■■■□□□■■■□■■■□■■□■□■■□■
             □■■■■□■■■■□■■■■□■■□■□■■□■
             □□□□■□■■■■□□□□■■□□■■□□□■■
             """)
  end
end
