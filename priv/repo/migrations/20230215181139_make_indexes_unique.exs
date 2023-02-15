defmodule OpenBook.Repo.Migrations.MakeIndexesUnique do
  use Ecto.Migration

  def change do
    drop(index(:users, [:phone]))
    create(unique_index(:users, [:phone]))

    drop(index(:verification_codes, [:code]))
    create(unique_index(:verification_codes, [:code]))
  end
end
