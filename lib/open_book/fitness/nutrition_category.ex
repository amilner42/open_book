defmodule OpenBook.Fitness.NutritionCategory do
  use Ecto.Schema

  import Ecto.Changeset

  schema "nutrition_categories" do
    field(:name, :string)
    field(:calorie_options, {:array, :integer})

    field(:icon_css_class, :string)

    timestamps()
  end

  ## Changesets

  def new_category_changeset(params) do
    change(%__MODULE__{})
    |> cast(params, [:name, :calorie_options, :icon_css_class])
    |> validate_required([:name, :calorie_options])
    |> validate_length(:name, min: 3)
    |> validate_length(:calorie_options, min: 3)
  end
end
