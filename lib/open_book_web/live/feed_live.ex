defmodule OpenBookWeb.FeedLive do
  @moduledoc """
  The LiveView for the feed page which is essentially the home page, showing a list of
  """
  use OpenBookWeb, :live_view

  import Phoenix.Component

  alias OpenBook.LittleLogger, as: LL
  alias OpenBookWeb.ExerciseLogLive
  alias OpenBookWeb.NutritionLogLive

  def mount(_params, %{"user_id" => user_id}, socket) do
    LL.metadata_add_current_user_id(user_id)

    {:ok, socket}
  end

  ## Render

  def render(assigns) do
    ~H"""
    <.new_entry_footer />
    """
  end

  ## Handle Events

  # Private

  ## Markdown

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
