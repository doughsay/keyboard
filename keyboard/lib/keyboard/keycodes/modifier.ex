defmodule Keyboard.Keycodes.Modifier do
  @enforce_keys [:id, :value, :description]
  defstruct [:id, :value, :description]

  @modifiers [
    {0x01, :kc_lctl, "Left Control"},
    {0x02, :kc_lsft, "Left Shift"},
    {0x04, :kc_lalt, "Left Alt"},
    {0x08, :kc_lspr, "Left Super"},
    {0x10, :kc_rctl, "Right Control"},
    {0x20, :kc_rsft, "Right Shift"},
    {0x40, :kc_ralt, "Right Alt"},
    {0x80, :kc_rspr, "Right Super"}
  ]

  @doc """
  Gets a modifier by its ID.

  A modifier ID is an `Atom`, e.g. `:kc_lctl`. This function returns a modifier
  struct by a given ID.

  ## Examples

      iex> from_id!(:kc_lctl)
      #Keyboard.Keycodes.Modifier<Left Control>

      iex> from_id!(:kc_rspr)
      #Keyboard.Keycodes.Modifier<Right Super>
  """
  def from_id!(id)

  for {value, id, description} <- @modifiers do
    def from_id!(unquote(id)) do
      struct!(__MODULE__,
        id: unquote(id),
        value: unquote(value),
        description: unquote(description)
      )
    end
  end

  def from_id!(id), do: raise("Invalid Modifier ID: #{id}")
end

defimpl Inspect, for: Keyboard.Keycodes.Modifier do
  import Inspect.Algebra

  def inspect(key, _opts) do
    concat(["#Keyboard.Keycodes.Modifier<", key.description, ">"])
  end
end
