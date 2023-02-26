defmodule OpenBookWeb.ViewUtils do
  @moduledoc """
  A place to keep utils helpful for views.
  """

  @doc """
  Conditionally add classes.

  Eg. `css_class = class_list("class-I-always-want", {"will-add": true, "wont-add": false})`
  """
  def class_list(base_class, boolean_by_class_name) do
    Enum.reduce(boolean_by_class_name, base_class, fn {class_name, should_include}, acc ->
      if should_include do
        "#{acc} #{class_name}"
      else
        acc
      end
    end)
  end
end
