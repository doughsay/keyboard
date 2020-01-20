defmodule Excalibur.Interface.ErrorView do
  use Phoenix.View,
    root: "lib/excalibur/interface/templates",
    namespace: Excalibur.Interface

  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
