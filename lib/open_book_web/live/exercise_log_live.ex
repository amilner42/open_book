defmodule OpenBookWeb.ExerciseLogLive do
  @moduledoc """
  The LiveView for the exercise log.

  Assigns:
    - exercise_categories: array of `ExerciseCategory`
  """
  use OpenBookWeb, :live_view_connected

  alias OpenBook.Accounts
  alias OpenBook.Fitness
  alias OpenBook.LittleLogger, as: LL

  alias OpenBookWeb.HomeLive

  def mount_live(_params, %{"user_id" => user_id}, socket) do
    LL.metadata_add_current_user_id(user_id)
    LL.metadata_add_current_page("ExerciseLogLive")
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

    # Exercise Categories

    socket =
      if(socket.assigns[:exercise_categories]) do
        socket
      else
        exercise_categories = Fitness.fetch_all_exercise_categories()

        socket
        |> assign(:exercise_categories, exercise_categories)
      end

    # Selected exercise category

    selected_exercise_category_id = params["secid"]

    selected_exercise_category =
      Enum.find(
        socket.assigns[:exercise_categories] || [],
        &("#{&1.id}" == selected_exercise_category_id)
      )

    socket =
      socket
      |> assign(:selected_exercise_category, selected_exercise_category)

    # Selected intensity level

    selected_intensity_level = params["sil"]

    socket =
      socket
      |> assign(:selected_intensity_level, selected_intensity_level)

    # Selected exercise measurement

    selected_exercise_measurement = params["sem"] && String.to_integer(params["sem"])

    socket =
      socket
      |> assign(:selected_exercise_measurement, selected_exercise_measurement)

    {:noreply, socket}
  end

  ## Render

  def render(assigns) do
    ~H"""
    <%= unless @page_loading do %>
      <section class="section pt-5">
      <%= cond do %>
      <% !@selected_exercise_category  -> %>
        <p class="pt-0 pb-4">
          What did you go for today?
        </p>

        <div class="is-flex is-flex-direction-row is-flex-wrap-wrap	">
        <%= for exercise_category <- @exercise_categories do %>
          <div class="tile p-1">
            <button
              class="button is-light is-medium is-fullwidth has_border_grey"
              phx-click="select_exercise_category"
              phx-value-exercise_category_id={exercise_category.id}
            >
              <%= if exercise_category.icon_css_class do %>
              <span class="icon is-small has_text_dark_blue">
                <i class={exercise_category.icon_css_class}></i>
              </span>
              <% end %>
              <span class="has_text_dark_blue">
                <%= exercise_category.name %>
              </span>
            </button>
          </div>
        <% end %>
        </div>

      <%= !@selected_intensity_level && @selected_exercise_category.measurement_kind == :minutes -> %>
        <p class="pt-0 pb-4">
          How hard did you go?
        </p>
        <div class="is-flex is-flex-direction-row is-flex-wrap-wrap	">
        <%= for intensity_level <- Fitness.intensity_levels do %>
          <div class="tile p-1">
            <button
              class="button is-light is-medium is-fullwidth has_border_grey"
              phx-click="select_intensity_level"
              phx-value-intensity_level={intensity_level}
            >
              <%= case intensity_level do %>
              <% :light -> %>
                took it easy

              <% :regular -> %>
                the usual

              <% :intense -> %>
                went hard af

              <% end %>
            </button>
          </div>
        <% end %>
        </div>

      <%= !@selected_exercise_measurement -> %>
        <%= case @selected_exercise_category.measurement_kind do %>
        <% :repetitions -> %>
          <p class="pt-0 pb-4">
            How many?
          </p>
          <div class="is-flex is-flex-direction-row is-flex-wrap-wrap	">
          <%= for amount_option <- get_amount_options() do %>
            <div class="tile p-1">
              <button
                class="button is-medium is-light is-fullwidth has_border_grey"
                phx-click="select_exercise_measurement"
                phx-value-exercise_measurement={amount_option}
              >
                <%= amount_option %>
              </button>
            </div>
          <% end %>
          </div>

        <% :minutes -> %>
          <p class="pt-0 pb-4">
            For how long?
          </p>
          <div class="is-flex is-flex-direction-row is-flex-wrap-wrap	">
          <%= for minute_option <- get_duration_minute_options() do %>
            <div class="tile p-1">
              <button
                class="button is-medium is-light is-fullwidth has_border_grey"
                phx-click="select_exercise_measurement"
                phx-value-exercise_measurement={minute_option}
              >
                <%= human_readable_minute_option(minute_option) %>
              </button>
            </div>
          <% end %>
          </div>

        <% end %>

      <% true -> %>
        <p class="pt-0 pb-4 has-text-centered">
          <span>
            <%=
              Fitness.human_readable_exercise_selection(
                @selected_exercise_category,
                @selected_intensity_level,
                @selected_exercise_measurement
              )
            %>
          </span>
        </p>
        <button
          class="button is-fullwidth is-dark has_background_purple"
          phx-click="confirm_add_new_exercise_entry"
          phx-value-selected_exercise_category_id={@selected_exercise_category.id}
          phx-value-selected_exercise_measurement={@selected_exercise_measurement}
          phx-value-selected_intensity_level={@selected_intensity_level}
        >
          <span class="icon has-text-white">
            <i class="fas fa-pencil-alt"></i>
          </span>
          <span>
            Save
          </span>
        </button>

      <% end %>
      </section>
    <% end %>
    """
  end

  ## Handle Events

  def handle_event(
        "confirm_add_new_exercise_entry",
        params = %{
          "selected_exercise_category_id" => selected_exercise_category_id,
          "selected_exercise_measurement" => selected_exercise_measurement
        },
        socket
      ) do
    LL.info_event("handle_event", %{event_name: :confirm_add_new_exercise_entry})

    %{user: user} = socket.assigns
    selected_intensity_level = params["selected_intensity_level"]

    params = %{
      exercise_category_id: selected_exercise_category_id,
      measurement: selected_exercise_measurement,
      intensity_level: selected_intensity_level,
      # TODO(Arie): timezone-support
      local_datetime: DateTime.now!("America/Los_Angeles")
    }

    Fitness.insert_new_exercise_entry!(user.id, params)

    to = Routes.live_path(OpenBookWeb.Endpoint, HomeLive, %{stbt: "book"})

    socket =
      socket
      |> push_navigate(to: to)

    {:noreply, socket}
  end

  def handle_event(
        "select_exercise_category",
        %{"exercise_category_id" => exercise_category_id},
        socket
      ) do
    params = Map.merge(socket.assigns.params, %{secid: exercise_category_id})
    to = Routes.live_path(OpenBookWeb.Endpoint, __MODULE__, params)

    socket =
      socket
      |> push_patch(to: to, replace: false)

    {:noreply, socket}
  end

  def handle_event(
        "select_intensity_level",
        %{"intensity_level" => intensity_level},
        socket
      ) do
    params = Map.merge(socket.assigns.params, %{sil: intensity_level})
    to = Routes.live_path(OpenBookWeb.Endpoint, __MODULE__, params)

    socket =
      socket
      |> push_patch(to: to, replace: false)

    {:noreply, socket}
  end

  def handle_event(
        "select_exercise_measurement",
        %{"exercise_measurement" => exercise_measurement},
        socket
      ) do
    params = Map.merge(socket.assigns.params, %{sem: exercise_measurement})
    to = Routes.live_path(OpenBookWeb.Endpoint, __MODULE__, params)

    socket =
      socket
      |> push_patch(to: to, replace: false)

    {:noreply, socket}
  end

  # Private

  defp get_duration_minute_options() do
    sub_hour_options = Enum.to_list(10..60//5)
    one_to_two_hour_options = Enum.to_list(70..120//10)
    two_to_four_hours = Enum.to_list(135..240//15)
    four_to_ten_hours = Enum.to_list(270..600//30)

    sub_hour_options ++ one_to_two_hour_options ++ two_to_four_hours ++ four_to_ten_hours
  end

  defp get_amount_options() do
    1..100
  end

  defp human_readable_minute_option(total_minutes) do
    minutes = rem(total_minutes, 60)
    hours = div(total_minutes, 60)

    hour_text =
      if hours == 0 do
        ""
      else
        "#{hours} hour "
      end

    minutes_text =
      if minutes == 0 do
        ""
      else
        "#{minutes} min"
      end

    "#{hour_text}#{minutes_text}"
  end
end
