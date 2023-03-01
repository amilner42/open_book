defmodule OpenBook.Repo.Migrations.CreateDayStatsLinks do
  use Ecto.Migration

  def change do
    create table(:day_stats_links) do
      add :date, :date, null: false
      add :code, :string, null: false
      add :user_id, references(:users, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:day_stats_links, [:user_id])
    create index(:day_stats_links, [:code])
  end
end
