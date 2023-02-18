defmodule OpenBookWeb.LogLive do
  @moduledoc """
  The LiveView for the journal page where one enters data.

  Assigns:
    - kind: string in `@all_kinds`
    - nutrition_categories: array of `NutritionCategory`
    - exercise_categories: array of `ExerciseCategory`
  """
  use OpenBookWeb, :live_view_connected

  alias OpenBook.LittleLogger, as: LL
  alias OpenBook.Fitness

  @exercise_kind "exercise"
  @nutrition_kind "nutrition"
  @default_kind @nutrition_kind
  @all_kinds [@nutrition_kind, @exercise_kind]

  def mount_live(_params, %{"user_id" => user_id}, socket) do
    LL.metadata_add_current_user_id(user_id)

    {:ok, socket}
  end

  def handle_params_live(params, _url, socket) do
    # Params

    socket =
      socket
      |> assign(:params, params)

    # Kind

    kind = params["kind"]

    kind =
      if kind in @all_kinds do
        kind
      else
        @default_kind
      end

    socket =
      socket
      |> assign(:kind, kind)

    # Nutrition Categories / Exercise Categories

    socket =
      case kind do
        @nutrition_kind ->
          if(socket.assigns[:nutrition_categories]) do
            socket
          else
            nutrition_categories = Fitness.fetch_all_nutrition_categories()

            socket
            |> assign(:nutrition_categories, nutrition_categories)
          end

        @exercise_kind ->
          if(socket.assigns[:exercise_categories]) do
            socket
          else
            exercise_categories = Fitness.fetch_all_exercise_categories()

            socket
            |> assign(:exercise_categories, exercise_categories)
          end
      end

    # Selected Nutrition Category

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

    # Selected exercise measurement

    selected_exercise_measurement = params["sem"]

    socket =
      socket
      |> assign(:selected_exercise_measurement, selected_exercise_measurement)

    {:noreply, socket}
  end

  ## Render

  def render(assigns) do
    ~H"""
    <%= unless @page_loading do %>
      <%= case @kind do %>
      <% "nutrition" -> %>
        <.nutrition_title_section
          selected_nutrition_category={@selected_nutrition_category}
          selected_calorie_count={@selected_calorie_count}
        />
        <section class="section pt-0">
        <%= cond do %>
        <% !@selected_nutrition_category -> %>
          <div class="buttons are-medium">
            <%= for nutrition_category <- @nutrition_categories do %>
            <button
              class="button is-fullwidth is-outlined has_dark_blue_border"
              phx-click="select_nutrition_category"
              phx-value-nutrition_category_id={nutrition_category.id}
            >
              <%= if nutrition_category.icon_css_class do %>
              <span class="icon is-small has_text_dark_blue">
                <i class={nutrition_category.icon_css_class}></i>
              </span>
              <% end %>
              <span>
                <%= nutrition_category.name %>
              </span>
            </button>
            <% end %>
          </div>

        <% !@selected_calorie_count -> %>
          <div class="buttons are-small">
            <%= for calorie_count <- @selected_nutrition_category.calorie_options do %>
              <button
                class="button is-fullwidth is-outlined has_dark_blue_border"
                phx-click="select_calorie_option"
                phx-value-calorie_count={calorie_count}
              >
                <span class="has_text_dark_blue">~<%= calorie_count %> calories</span>
              </button>
            <% end %>
          </div>

        <% @selected_nutrition_category && @selected_calorie_count -> %>
          <button
            class="button is-fullwidth is-success"
            phx-click="confirm_add_new_nutrition_entry"
            phx-value-selected_nutrition_category_id={@selected_nutrition_category.id}
            phx-value-selected_calorie_count={@selected_calorie_count}
          >
            confirm
          </button>

        <% true -> %>
          <%= nil %>

        <% end %>
        </section>

      <% "exercise" -> %>
        <.exercise_title_section
          selected_exercise_category={@selected_exercise_category}
          selected_exercise_measurement={@selected_exercise_measurement}
        />
        <section class="section pt-0">
        <%= cond do %>
        <% !@selected_exercise_category  -> %>
          <div class="buttons are-medium">
          <%= for exercise_category <- @exercise_categories do %>
            <button
              class="button is-fullwidth is-outlined has_dark_blue_border"
              phx-click="select_exercise_category"
              phx-value-exercise_category_id={exercise_category.id}
            >
              <%= if exercise_category.icon_css_class do %>
              <span class="icon is-small has_text_dark_blue">
                <i class={exercise_category.icon_css_class}></i>
              </span>
              <% end %>
              <span>
              <%= exercise_category.name %>
              </span>
            </button>
          <% end %>
          </div>

        <%= !@selected_exercise_measurement -> %>
          <div class="buttons are-small">
          <%= case @selected_exercise_category && @selected_exercise_category.measurement_kind do %>
          <% nil -> %>
            <%= nil %>

          <% :amount -> %>
            todo amount

          <% :duration -> %>
            todo duration

          <% end %>
          </div>

        <% true -> %>
          <%= nil %>

        <% end %>
        </section>
      <% end %>
    <% end %>
    """
  end

  ## Handle Events

  def handle_event(
        "confirm_add_new_nutrition_entry",
        params = %{
          "selected_nutrition_category_id" => selected_nutrition_category_id,
          "selected_calorie_count" => selected_calorie_count
        },
        socket
      ) do
    # TODO(Arie): Implement.
    {:noreply, socket}
  end

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

  # Private

  ## Markdowns

  defp nutrition_title_section(assigns) do
    ~H"""
    <section class="section pb-5">
      <p>
        <div class="title is-4">
          Nutrition Log
        </div>

        <div class="subtitle is-6 mb-0">
          What did you have? <span class="has-text-weight-semibold"><%= @selected_nutrition_category && @selected_nutrition_category.name %></span>
        </div>

        <%= if @selected_nutrition_category do %>
        <div class="subtitle is-6 mb-0">
          Approximately how many calories? <span class="has-text-weight-semibold"><%= @selected_calorie_count %></span>
        </div>
        <% end %>
      </p>
    </section>
    """
  end

  defp exercise_title_section(assigns) do
    ~H"""
    <section class="section pb-5">
      <p>
        <div class="title is-4">
          Exercise Log
        </div>

        <div class="subtitle is-6 mb-0">
          What did you do? <span class="has-text-weight-semibold"><%= @selected_exercise_category && @selected_exercise_category.name %></span>
        </div>

        <%= case @selected_exercise_category && @selected_exercise_category.measurement_kind do %>
        <% :duration -> %>
          <div class="subtitle is-6 mb-0">
            Approximately how long? <span class="has-text-weight-semibold"><%= @selected_exercise_measurement %></span>
          </div>

        <% :amount -> %>
          <div class="subtitle is-6 mb-0">
            How many? <span class="has-text-weight-semibold">todo</span>
          </div>

        <% nil -> %>
          <%= nil %>

        <% end %>
      </p>
    </section>
    """
  end
end
