defmodule OpenBookWeb.PageController do
  use OpenBookWeb, :controller

  def index(conn, _params) do
    conn
    |> put_layout("hero.html")
    |> render("index.html")
  end
end
