defmodule OpenBook.Share.DayStatsLink do
  use Ecto.Schema
  import Ecto.Changeset

  alias OpenBook.Accounts.VerificationCode

  schema "day_stats_links" do
    field :date, :date
    field :code, :string
    field :user_id, :id

    timestamps()
  end

  def new_link_changeset(by_user_id, date) do
    changeset(%__MODULE__{}, %{date: date})
    |> put_change(:user_id, by_user_id)
    |> put_change(:code, VerificationCode.generate_url_friendly_verification_code(human_friendly: false))
  end

  @doc false
  def changeset(day_stats_link, attrs) do
    day_stats_link
    |> cast(attrs, [:date])
    |> validate_required([:date])
  end
end
