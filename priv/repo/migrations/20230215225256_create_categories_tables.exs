defmodule OpenBook.Repo.Migrations.CreateCategoriesTables do
  use Ecto.Migration

  def change do
    create table(:nutrition_categories) do
      add(:name, :string, null: false)
      add(:calorie_options, {:array, :integer}, null: false)

      add(:icon_css_class, :string)

      timestamps()
    end

    create table(:exercise_categories) do
      add(:name, :string, null: false)
      add(:measurement_kind, :string, null: false)

      add(:icon_css_class, :string)

      timestamps()
    end
  end
end
