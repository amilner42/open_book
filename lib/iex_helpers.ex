defmodule IexHelpers do
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
      alias OpenBook.Fitness.NutritionCategory
      alias OpenBook.Fitness.NutritionEntry

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
end
