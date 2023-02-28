defmodule OpenBookWeb.HomeLive do
  @moduledoc """
  The LiveView for the core home page.
  """
  use OpenBookWeb, :live_view_connected

  import Phoenix.Component

  alias OpenBook.Accounts
  alias OpenBook.DateHelpers
  alias OpenBook.Fitness
  alias OpenBook.LittleLogger, as: LL
  alias OpenBookWeb.ExerciseLogLive
  alias OpenBookWeb.NutritionLogLive
  alias OpenBookWeb.ViewUtils

  @top_bar_stats_tab "stats"
  @top_bar_book_tab "book"
  @top_bar_friends_tab "friends"
  @top_bar_tabs [@top_bar_stats_tab, @top_bar_book_tab, @top_bar_friends_tab]

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

    current_user = socket.assigns.user

    # Params
    socket =
      socket
      |> assign(:params, params)

    # Top Bar Tab

    selected_top_bar_tab =
      if (tab = params["stbt"]) in @top_bar_tabs do
        tab
      else
        @top_bar_book_tab
      end

    socket =
      socket
      |> assign(:selected_top_bar_tab, selected_top_bar_tab)

    # Top Bar Tab Required Nested Data

    socket =
      case selected_top_bar_tab do
        @top_bar_book_tab ->
          socket =
            socket
            |> assign_new(:book_daily_pages, fn ->
              get_book_daily_pages(current_user, Fitness.fetch_all_exercise_category_names_by_id())
            end)

        _ ->
          socket
      end

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
          see stats here soon
        </div>

      <% "book" -> %>
        <div>
          <%= for day <- @book_daily_pages do %>
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
                <%= day.my_nutrition_summary %>
              </div>
              <%= for summary <- day.friend_nutrition_summaries do %>
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
                <%= day.my_exercise_summary %>
              </div>
              <%= for summary <- day.friend_exercise_summaries do %>
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

      <% "friends" -> %>
        <div class="has-text-centered">
          add friends here soon
        </div>

      <% end %>
    </div>

    <.new_entry_footer />
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
      compress_nutrition_and_exercise_entries(nutrition_and_exercise_entries_and_friends)

    date_range =
      Date.range(
        NaiveDateTime.to_date(naive_date_time_end_of_today),
        NaiveDateTime.to_date(naive_date_time_start_of_thirty_days_ago)
      )

    for date <- date_range do
      maybe_my_calories =
        get_in(compressed_nutrition_and_exercise_entries, [date, current_user.id, :total_calorie_estimate])

      readable_calorie_description = get_readable_calorie_description("I", maybe_my_calories)

      measurement_by_exercise_category_id_and_intensity_tuple =
        get_in(compressed_nutrition_and_exercise_entries, [
          date,
          current_user.id,
          :measurement_by_exercise_category_id_and_intensity_tuple
        ])

      readable_exercise_description =
        get_readable_exercise_description(
          "I",
          measurement_by_exercise_category_id_and_intensity_tuple,
          all_exercise_category_names_by_id
        )

      %{
        friend_by_id: friend_by_id,
        nutrition_open_book_friend_ids: nutrition_open_book_friend_ids,
        exercise_open_book_friend_ids: exercise_open_book_friend_ids
      } = nutrition_and_exercise_entries_and_friends

      friend_nutrition_summaries =
        Enum.map(nutrition_open_book_friend_ids, fn friend_id ->
          friend_display_name = Map.fetch!(friend_by_id, friend_id).display_name

          maybe_friend_calories =
            get_in(compressed_nutrition_and_exercise_entries, [date, friend_id, :total_calorie_estimate])

          get_readable_calorie_description(friend_display_name, maybe_friend_calories)
        end)

      friend_exercise_summaries =
        Enum.map(exercise_open_book_friend_ids, fn friend_id ->
          friend_display_name = Map.fetch!(friend_by_id, friend_id).display_name

          measurement_by_exercise_category_id_and_intensity_tuple =
            get_in(compressed_nutrition_and_exercise_entries, [
              date,
              friend_id,
              :measurement_by_exercise_category_id_and_intensity_tuple
            ])

          get_readable_exercise_description(
            friend_display_name,
            measurement_by_exercise_category_id_and_intensity_tuple,
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

  # Returns the following nested map structure:
  #
  # [
  #   %{
  #     <date> => %{
  #       <user_id> => %{
  #         measurement_by_exercise_category_id_and_intensity_tuple: %{
  #           {13, :light} => 20,
  #           {14, :intense} => 60,
  #           {14, :light} => 20,
  #           {21, nil} => 8
  #         },
  #         total_calorie_estimate: 1500
  #       }
  #     }
  #   },
  #   ...
  # ]
  defp compress_nutrition_and_exercise_entries(%{
         nutrition_entries: nutrition_entries,
         exercise_entries: exercise_entries
       }) do
    result = %{}
    default_data = %{total_calorie_estimate: 0, measurement_by_exercise_category_id_and_intensity_tuple: %{}}

    # Merge in nutrition entries.
    result =
      Enum.reduce(nutrition_entries, result, fn %{
                                                  local_datetime: local_datetime,
                                                  user_id: user_id,
                                                  calorie_estimate: calorie_estimate
                                                },
                                                result_acc ->
        date = NaiveDateTime.to_date(local_datetime)

        update_in(result_acc, [Access.key(date, %{}), user_id], fn maybe_current_value ->
          current_value = maybe_current_value || default_data
          new_total_calorie_estimate = current_value.total_calorie_estimate + calorie_estimate

          %{current_value | total_calorie_estimate: new_total_calorie_estimate}
        end)
      end)

    # Merge in exercise entries.
    result =
      Enum.reduce(exercise_entries, result, fn %{
                                                 local_datetime: local_datetime,
                                                 user_id: user_id,
                                                 exercise_category_id: exercise_category_id,
                                                 intensity_level: intensity_level,
                                                 measurement: measurement
                                               },
                                               result_acc ->
        date = NaiveDateTime.to_date(local_datetime)

        update_in(result_acc, [Access.key(date, %{}), user_id], fn maybe_current_value ->
          current_value = maybe_current_value || default_data

          new_measurement_by_exercise_category_id_and_intensity_tuple =
            current_value.measurement_by_exercise_category_id_and_intensity_tuple
            |> Map.put_new({exercise_category_id, intensity_level}, 0)
            |> Map.update!({exercise_category_id, intensity_level}, fn total_measurement ->
              total_measurement + measurement
            end)

          %{
            current_value
            | measurement_by_exercise_category_id_and_intensity_tuple:
                new_measurement_by_exercise_category_id_and_intensity_tuple
          }
        end)
      end)

    result
  end

  ### Readablity Helpers

  defp get_readable_calorie_description(who, nil), do: "#{who} did not record any nutrition."
  defp get_readable_calorie_description(who, 0), do: "#{who} did not record any nutrition."
  defp get_readable_calorie_description(who, calorie_estimate), do: "#{who} had around #{calorie_estimate} calories."

  defp get_readable_exercise_description(who, nil, _all_exercise_category_names_by_id), do: "#{who} did not exercise."

  defp get_readable_exercise_description(
         who,
         measurement_by_exercise_category_id_and_intensity_tuple,
         all_exercise_category_names_by_id
       ) do
    if(measurement_by_exercise_category_id_and_intensity_tuple == %{}) do
      get_readable_exercise_description(who, nil, all_exercise_category_names_by_id)
    else
      readable_exercise_segments =
        Enum.map(measurement_by_exercise_category_id_and_intensity_tuple, fn {{exercise_category_id, intensity_level},
                                                                              measurement} ->
          exercise_category_name = Map.fetch!(all_exercise_category_names_by_id, exercise_category_id)
          Fitness.human_readable_exercise_selection(exercise_category_name, intensity_level, measurement)
        end)

      readable_exercise_string = ViewUtils.readable_and_list(readable_exercise_segments)

      "#{who} did #{readable_exercise_string}."
    end
  end

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
        class={ViewUtils.class_list("button", %{"is-selected": @selected_tab == "book" })}
        style="width: 110px"
        phx-click="top_level_navigate"
        phx-value-top_bar_tab="book"
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
        phx-value-top_bar_tab="friends"
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
