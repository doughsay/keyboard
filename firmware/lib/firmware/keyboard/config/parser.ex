defmodule Firmware.Keyboard.Config.Parser do
  @moduledoc """
  Parses various kinds of config strings into keyboard config data structures.
  """

  @token_pattern ~r/^(:?k\d{3}|kc_[a-z0-9]+)$/

  @doc ~S"""
  Parses a given layout config string.

  ## Examples

      iex> parse!("k001 k002 k003\nk004 k005 k006")
      [[:k001, :k002, :k003], [:k004, :k005, :k006]]

      iex> parse!("k001 k002 k003\nk004")
      [[:k001, :k002, :k003], [:k004]]

      iex> parse!("kc_a   kc_spc   kc_ent")
      [[:kc_a, :kc_spc, :kc_ent]]
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
