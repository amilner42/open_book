defmodule OpenBook.Repo.Migrations.CreateNutritionEntriesTable do
  use Ecto.Migration

  def change do
    create table(:nutrition_entries) do
      add(:nutrition_category_id, references(:nutrition_categories, on_delete: :nothing),
        null: false
      )

      add(:user_id, references(:users, on_delete: :nothing), null: false)

      add(:calorie_estimate, :integer, null: false)
      add(:local_datetime, :naive_datetime, null: false)

      timestamps()
    end
  end
end
