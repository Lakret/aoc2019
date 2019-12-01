defmodule Aoc2019 do
  @moduledoc """
  Documentation for Aoc2019.
  """

  @inputs_dir "priv/inputs/"

  @doc """
  Reads input file for the specified `day`.

  Optionally, accepts `is_second_part` boolean. If set to true,
  will read the `_part2` file instead.

  Returns the contents of the file.
  """
  @spec read_input(day :: non_neg_integer(), is_second_part :: boolean()) :: String.t()
  def read_input(day, is_second_part \\ false)
      when is_integer(day) and is_boolean(is_second_part) do
    path_to_file = "day" <> to_string(day)
    path_to_file = if is_second_part, do: path_to_file <> "_part2", else: path_to_file
    path_to_file = path_to_inputs() |> Path.join(path_to_file)

    File.read!(path_to_file)
  end

  defp path_to_inputs() do
    Path.join(File.cwd!(), @inputs_dir)
  end
end
