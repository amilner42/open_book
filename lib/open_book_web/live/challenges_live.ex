defmodule OpenBookWeb.ChallengesLive do
  use OpenBookWeb, :live_view_connected

  alias OpenBook.Accounts
  alias OpenBook.LittleLogger, as: LL

  alias OpenBookWeb.Markdowns.InnerBar

  def mount_live(_params, %{"user_id" => user_id}, socket) do
    LL.metadata_add_current_user_id(user_id)
    LL.metadata_add_current_page("ChallengesLive")
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
    <InnerBar.inner_bar active_tab={"challenges"}/>

    <section class="hero">
      <div class="hero-body has-text-centered">
        <div class="is-5 has-text-grey">
          <span class="icon" style="vertical-align: middle;">
            <i class="fas fa-code"></i>
          </span>
          <span style="vertical-align: middle;">
            under development
          </span>
        </div>
      </div>
    </section>
    """
  end
end
