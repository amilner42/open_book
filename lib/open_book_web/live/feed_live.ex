defmodule OpenBookWeb.FeedLive do
  @moduledoc """
  The LiveView for the feed page which is essentially the home page, showing a list of
  """
  use OpenBookWeb, :live_view_connected

  import Phoenix.Component

  alias OpenBook.LittleLogger, as: LL
  alias OpenBookWeb.ExerciseLogLive
  alias OpenBookWeb.NutritionLogLive
  alias OpenBookWeb.ViewUtils

  @top_bar_stats_tab "stats"
  @top_bar_history_tab "history"
  @top_bar_tabs [@top_bar_stats_tab, @top_bar_history_tab]

  def mount_live(_params, %{"user_id" => user_id}, socket) do
    LL.metadata_add_current_user_id(user_id)

    {:ok, socket}
  end

  def handle_params_live(params, _url, socket) do
    # Params
    socket =
      socket
      |> assign(:params, params)

    # Top Bar Tab

    selected_top_bar_tab =
      if params["stbt"] in @top_bar_tabs do
        params["stbt"]
      else
        @top_bar_stats_tab
      end

    socket =
      socket
      |> assign(:selected_top_bar_tab, selected_top_bar_tab)

    {:noreply, socket}
  end

  ## Handle Events

  def handle_event(
        "top_level_navigate",
        params = %{
          "top_bar_tab" => top_bar_tab
        },
        socket
      ) do
    LL.info_event("top_level_navigate", params)

    params = Map.merge(socket.assigns.params, %{stbt: top_bar_tab})
    to = Routes.live_path(OpenBookWeb.Endpoint, __MODULE__, params)

    socket =
      socket
      |> push_patch(to: to, replace: false)

    {:noreply, socket}
  end

  ## Render

  def render(assigns) do
    ~H"""
    <%= unless @page_loading do %>
    <.top_bar_nav selected_tab={@selected_top_bar_tab}/>

    <div class="pl-4 pr-4">
      <%= case @selected_top_bar_tab do %>
      <% "stats" -> %> <% # @top_bar_stats_tab %>
        <div class="has-text-centered">
          coming soon
        </div>

      <% "history" -> %> <% # @top_bar_history_tab %>
        <div class="has-text-centered">
          coming soon
        </div>

      <% end %>
    </div>

    <.new_entry_footer />
    <% end %>
    """
  end

  # Private

  ## Markdown

  defp top_bar_nav(assigns) do
    ~H"""
    <div class="buttons top-bar has-addons is-centered pt-4 pb-4 mb-0 button-navbar">
      <button
        class={ViewUtils.class_list("button", %{"is-selected": @selected_tab == "stats" })}
        style="width: 110px"
        phx-click="top_level_navigate"
        phx-value-top_bar_tab="stats"
      >
        <span class="icon">
          <i class="fas fa-chart-line"></i>
        </span>
        <span>Stats</span>
      </button>

      <button
        class={ViewUtils.class_list("button", %{"is-selected": @selected_tab == "history" })}
        style="width: 110px"
        phx-click="top_level_navigate"
        phx-value-top_bar_tab="history"
      >
        <span class="icon">
          <i class="far fa-calendar"></i>
        </span>
        <span>History</span>
      </button>
    </div>
    """
  end

  defp new_entry_footer(assigns) do
    ~H"""
    <div class="new_entry_footer">
      <p class="buttons is-right pb-4 pr-4 ">
        <.link
          navigate={Routes.live_path(OpenBookWeb.Endpoint, NutritionLogLive)}
          class="button is-light has_border_grey has_text_dark_blue b-0"
        >
          <span class="icon has_text_dark_blue">
            <i class="fas fa-utensils mr-0"></i>
          </span>
          <span class="has_text_dark_blue">
            log nutrition
          </span>
        </.link>
        <.link
          navigate={Routes.live_path(OpenBookWeb.Endpoint, ExerciseLogLive)}
          class="button is-light has_border_grey has_text_dark_blue b-0"
        >
          <span class="icon has_text_dark_blue">
            <i class="fas fa-dumbbell"></i>
          </span>
          <span>
            record workout
          </span>
        </.link>
      </p>
    </div>
    """
  end
end
