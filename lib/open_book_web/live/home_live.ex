defmodule OpenBookWeb.HomeLive do
  use OpenBookWeb, :live_view_connected

  alias OpenBook.Accounts
  alias OpenBook.LittleLogger, as: LL

  def mount_live(_params, %{"user_id" => user_id}, socket) do
    LL.metadata_add_current_user_id(user_id)
    LL.metadata_add_current_page("HomeLive")
    LL.info_event("mount_live")

    user = Accounts.get_user!(user_id)

    socket =
      socket
      |> assign(:user, user)

    {:ok, socket}
  end

  def handle_params_live(params, _url, socket) do
    LL.info_event("handle_params_live", params)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <section class="section">
      <p class="title is-size-4 has-text-black">
        Coming Soon - Home Page
      </p>
    </section>
    """
  end
end
