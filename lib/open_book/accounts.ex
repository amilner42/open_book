defmodule OpenBook.Accounts do
  alias OpenBook.Accounts.User
  alias OpenBook.Repo

  def get_user!(user_id) do
    Repo.get!(User, user_id)
  end

  def get_user(user_id) do
    Repo.get(User, user_id)
  end
end
