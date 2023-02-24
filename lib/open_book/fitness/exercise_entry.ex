defmodule OpenBook.Fitness.ExerciseEntry do
  use Ecto.Schema

  import Ecto.Changeset

  @intensity_levels [:light, :regular, :intense]

  schema "exercise_entries" do
    belongs_to(:exercise_category, OpenBook.Fitness.ExerciseCategory)
    belongs_to(:user, OpenBook.Accounts.User)

    field(:intensity_level, Ecto.Enum, values: @intensity_levels)
    field(:measurement, :integer)

    field(:local_datetime, :naive_datetime)

    timestamps()
  end

  ## Changesets

  def new_entry_changeset(params) do
    change(%__MODULE__{})
    |> cast(params, [:exercise_category_id, :user_id, :intensity_level, :measurement, :local_datetime])
    |> validate_required([:exercise_category_id, :user_id, :measurement, :local_datetime])
    |> validate_number(:measurement, greater_than: 0)
  end

  ## Helpers

  def intensity_levels() do
    @intensity_levels
  end
end
