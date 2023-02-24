defmodule OpenBook.Fitness.NutritionEntry do
  use Ecto.Schema

  import Ecto.Changeset

  schema "nutrition_entries" do
    belongs_to(:nutrition_category, OpenBook.Fitness.NutritionCategory)
    belongs_to(:user, OpenBook.Accounts.User)

    field(:calorie_estimate, :integer)
    field(:local_datetime, :naive_datetime)

    timestamps()
  end

  ## Changesets

  def new_entry_changeset(params) do
    change(%__MODULE__{})
    |> cast(params, [:nutrition_category_id, :user_id, :calorie_estimate, :local_datetime])
    |> validate_required([:nutrition_category_id, :user_id, :calorie_estimate, :local_datetime])
    |> validate_number(:calorie_estimate, greater_than: 0)
  end
end
