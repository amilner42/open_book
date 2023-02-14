defmodule OpenBook.Accounts.User do
  use Ecto.Schema

  import Ecto.Changeset

  schema "users" do
    field(:phone, :string)
    field(:display_name, :string)

    timestamps()
  end

  ## Changesets

  def changeset(user, params) do
    user
    |> cast(params, [:display_name, :phone])
    |> validate_required([:display_name, :phone])
    |> unique_constraint(:phone)
  end
end
