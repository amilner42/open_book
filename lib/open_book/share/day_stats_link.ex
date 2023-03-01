defmodule OpenBook.Share.DayStatsLink do
  use Ecto.Schema
  import Ecto.Changeset

  schema "day_stats_links" do
    field :date, :date
    field :code, :string
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(day_stats_link, attrs) do
    day_stats_link
    |> cast(attrs, [:date, :code])
    |> validate_required([:date, :code])
  end
end
