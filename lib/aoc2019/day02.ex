defmodule Aoc2019.Day02 do
  import Aoc2019

  @type program :: %{non_neg_integer() => integer()}

  @type ptr :: non_neg_integer()
  @type value :: integer()
  @type instruction_ptr :: non_neg_integer()
  @type state :: %{
          program: program(),
          instruction_ptr: instruction_ptr()
        }

  @spec solve_part_one :: value()
  def solve_part_one() do
    program = read_input(2) |> parse_input()
    program = Map.put(program, 1, 12) |> Map.put(2, 2)

    end_state = interpret(%{program: program, instruction_ptr: 0})
    Map.fetch!(end_state, 0)
  end

  @spec execute_program(input :: String.t()) :: state()
  def execute_program(input) do
    program = parse_input(input)
    interpret(%{program: program, instruction_ptr: 0})
  end

  # Helpers

  @terminate_op 99
  @add_op 1
  @multiply_op 2

  @spec interpret(state :: state()) :: program() | no_return()
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
          {arg1 :: value(), arg2 :: value(), res_idx :: ptr()}
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
