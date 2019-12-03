defmodule Aoc2019.Day01 do
  import Aoc2019

  @spec solve_part_one() :: non_neg_integer() | no_return()
  def solve_part_one() do
    parse_input()
    |> Enum.map(&fuel_requirement/1)
    |> Enum.sum()
  end

  @spec solve_part_two() :: non_neg_integer() | no_return()
  def solve_part_two() do
    parse_input()
    |> Enum.map(&fuel_requirement_accounting_for_the_fuel/1)
    |> Enum.sum()
  end

  # Helpers

  @doc false
  @spec parse_input :: [non_neg_integer()] | no_return()
  def parse_input() do
    read_input(1)
    |> String.split("\n")
    |> Enum.map(fn line ->
      {mass, ""} = Integer.parse(line)
      mass
    end)
  end

  @doc """
  Calculates the fuel requirement based on the `mass`.

  Assumes that `mass` is >= 6, otherwise a negative number will be returned.

  ## Examples

      iex> import Aoc2019.Day01
      iex> fuel_requirement(12)
      2
      iex> fuel_requirement(14)
      2
      iex> fuel_requirement(1969)
      654
      iex> fuel_requirement(100756)
      33583

  """
  def fuel_requirement(mass) when is_integer(mass) do
    :erlang.trunc(mass / 3) - 2
  end

  @doc """
  Calculates fuel requirement for the provided `mass`, accounting for
  the mass of the added fuel itself.

  ## Examples

      iex> import Aoc2019.Day01
      iex> fuel_requirement_accounting_for_the_fuel(14)
      2
      iex> fuel_requirement_accounting_for_the_fuel(1969)
      966
      iex> fuel_requirement_accounting_for_the_fuel(100756)
      50346

  """
  @spec fuel_requirement_accounting_for_the_fuel(mass :: non_neg_integer()) :: non_neg_integer()
  def fuel_requirement_accounting_for_the_fuel(mass) when is_integer(mass) do
    fuel_requirement(mass)
    |> Stream.unfold(fn
      n when n > 0 -> {n, fuel_requirement(n)}
      _ -> nil
    end)
    |> Enum.sum()
  end
end
