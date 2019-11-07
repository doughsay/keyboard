defmodule Firmware.Layout do
  @moduledoc """
  Parses layout config strings into layout data structures.
  """

  @token_pattern ~r/^k\d{3}$/

  @doc """
  Parses a given layout config string.
  """
  def parse!(string) do
    string
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.trim()
      |> String.split(~r/\s+/)
      |> Enum.map(fn token ->
        unless Regex.match?(@token_pattern, token) do
          raise "Invalid token in layout config: #{token}"
        end

        String.to_atom(token)
      end)
    end)
  end
end
