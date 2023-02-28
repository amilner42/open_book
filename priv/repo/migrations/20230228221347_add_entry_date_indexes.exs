defmodule OpenBook.Repo.Migrations.AddEntryDateIndexes do
  use Ecto.Migration

  def change do
    create(index(:nutrition_entries, [:local_datetime]))
    create(index(:exercise_entries, [:local_datetime]))
  end
end
