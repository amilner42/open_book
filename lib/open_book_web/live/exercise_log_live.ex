defmodule OpenBookWeb.ExerciseLogLive do
  @moduledoc """
  The LiveView for the exercise log.

  Assigns:
    - exercise_categories: array of `ExerciseCategory`
  """
  use OpenBookWeb, :live_view_connected

  alias OpenBook.LittleLogger, as: LL
  alias OpenBook.Fitness

  def mount_live(_params, %{"user_id" => user_id}, socket) do
    LL.metadata_add_current_user_id(user_id)
    LL.info_event("live_page_load", %{page: "ExerciseLogLive"})

    {:ok, socket}
  end

  def handle_params_live(params, _url, socket) do
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
      <section class="section">
      <.exercise_title_section />
      <%= cond do %>
      <% !@selected_exercise_category  -> %>
        <p class="pb-2">
          What did you go for today?
        </p>
        <div class="buttons are-medium">
        <%= for exercise_category <- @exercise_categories do %>
          <button
            class="button is-light is-fullwidth"
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
        <% end %>
        </div>

      <%= !@selected_intensity_level && @selected_exercise_category.measurement_kind == :duration -> %>
        <p class="pb-2">
          How hard did you go?
        </p>
        <%!-- TODO(Arie): Move intensity levels to exercise entry schema once I add it to DB. --%>
        <div class="buttons">
        <%= for intensity_level <- [:light, :regular, :intense] do %>
          <button
            class="button is-light is-fullwidth"
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
    """
  end

  ## Handle Events

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

  # Private

  ## Markdowns

  defp exercise_title_section(assigns) do
    ~H"""
    <section class="pb-4">
      <div>
        <p class="title is-4">
          Exercise Log
        </p>
        <p class="subtitle is-7">
          It's always a better day when you workout
        </p>
      </div>
    </section>
    """
  end
end
