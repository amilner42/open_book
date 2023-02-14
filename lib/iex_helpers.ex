defmodule IexHelpers do
  @moduledoc """
  This module is not for production code, just to make using IEX easier.

  `use IexHelpers` in your `iex` to get some helpful aliases for you.

  Additional iex-only helpers can be placed here (eg. to help inspect logs manually in prod).
  """

  defmacro __using__(_) do
    quote do
      import Ecto.Query

      alias OpenBook.Repo

      alias OpenBook.Accounts
      alias OpenBook.Accounts.User
      alias OpenBook.Accounts.VerificationCode
    end
  end
end
