defmodule OpenBookWeb.HomeLive do
  use OpenBookWeb, :live_view

  alias OpenBook.Accounts
  alias OpenBook.LittleLogger, as: LL

  def mount(_params, %{"user_id" => user_id}, socket) do
    LL.metadata_add_current_user_id(user_id)
    LL.metadata_add_current_page("HomeLive")
    LL.info_event("mount")

    user = Accounts.get_user!(user_id)

    socket =
      socket
      |> assign(:user, user)

    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    LL.info_event("handle_params", params)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <section class="section">
      <p class="title is-size-4">
        Coming Soon - Home Page
      </p>
    </section>
    """
  end
end
