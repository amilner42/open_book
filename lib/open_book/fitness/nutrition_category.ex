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

  ## Helpers

  # TODO(Arie): This will break if we change the categories in the DB. Poor dependency?
  def human_readable_nutrition_and_calorie_selection(category_name, approx_calorie_count) do
    case category_name do
      "Meal" ->
        "I had a ~#{approx_calorie_count} calorie meal."

      "Drinks" ->
        "I had ~#{approx_calorie_count} calories of drinks."

      "Snacks" ->
        "I had ~#{approx_calorie_count} calories of snacks."

      "Dessert" ->
        "I had a ~#{approx_calorie_count} calorie dessert."
    end
  end
end
