defmodule OpenBookWeb.ViewUtils do
  @moduledoc """
  A place to keep utils helpful for views.
  """

  @doc """
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

  @doc ~S"""
  Create a human-readable list of things and-ed together.

  ## Examples:

    iex> OpenBookWeb.ViewUtils.readable_and_list([])
    ""

    iex> OpenBookWeb.ViewUtils.readable_and_list(["biking"])
    "biking"

    iex> OpenBookWeb.ViewUtils.readable_and_list(["biking", "climbing"])
    "biking and climbing"

    iex> OpenBookWeb.ViewUtils.readable_and_list(["biking", "climbing", "swimming"])
    "climbing, swimming, and biking"
  """
  def readable_and_list([]), do: ""
  def readable_and_list([single_string]), do: single_string
  def readable_and_list([first_string, second_string]), do: "#{first_string} and #{second_string}"

  def readable_and_list([first_string | rest_strings]) do
    "#{Enum.join(rest_strings, ", ")}, and #{first_string}"
  end
end
