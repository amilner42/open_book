defmodule OpenBookWeb.WriteLive do
  use OpenBookWeb, :live_view_connected

  alias OpenBook.Accounts
  alias OpenBook.Fitness
  alias OpenBook.HumanReadable
  alias OpenBook.LittleLogger, as: LL

  alias OpenBookWeb.BookLive
  alias OpenBookWeb.Markdowns.InnerBar
  alias OpenBookWeb.ViewUtils

  def mount_live(_params, %{"user_id" => user_id}, socket) do
    LL.metadata_add_current_user_id(user_id)
    LL.metadata_add_current_page("WriteLive")
    LL.info_event("mount_live")

    db_tasks = [
      Task.async(fn -> Accounts.get_user!(user_id) end),
      Task.async(fn -> Fitness.fetch_all_nutrition_categories() end),
      Task.async(fn -> Fitness.fetch_all_exercise_categories() end)
    ]

    [user, nutrition_categories, exercise_categories] = Task.await_many(db_tasks)

    socket =
      socket
      |> assign(:user, user)
      |> assign(:nutrition_categories, nutrition_categories)
      |> assign(:exercise_categories, exercise_categories)

    {:ok, socket}
  end

  def handle_params_live(params, _url, socket) do
    LL.info_event("handle_params_live", params)

    # All routes

    socket =
      socket
      |> assign(:params, params)

    # Nutrition

    ## Selected Nutrition Category

    selected_nutrition_category_id = params["sncid"]

    selected_nutrition_category =
      Enum.find(
        socket.assigns[:nutrition_categories] || [],
        &("#{&1.id}" == selected_nutrition_category_id)
      )

    socket =
      socket
      |> assign(:selected_nutrition_category, selected_nutrition_category)

    # Selected Calorie Count

    selected_calorie_count = params["cc"] && String.to_integer(params["cc"])

    socket =
      socket
      |> assign(:selected_calorie_count, selected_calorie_count)

    # Exercise

    ## Selected exercise category

    selected_exercise_category_id = params["secid"]

    selected_exercise_category =
      Enum.find(
        socket.assigns[:exercise_categories] || [],
        &("#{&1.id}" == selected_exercise_category_id)
      )

    socket =
      socket
      |> assign(:selected_exercise_category, selected_exercise_category)

    ## Selected intensity level

    selected_intensity_level = params["sil"]

    socket =
      socket
      |> assign(:selected_intensity_level, selected_intensity_level)

    ## Selected exercise measurement

    selected_exercise_measurement = params["sem"] && String.to_integer(params["sem"])

    socket =
      socket
      |> assign(:selected_exercise_measurement, selected_exercise_measurement)

    {:noreply, socket}
  end

  # Handle Events

  ## Nutrition

  def handle_event(
        "select_nutrition_category",
        %{"nutrition_category_id" => nutrition_category_id},
        socket
      ) do
    params = Map.merge(socket.assigns.params, %{sncid: nutrition_category_id})
    to = Routes.live_path(OpenBookWeb.Endpoint, __MODULE__, params)

    socket =
      socket
      |> push_patch(to: to, replace: false)

    {:noreply, socket}
  end

  def handle_event(
        "select_calorie_option",
        %{"calorie_count" => calorie_count},
        socket
      ) do
    params = Map.merge(socket.assigns.params, %{cc: calorie_count})
    to = Routes.live_path(OpenBookWeb.Endpoint, __MODULE__, params)

    socket =
      socket
      |> push_patch(to: to, replace: false)

    {:noreply, socket}
  end

  def handle_event(
        "save_new_nutrition_entry",
        _params = %{
          "selected_nutrition_category_id" => selected_nutrition_category_id,
          "selected_calorie_count" => selected_calorie_count
        },
        socket
      ) do
    LL.info_event("handle_event", %{event_name: :save_new_nutrition_entry})

    %{user: user} = socket.assigns

    params = %{
      nutrition_category_id: selected_nutrition_category_id,
      calorie_estimate: selected_calorie_count,
      # TODO(Arie): timezone-support
      local_datetime: DateTime.now!("America/Los_Angeles")
    }

    Fitness.insert_new_nutrition_entry!(user.id, params)
    to = Routes.live_path(OpenBookWeb.Endpoint, BookLive)

    socket =
      socket
      |> push_navigate(to: to)

    {:noreply, socket}
  end

  ## Exercise

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

  def handle_event(
        "save_new_exercise_entry",
        params = %{
          "selected_exercise_category_id" => selected_exercise_category_id,
          "selected_exercise_measurement" => selected_exercise_measurement
        },
        socket
      ) do
    LL.info_event("handle_event", %{event_name: :save_new_exercise_entry})

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

    to = Routes.live_path(OpenBookWeb.Endpoint, BookLive)

    socket =
      socket
      |> push_navigate(to: to)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <InnerBar.inner_bar active_tab={"write"}/>

    <%= unless @page_loading do %>

    <div class="p-4 pt-5">
      <%= cond do %>
      <% @selected_nutrition_category == nil && @selected_exercise_category == nil -> %>
        <.exercise_and_nutrition_category_selections
          nutrition_categories={@nutrition_categories}
          exercise_categories={@exercise_categories}
        />

      <% @selected_nutrition_category != nil -> %>
        <%= cond do %>
        <% !@selected_calorie_count -> %>
          <.calorie_selection calorie_options={@selected_nutrition_category.calorie_options}/>

        <% true -> %>
          <.save_nutrition_selection
            selected_nutrition_category_name={@selected_nutrition_category.name}
            selected_nutrition_category_id={@selected_nutrition_category.id}
            selected_calorie_count={@selected_calorie_count}
          />

        <% end %>

      <% @selected_exercise_category != nil -> %>
        <%= cond do %>
        <% !@selected_intensity_level && @selected_exercise_category.measurement_kind == :minutes -> %>
          <.intensity_selection />

        <% !@selected_exercise_measurement -> %>
          <.measurement_selection measurement_kind={@selected_exercise_category.measurement_kind}/>

        <% true -> %>
          <.save_exercise_selection
            exercise_category_id={@selected_exercise_category.id}
            exercise_category_name={@selected_exercise_category.name}
            intensity_level={@selected_intensity_level}
            measurement={@selected_exercise_measurement}
          />

        <% end %>

      <% end %>
    </div>

    <div class="pt-6"> </div>
    <% end %>
    """
  end

  # Private

  ## Helpers

  defp get_amount_options() do
    1..100
  end

  defp get_duration_minute_options() do
    sub_hour_options = Enum.to_list(15..60//5)
    one_to_ten_hour_options = Enum.to_list(75..600//15)

    sub_hour_options ++ one_to_ten_hour_options
  end

  defp button_readable_minute_option(total_minutes) do
    minutes = rem(total_minutes, 60)
    hours = div(total_minutes, 60)

    cond do
      minutes == 0 && hours == 1 ->
        "1 hour"

      minutes == 0 ->
        "#{hours} hours"

      hours == 0 ->
        "#{minutes} min"

      true ->
        "#{hours}h #{minutes}m"
    end
  end

  ## Markdowns

  defp exercise_and_nutrition_category_selections(assigns) do
    ~H"""
    <.nutrition_divider />

    <.nutriton_category_selection
      nutrition_categories={@nutrition_categories}
    />

    <.exercise_divider />
    <.exercise_category_selection
      exercise_categories={@exercise_categories}
    />
    """
  end

  defp nutrition_divider(assigns) do
    ~H"""
    <div class="level is-mobile pb-0 mb-2 has-text-grey">
      <div class="level-left">
        <div class="level-item">
          <span>
            Nutrition
          </span>
        </div>
      </div>

      <div class="level-item ml-3" style="border-bottom: 1px #DDD dashed;"></div>

      <div class="level-right has-text-grey">
        <span class="icon">
          <i class="fas fa-utensils"></i>
        </span>
      </div>
    </div>
    """
  end

  defp exercise_divider(assigns) do
    ~H"""
    <div class="level is-mobile pb-0 mt-5 mb-2 has-text-grey">
      <div class="level-left">
        <div class="level-item">
          <span>
            Exercise
          </span>
        </div>
      </div>

      <div class="level-item ml-3" style="border-bottom: 1px #DDD dashed;"></div>

      <div class="level-right has-text-grey">
        <span class="icon">
          <i class="fas fa-dumbbell"></i>
        </span>
      </div>
    </div>
    """
  end

  defp nutriton_category_selection(assigns) do
    ~H"""
    <div class="is-flex is-flex-direction-row is-flex-wrap-wrap mb-4">
      <%= for nutrition_category <- @nutrition_categories do %>
      <div class="flex-basis-half p-1">
        <button
          class="button is-small small-button-medium-height is-fullwidth is-white has_border_grey"
          style="border-radius: 5px"
          phx-click="select_nutrition_category"
          phx-value-nutrition_category_id={nutrition_category.id}
        >
          <%= if nutrition_category.icon_css_class do %>
          <span class="icon is-small has_text_dark_blue">
            <i class={nutrition_category.icon_css_class}></i>
          </span>
          <% end %>
          <span class="has_text_dark_blue">
            <%= nutrition_category.name %>
          </span>
        </button>
      </div>
      <% end %>
    </div>
    """
  end

  defp exercise_category_selection(assigns) do
    ~H"""
    <div class="is-flex is-flex-direction-row is-flex-wrap-wrap	">
      <%= for exercise_category <- @exercise_categories do %>
        <div
          class={ViewUtils.class_list("p-1 flex-basis-third", %{"flex-basis-half" => exercise_category.icon_css_class != nil})}
        >
          <button
            class="button is-small small-button-medium-height is-white is-small is-fullwidth has_border_grey"
            style="border-radius: 5px"
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
    """
  end

  defp calorie_selection(assigns) do
    ~H"""
    <p class="pt-0 pb-4">
      Approximately how many calories?
    </p>
    <div class="is-flex is-flex-direction-row is-flex-wrap-wrap	">
      <%= for calorie_count <- @calorie_options do %>
      <div
        class={
          ViewUtils.class_list("p-1", %{
              "flex-basis-full" => rem(calorie_count, 100) == 0,
              "flex-basis-third" => rem(calorie_count, 100) != 0
            }
          )
        }
      >
        <button
          class="button is-small small-button-medium-height is-fullwidth is-white is-rounded has_border_grey"
          style="border-radius: 5px"
          phx-click="select_calorie_option"
          phx-value-calorie_count={calorie_count}
        >
          <span class=""><%= calorie_count %> cals</span>
        </button>
      </div>
      <% end %>
    </div>
    """
  end

  defp intensity_selection(assigns) do
    ~H"""
    <p class="pt-0 pb-4">
      How hard did you go?
    </p>
    <div class="is-flex is-flex-direction-row is-flex-wrap-wrap	">
    <%= for intensity_level <- Fitness.intensity_levels do %>
      <div class="tile p-1">
        <button
          class="button is-small small-button-medium-height is-fullwidth is-white is-rounded has_border_grey"
          style="border-radius: 5px"
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
    """
  end

  defp measurement_selection(assigns) do
    ~H"""
    <%= case @measurement_kind do %>
    <% :repetitions -> %>
      <p class="pt-0 pb-4">
        How many?
      </p>
      <div class="is-flex is-flex-wrap-wrap">
      <%= for amount_option <- get_amount_options() do %>
        <div
          class={
            ViewUtils.class_list("p-1", %{
                "flex-basis-full" => rem(amount_option, 10) == 0,
                "flex-basis-third" => rem(amount_option, 10) != 0
              }
            )
          }
        >
          <button
            class="button is-small small-button-medium-height is-white is-rounded is-fullwidth has_border_grey"
            style="border-radius: 5px;"
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
      <div class="is-flex is-flex-wrap-wrap	">
      <%= for minute_option <- get_duration_minute_options() do %>
        <div
            class={
              ViewUtils.class_list("p-1", %{
                  "flex-basis-full" => rem(minute_option, 60) == 0,
                  "flex-basis-third" => rem(minute_option, 60) != 0
                }
              )
            }
          >
          <button
            class="button is-small small-button-medium-height is-white is-rounded is-fullwidth has_border_grey"
            style="border-radius: 5px;"
            phx-click="select_exercise_measurement"
            phx-value-exercise_measurement={minute_option}
          >
            <%= button_readable_minute_option(minute_option) %>
          </button>
        </div>
      <% end %>
      </div>

    <% end %>
    """
  end

  defp save_nutrition_selection(assigns) do
    ~H"""
    <p class="pt-0 pb-4 has-text-centered">
      <span>
        <%=
          Fitness.human_readable_nutrition_and_calorie_selection(
            @selected_nutrition_category_name,
            @selected_calorie_count
          )
        %>
      </span>
    </p>
    <button
      class="button is-fullwidth is-dark has_background_purple"
      phx-click="save_new_nutrition_entry"
      phx-value-selected_nutrition_category_id={@selected_nutrition_category_id}
      phx-value-selected_calorie_count={@selected_calorie_count}
    >
      <span class="icon has-text-white">
        <i class="fas fa-pencil-alt"></i>
      </span>
      <span>
        Save
      </span>
    </button>
    """
  end

  defp save_exercise_selection(assigns) do
    ~H"""
    <p class="pt-0 pb-4 has-text-centered">
      <span>
        I did <%=
          HumanReadable.human_readable_exercise_selection(
            @exercise_category_name,
            @intensity_level,
            @measurement
          )
        %>
      </span>
    </p>
    <button
      class="button is-fullwidth is-dark has_background_purple"
      phx-click="save_new_exercise_entry"
      phx-value-selected_exercise_category_id={@exercise_category_id}
      phx-value-selected_exercise_measurement={@measurement}
      phx-value-selected_intensity_level={@intensity_level}
    >
      <span class="icon has-text-white">
        <i class="fas fa-pencil-alt"></i>
      </span>
      <span>
        Save
      </span>
    </button>
    """
  end
end
