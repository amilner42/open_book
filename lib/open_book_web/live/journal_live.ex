defmodule OpenBookWeb.JournalLive do
  @moduledoc """
  The LiveView for the journal page where one enters data.
  """
  use OpenBookWeb, :live_view

  alias OpenBook.LittleLogger, as: LL

  def mount(_params, %{"user_id" => user_id}, socket) do
    LL.metadata_add_current_user_id(user_id)

    {:ok, socket}
  end

  ## Render

  def render(assigns) do
    ~H"""
    Journal Page.
    """
  end

  ## Handle Events
end
