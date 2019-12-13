defmodule Aoc2019.Day07 do
  import Aoc2019

  alias Aoc2019.Intcode

  @type phase :: non_neg_integer()

  @min_phase 0
  @max_phase 4
  @amplifiers 5

  @spec solve_part_one() :: Intcode.value()
  def solve_part_one() do
    {_phase_setting, thruster_signal} =
      read_input(7)
      |> find_best_phase_setting_and_thruster_signal()

    thruster_signal
  end

  # Helpers

  @spec find_best_phase_setting_and_thruster_signal(String.t()) ::
          {phase_setting :: [phase()], thruster_signal :: non_neg_integer()}
  def find_best_phase_setting_and_thruster_signal(amplifier_program) do
    generate_phase_settings()
    |> Enum.map(&with_computed_thruster_signal(&1, amplifier_program))
    |> Enum.max_by(fn {_phase_setting, thruster_signal} -> thruster_signal end)
  end

  @spec generate_phase_settings() :: [[phase()]]
  def generate_phase_settings() do
    Enum.flat_map(@min_phase..@max_phase, &generate_phase_settings([&1], @amplifiers - 1))
    |> Enum.chunk_every(5)
  end

  @spec generate_phase_settings([phase()], non_neg_integer()) :: [phase()]
  def generate_phase_settings(acc, remaining_settings_to_fill)

  def generate_phase_settings(acc, 0), do: acc

  def generate_phase_settings(acc, remaining_settings_to_fill) do
    Enum.filter(@min_phase..@max_phase, fn phase -> phase not in acc end)
    |> Enum.flat_map(fn phase ->
      generate_phase_settings([phase | acc], remaining_settings_to_fill - 1)
    end)
  end

  @spec with_computed_thruster_signal([phase()], String.t()) :: {[phase()], thruster_signal :: non_neg_integer()}
  def with_computed_thruster_signal(phase_setting, amplifier_program) do
    thruster_signal =
      Enum.reduce(phase_setting, 0, fn phase, prev_amplifier_output ->
        program_state = Intcode.execute_program(amplifier_program, [phase, prev_amplifier_output])
        hd(program_state.outputs)
      end)

    {phase_setting, thruster_signal}
  end
end
