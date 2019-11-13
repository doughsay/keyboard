defmodule InterfaceWeb.PageView do
  use InterfaceWeb, :view

  defp html_for_key({width, key_id}, active_keys) when is_atom(key_id),
    do:
      "<span class='key#{active?(key_id, active_keys)}' style='width: #{px_width(width)}px'></span>"

  defp html_for_key(key_id, active_keys) when is_atom(key_id),
    do: "<span class='key#{active?(key_id, active_keys)}' style='width: #{px_width(1)}px'></span>"

  defp html_for_key(width, _active_keys) when is_number(width),
    do: "<span class='spacer' style='width: #{px_width(width)}px'></span>"

  defp px_width(x), do: 40 * x

  defp active?(key_id, active_keys) do
    case active_keys do
      %{^key_id => _} -> " active"
      _ -> ""
    end
  end
end
