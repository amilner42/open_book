defmodule OpenBookWeb.BookLive do
  use OpenBookWeb, :live_view_connected

  alias OpenBook.Accounts
  alias OpenBook.LittleLogger, as: LL

  alias OpenBookWeb.Markdowns.FooterMenuBar

  def mount_live(_params, %{"user_id" => user_id}, socket) do
    LL.metadata_add_current_user_id(user_id)
    LL.metadata_add_current_page("BookLive")
    LL.info_event("mount_live")

    user = Accounts.get_user!(user_id)

    socket =
      socket
      |> assign(:user, user)
      |> assign(:active_share_day_modal_data, nil)

    {:ok, socket}
  end

  def handle_params_live(params, _url, socket) do
    LL.info_event("handle_params_live", params)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    Book LivePage.

    <div class="pt-6"> </div>
    <FooterMenuBar.footer_menu_bar active_tab={"book"}/>
    """
  end
end
