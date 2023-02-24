defmodule OpenBook.Repo.Migrations.CreateExerciseEntriesTable do
  use Ecto.Migration

  def change do
    create table(:exercise_entries) do
      add(:exercise_category_id, references(:exercise_categories, on_delete: :nothing),
        null: false
      )

      add(:user_id, references(:users, on_delete: :nothing), null: false)

      add(:measurement, :integer, null: false)
      add(:local_datetime, :naive_datetime, null: false)

      add(:intensity_level, :string)

      timestamps()
    end
  end
end
