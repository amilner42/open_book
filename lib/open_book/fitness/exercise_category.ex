defmodule OpenBook.Fitness.ExerciseCategory do
  use Ecto.Schema

  import Ecto.Changeset

  @measurement_kinds [:repetitions, :minutes]

  schema "exercise_categories" do
    field(:name, :string)
    field(:measurement_kind, Ecto.Enum, values: @measurement_kinds)

    field(:icon_css_class, :string)

    timestamps()
  end

  ## Changesets

  def new_category_changeset(params) do
    change(%__MODULE__{})
    |> cast(params, [:name, :measurement_kind, :icon_css_class])
    |> validate_required([:name, :measurement_kind])
    |> validate_length(:name, min: 3)
    |> validate_inclusion(:measurement_kind, @measurement_kinds)
  end

  ## Helpers

  def human_readable_exercise_selection(exercise_category, intensity_level, exercise_measurement) do
    hr_exercise_name = String.downcase(exercise_category.name)

    if intensity_level do
      human_readable_intensity_level(intensity_level)
      hr_duration = human_readable_minutes(exercise_measurement)
      hr_intensity_level = human_readable_intensity_level(intensity_level)

      "I did #{hr_duration} of #{hr_intensity_level} #{hr_exercise_name}"
    else
      "I did #{exercise_measurement} #{hr_exercise_name}"
    end
  end

  # Private

  defp human_readable_intensity_level("light"), do: "light"
  defp human_readable_intensity_level("regular"), do: ""
  defp human_readable_intensity_level("intense"), do: "intense"

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
