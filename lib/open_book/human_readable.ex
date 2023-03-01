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

  @doc ~S"""
  Create a human-readable description of the calorie count.

  ## Examples:

    iex> OpenBook.HumanReadable.human_readable_calorie_description("I", nil)
    "I did not record any nutrition."

    iex> OpenBook.HumanReadable.human_readable_calorie_description("Charlie", 0)
    "Charlie did not record any nutrition."

    iex> OpenBook.HumanReadable.human_readable_calorie_description("Banafsheh", 500)
    "Banafsheh had around 500 calories."
  """
  def human_readable_calorie_description(who, nil), do: "#{who} did not record any nutrition."
  def human_readable_calorie_description(who, 0), do: "#{who} did not record any nutrition."
  def human_readable_calorie_description(who, calorie_estimate), do: "#{who} had around #{calorie_estimate} calories."

  @doc ~S"""
  Create a human-readable description of the given exercises.

  TODO(Arie): doctest
  """
  def human_readable_exercise_description(who, nil, _all_exercise_category_names_by_id), do: "#{who} did not exercise."

  def human_readable_exercise_description(
        who,
        measurement_by_exercise_category_id_and_intensity_tuple,
        all_exercise_category_names_by_id
      ) do
    if(measurement_by_exercise_category_id_and_intensity_tuple == %{}) do
      human_readable_exercise_description(who, nil, all_exercise_category_names_by_id)
    else
      readable_exercise_segments =
        Enum.map(measurement_by_exercise_category_id_and_intensity_tuple, fn {{exercise_category_id, intensity_level},
                                                                              measurement} ->
          exercise_category_name = Map.fetch!(all_exercise_category_names_by_id, exercise_category_id)
          human_readable_exercise_selection(exercise_category_name, intensity_level, measurement)
        end)

      # TODO : move readable_and_list to backend.
      readable_exercise_string = __MODULE__.readable_and_list(readable_exercise_segments)
      "#{who} did #{readable_exercise_string}"
    end
  end

  @doc """
  Create a human-readable description of the given exercise selection.

  ## Examples

  iex> OpenBook.HumanReadable.human_readable_exercise_selection("Snowboarding", :light, 30)
  "30 minutes of light snowboarding"

  iex> OpenBook.HumanReadable.human_readable_exercise_selection("Snowboarding", "regular", 60)
  "an hour of snowboarding"
  """
  def human_readable_exercise_selection(exercise_category_name, intensity_level, exercise_measurement) do
    hr_exercise_name = String.downcase(exercise_category_name)

    if intensity_level do
      hr_duration = human_readable_minutes(exercise_measurement)
      # String interp here to allow either atom/string for intensity level.
      hr_intensity_level = human_readable_intensity_level("#{intensity_level}")

      "#{hr_duration} of#{hr_intensity_level}#{hr_exercise_name}"
    else
      "#{exercise_measurement} #{hr_exercise_name}"
    end
  end

  # Private

  defp human_readable_intensity_level("light"), do: " light "
  defp human_readable_intensity_level("regular"), do: " "
  defp human_readable_intensity_level("intense"), do: " intense "

  defp human_readable_minutes(minutes) do
    cond do
      minutes < 60 ->
        "#{minutes} minutes"

      minutes == 60 ->
        "an hour"

      minutes < 120 ->
        "an hour and #{rem(minutes, 60)} minutes"

      rem(minutes, 60) == 0 ->
        "#{div(minutes, 60)} hours"

      true ->
        "#{div(minutes, 60)} hours and #{rem(minutes, 60)} minutes"
    end
  end
end
