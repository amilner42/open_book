defmodule OpenBookWeb.FeedLive do
  @moduledoc """
  The LiveView for the feed page which is essentially the home page, showing a list of
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
    Feed Page.
    """
  end

  ## Handle Events
end
