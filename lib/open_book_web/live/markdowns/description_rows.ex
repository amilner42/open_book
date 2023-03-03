defmodule OpenBookWeb.Markdowns.DescriptionRows do
  use OpenBookWeb, :component

  def nutrition_description_row(assigns) do
    ~H"""
    <%= if assigns.maybe_readable_calorie_description do %>
      <div class="level is-mobile pb-0 mb-0">
        <div class="level-left">
          <div class="level-item mr-2">
            <span class="icon">
              <i class="fas fa-utensils"></i>
            </span>
          </div>
          <div class="level-item">
            <span style="max-width: 250px; line-height: 20px;">
              <%= @maybe_readable_calorie_description %>
            </span>
          </div>
        </div>
      </div>
    <% end %>
    """
  end

  def exercise_description_row(assigns) do
    ~H"""
    <%= if assigns.maybe_readable_exercise_description do %>
      <div class="level is-mobile pb-0 mb-0 mt-4">
        <div class="level-left">
          <div class="level-item mr-2">
            <span class="icon">
            <i class="fas fa-dumbbell"></i>
            </span>
          </div>
          <div class="level-item">
            <span style="max-width: 250px; line-height: 20px;">
              <%= @maybe_readable_exercise_description %>
            </span>
          </div>
        </div>
      </div>
    <% end %>
    """
  end
end
