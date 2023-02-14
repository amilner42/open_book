defmodule OpenBook.Repo.Migrations.AddUsersTable do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:phone, :string, null: false)
      add(:display_name, :string, null: false)

      timestamps()
    end

    create(index(:users, [:phone]))
  end
end
