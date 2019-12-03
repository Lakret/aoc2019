defmodule Aoc2019.Day02 do
  import Aoc2019

  @type program :: %{non_neg_integer() => integer()}

  @type address :: non_neg_integer()
  @type value :: integer()
  @type instruction_ptr :: non_neg_integer()
  @type state :: %{
          program: program(),
          instruction_ptr: instruction_ptr()
        }

  @doc """
  # Task

  Before running the program, replace position 1 with the value 12 and replace position 2 with the value 2.

  What value is left at position 0 after the program halts?
  """
  @spec solve_part_one :: value()
  def solve_part_one() do
    read_input(2)
    |> parse_input()
    |> parametrize(12, 2)
    |> interpret()
    |> get_result()
  end

  @doc """
  # Task

  Find the input noun and verb that cause the program to produce the output 19690720.

  What is 100 * noun + verb? (For example, if noun=12 and verb=2, the answer would be 1202.)

  Each of the two input values will be between 0 and 99, inclusive.
  """
  @spec solve_part_two() :: number
  def solve_part_two() do
    program = read_input(2) |> parse_input()

    {noun, verb} =
      try do
        for noun <- 0..99, verb <- 0..99 do
          result =
            parametrize(program, noun, verb)
            |> interpret()
            |> get_result()

          if result == 19_690_720 do
            throw({noun, verb})
          end
        end
      catch
        {noun, verb} -> {noun, verb}
      end

    # corect noun and verb turned out to be: {64, 21}
    100 * noun + verb
  end

  # Helpers

  @spec parametrize(program(), noun :: value(), verb :: value()) :: program()
  def parametrize(program, noun, verb) do
    Map.put(program, 1, noun) |> Map.put(2, verb)
  end

  @spec get_result(end_program_state :: program()) :: value()
  def get_result(end_program_state) do
    Map.fetch!(end_program_state, 0)
  end

  @spec execute_program(input :: String.t()) :: program()
  def execute_program(input) do
    parse_input(input)
    |> interpret()
  end

  @terminate_op 99
  @add_op 1
  @multiply_op 2

  @spec interpret(program_or_state :: program() | state()) :: program() | no_return()
  def interpret(%{program: program, instruction_ptr: instruction_ptr}) do
    case Map.fetch!(program, instruction_ptr) do
      @terminate_op ->
        program

      @add_op ->
        new_state = execute_binary_operation(program, instruction_ptr, &+/2)
        interpret(new_state)

      @multiply_op ->
        new_state = execute_binary_operation(program, instruction_ptr, &*/2)
        interpret(new_state)
    end
  end

  def interpret(program) do
    interpret(%{program: program, instruction_ptr: 0})
  end

  @type binary_operation :: (value(), value() -> value())

  @spec execute_binary_operation(program(), instruction_ptr(), operation :: binary_operation()) :: state()
  def execute_binary_operation(program, instruction_ptr, operation) do
    {arg1, arg2, res_idx} = get_arguments(program, instruction_ptr)
    res = operation.(arg1, arg2)
    program = Map.put(program, res_idx, res)
    instruction_ptr = advance_instruction_ptr(instruction_ptr)

    %{program: program, instruction_ptr: instruction_ptr}
  end

  @spec get_arguments(program(), instruction_ptr()) ::
          {arg1 :: value(), arg2 :: value(), res_idx :: address()}
  def get_arguments(program, instruction_ptr) do
    arg1_idx = Map.fetch!(program, instruction_ptr + 1)
    arg2_idx = Map.fetch!(program, instruction_ptr + 2)
    res_idx = Map.fetch!(program, instruction_ptr + 3)

    arg1 = Map.fetch!(program, arg1_idx)
    arg2 = Map.fetch!(program, arg2_idx)

    {arg1, arg2, res_idx}
  end

  @spec advance_instruction_ptr(instruction_ptr()) :: instruction_ptr()
  def advance_instruction_ptr(instruction_ptr), do: instruction_ptr + 4

  @spec parse_input(input :: String.t()) :: program()
  def parse_input(input) when is_binary(input) do
    String.split(input, ",")
    |> Enum.with_index()
    |> Enum.map(fn {input, idx} ->
      {int, ""} = Integer.parse(input)
      {idx, int}
    end)
    |> Enum.into(%{})
  end
end
