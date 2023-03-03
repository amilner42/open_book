defmodule OpenBookWeb.BookLive do
  use OpenBookWeb, :live_view_connected

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

  # <%= for summary <- day.friend_nutrition_summaries do %>
  # <div class="level is-mobile pl-2 pb-0 mb-0">
  #   <div class="level-left">
  #     <div class="level-item mr-1">
  #       <span class="icon">
  #         <i class="far fa-user-circle"></i>
  #       </span>
  #     </div>
  #     <div class="level-item">
  #       <span style="max-width: 250px; line-height: 20px;">
  #         <%= summary %>
  #       </span>
  #     </div>
  #   </div>
  # </div>
  # <% end %>

#   <div class="pt-0 pb-2">
#   <div class="pb-4" style="line-height: 20px;">
#     <%= day.my_exercise_summary %>
#   </div>
#   <%= for summary <- day.friend_exercise_summaries do %>
#   <div class="level is-mobile pl-2 pb-0 mb-2">
#     <div class="level-left">
#       <div class="level-item mr-2">
#         <span class="icon">
#           <i class="far fa-user-circle"></i>
#         </span>
#       </div>
#       <div class="level-item">
#         <span style="max-width: 250px; line-height: 20px;">
#           <%= summary %>
#         </span>
#       </div>
#     </div>
#   </div>
#   <% end %>
# </div>

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
                <%= day.my_nutrition_summary %>
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
                <%= day.my_exercise_summary %>
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
  #       my_nutrition_summary: "I did not record any nutrition",
  #       my_exercise_summary: "I did not exercise.",
  #       friend_nutrition_summaries: ["Charlie had 2000 calories", "Robin did not record any nutrition."]
  #       friend_exercise_summaries: ["Charlie did not exercise", "Robin did 50 pull-ups."]
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
      readable_calorie_description =
        Fitness.get_readable_calorie_description(
          compressed_nutrition_and_exercise_entries,
          date,
          current_user.id,
          "I"
        )

      readable_exercise_description =
        Fitness.get_readable_exercise_description(
          compressed_nutrition_and_exercise_entries,
          date,
          current_user.id,
          "I",
          all_exercise_category_names_by_id
        )

      %{
        friend_by_id: friend_by_id,
        nutrition_open_book_friend_ids: nutrition_open_book_friend_ids,
        exercise_open_book_friend_ids: exercise_open_book_friend_ids
      } = nutrition_and_exercise_entries_and_friends

      friend_nutrition_summaries =
        Enum.map(nutrition_open_book_friend_ids, fn friend_id ->
          Fitness.get_readable_calorie_description(
            compressed_nutrition_and_exercise_entries,
            date,
            friend_id,
            Map.fetch!(friend_by_id, friend_id).display_name
          )
        end)

      friend_exercise_summaries =
        Enum.map(exercise_open_book_friend_ids, fn friend_id ->
          Fitness.get_readable_exercise_description(
            compressed_nutrition_and_exercise_entries,
            date,
            friend_id,
            Map.fetch!(friend_by_id, friend_id).display_name,
            all_exercise_category_names_by_id
          )
        end)

      %{
        date: date,
        my_nutrition_summary: readable_calorie_description,
        my_exercise_summary: readable_exercise_description,
        friend_nutrition_summaries: friend_nutrition_summaries,
        friend_exercise_summaries: friend_exercise_summaries
      }
    end
  end
end
