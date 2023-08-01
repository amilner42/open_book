defmodule OpenBook.HumanReadable do
  @moduledoc """
  Some miscellaneous helpers to make things human-readable.
  """

  @doc ~S"""
  Create a human-readable list of things and-ed together.

  ## Examples:

    iex> OpenBook.HumanReadable.readable_and_list([])
    ""

    iex> OpenBook.HumanReadable.readable_and_list(["biking"])
    "biking"

    iex> OpenBook.HumanReadable.readable_and_list(["biking", "climbing"])
    "biking and climbing"

    iex> OpenBook.HumanReadable.readable_and_list(["biking", "climbing", "swimming"])
    "climbing, swimming, and biking"
  """
  def readable_and_list([]), do: ""
  def readable_and_list([single_string]), do: single_string
  def readable_and_list([first_string, second_string]), do: "#{first_string} and #{second_string}"

  def readable_and_list([first_string | rest_strings]) do
    "#{Enum.join(rest_strings, ", ")}, and #{first_string}"
  end
end
