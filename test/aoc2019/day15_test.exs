defmodule Aoc2019.Day15Test do
  use ExUnit.Case

  alias Aoc2019.Day15

  test "move_stepwise works" do
    {output, cont} = Day15.move_stepwise(:n)
    assert output == :wall

    # at the start position it doesn't really matter if we use the returned cont
    # (since robot doesn't move if it hits the wall),
    {output, _cont} = Day15.move_stepwise(:e, cont)
    assert output == :ok

    # ... or if we start from the blank state
    {output, cont} = Day15.move_stepwise(:e)
    assert output == :ok

    {output, cont} = Day15.move_stepwise(:e, cont)
    assert output == :ok

    # but after a couple of steps, it starts to matter, since we are in different position on the map now
    {output, _cont} = Day15.move_stepwise(:e, cont)
    assert output == :wall
  end
end
