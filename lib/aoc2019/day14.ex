defmodule Aoc2019.Day14 do
  import Aoc2019

  require Logger

  @spec solve_part_one() :: non_neg_integer()
  def solve_part_one() do
    {ore, _unused} =
      read_input(14)
      |> parse_reactions()
      |> find_total_ore("FUEL", 1)

    ore
  end

  @spec solve_part_two() :: non_neg_integer()
  def solve_part_two() do
    reactions =
      read_input(14)
      |> parse_reactions()

    maximum_possible(reactions, "FUEL", 1_000_000_000_000)
  end

  # Parser

  @type compound :: String.t()
  @type quantity :: non_neg_integer()
  @type reaction :: %{reagents: [{compound, quantity}], yield: quantity}
  @type reactions :: %{compound => reaction}

  @spec parse_reactions(String.t()) :: reactions()
  def parse_reactions(reactions) when is_binary(reactions) do
    String.split(reactions, "\n", trim: true)
    |> Enum.map(&parse_reaction/1)
    |> Enum.reduce(%{}, fn {reagents, {product, product_yield}}, reactions ->
      Map.put(reactions, product, %{reagents: reagents, yield: product_yield})
    end)
  end

  @spec parse_reaction(String.t()) ::
          {reagents :: [{compound, quantity}], product :: {compound, quantity}}
  def parse_reaction(reaction) do
    [reagents, product] = String.split(reaction, " => ")

    reagents = String.split(reagents, ", ") |> Enum.map(&parse_compound_quantity/1)
    product = parse_compound_quantity(product)

    {reagents, product}
  end

  @spec parse_compound_quantity(String.t()) :: {compound, quantity}
  def parse_compound_quantity(compound_quantity) do
    [quantity, compound] = String.split(compound_quantity, " ")
    {quantity, ""} = Integer.parse(quantity)
    {compound, quantity}
  end

  # Solver

  @ore "ORE"

  @type unused_compounds :: %{compound => quantity}

  @doc """
  Finds total ore required to synthesize `quantity` of `compound` via `reactions`.

  Returns a tuple of produced quantity of `compound`, and a map of `unused_compounds`.
  """
  @spec find_total_ore(reactions(), compound(), quantity(), unused_compounds()) :: {quantity(), unused_compounds()}
  def find_total_ore(reactions, compound, quantity, unused_compounds \\ %{}) do
    unused_quantity = unused_compounds[compound] || 0

    if unused_quantity >= quantity do
      still_unused = unused_quantity - quantity
      Logger.debug("to get #{quantity} #{compound}: using #{quantity} of unused (#{still_unused} still unused).")

      {0, Map.put(unused_compounds, compound, still_unused)}
    else
      %{reagents: reagents, yield: yield} = Map.fetch!(reactions, compound)

      quantity_to_synthesize = quantity - unused_quantity
      times = ceil(quantity_to_synthesize / yield)
      unused = times * yield - quantity_to_synthesize
      Logger.debug("(before reduce) unused: #{inspect(unused_compounds)}, current unused: #{unused}")

      {total_ore, unused_compounds} =
        Enum.reduce(reagents, {0, unused_compounds}, fn
          {@ore, ore_quantity}, {total_ore, unused_compounds} ->
            {total_ore + times * ore_quantity, unused_compounds}

          {compound, quantity}, {total_ore, unused_compounds} ->
            {add_ore, unused_compounds} = find_total_ore(reactions, compound, times * quantity, unused_compounds)
            Logger.debug("(in reduce) new unused: #{inspect(unused_compounds)}")

            {total_ore + add_ore, unused_compounds}
        end)

      unused_compounds = Map.put(unused_compounds, compound, unused)
      Logger.debug("to get #{quantity} #{compound}: #{times}x #{inspect(reagents)}")
      Logger.debug("\tunused compounds after: #{inspect(unused_compounds)}")

      {total_ore, unused_compounds}
    end
  end

  @doc """
  Finds the maximum possible `quantity` of `compound` produced via `reactions`
  from `total_ore` ore quantity.

  Uses binary search to maximize the output.
  """
  @spec maximum_possible(reactions(), compound(), quantity()) :: quantity()
  def maximum_possible(reactions, compound, total_ore) do
    binary_search(reactions, compound, total_ore, 0, total_ore, nil)
  end

  @spec binary_search(reactions(), compound(), quantity(), quantity(), quantity(), quantity() | nil) :: integer
  def binary_search(reactions, compound, total_ore, lower, upper, previous_guess \\ nil) do
    guess = floor((lower + upper) / 2)

    if guess == previous_guess do
      guess
    else
      {ore_requirement, _unused} = find_total_ore(reactions, compound, guess)

      Logger.debug("lower = #{lower}, upper = #{upper}, guess = #{guess}, ore_requirement = #{ore_requirement}")

      cond do
        ore_requirement < total_ore ->
          binary_search(reactions, compound, total_ore, guess, upper, guess)

        ore_requirement > total_ore ->
          binary_search(reactions, compound, total_ore, lower, guess, guess)

        ore_requirement == total_ore && lower - upper <= 1 ->
          guess

        ore_requirement == total_ore ->
          binary_search(reactions, compound, total_ore, min(guess, lower), min(guess + 1, upper), guess)
      end
    end
  end
end
