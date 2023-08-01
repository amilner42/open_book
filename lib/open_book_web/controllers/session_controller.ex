defmodule OpenBookWeb.SessionController do
  use OpenBookWeb, :controller

  alias OpenBook.Accounts
  alias OpenBook.LittleLogger, as: LL
  alias OpenBook.Plugs.Auth

  def login_through_url_with_verification_code(conn, %{"code" => code}) do
    LL.info_event("login_with_code", %{code: code})

    case Accounts.get_user_from_valid_verification_code(code) do
      nil ->
        LL.info_event("login_from_code_failure", %{code: code})

        conn
        |> Phoenix.Controller.put_flash(:error, "Invalid authentication code.")
        |> redirect(to: ~p"/")

      user ->
        LL.info_event("login_from_code_success", %{user_id: user.id})

        conn
        |> Auth.login(user)
        |> redirect(to: ~p"/home")
    end
  end

  def delete(conn, _) do
    Auth.logout(conn, %{redirect_to: ~p"/"})
  end
end
