defmodule OpenBookWeb.ViewUtils do
  @moduledoc """
  A place to keep utils helpful for views.
  """

  @doc ~S"""
  Conditionally add classes.

  ## Examples:

    iex> OpenBookWeb.ViewUtils.class_list("always-class", %{})
    "always-class"

    iex> OpenBookWeb.ViewUtils.class_list("always-class", %{"also-this-class": true, "but-not-this-class": false})
    "always-class also-this-class"
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
