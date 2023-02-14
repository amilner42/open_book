defmodule OpenBook.Accounts.User do
  use Ecto.Schema

  schema "users" do
    field :phone, :string
    field :display_name, :string

    timestamps()
  end
end
