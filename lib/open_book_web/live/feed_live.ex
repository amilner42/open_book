defmodule OpenBookWeb.FeedLive do
  @moduledoc """
  The LiveView for the feed page which is essentially the home page, showing a list of
  """
  use OpenBookWeb, :live_view_connected

  import Phoenix.Component

  alias OpenBook.Accounts
  alias OpenBook.DateHelpers
  alias OpenBook.LittleLogger, as: LL
  alias OpenBookWeb.ExerciseLogLive
  alias OpenBookWeb.NutritionLogLive
  alias OpenBookWeb.ViewUtils

  @top_bar_stats_tab "stats"
  @top_bar_history_tab "history"
  @top_bar_tabs [@top_bar_stats_tab, @top_bar_history_tab]

  @mock_daily_histories [
    %{
      date: ~D[2023-02-26],
      my_summary: {"You had 1900 calories.", "You did 1 hour and 15 minutes of intense cardio and 22 pushups."},
      summary_by_user_display_name: %{
        Charlie: {"Charlie had 2000 calories", "Charlie did a 30 min casual bike and then 55 pushups."},
        Robin: {"Robin had 2500 calories.", "Robin did 90 minutes of intense cardio"}
      }
    },
    %{
      date: ~D[2023-02-25],
      my_summary: {"You had 1900 calories.", "You did 1 hour 15 min intense cardio and 22 pushups."},
      summary_by_user_display_name: %{
        Charlie: {"Charlie had 2000 calories", "Charlie did a 30 min casual bike."},
        Robin: {"Robin had 2500 calories.", "Robin did 90 minutes"}
      }
    },
    %{
      date: ~D[2023-02-24],
      my_summary: {"You had 1900 calories.", "You did 1 hour 15 min intense cardio and 22 pushups."},
      summary_by_user_display_name: %{
        Charlie: {"Charlie had 2000 calories", "Charlie did a 30 min casual bike."},
        Robin: {"Robin had 2500 calories.", "Robin did 90 minute intense cardio"}
      }
    },
    %{
      date: ~D[2023-02-23],
      my_summary: {"You had 1900 calories.", "You did 1 hour 15 min intense cardio and 22 pushups."},
      summary_by_user_display_name: %{
        Charlie: {"Charlie had 2000 calories", "Charlie did a 30 min casual bike."},
        Robin: {"Robin had 2500 calories.", "Robin did 90 minute intense cardio"}
      }
    }
  ]

  def mount_live(_params, %{"user_id" => user_id}, socket) do
    LL.metadata_add_current_user_id(user_id)
    LL.metadata_add_current_page("FeedLive")
    LL.info_event("mount_live")

    user = Accounts.get_user!(user_id)

    socket =
      socket
      |> assign(:user, user)

    {:ok, socket}
  end

  def handle_params_live(params, _url, socket) do
    LL.info_event("handle_params_live", params)

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

    # Top Bar Tab Required Nested Data

    socket =
      case selected_top_bar_tab do
        @top_bar_history_tab ->
          socket
          |> assign(:daily_histories, @mock_daily_histories)

        _ ->
          socket
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
    LL.info_event("handle_event", Map.merge(params, %{event_name: :top_level_navigate}))

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

    <div class="pl-5 pr-5">
      <%= case @selected_top_bar_tab do %>
      <% "stats" -> %> <% # @top_bar_stats_tab %>
        <div class="has-text-centered">
          coming soon
        </div>

      <% "history" -> %> <% # @top_bar_history_tab %>
        <div>
          <%= for day <- @daily_histories do %>
          <div class="mb-4 daily-entry">
            <div class="is-capitalized is-size-4 has-text-centered pb-4 has-text-weight-bold">
              <%= DateHelpers.readable_date(DateTime.now!("America/Los_Angeles"), day.date, :human_relative_lingo_with_prefix) %>
            </div>

            <div class="level is-mobile pb-0 mb-2">
              <div class="level-left">
                <div class="level-item">
                  <span class="has-text-weight-semibold">
                    Nutrition
                  </span>
                </div>
              </div>

              <div class="level-item ml-3" style="border-bottom: 1px #2f364d solid;"></div>

              <div class="level-right has_text_dark_blue">
                <span class="icon">
                  <i class="fas fa-utensils"></i>
                </span>
              </div>
            </div>

            <p class="pt-0 pb-2">
              <div class="pb-4" style="line-height: 20px;">
                <%= {cal_summary, _} = day.my_summary; cal_summary %>
              </div>
              <%= for {user_display_name, {summary, _}} <- day.summary_by_user_display_name do %>
              <div class="level is-mobile pl-2 pb-0 mb-0">
                <div class="level-left">
                  <div class="level-item mr-1">
                    <span class="icon">
                      <i class="far fa-user-circle"></i>
                    </span>
                  </div>
                  <div class="level-item">
                    <span style="max-width: 250px; line-height: 20px;">
                      <%= summary %>
                    </span>
                  </div>
                </div>
              </div>
              <% end %>
            </p>

            <div class="level is-mobile pt-5 pb-0">
              <div class="level-left">
                <div class="level-item">
                <span class="has-text-weight-semibold">
                    Exercise
                  </span>
                </div>
              </div>

              <div class="level-item ml-3" style="border-bottom: 1px #2f364d solid;"></div>

              <div class="level-right">
                <span class="icon">
                  <i class="fas fa-dumbbell"></i>
                </span>
              </div>
            </div>
            <div class="pt-0 pb-2">
              <div class="pb-4" style="line-height: 20px;">
                <%= {_, exercise_summary} = day.my_summary; exercise_summary %>
              </div>
              <%= for {user_display_name, {_, summary}} <- day.summary_by_user_display_name do %>
              <div class="level is-mobile pl-2 pb-0 mb-2">
                <div class="level-left">
                  <div class="level-item mr-2">
                    <span class="icon">
                      <i class="far fa-user-circle"></i>
                    </span>
                  </div>
                  <div class="level-item">
                    <span style="max-width: 250px; line-height: 20px;">
                      <%= summary %>
                    </span>
                  </div>
                </div>
              </div>
              <% end %>
            </div>
          </div>
          <% end %>
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
          <i class="fas fa-trophy"></i>
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
          <i class="fas fa-book"></i>
        </span>
        <span>Book</span>
      </button>

      <button
        class={ViewUtils.class_list("button", %{"is-selected": @selected_tab == "friends" })}
        style="width: 110px"
        phx-click="top_level_navigate"
        phx-value-top_bar_tab="history"
      >
        <span class="icon">
          <i class="fas fa-user-friends"></i>
        </span>
        <span>Friends</span>
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
