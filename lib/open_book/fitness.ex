defmodule OpenBook.Fitness do
  import Ecto.Query

  alias OpenBook.Fitness.ExerciseCategory
  alias OpenBook.Fitness.NutritionCategory
  alias OpenBook.Fitness.NutritionEntry
  alias OpenBook.LittleLogger, as: LL
  alias OpenBook.QueryBuilders, as: QB
  alias OpenBook.Repo

  defdelegate human_readable_nutrition_and_calorie_selection(category_name, approx_calorie_count), to: NutritionCategory

  defdelegate human_readable_exercise_selection(exercise_category, intensity_level, exercise_measurement),
    to: ExerciseCategory

  # DB Mutations

  def insert_new_nutrition_entry!(
        by_user_id,
        params = %{nutrition_category_id: _, calorie_estimate: _, local_datetime: _}
      ) do
    LL.info_event("insert_new_nutrition_entry!", Map.merge(params, %{by_user_id: by_user_id}))

    params = Map.merge(params, %{user_id: by_user_id})

    NutritionEntry.new_entry_changeset(params)
    |> Repo.insert!()
  end

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
    |> QB.ordered_by(asc: :id)
    |> Repo.all()
  end

  def fetch_all_exercise_categories() do
    from(ec in ExerciseCategory)
    |> QB.ordered_by(asc: :id)
    |> Repo.all()
  end
end
