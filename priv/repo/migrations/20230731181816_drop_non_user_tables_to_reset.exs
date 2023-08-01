defmodule OpenBook.Repo.Migrations.DropNonUserTablesToReset do
  use Ecto.Migration

  def change do
    drop table(:nutrition_entries)
    drop table(:exercise_entries)
    drop table(:exercise_categories)
    drop table(:nutrition_categories)
    drop table(:friends)
    drop table(:day_stats_links)
  end
end
