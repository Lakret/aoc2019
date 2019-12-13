defmodule Aoc2019.Day07 do
  import Aoc2019

  alias Aoc2019.Intcode

  @type phase :: non_neg_integer()

  @min_phase 0
  @max_phase 4

  @min_feedback_phase 5
  @max_feedback_phase 9

  @amplifiers 5

  @spec solve_part_one() :: Intcode.value()
  def solve_part_one() do
    {_phase_setting, thruster_signal} =
      read_input(7)
      |> find_best_phase_setting_and_thruster_signal()

    thruster_signal
  end

  @spec solve_part_two() :: Intcode.value()
  def solve_part_two() do
    {_phase_setting, thruster_signal} =
      read_input(7)
      |> find_best_phase_setting_in_feedback_mode()

    thruster_signal
  end

  # Helpers

  @spec find_best_phase_setting_and_thruster_signal(String.t()) ::
          {phase_setting :: [phase()], thruster_signal :: non_neg_integer()}
  def find_best_phase_setting_and_thruster_signal(amplifier_program) do
    generate_phase_settings(@min_phase, @max_phase)
    |> Enum.map(&with_computed_thruster_signal(&1, amplifier_program))
    |> Enum.max_by(fn {_phase_setting, thruster_signal} -> thruster_signal end)
  end

  @spec find_best_phase_setting_in_feedback_mode(any) ::
          {phase_setting :: [phase()], thruster_signal :: non_neg_integer()}
  def find_best_phase_setting_in_feedback_mode(amplifier_program) do
    generate_phase_settings(@min_feedback_phase, @max_feedback_phase)
    |> Enum.map(&with_computed_feedback_thruster_signal(&1, amplifier_program))
    |> Enum.max_by(fn {_phase_setting, thruster_signal} -> thruster_signal end)
  end

  @spec generate_phase_settings(phase(), phase()) :: [[phase()]]
  def generate_phase_settings(min_phase, max_phase) do
    Enum.flat_map(min_phase..max_phase, &generate_phase_settings([&1], @amplifiers - 1, min_phase, max_phase))
    |> Enum.chunk_every(5)
  end

  @spec generate_phase_settings([phase()], non_neg_integer(), phase(), phase()) :: [phase()]
  def generate_phase_settings(acc, remaining_settings_to_fill, min_phase, max_phase)

  def generate_phase_settings(acc, 0, _, _), do: acc

  def generate_phase_settings(acc, remaining_settings_to_fill, min_phase, max_phase) do
    Enum.filter(min_phase..max_phase, fn phase -> phase not in acc end)
    |> Enum.flat_map(fn phase ->
      generate_phase_settings([phase | acc], remaining_settings_to_fill - 1, min_phase, max_phase)
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

  @spec with_computed_feedback_thruster_signal([phase()], String.t()) ::
          {[phase()], thruster_signal :: non_neg_integer()}
  def with_computed_feedback_thruster_signal(phase_setting, amplifier_program) do
    # create agents to store inputs/outputs of amplifiers
    # input of the first amplifier is the output of the last one
    # output of A is input of B, output of B is input of C, etc.
    # thus, cell with amplifier id 1 stores input of A / output of E;
    # cell with amplifier id 2 stores input of B / output of A, etc.
    cells =
      Enum.with_index(phase_setting, 1)
      |> Enum.map(fn {phase, amplifier_id} ->
        {:ok, cell_pid} =
          Agent.start_link(fn ->
            if amplifier_id == 1 do
              [phase, 0]
            else
              phase
            end
          end)

        {amplifier_id, cell_pid}
      end)
      |> Enum.into(%{})

    amplifiers =
      Enum.map(1..@amplifiers, fn amplifier_id ->
        current_amplifier_cell_pid = Map.fetch!(cells, amplifier_id)
        # the current amplifier's output is the input of the next amplifier
        next_amplifier_id = if amplifier_id == 5, do: 1, else: amplifier_id + 1
        next_amplifier_cell_pid = Map.fetch!(cells, next_amplifier_id)

        amplifier =
          Task.async(fn ->
            output_fun = fn value ->
              # IO.puts("outputing value #{value} for #{next_amplifier_id} (#{inspect(next_amplifier_cell_pid)})")
              Agent.update(next_amplifier_cell_pid, fn
                nil -> value
                existing_value when is_integer(existing_value) -> [existing_value, value]
                existing_values when is_list(existing_values) -> existing_values ++ [value]
              end)
            end

            Intcode.execute_program_with_io_adapter(
              amplifier_program,
              [],
              fn -> cell_input_fun(current_amplifier_cell_pid) end,
              output_fun
            )
          end)

        {amplifier_id, amplifier}
      end)
      |> Enum.into(%{})

    # wait till all amplifiers finish running
    Enum.each(amplifiers, fn {_amplifier_id, task} -> Task.await(task, :infinity) end)

    thruster_signal = Map.fetch!(cells, 1) |> Agent.get(& &1)

    {phase_setting, thruster_signal}
  end

  defp cell_input_fun(cell_pid) do
    input =
      Agent.get_and_update(cell_pid, fn
        nil -> {nil, nil}
        [value] -> {value, nil}
        [value | remaining_values] -> {value, remaining_values}
        value when is_integer(value) -> {value, nil}
      end)

    if is_nil(input) do
      Process.sleep(10)
      cell_input_fun(cell_pid)
    else
      # IO.puts("got input #{input} for #{inspect(cell_pid)}")
      input
    end
  end
end
