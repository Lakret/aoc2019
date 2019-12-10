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

  @type opcode :: non_neg_integer()
  @type parameter_mode :: non_neg_integer()

  @type binary_operation :: (value(), value() -> value())

  # Instructions
  @terminate_op 99
  @add_op 1
  @multiply_op 2
  @input_op 3
  @output_op 4

  # Parameter modes
  @position_mode 0
  @immediate_mode 1

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

  @spec execute_program(input :: String.t(), inputs :: [integer()]) :: program()
  def execute_program(input, inputs \\ []) do
    parse_input(input, inputs)
    |> interpret()
  end

  @spec interpret(program_or_state :: program() | state()) :: program() | no_return()
  def interpret(%{program: program, instruction_ptr: instruction_ptr}) do
    {opcode, parameter_modes} = Map.fetch!(program.body, instruction_ptr) |> parse_instruction()

    case opcode do
      @terminate_op ->
        program

      @add_op ->
        new_state = execute_binary_operation(program, parameter_modes, instruction_ptr, &+/2)
        interpret(new_state)

      @multiply_op ->
        new_state = execute_binary_operation(program, parameter_modes, instruction_ptr, &*/2)
        interpret(new_state)

      @input_op ->
        # take input
        [input | remaining_inputs] = program.inputs
        program = Map.put(program, :inputs, remaining_inputs)

        # read the result address
        res_idx = Map.fetch!(program.body, instruction_ptr + 1)

        # save input at the result address, and advance the instruction pointer
        program = put_in(program, [:body, res_idx], input)
        instruction_ptr = advance_instruction_ptr(instruction_ptr, 2)

        interpret(%{program: program, instruction_ptr: instruction_ptr})

      @output_op ->
        # read the value (accounting for the parameter mode)
        output_idx_or_value = Map.fetch!(program.body, instruction_ptr + 1)
        output = fetch_parameter(program.body, output_idx_or_value, 0, parameter_modes)

        # output it, advance the instruction pointer
        program = put_in(program.outputs, program.outputs ++ [output])
        instruction_ptr = advance_instruction_ptr(instruction_ptr, 2)

        interpret(%{program: program, instruction_ptr: instruction_ptr})
    end
  end

  def interpret(program) do
    interpret(%{program: program, instruction_ptr: 0})
  end

  @spec parse_instruction(non_neg_integer()) :: {opcode(), [parameter_mode()]}
  def parse_instruction(instruction) when is_integer(instruction) do
    if instruction < 10 do
      {instruction, []}
    else
      [opcode_char2 | [opcode_char1 | parameter_modes]] =
        to_string(instruction) |> String.codepoints() |> Enum.reverse()

      {opcode, ""} = [opcode_char1, opcode_char2] |> to_string() |> Integer.parse()

      parameter_modes =
        Enum.map(parameter_modes, fn mode_char ->
          {mode, ""} = Integer.parse(mode_char)
          mode
        end)

      {opcode, parameter_modes}
    end
  end

  @spec execute_binary_operation(program(), [parameter_mode()], instruction_ptr(), operation :: binary_operation()) ::
          state()
  def execute_binary_operation(program, parameter_modes, instruction_ptr, operation) do
    {arg1, arg2, res_idx} = get_binary_arguments(program, parameter_modes, instruction_ptr)
    res = operation.(arg1, arg2)
    program = put_in(program.body, Map.put(program.body, res_idx, res))
    instruction_ptr = advance_instruction_ptr(instruction_ptr)

    %{program: program, instruction_ptr: instruction_ptr}
  end

  @spec get_binary_arguments(program(), [parameter_mode()], instruction_ptr()) ::
          {arg1 :: value(), arg2 :: value(), res_idx :: address()}
  def get_binary_arguments(program, parameter_modes, instruction_ptr) do
    arg1_idx = Map.fetch!(program.body, instruction_ptr + 1)
    arg2_idx = Map.fetch!(program.body, instruction_ptr + 2)
    res_idx = Map.fetch!(program.body, instruction_ptr + 3)

    arg1 = fetch_parameter(program.body, arg1_idx, 0, parameter_modes)
    arg2 = fetch_parameter(program.body, arg2_idx, 1, parameter_modes)

    {arg1, arg2, res_idx}
  end

  def fetch_parameter(body, parameter_idx_or_value, mode_idx, parameter_modes) do
    case Enum.at(parameter_modes, mode_idx, 0) do
      @position_mode -> Map.fetch!(body, parameter_idx_or_value)
      @immediate_mode -> parameter_idx_or_value
    end
  end

  @spec advance_instruction_ptr(instruction_ptr(), step :: non_neg_integer()) :: instruction_ptr()
  def advance_instruction_ptr(instruction_ptr, step \\ 4), do: instruction_ptr + step

  @spec parse_input(String.t(), [integer()]) :: program()
  def parse_input(input, inputs \\ []) when is_binary(input) do
    body =
      String.split(input, ",")
      |> Enum.with_index()
      |> Enum.map(fn {input, idx} ->
        {int, ""} = Integer.parse(input)
        {idx, int}
      end)
      |> Enum.into(%{})

    %{body: body, inputs: inputs, outputs: []}
  end
end
