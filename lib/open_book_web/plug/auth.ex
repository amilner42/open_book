defmodule OpenBook.Plugs.Auth do
  import Plug.Conn

  alias OpenBook.LittleLogger, as: LL

  alias OpenBookWeb.HomeLive
  alias OpenBookWeb.Router.Helpers, as: Routes

  # Plugs

  # Puts required metadata into the `assigns` from the user session.
  #
  # Metadata:
  #   - assigns[:current_user] = user | nil
  def get_current_user_from_session(conn, _opts) do
    user_id = get_session(conn, :user_id)

    cond do
      # This is for easier testing, if there is a user already in the connection, we honor it. This way tests can
      # just include a user in the assigns and we don't need any elobrate mocking.
      user = conn.assigns[:current_user] ->
        put_current_user(conn, user)

      user = user_id && OpenBook.Accounts.get_user(user_id) ->
        put_current_user(conn, user)

      true ->
        put_current_user(conn, nil)
    end
  end

  # Halts the connection and redirects to the index page if there is no `current_user` in the `assigns`.
  def authenticate_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> Phoenix.Controller.put_flash(:error, "You must be logged in to access that page")
      |> Phoenix.Controller.redirect(to: default_logged_out_route(conn))
      |> halt()
    end
  end

  def redirect_to_if_not_user(conn, %{
        redirect_to: redirect_to,
        allowed_user_ids: allowed_user_ids
      }) do
    allow_through = conn.assigns.current_user && conn.assigns.current_user.id in allowed_user_ids

    if allow_through do
      conn
    else
      conn
      |> Phoenix.Controller.redirect(to: redirect_to)
      |> halt()
    end
  end

  def redirect_if_logged_in(conn, opts \\ %{}) do
    unless conn.assigns.current_user do
      conn
    else
      redirect_to = opts[:redirect_to] || default_logged_in_route(conn)

      conn
      |> Phoenix.Controller.redirect(to: redirect_to)
      |> halt()
    end
  end

  # Auth Helpers

  def login(conn, user) do
    conn
    |> put_current_user(user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  def logout(conn, opts \\ %{}) do
    conn = configure_session(conn, drop: true)

    unless opts[:and_redirect_to_home_page] do
      conn
    else
      conn
      |> Phoenix.Controller.redirect(to: default_logged_out_route(conn))
      |> halt()
    end
  end

  # Private

  defp put_current_user(conn, user) do
    if(user) do
      LL.metadata_add_current_user_id(user.id)
    end

    # In the future, this is the place to create user tokens (eg. for web sockets).
    conn
    |> assign(:current_user, user)
  end

  # Default redirect routes for logged-in/out users.
  defp default_logged_in_route(conn), do: Routes.live_path(conn, HomeLive)
  defp default_logged_out_route(conn), do: Routes.page_path(conn, :index)
end
