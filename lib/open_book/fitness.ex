defmodule OpenBook.Fitness do
  import Ecto.Query

  alias OpenBook.Fitness.ExerciseCategory
  alias OpenBook.Fitness.NutritionCategory
  alias OpenBook.LittleLogger, as: LL
  alias OpenBook.Repo

  # DB Mutations

  def insert_new_nutrition_category!(by_user_id, params = %{name: _, calorie_options: _}) do
    LL.info_event("insert_new_nutrition_category!", Map.merge(params, %{by_user_id: by_user_id}))

    NutritionCategory.new_category_changeset(params)
    |> Repo.insert!()
  end

  def insert_new_exercise_category!(by_user_id, params = %{name: _, measurement_kind: _}) do
    LL.info_event("insert_new_exercise_category!", Map.merge(params, %{by_user_id: by_user_id}))

    ExerciseCategory.new_category_changeset(params)
    |> Repo.insert!()
  end

  ## DB Queries

  def fetch_all_nutrition_categories() do
    from(nc in NutritionCategory)
    |> nutrition_categories_ordered_by(asc: :created_at)
  end

  # Private

  ## Query Builders

  defp nutrition_categories_ordered_by(query, order_by) do
    from(nc in query, order_by: ^order_by)
  end
end
