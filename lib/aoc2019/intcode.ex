defmodule Aoc2019.Intcode do
  @moduledoc """
  Implementation of Intcode computer used in days 2 and 5.
  """

  @type program :: %{body: %{non_neg_integer() => integer()}, inputs: [integer()], outputs: [integer()]}

  @type address :: non_neg_integer()
  @type value :: integer()
  @type instruction_ptr :: non_neg_integer()
  @type state :: %{
          program: program(),
          instruction_ptr: instruction_ptr()
        }

  # Instructions
  @terminate_op 99
  @add_op 1
  @multiply_op 2
  @input_op 3
  @output_op 4

  @spec parametrize_first_and_second_addresses(program(), noun :: value(), verb :: value()) :: program()
  def parametrize_first_and_second_addresses(program, noun, verb) do
    body =
      Map.put(program.body, 1, noun)
      |> Map.put(2, verb)

    Map.put(program, :body, body)
  end

  @spec parametrize(program(), [integer()]) :: program()
  def parametrize(program, params) when is_list(params) do
    put_in(program.inputs, params)
  end

  @spec get_result(end_program_state :: program()) :: value()
  def get_result(end_program_state) do
    Map.fetch!(end_program_state.body, 0)
  end

  @spec execute_program(input :: String.t()) :: program()
  def execute_program(input) do
    parse_input(input)
    |> interpret()
  end

  @spec interpret(program_or_state :: program() | state()) :: program() | no_return()
  def interpret(%{program: program, instruction_ptr: instruction_ptr}) do
    case Map.fetch!(program.body, instruction_ptr) do
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
    program = put_in(program.body, Map.put(program.body, res_idx, res))
    instruction_ptr = advance_instruction_ptr(instruction_ptr)

    %{program: program, instruction_ptr: instruction_ptr}
  end

  @spec get_arguments(program(), instruction_ptr()) ::
          {arg1 :: value(), arg2 :: value(), res_idx :: address()}
  def get_arguments(program, instruction_ptr) do
    arg1_idx = Map.fetch!(program.body, instruction_ptr + 1)
    arg2_idx = Map.fetch!(program.body, instruction_ptr + 2)
    res_idx = Map.fetch!(program.body, instruction_ptr + 3)

    arg1 = Map.fetch!(program.body, arg1_idx)
    arg2 = Map.fetch!(program.body, arg2_idx)

    {arg1, arg2, res_idx}
  end

  @spec advance_instruction_ptr(instruction_ptr(), step :: non_neg_integer()) :: instruction_ptr()
  def advance_instruction_ptr(instruction_ptr, step \\ 4), do: instruction_ptr + step

  @spec parse_input(input :: String.t()) :: program()
  def parse_input(input) when is_binary(input) do
    body =
      String.split(input, ",")
      |> Enum.with_index()
      |> Enum.map(fn {input, idx} ->
        {int, ""} = Integer.parse(input)
        {idx, int}
      end)
      |> Enum.into(%{})

    %{body: body, inputs: [], outputs: []}
  end
end
