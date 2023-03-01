defmodule OpenBook.Fitness do
  import Ecto.Query

  alias OpenBook.Accounts
  alias OpenBook.Fitness.ExerciseCategory
  alias OpenBook.Fitness.ExerciseEntry
  alias OpenBook.Fitness.NutritionCategory
  alias OpenBook.Fitness.NutritionEntry
  alias OpenBook.HumanReadable
  alias OpenBook.LittleLogger, as: LL
  alias OpenBook.QueryBuilders, as: QB
  alias OpenBook.Repo

  defdelegate human_readable_nutrition_and_calorie_selection(category_name, approx_calorie_count), to: NutritionCategory

  defdelegate intensity_levels(), to: ExerciseEntry

  # DB Mutations

  def insert_new_nutrition_entry!(
        by_user_id,
        params = %{nutrition_category_id: _, calorie_estimate: _, local_datetime: _}
      ) do
    params = Map.merge(params, %{user_id: by_user_id})
    LL.info_event("insert_new_nutrition_entry!", params)

    NutritionEntry.new_entry_changeset(params)
    |> Repo.insert!()
  end

  def insert_new_exercise_entry!(
        by_user_id,
        params = %{exercise_category_id: _, measurement: _, intensity_level: _, local_datetime: _}
      ) do
    params = Map.merge(params, %{user_id: by_user_id})
    LL.info_event("insert_new_exercise_entry!", params)

    ExerciseEntry.new_entry_changeset(params)
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

  # DB Queries

  def fetch_nutrition_and_exercise_entries_and_friends(
        by_user_id,
        params = %{from_local_datetime: _, to_local_datetime: _}
      ) do
    LL.info_event("fetch_nutrition_and_exercise_entries_and_friends", Map.merge(params, %{by_user_id: by_user_id}))

    db_tasks = [
      Task.async(fn -> fetch_nutrition_entries_and_friend_ids(by_user_id, params) end),
      Task.async(fn -> fetch_exercise_entries_and_friend_ids(by_user_id, params) end)
    ]

    [{nutrition_open_book_friend_ids, nutrition_entries}, {exercise_open_book_friend_ids, exercise_entries}] =
      Task.await_many(db_tasks)

    all_friend_ids = nutrition_open_book_friend_ids ++ exercise_open_book_friend_ids

    friend_by_id = Accounts.get_users_as_map(all_friend_ids)

    %{
      friend_by_id: friend_by_id,
      nutrition_open_book_friend_ids: nutrition_open_book_friend_ids,
      nutrition_entries: nutrition_entries,
      exercise_open_book_friend_ids: exercise_open_book_friend_ids,
      exercise_entries: exercise_entries
    }
  end

  def fetch_all_nutrition_categories() do
    from(nc in NutritionCategory)
    |> QB.ordered_by(asc: :id)
    |> Repo.all()
  end

  def fetch_all_exercise_category_names_by_id() do
    Enum.reduce(fetch_all_exercise_categories(), %{}, fn %{id: id, name: name}, result_acc ->
      Map.put(result_acc, id, name)
    end)
  end

  def fetch_all_exercise_categories() do
    from(ec in ExerciseCategory)
    |> QB.ordered_by(asc: :id)
    |> Repo.all()
  end

  # Helpers

  # Returns the following nested map structure:
  #
  # [
  #   %{
  #     <date> => %{
  #       <user_id> => %{
  #         measurement_by_exercise_category_id_and_intensity_tuple: %{
  #           {13, :light} => 20,
  #           {14, :intense} => 60,
  #           {14, :light} => 20,
  #           {21, nil} => 8
  #         },
  #         total_calorie_estimate: 1500
  #       }
  #     }
  #   },
  #   ...
  # ]
  def compress_nutrition_and_exercise_entries(%{
        nutrition_entries: nutrition_entries,
        exercise_entries: exercise_entries
      }) do
    result = %{}
    default_data = %{total_calorie_estimate: 0, measurement_by_exercise_category_id_and_intensity_tuple: %{}}

    # Merge in nutrition entries.
    result =
      Enum.reduce(nutrition_entries, result, fn %{
                                                  local_datetime: local_datetime,
                                                  user_id: user_id,
                                                  calorie_estimate: calorie_estimate
                                                },
                                                result_acc ->
        date = NaiveDateTime.to_date(local_datetime)

        update_in(result_acc, [Access.key(date, %{}), user_id], fn maybe_current_value ->
          current_value = maybe_current_value || default_data
          new_total_calorie_estimate = current_value.total_calorie_estimate + calorie_estimate

          %{current_value | total_calorie_estimate: new_total_calorie_estimate}
        end)
      end)

    # Merge in exercise entries.
    result =
      Enum.reduce(exercise_entries, result, fn %{
                                                 local_datetime: local_datetime,
                                                 user_id: user_id,
                                                 exercise_category_id: exercise_category_id,
                                                 intensity_level: intensity_level,
                                                 measurement: measurement
                                               },
                                               result_acc ->
        date = NaiveDateTime.to_date(local_datetime)

        update_in(result_acc, [Access.key(date, %{}), user_id], fn maybe_current_value ->
          current_value = maybe_current_value || default_data

          new_measurement_by_exercise_category_id_and_intensity_tuple =
            current_value.measurement_by_exercise_category_id_and_intensity_tuple
            |> Map.put_new({exercise_category_id, intensity_level}, 0)
            |> Map.update!({exercise_category_id, intensity_level}, fn total_measurement ->
              total_measurement + measurement
            end)

          %{
            current_value
            | measurement_by_exercise_category_id_and_intensity_tuple:
                new_measurement_by_exercise_category_id_and_intensity_tuple
          }
        end)
      end)

    result
  end

  def get_readable_calorie_description(compressed_nutrition_and_exercise_entries, date, user_id, who) do
    maybe_calories = get_in(compressed_nutrition_and_exercise_entries, [date, user_id, :total_calorie_estimate])

    HumanReadable.human_readable_calorie_description(who, maybe_calories)
  end

  def get_readable_exercise_description(
        compressed_nutrition_and_exercise_entries,
        date,
        user_id,
        who,
        all_exercise_category_names_by_id
      ) do
    measurement_by_exercise_category_id_and_intensity_tuple =
      get_in(compressed_nutrition_and_exercise_entries, [
        date,
        user_id,
        :measurement_by_exercise_category_id_and_intensity_tuple
      ])

    HumanReadable.human_readable_exercise_description(
      who,
      measurement_by_exercise_category_id_and_intensity_tuple,
      all_exercise_category_names_by_id
    )
  end

  # Private

  ## DB Queries

  defp fetch_nutrition_entries_and_friend_ids(
         by_user_id,
         params = %{
           from_local_datetime: from_local_datetime,
           to_local_datetime: to_local_datetime
         }
       ) do
    LL.info_event("fetch_nutrition_entries_and_friend_ids", Map.merge(params, %{by_user_id: by_user_id}))

    friend_ids =
      Accounts.get_nutrition_open_book_friend_id_mapset(by_user_id)
      |> MapSet.to_list()

    nutrition_entries =
      from(ne in NutritionEntry)
      |> QB.with_user_id([by_user_id | friend_ids])
      |> QB.gte_local_datetime(from_local_datetime)
      |> QB.lte_local_datetime(to_local_datetime)
      |> QB.ordered_by(desc: :local_datetime)
      |> Repo.all()

    {friend_ids, nutrition_entries}
  end

  defp fetch_exercise_entries_and_friend_ids(
         by_user_id,
         params = %{
           from_local_datetime: from_local_datetime,
           to_local_datetime: to_local_datetime
         }
       ) do
    LL.info_event("fetch_exercise_entries_and_friend_ids", Map.merge(params, %{by_user_id: by_user_id}))

    friend_ids =
      Accounts.get_exercise_open_book_friend_id_mapset(by_user_id)
      |> MapSet.to_list()

    exercise_entries =
      from(ee in ExerciseEntry)
      |> QB.with_user_id([by_user_id | friend_ids])
      |> QB.gte_local_datetime(from_local_datetime)
      |> QB.lte_local_datetime(to_local_datetime)
      |> QB.ordered_by(desc: :local_datetime)
      |> Repo.all()

    {friend_ids, exercise_entries}
  end
end
