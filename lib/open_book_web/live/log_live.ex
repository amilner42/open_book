defmodule OpenBookWeb.LogLive do
  @moduledoc """
  The LiveView for the journal page where one enters data.

  Assigns:
    - kind: "exercise" | "nutrition"
  """
  use OpenBookWeb, :live_view

  alias OpenBook.LittleLogger, as: LL

  @default_kind "nutrition"

  def mount(_params, %{"user_id" => user_id}, socket) do
    LL.metadata_add_current_user_id(user_id)

    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    selected_kind = params["kind"] || @default_kind

    socket =
      socket
      |> assign(:kind, selected_kind)

    {:noreply, socket}
  end

  ## Render

  def render(assigns) do
    ~H"""
    Log Page.
    """
  end

  ## Handle Events
end
