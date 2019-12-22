defmodule Aoc2019.Intcode do
  @moduledoc """
  Implementation of Intcode computer used in days 2 and 5.
  """

  @type program :: %{body: body, inputs: [integer()], outputs: [integer()]}
  @type body :: %{non_neg_integer() => integer()}

  @type address :: non_neg_integer()
  @type value :: integer()
  @type instruction_ptr :: non_neg_integer()
  @type input_fun :: (() -> value()) | nil | :yield
  @type output_fun :: (value() -> :ok) | nil | :yield
  @type relative_base :: integer()
  @type state :: %{
          program: program(),
          instruction_ptr: instruction_ptr(),
          relative_base: relative_base(),
          input_fun: input_fun(),
          output_fun: output_fun()
        }

  @type output_cont :: (() -> program() | no_return() | input_yield() | output_yield())
  @type input_cont :: (value() -> program() | no_return() | input_yield() | output_yield())
  @type output_yield :: {:output, output :: value(), state(), output_cont()}
  @type input_yield :: {:input, state(), input_cont()}

  @type opcode :: non_neg_integer()
  @type parameter_mode :: non_neg_integer()

  @type binary_operation :: (value(), value() -> value())

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

  @increase_relative_base_op 9

  # Parameter modes
  @position_mode 0
  @immediate_mode 1
  @relative_mode 2

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
    |> initialize_interpret_state()
    |> interpret()
  end

  @spec execute_program_with_io_adapter(input :: String.t(), inputs :: [integer()], input_fun(), output_fun()) ::
          program()
  def execute_program_with_io_adapter(input, inputs, input_fun, output_fun) do
    parse_input(input, inputs)
    |> initialize_interpret_state(input_fun: input_fun, output_fun: output_fun)
    |> interpret()
  end

  @doc """
  Inputs string `input_string` into a yielded state `input_yield` from an executing Intcode program.

  Typically, the last character in the `input_string` should be a newline.

  Returns a new yielded state after the input is feeded into the program.
  """
  @spec input_string_as_char_codes_in_yield_mode(input_yield(), String.t()) :: input_yield() | output_yield() | state()
  def input_string_as_char_codes_in_yield_mode(input_yield, input_string) when is_binary(input_string) do
    input = String.to_charlist(input_string)

    # we need to input each character one by one, since Intcode input instruction expects to get one integer at a time;
    [yield_state] =
      Stream.unfold({input_yield, input}, fn
        {{:input, _, cont}, [next | rest]} ->
          {nil, {cont.(next), rest}}

        {{:input, _, _cont} = input_yield, []} ->
          {input_yield, nil}

        {input_yield, []} ->
          {input_yield, nil}

        nil ->
          nil
      end)
      |> Enum.into([])
      |> Enum.reject(&is_nil/1)

    yield_state
  end

  defp initialize_interpret_state(program, opts \\ []) do
    input_fun = Keyword.get(opts, :input_fun)
    output_fun = Keyword.get(opts, :output_fun)

    %{program: program, instruction_ptr: 0, relative_base: 0, input_fun: input_fun, output_fun: output_fun}
  end

  @spec interpret(program_or_state :: program() | state()) :: program() | no_return() | input_yield() | output_yield()
  def interpret(%{program: program, instruction_ptr: instruction_ptr} = state) do
    {opcode, parameter_modes} = Map.fetch!(program.body, instruction_ptr) |> parse_instruction()

    try do
      case opcode do
        @terminate_op ->
          program

        @add_op ->
          execute_binary_operation(state, parameter_modes, instruction_ptr, &+/2, state.relative_base)
          |> interpret()

        @multiply_op ->
          execute_binary_operation(state, parameter_modes, instruction_ptr, &*/2, state.relative_base)
          |> interpret()

        @input_op ->
          # read the result address
          res_idx =
            Map.fetch!(program.body, instruction_ptr + 1)
            |> fetch_return_address(0, parameter_modes, state.relative_base)

          # take input
          {input, program} =
            case program.inputs do
              [] ->
                case state[:input_fun] do
                  nil -> raise("Ran out of inputs and input_fun is not set!")
                  :yield -> throw({:input, state, &continue_with_input(&1, program, res_idx, instruction_ptr, state)})
                  input_fun when is_function(input_fun) -> {input_fun.(), program}
                end

              [input | remaining_inputs] ->
                {input, Map.put(program, :inputs, remaining_inputs)}
            end

          continue_with_input(input, program, res_idx, instruction_ptr, state)

        @output_op ->
          # read the value (accounting for the parameter mode)
          output_idx_or_value = Map.fetch!(program.body, instruction_ptr + 1)
          output = fetch_parameter(program.body, output_idx_or_value, 0, parameter_modes, state.relative_base)

          # output it, advance the instruction pointer
          program = put_in(program.outputs, program.outputs ++ [output])

          instruction_ptr = advance_instruction_ptr(instruction_ptr, 2)

          state = %{state | program: program, instruction_ptr: instruction_ptr}

          case state[:output_fun] do
            nil -> :ok
            :yield -> throw({:output, output, state, fn -> interpret(state) end})
            output_fun when is_function(output_fun) -> state.output_fun.(output)
          end

          interpret(state)

        @jump_if_true_op ->
          {arg1, arg2} = read_two_arguments(program, parameter_modes, instruction_ptr, state.relative_base)

          instruction_ptr =
            if arg1 != 0 do
              arg2
            else
              advance_instruction_ptr(instruction_ptr, 3)
            end

          interpret(%{state | program: program, instruction_ptr: instruction_ptr})

        @jump_if_false_op ->
          {arg1, arg2} = read_two_arguments(program, parameter_modes, instruction_ptr, state.relative_base)

          instruction_ptr =
            if arg1 == 0 do
              arg2
            else
              advance_instruction_ptr(instruction_ptr, 3)
            end

          interpret(%{state | program: program, instruction_ptr: instruction_ptr})

        @less_than_op ->
          execute_binary_operation(
            state,
            parameter_modes,
            instruction_ptr,
            fn arg1, arg2 -> if arg1 < arg2, do: 1, else: 0 end,
            state.relative_base
          )
          |> interpret()

        @equals_op ->
          execute_binary_operation(
            state,
            parameter_modes,
            instruction_ptr,
            fn arg1, arg2 -> if arg1 == arg2, do: 1, else: 0 end,
            state.relative_base
          )
          |> interpret()

        @increase_relative_base_op ->
          relative_base_offset_idx_or_value = Map.fetch!(program.body, instruction_ptr + 1)

          relative_base_offset =
            fetch_parameter(program.body, relative_base_offset_idx_or_value, 0, parameter_modes, state.relative_base)

          instruction_ptr = advance_instruction_ptr(instruction_ptr, 2)
          state = %{state | relative_base: state.relative_base + relative_base_offset, instruction_ptr: instruction_ptr}

          interpret(state)
      end
    catch
      {:output, _output, _state, _cont} = output_yield -> output_yield
      {:input, _state, _cont} = input_yield -> input_yield
    end
  end

  def interpret(program) do
    initialize_interpret_state(program)
    |> interpret()
  end

  @spec continue_with_input(value(), program(), address(), instruction_ptr(), state()) :: program() | no_return()
  def continue_with_input(input, program, res_idx, instruction_ptr, state) do
    # save input at the result address, and advance the instruction pointer
    program = put_in(program, [:body, res_idx], input)
    instruction_ptr = advance_instruction_ptr(instruction_ptr, 2)

    interpret(%{state | program: program, instruction_ptr: instruction_ptr})
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

  @spec execute_binary_operation(
          state(),
          [parameter_mode()],
          instruction_ptr(),
          operation :: binary_operation(),
          relative_base()
        ) ::
          state()
  def execute_binary_operation(state, parameter_modes, instruction_ptr, operation, relative_base) do
    program = state.program
    {arg1, arg2, res_idx} = get_binary_arguments(program, parameter_modes, instruction_ptr, relative_base)
    res = operation.(arg1, arg2)
    program = put_in(program.body, Map.put(program.body, res_idx, res))
    instruction_ptr = advance_instruction_ptr(instruction_ptr)

    %{state | program: program, instruction_ptr: instruction_ptr}
  end

  @spec get_binary_arguments(program(), [parameter_mode()], instruction_ptr(), relative_base()) ::
          {arg1 :: value(), arg2 :: value(), res_idx :: address()}
  def get_binary_arguments(program, parameter_modes, instruction_ptr, relative_base) do
    {arg1, arg2} = read_two_arguments(program, parameter_modes, instruction_ptr, relative_base)

    res_idx = Map.fetch!(program.body, instruction_ptr + 3) |> fetch_return_address(2, parameter_modes, relative_base)

    {arg1, arg2, res_idx}
  end

  @spec read_two_arguments(program(), [parameter_mode()], instruction_ptr(), relative_base()) :: {value(), value()}
  def read_two_arguments(program, parameter_modes, instruction_ptr, relative_base) do
    arg1_idx = Map.fetch!(program.body, instruction_ptr + 1)
    arg2_idx = Map.fetch!(program.body, instruction_ptr + 2)

    arg1 = fetch_parameter(program.body, arg1_idx, 0, parameter_modes, relative_base)
    arg2 = fetch_parameter(program.body, arg2_idx, 1, parameter_modes, relative_base)

    {arg1, arg2}
  end

  @spec fetch_parameter(body(), address() | value(), non_neg_integer(), [parameter_mode()], relative_base()) :: any
  def fetch_parameter(body, parameter_idx_or_value, mode_idx, parameter_modes, relative_base) do
    case Enum.at(parameter_modes, mode_idx, 0) do
      @position_mode -> Map.get(body, parameter_idx_or_value, 0)
      @immediate_mode -> parameter_idx_or_value
      @relative_mode -> Map.get(body, relative_base + parameter_idx_or_value, 0)
    end
  end

  @spec fetch_return_address(address() | value(), non_neg_integer(), [parameter_mode()], relative_base()) ::
          address() | no_return()
  def fetch_return_address(parameter_idx_or_value, mode_idx, parameter_modes, relative_base) do
    case Enum.at(parameter_modes, mode_idx, 0) do
      @position_mode -> parameter_idx_or_value
      @immediate_mode -> raise "return address cannot be in immediate mode"
      @relative_mode -> relative_base + parameter_idx_or_value
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
