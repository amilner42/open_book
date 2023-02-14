defmodule OpenBook.Repo.Migrations.AddVerficationCodesTable do
  use Ecto.Migration

  def change do
    create table(:verification_codes) do
      add(:code, :string, null: false)
      add(:user_id, references(:users, on_delete: :nothing), null: false)

      timestamps()
    end

    create(index(:verification_codes, [:code]))
  end
end
