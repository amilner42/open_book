defmodule OpenBook.Repo do
  use Ecto.Repo,
    otp_app: :open_book,
    adapter: Ecto.Adapters.Postgres
end
