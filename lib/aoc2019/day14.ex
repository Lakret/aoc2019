defmodule Aoc2019.Day14 do
  import Aoc2019

  @spec solve_part_one() :: non_neg_integer()
  def solve_part_one() do
    read_input(14)
    |> parse_reactions()
    |> needed_ore("FUEL", 1)
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

  @spec needed_ore(reactions(), compound(), quantity()) :: quantity()
  def needed_ore(reactions, compound, quantity) do
    0
  end
end
