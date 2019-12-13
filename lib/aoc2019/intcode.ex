defmodule Aoc2019.Intcode do
  @moduledoc """
  Implementation of Intcode computer used in days 2 and 5.
  """

  @type program :: %{body: body, inputs: [integer()], outputs: [integer()]}
  @type body :: %{non_neg_integer() => integer()}

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

  @type input_fun :: (() -> value()) | nil
  @type output_fun :: (value() -> :ok) | nil

  # Instructions
  @terminate_op 99
  @jump_if_true_op 5
  @jump_if_false_op 6

  @add_op 1
  @multiply_op 2
  @less_than_op 7
  @equals_op 8

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

  @spec get_result(end_program_state :: program()) :: value()
  def get_result(end_program_state) do
    Map.fetch!(end_program_state.body, 0)
  end

  @spec execute_program(input :: String.t(), inputs :: [integer()]) :: program()
  def execute_program(input, inputs \\ []) do
    parse_input(input, inputs)
    |> interpret()
  end

  @spec execute_program_with_io_adapter(input :: String.t(), inputs :: [integer()], input_fun(), output_fun()) ::
          program()
  def execute_program_with_io_adapter(input, inputs, input_fun, output_fun) do
    parse_input(input, inputs)
    |> interpret(input_fun, output_fun)
  end

  @spec interpret(program_or_state :: program() | state(), input_fun(), output_fun()) :: program() | no_return()
  def interpret(program_or_state, input_fun \\ nil, output_fun \\ nil)

  def interpret(%{program: program, instruction_ptr: instruction_ptr}, input_fun, output_fun) do
    {opcode, parameter_modes} = Map.fetch!(program.body, instruction_ptr) |> parse_instruction()

    case opcode do
      @terminate_op ->
        program

      @add_op ->
        execute_binary_operation(program, parameter_modes, instruction_ptr, &+/2)
        |> interpret(input_fun, output_fun)

      @multiply_op ->
        execute_binary_operation(program, parameter_modes, instruction_ptr, &*/2)
        |> interpret(input_fun, output_fun)

      @input_op ->
        # take input
        {input, program} =
          case program.inputs do
            [] ->
              if is_nil(input_fun), do: raise("Ran out of inputs and input_fun is not set!")

              input = input_fun.()
              {input, program}

            [input | remaining_inputs] ->
              {input, Map.put(program, :inputs, remaining_inputs)}
          end

        # read the result address
        res_idx = Map.fetch!(program.body, instruction_ptr + 1)

        # save input at the result address, and advance the instruction pointer
        program = put_in(program, [:body, res_idx], input)
        instruction_ptr = advance_instruction_ptr(instruction_ptr, 2)

        interpret(%{program: program, instruction_ptr: instruction_ptr}, input_fun, output_fun)

      @output_op ->
        # read the value (accounting for the parameter mode)
        output_idx_or_value = Map.fetch!(program.body, instruction_ptr + 1)
        output = fetch_parameter(program.body, output_idx_or_value, 0, parameter_modes)

        # output it, advance the instruction pointer
        program = put_in(program.outputs, program.outputs ++ [output])

        if not is_nil(output_fun) do
          output_fun.(output)
        end

        instruction_ptr = advance_instruction_ptr(instruction_ptr, 2)

        interpret(%{program: program, instruction_ptr: instruction_ptr}, input_fun, output_fun)

      @jump_if_true_op ->
        {arg1, arg2} = read_two_arguments(program, parameter_modes, instruction_ptr)

        instruction_ptr =
          if arg1 != 0 do
            arg2
          else
            advance_instruction_ptr(instruction_ptr, 3)
          end

        interpret(%{program: program, instruction_ptr: instruction_ptr}, input_fun, output_fun)

      @jump_if_false_op ->
        {arg1, arg2} = read_two_arguments(program, parameter_modes, instruction_ptr)

        instruction_ptr =
          if arg1 == 0 do
            arg2
          else
            advance_instruction_ptr(instruction_ptr, 3)
          end

        interpret(%{program: program, instruction_ptr: instruction_ptr}, input_fun, output_fun)

      @less_than_op ->
        execute_binary_operation(program, parameter_modes, instruction_ptr, fn arg1, arg2 ->
          if arg1 < arg2 do
            1
          else
            0
          end
        end)
        |> interpret(input_fun, output_fun)

      @equals_op ->
        execute_binary_operation(program, parameter_modes, instruction_ptr, fn arg1, arg2 ->
          if arg1 == arg2 do
            1
          else
            0
          end
        end)
        |> interpret(input_fun, output_fun)
    end
  end

  def interpret(program, input_fun, output_fun) do
    interpret(%{program: program, instruction_ptr: 0}, input_fun, output_fun)
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
    {arg1, arg2} = read_two_arguments(program, parameter_modes, instruction_ptr)
    res_idx = Map.fetch!(program.body, instruction_ptr + 3)
    {arg1, arg2, res_idx}
  end

  @spec read_two_arguments(program(), [parameter_mode()], instruction_ptr()) :: {value(), value()}
  def read_two_arguments(program, parameter_modes, instruction_ptr) do
    arg1_idx = Map.fetch!(program.body, instruction_ptr + 1)
    arg2_idx = Map.fetch!(program.body, instruction_ptr + 2)

    arg1 = fetch_parameter(program.body, arg1_idx, 0, parameter_modes)
    arg2 = fetch_parameter(program.body, arg2_idx, 1, parameter_modes)

    {arg1, arg2}
  end

  @spec fetch_parameter(body(), address() | value(), non_neg_integer(), [parameter_mode()]) :: any
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
