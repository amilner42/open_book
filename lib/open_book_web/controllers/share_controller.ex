defmodule OpenBookWeb.ShareController do
  use OpenBookWeb, :controller

  alias OpenBook.Accounts
  alias OpenBook.DateHelpers
  alias OpenBook.Fitness
  alias OpenBook.LittleLogger, as: LL
  alias OpenBook.Share

  def share_day_stats(conn, %{"code" => code}) do
    LL.info_event("share_viewed", %{code: code, is_new_user: conn.assigns.current_user == nil})

    db_tasks = [
      Task.async(fn -> Fitness.fetch_all_exercise_category_names_by_id() end),
      Task.async(fn -> Share.get_day_stats_link_by_code!(code) end)
    ]

    [
      all_exercise_category_names_by_id,
      %{user_id: user_id, date: date}
    ] = Task.await_many(db_tasks)

    shared_user = Accounts.get_user!(user_id)

    # TODO(Arie): This is inefficient as it fetches all [inc. unused] friend data, but, whatevs.
    compressed_nutrition_and_exercise_entries =
      user_id
      |> Fitness.fetch_nutrition_and_exercise_entries_and_friends(%{
        from_local_datetime: DateHelpers.naive_start_of_day(date),
        to_local_datetime: DateHelpers.naive_end_of_day(date)
      })
      |> Fitness.compress_nutrition_and_exercise_entries()

    shared_readable_calorie_description =
      Fitness.get_readable_calorie_description(
        compressed_nutrition_and_exercise_entries,
        date,
        user_id,
        shared_user.display_name
      )

    shared_readable_exercise_description =
      Fitness.get_readable_exercise_description(
        compressed_nutrition_and_exercise_entries,
        date,
        user_id,
        shared_user.display_name,
        all_exercise_category_names_by_id
      )

    conn
    |> assign(:shared_readable_calorie_description, shared_readable_calorie_description)
    |> assign(:shared_readable_exercise_description, shared_readable_exercise_description)
    |> render("share_day_stats.html")
  end
end
