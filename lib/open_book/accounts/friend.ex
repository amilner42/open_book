defmodule OpenBook.Accounts.Friend do
  use Ecto.Schema

  import Ecto.Changeset

  schema "friends" do
    belongs_to(:user_1, OpenBook.Accounts.User)
    belongs_to(:user_2, OpenBook.Accounts.User)

    field(:has_exercise_open_book, :boolean)
    field(:has_nutrition_open_book, :boolean)

    timestamps()
  end

  ## Changesets

  def changeset(user, params) do
    user
    |> cast(params, [:user_1_id, :user_2_id, :has_exercise_open_book, :has_nutrition_open_book])
    |> validate_required([:user_1_id, :user_2_id, :has_exercise_open_book, :has_nutrition_open_book])
  end
end
