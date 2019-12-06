defmodule Aoc2019.Day04 do
  @low_limit 171_309
  @high_limit 643_603

  @spec solve_part_one :: non_neg_integer()
  def solve_part_one() do
    @low_limit..@high_limit
    |> Enum.filter(&password?/1)
    |> Enum.count()
  end

  @spec solve_part_two :: non_neg_integer()
  def solve_part_two() do
    @low_limit..@high_limit
    |> Enum.filter(&stricter_password?/1)
    |> Enum.count()
  end

  # Helpers

  @doc false
  @spec password?(non_neg_integer()) :: boolean()
  def password?(number) when is_integer(number) do
    digits = as_digits(number)

    {identical_pair, no_decrease} =
      Enum.chunk_every(digits, 2, 1, :discard)
      |> Enum.reduce({false, true}, fn [x, y], {identical_pair, no_decrease} ->
        cond do
          x == y -> {true, no_decrease}
          x > y -> {identical_pair, false}
          true -> {identical_pair, no_decrease}
        end
      end)

    identical_pair && no_decrease
  end

  @doc false
  @spec stricter_password?(non_neg_integer()) :: boolean()
  def stricter_password?(number) do
    digits = as_digits(number)

    no_decrease =
      Enum.chunk_every(digits, 2, 1, :discard)
      |> Enum.reduce(true, fn [x, y], no_decrease ->
        if x > y do
          false
        else
          no_decrease
        end
      end)

    # short-circuit to avoid computing more expensive criterion
    no_decrease &&
      (
        chunks = Enum.chunk_every(digits, 4, 1, :discard)
        last_idx = length(chunks) - 1

        Enum.with_index(chunks)
        |> Enum.reduce(false, fn chunk, identical_pair ->
          case chunk do
            {[a, a, b, _c], 0} when a != b -> true
            {[_a, b, c, c], ^last_idx} when b != c -> true
            {[a, b, b, c], _} when a != b and b != c -> true
            _ -> identical_pair
          end
        end)
      )
  end

  @spec as_digits(non_neg_integer()) :: [non_neg_integer()]
  defp as_digits(number) do
    to_string(number)
    |> String.codepoints()
    |> Enum.map(fn digit ->
      {digit, ""} = Integer.parse(digit)
      digit
    end)
  end
end
