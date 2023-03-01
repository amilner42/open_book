defmodule OpenBookWeb.NutritionLogLive do
  @moduledoc """
  The LiveView for the nutrition log.

  Assigns:
    - nutrition_categories: array of `NutritionCategory`
  """
  use OpenBookWeb, :live_view_connected

  alias OpenBook.Accounts
  alias OpenBook.Fitness
  alias OpenBook.LittleLogger, as: LL

  alias OpenBookWeb.HomeLive
  alias OpenBookWeb.ViewUtils

  def mount_live(_params, %{"user_id" => user_id}, socket) do
    LL.metadata_add_current_user_id(user_id)
    LL.metadata_add_current_page("NutritionLogLive")
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

    # Nutrition Categories

    socket =
      if(socket.assigns[:nutrition_categories]) do
        socket
      else
        nutrition_categories = Fitness.fetch_all_nutrition_categories()

        socket
        |> assign(:nutrition_categories, nutrition_categories)
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

    {:noreply, socket}
  end

  ## Render

  def render(assigns) do
    ~H"""
    <%= unless @page_loading do %>
        <section class="section pt-5">
          <%= cond do %>
          <% !@selected_nutrition_category -> %>
            <p class="pt-0 pb-4">
              What did you have?
            </p>
            <div class="is-flex is-flex-direction-row is-flex-wrap-wrap	">
              <%= for nutrition_category <- @nutrition_categories do %>
              <div class="tile p-1">
                <button
                  class="button is-medium is-fullwidth is-light has_border_grey"
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

          <% !@selected_calorie_count -> %>
            <p class="pt-0 pb-4">
              Approximately how many calories?
            </p>
            <div class="is-flex is-flex-direction-row is-flex-wrap-wrap	">
              <%= for calorie_count <- @selected_nutrition_category.calorie_options do %>
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
                  class="button is-small small-button-medium-height is-fullwidth is-light br-0 has_border_grey"
                  phx-click="select_calorie_option"
                  phx-value-calorie_count={calorie_count}
                >
                  <span class=""><%= calorie_count %> cals</span>
                </button>
              </div>
              <% end %>
            </div>

          <% @selected_nutrition_category && @selected_calorie_count -> %>
            <p class="pt-0 pb-4 has-text-centered">
              <span>
                <%=
                  Fitness.human_readable_nutrition_and_calorie_selection(
                    @selected_nutrition_category.name,
                    @selected_calorie_count
                  )
                %>
              </span>
            </p>
            <button
              class="button is-fullwidth is-dark has_background_purple"
              phx-click="confirm_add_new_nutrition_entry"
              phx-value-selected_nutrition_category_id={@selected_nutrition_category.id}
              phx-value-selected_calorie_count={@selected_calorie_count}
            >
              <span class="icon has-text-white">
                <i class="fas fa-pencil-alt"></i>
              </span>
              <span>
                Save
              </span>
            </button>

          <% true -> %>
            <%= nil %>

          <% end %>
        </section>
    <% end %>
    """
  end

  ## Handle Events

  def handle_event(
        "confirm_add_new_nutrition_entry",
        _params = %{
          "selected_nutrition_category_id" => selected_nutrition_category_id,
          "selected_calorie_count" => selected_calorie_count
        },
        socket
      ) do
    LL.info_event("handle_event", %{event_name: :confirm_add_new_nutrition_entry})

    %{user: user} = socket.assigns

    params = %{
      nutrition_category_id: selected_nutrition_category_id,
      calorie_estimate: selected_calorie_count,
      # TODO(Arie): timezone-support
      local_datetime: DateTime.now!("America/Los_Angeles")
    }

    Fitness.insert_new_nutrition_entry!(user.id, params)

    to = Routes.live_path(OpenBookWeb.Endpoint, HomeLive, %{stbt: "book"})

    socket =
      socket
      |> push_navigate(to: to)

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
end
