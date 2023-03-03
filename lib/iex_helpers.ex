defmodule IexHelpers do
  alias OpenBook.Fitness.NutritionCategory
  alias OpenBook.Fitness
  alias OpenBook.Repo

  @manually_in_repl_user_id 0

  @moduledoc """
  This module is not for production code, just to make using IEX easier.

  `use IexHelpers` in your iex repl to get some helpful aliases for you.

  Additional iex-only helpers can be placed here (eg. to help inspect logs manually in prod).
  """

  defmacro __using__(_) do
    quote do
      import Ecto.Query

      alias OpenBook.Repo

      alias OpenBook.Accounts
      alias OpenBook.Accounts.Friend
      alias OpenBook.Accounts.User
      alias OpenBook.Accounts.VerificationCode
      alias OpenBook.DateHelpers
      alias OpenBook.Fitness
      alias OpenBook.Fitness.ExerciseCategory
      alias OpenBook.Fitness.ExerciseEntry
      alias OpenBook.Fitness.NutritionCategory
      alias OpenBook.Fitness.NutritionEntry
      alias OpenBook.Share
      alias OpenBook.Share.DayStatsLink

      :ok
    end
  end

  def insert_default_exercise_categories!() do
    default_exercise_categories_params = [
      %{name: "Cardio", measurement_kind: :minutes, icon_css_class: "fas fa-running"},
      %{name: "Climbing", measurement_kind: :minutes, icon_css_class: "fas fa-mountain"},
      %{name: "Lifting Weights", measurement_kind: :minutes, icon_css_class: "fas fa-dumbbell"},
      %{name: "Tennis", measurement_kind: :minutes, icon_css_class: "fas fa-table-tennis"},
      %{name: "Hiking", measurement_kind: :minutes, icon_css_class: "fas fa-hiking"},
      %{name: "Snowboarding", measurement_kind: :minutes, icon_css_class: "fas fa-snowboarding"},
      %{name: "Yoga", measurement_kind: :minutes},
      %{name: "Push-ups", measurement_kind: :repetitions},
      %{name: "Pull-ups", measurement_kind: :repetitions},
      %{name: "Chin-ups", measurement_kind: :repetitions},
      %{name: "Sit-ups", measurement_kind: :repetitions},
      %{name: "Hanging Leg Raises", measurement_kind: :repetitions}
    ]

    Repo.transaction(fn ->
      for params <- default_exercise_categories_params do
        Fitness.insert_new_exercise_category!(@manually_in_repl_user_id, params)
      end
    end)
  end

  def insert_default_nutrition_categories!() do
    default_nutrition_categories_params = [
      %{name: "Meal", icon_css_class: "fas fa-hamburger", calorie_options: Enum.map(3..20, &(&1 * 100))},
      %{name: "Drinks", icon_css_class: "fas fa-glass-martini", calorie_options: Enum.map(1..40, &(&1 * 50))},
      %{name: "Snacks", icon_css_class: "fas fa-carrot", calorie_options: Enum.map(1..40, &(&1 * 50))},
      %{name: "Dessert", icon_css_class: "fas fa-ice-cream", calorie_options: Enum.map(1..40, &(&1 * 50))}
    ]

    Repo.transaction(fn ->
      for params <- default_nutrition_categories_params do
        Fitness.insert_new_nutrition_category!(@manually_in_repl_user_id, params)
      end
    end)
  end

  # To play around with calorie option defaults for each category.
  def update_nutriton_category_calorie_selections!() do
    updates = [{"Meal", 225..2000//25}, {"Drinks", 25..2000//25}, {"Snacks", 25..2000//25}, {"Dessert", 25..2000//25}]

    for {name, new_calorie_options} <- updates do
      IO.inspect("updating #{name}...")

      Repo.get_by!(NutritionCategory, name: name)
      |> Ecto.Changeset.change(calorie_options: Enum.to_list(new_calorie_options))
      |> Repo.update!()
    end

    :ok
  end
end
