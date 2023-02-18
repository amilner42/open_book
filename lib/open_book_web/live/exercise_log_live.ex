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

  # Private

  ## Markdowns

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
