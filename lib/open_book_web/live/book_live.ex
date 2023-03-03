defmodule OpenBookWeb.BookLive do
  use OpenBookWeb, :live_view_connected

  import Pit

  alias OpenBook.HumanReadable
  alias Phoenix.LiveView.JS

  alias OpenBook.Accounts
  alias OpenBook.DateHelpers
  alias OpenBook.Fitness
  alias OpenBook.Share
  alias OpenBook.LittleLogger, as: LL

  alias OpenBookWeb.Markdowns.InnerBar
  alias OpenBookWeb.ViewUtils

  def mount_live(_params, %{"user_id" => user_id}, socket) do
    LL.metadata_add_current_user_id(user_id)
    LL.metadata_add_current_page("BookLive")
    LL.info_event("mount_live")

    user = Accounts.get_user!(user_id)

    socket =
      socket
      |> assign(:user, user)
      |> assign(:active_share_day_modal_data, nil)
      |> assign_new(:book_daily_pages, fn ->
        get_book_daily_pages(user, Fitness.fetch_all_exercise_category_names_by_id())
      end)

    {:ok, socket}
  end

  def handle_params_live(params, _url, socket) do
    LL.info_event("handle_params_live", params)

    {:noreply, socket}
  end

  def handle_event(
        "activate_share_day_modal",
        params = %{"date" => date},
        socket
      ) do
    LL.info_event("handle_event", Map.merge(params, %{event_name: :activate_share_day_modal}))

    current_user = socket.assigns.user

    dsl = Share.generate_new_day_stats_link!(current_user.id, date)
    dsl_share_link = Routes.share_url(socket, :share_day_stats, dsl.code)

    socket =
      socket
      |> assign(:active_share_day_modal_data, dsl_share_link)

    {:noreply, socket}
  end

  def handle_event(
        "deactivate_share_day_modal",
        params,
        socket
      ) do
    LL.info_event("handle_event", Map.merge(params, %{event_name: :deactivate_share_day_modal}))

    socket =
      socket
      |> assign(:active_share_day_modal_data, nil)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <InnerBar.inner_bar active_tab={"book"}/>

    <%= unless @page_loading do %>

    <div class={ViewUtils.class_list("modal", %{"is-active" => @active_share_day_modal_data != nil})}>
      <div
        class="modal-background"
        phx-click="deactivate_share_day_modal"
      >
      </div>
      <div class="modal-content">
        <div class="box m-3">
          Share your progress with close friends

          <div class="mb-4 mt-3">
            <a
              href={@active_share_day_modal_data}
              class="has-text-link is-size-7"
              target="_blank"
            >
              <%= @active_share_day_modal_data %>
            </a>
          </div>

          <div class="buttons are-small has-addons is-right">
            <button
              class="button is-small is-rounded"
              phx-click={JS.dispatch("phx:copy")}
              data-text_to_copy={@active_share_day_modal_data}
            >
              <span class="icon">
                <i class="fas fa-link"></i>
              </span>

              <span>Copy Link</span>
            </button>
          </div>

        </div>
      </div>
    </div>

    <div class="p-5">
      <%= for day <- @book_daily_pages do %>
      <div class="mb-4 daily-entry">
        <div class="is-capitalized is-size-4 has-text-centered pb-4 has-text-weight-bold">
          <%= DateHelpers.readable_date(DateTime.now!("America/Los_Angeles"), day.date, :human_relative_lingo) %>
        </div>

        <div class="level is-mobile pb-0 mb-0">
          <div class="level-left">
            <div class="level-item mr-2">
              <span class="icon">
                <i class="fas fa-utensils"></i>
              </span>
            </div>
            <div class="level-item">
              <span style="max-width: 250px; line-height: 20px;">
                <%= day.maybe_readable_calorie_description %>
              </span>
            </div>
          </div>
        </div>

        <div class="level is-mobile pb-0 mb-0 mt-4">
          <div class="level-left">
            <div class="level-item mr-2">
              <span class="icon">
              <i class="fas fa-dumbbell"></i>
              </span>
            </div>
            <div class="level-item">
              <span style="max-width: 250px; line-height: 20px;">
                <%= day.maybe_readable_exercise_descrption %>
              </span>
            </div>
          </div>
        </div>

        <div class="buttons has-addons is-right mt-4">
          <button
            class="button is-small is-rounded b-0 aligned-right"
            phx-click="activate_share_day_modal"
            phx-value-date={day.date}
          >
            <span class="icon mr-1">
              <i class="fas fa-external-link-alt"></i>
            </span>
            <span class="is-size-7">
              share day
            </span>
          </button>
        </div>
      </div>
      <% end %>
    </div>
    <% end %>
    """
  end

  # Private

  ## Helpers

  # Fetch ~30 days of history for the book tab.
  #
  # Structure:
  #   [
  #     %{
  #       date: ~D[...],
  #       maybe_readable_calorie_description: "I did not record any nutrition",
  #       maybe_readable_exercise_descrption: "I did not exercise."
  #     },
  #     ...
  #   ]
  #
  # TODO(Arie): Function too large.
  defp get_book_daily_pages(current_user, all_exercise_category_names_by_id) do
    # TODO(Arie): timezone-support
    naive_date_time_end_of_today =
      DateTime.now!("America/Los_Angeles")
      |> DateTime.to_naive()
      |> DateHelpers.naive_end_of_day()

    naive_date_time_start_of_thirty_days_ago =
      naive_date_time_end_of_today
      |> NaiveDateTime.add(-30, :day)
      |> DateHelpers.naive_start_of_day()

    # TODO(Arie): We no longer need to fetch friend data as it is not rendered.
    nutrition_and_exercise_entries_and_friends =
      Fitness.fetch_nutrition_and_exercise_entries_and_friends(current_user.id, %{
        from_local_datetime: naive_date_time_start_of_thirty_days_ago,
        to_local_datetime: naive_date_time_end_of_today
      })

    compressed_nutrition_and_exercise_entries =
      Fitness.compress_nutrition_and_exercise_entries(nutrition_and_exercise_entries_and_friends)

    date_range =
      Date.range(
        NaiveDateTime.to_date(naive_date_time_end_of_today),
        NaiveDateTime.to_date(naive_date_time_start_of_thirty_days_ago)
      )

    for date <- date_range do
      maybe_readable_calorie_description =
        compressed_nutrition_and_exercise_entries
        |> Fitness.get_calories_from_compressed_nutrition_and_exercise_entries(date, current_user.id)
        |> pit!(not nil)
        |> HumanReadable.human_readable_calorie_description("I")
        |> pit!()

      maybe_readable_exercise_descrption =
        compressed_nutrition_and_exercise_entries
        |> Fitness.get_exercise_category_id_and_intensity_from_compressed_nutrition_and_exercise_entries(
          date,
          current_user.id
        )
        |> pit!(not nil)
        |> HumanReadable.human_readable_exercise_description("I", all_exercise_category_names_by_id)
        |> pit!()

      %{
        date: date,
        maybe_readable_calorie_description: maybe_readable_calorie_description,
        maybe_readable_exercise_descrption: maybe_readable_exercise_descrption
      }
    end
  end
end
