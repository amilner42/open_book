defmodule OpenBook.Repo.Migrations.CreateFriendsTable do
  use Ecto.Migration

  def change do
    create table(:friends) do
      add(:user_1_id, references(:users, on_delete: :nothing), null: false)
      add(:user_2_id, references(:users, on_delete: :nothing), null: false)

      add(:has_exercise_open_book, :boolean, null: false)
      add(:has_nutrition_open_book, :boolean, null: false)

      timestamps()
    end

    create(index(:friends, [:user_1_id]))
    create(index(:friends, [:user_2_id]))
  end
end
