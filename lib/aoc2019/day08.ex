defmodule Aoc2019.Day08 do
  import Aoc2019

  alias IO.ANSI

  @width 25
  @height 6

  @spec solve_part_one() :: Intcode.value()
  def solve_part_one() do
    layer =
      read_input(8)
      |> layers()
      |> Enum.min_by(&Enum.count(&1, fn ch -> ch == "0" end))

    Enum.count(layer, &(&1 == "1")) * Enum.count(layer, &(&1 == "2"))
  end

  def solve_part_two() do
    image =
      read_input(8)
      |> layers
      |> Enum.reduce(%{}, fn layer, image ->
        layer
        |> Enum.chunk_every(@width)
        |> Enum.with_index()
        |> Enum.reduce(image, fn {row, row_idx}, image ->
          Enum.with_index(row)
          |> Enum.reduce(image, fn {ch, col_idx}, image ->
            case ch do
              "0" -> Map.put_new(image, {row_idx, col_idx}, "■")
              "1" -> Map.put_new(image, {row_idx, col_idx}, "□")
              _ -> image
            end
          end)
        end)
      end)

    for row_idx <- 0..(@height - 1) do
      0..(@width - 1) |> Enum.map(&image[{row_idx, &1}]) |> Enum.join()
    end
    |> Enum.join("\n")
  end

  def layers(input) do
    input
    |> String.trim_trailing()
    |> String.graphemes()
    |> Enum.chunk_every(@width * @height)
  end
end
