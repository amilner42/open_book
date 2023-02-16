defmodule OpenBook.Fitness.ExerciseCategory do
  use Ecto.Schema

  import Ecto.Changeset

  @measurement_kinds [:amount, :duration]

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
end
