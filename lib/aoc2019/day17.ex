defmodule Aoc2019.Day17 do
  import Aoc2019

  alias Aoc2019.Intcode

  require Logger

  def solve_part_one() do
    view =
      read_input(17)
      |> Intcode.execute_program()
      |> Map.fetch!(:outputs)

    Logger.info(['\n' | view])

    parse(view)
    |> sum_of_alignments()
  end

  @doc """
  Manually established path:

  ```
  L,10,L,12,R,6,R,10,L,4,L,4,L,12,L,10,L,12,R,6,R,10,L,4,L,4,L,12,L,10,L,12,R,6,L,10,R,10,
  R,6,L,4,R,10,L,4,L,4,L,12,L,10,R,10,R,6,L,4,L,10,L,12,R,6,L,10,R,10,R,6,L,4
  ```

  One possible arrangement:

  ```
  L,10,L,12,R,6,
  R,10,L,4,L,4,L,12,
  L,10,L,12,R,6,
  R,10,L,4,L,4,L,12,
  L,10,L,12,R,6,
  L,10,R,10,R,6,L,4,
  R,10,L,4,L,4,L,12,
  L,10,R,10,R,6,L,4,
  L,10,L,12,R,6,
  L,10,R,10,R,6,L,4
  ```

  which can be encoded as `A,B,A,B,A,C,B,C,A,C`, where:

    - A is `L,10,L,12,R,6`
    - B is `R,10,L,4,L,4,L,12`
    - C is `L,10,R,10,R,6,L,4`

  """
  def solve_part_two() do
    program = read_input(17) |> wake_up_program()

    main = "A,B,A,B,A,C,B,C,A,C\n"
    a = "L,10,L,12,R,6\n"
    b = "R,10,L,4,L,4,L,12\n"
    c = "L,10,R,10,R,6,L,4\n"
    continuous_feed? = "n\n"

    [dust_count] = movement_interface(program, [main, a, b, c, continuous_feed?], no_print: true)

    dust_count
  end

  # Helpers

  def wake_up_program(program) do
    [_head | tail] = String.split(program, ",")
    Enum.join(["2" | tail], ",")
  end

  def movement_interface(program, input_buffer, opts \\ []) do
    Intcode.execute_program_with_io_adapter(program, [], :yield, :yield)
    |> movement_interface(input_buffer, [], opts)
  end

  def movement_interface(state, input_buffer, output_buffer, opts) do
    no_print = Keyword.get(opts, :no_print, false)

    case state do
      # flush buffer on newline
      {:output, 10, _, cont} ->
        output_buffer = Enum.reverse(output_buffer)

        if !no_print, do: IO.puts('~~ |' ++ output_buffer)

        movement_interface(cont.(), input_buffer, [], opts)

      {:output, output, _, cont} ->
        movement_interface(cont.(), input_buffer, [output | output_buffer], opts)

      {:input, _, _cont} ->
        {input, input_buffer} =
          case input_buffer do
            [] ->
              input = IO.gets("##> ")
              {input, []}

            [input | rest] when is_binary(input) ->
              if !no_print, do: IO.puts("##> #{input}")

              {input, rest}
          end

        state = Intcode.input_string_as_char_codes_in_yield_mode(state, input)

        movement_interface(state, input_buffer, [], opts)

      %{body: _body, outputs: _outputs} ->
        if !no_print, do: IO.puts('~> |' ++ output_buffer)
        output_buffer
    end
  end

  @robot_directions %{
    94 => :up,
    62 => :right,
    60 => :left,
    86 => :down
  }

  def parse(view) when is_list(view) do
    {res, {_, max_y}} =
      Enum.reduce(view, {%{scaffolds: %{}, max_x: nil, max_y: nil, robot: nil}, {0, 0}}, fn
        # '.'
        46, {res, {x, y}} ->
          {res, {x + 1, y}}

        # '/n'
        10, {%{max_x: max_x} = res, {x, y}} ->
          res = if is_nil(max_x), do: %{res | max_x: x - 1}, else: res
          {res, {0, y + 1}}

        # '#'
        35, {%{scaffolds: scaffolds} = res, {x, y}} ->
          scaffolds = Map.put(scaffolds, {x, y}, :scaffold)
          res = Map.put(res, :scaffolds, scaffolds)

          {res, {x + 1, y}}

        # <, >, ^, or v
        robot_char, {%{scaffolds: scaffolds} = res, {x, y}} ->
          direction = Map.fetch!(@robot_directions, robot_char)

          scaffolds = Map.put(scaffolds, {x, y}, :scaffold)
          robot = %{coordinates: {x, y}, direction: direction}
          res = %{res | scaffolds: scaffolds, robot: robot}

          {res, {x + 1, y}}
      end)

    Map.put(res, :max_y, max_y - 2)
  end

  def sum_of_alignments(%{scaffolds: scaffolds, max_x: max_x, max_y: max_y}) do
    coordinates = for x <- 0..max_x, y <- 0..max_y, do: {x, y}

    Enum.filter(coordinates, &intersection?(&1, scaffolds))
    |> Enum.map(fn {x, y} -> x * y end)
    |> Enum.sum()
  end

  def intersection?({x, y}, scaffolds) do
    scaffolds[{x, y}] && scaffolds[{x - 1, y}] && scaffolds[{x + 1, y}] && scaffolds[{x, y - 1}] &&
      scaffolds[{x, y + 1}]
  end
end
