defmodule OpenBookWeb.Markdowns.FooterMenuBar do
  use OpenBookWeb, :component

  alias OpenBookWeb.ExerciseLogLive
  alias OpenBookWeb.NutritionLogLive

  def footer_menu_bar(assigns) do
    ~H"""
    <div class="new_entry_footer">
      <p
        class="buttons"
        style="border-top: 0.5px solid #DDD"
      >
        <.link
          navigate={Routes.live_path(OpenBookWeb.Endpoint, NutritionLogLive)}
          class="button is_quarter_width has-text-grey b-0 pb-4 m-0 br-0"
        >
          <span class="icon">
            <i class="fas fa-trophy"></i>
          </span>
        </.link>

        <.link
          navigate={Routes.live_path(OpenBookWeb.Endpoint, NutritionLogLive)}
          class="button is_quarter_width has-text-grey b-0 pb-4 m-0 br-0"
        >
          <span class="icon">
            <i class="fas fa-book"></i>
          </span>
        </.link>

        <.link
          navigate={Routes.live_path(OpenBookWeb.Endpoint, ExerciseLogLive)}
          class="button is_quarter_width has-text-grey is-white b-0 pb-4 m-0 br-0"
        >
          <span class="icon">
            <i class="fas fa-user-friends"></i>
          </span>
        </.link>

        <.link
          navigate={Routes.live_path(OpenBookWeb.Endpoint, ExerciseLogLive)}
          class="button is_quarter_width has-text-grey is-white b-0 pb-4 m-0 br-0"
        >
          <span class="icon">
            <i class="fas fa-pencil-alt"></i>
          </span>
        </.link>
      </p>
    </div>
    """
  end
end

  ## Markdown

  # TODO(Arie): Delete.
  # defp top_bar_nav(assigns) do
  #   ~H"""
  #   <div class="buttons top-bar has-addons is-centered pt-4 pb-4 mb-0 button-navbar">
  #     <button
  #       class={ViewUtils.class_list("button", %{"is-selected": @selected_tab == "stats" })}
  #       style="width: 110px"
  #       phx-click="top_level_navigate"
  #       phx-value-top_bar_tab="stats"
  #     >
  #       <span class="icon">
  #         <i class="fas fa-trophy"></i>
  #       </span>
  #       <span>Stats</span>
  #     </button>

  #     <button
  #       class={ViewUtils.class_list("button", %{"is-selected": @selected_tab == "book" })}
  #       style="width: 110px"
  #       phx-click="top_level_navigate"
  #       phx-value-top_bar_tab="book"
  #     >
  #       <span class="icon">
  #         <i class="fas fa-book"></i>
  #       </span>
  #       <span>Book</span>
  #     </button>

  #     <button
  #       class={ViewUtils.class_list("button", %{"is-selected": @selected_tab == "friends" })}
  #       style="width: 110px"
  #       phx-click="top_level_navigate"
  #       phx-value-top_bar_tab="friends"
  #     >
  #       <span class="icon">
  #         <i class="fas fa-user-friends"></i>
  #       </span>
  #       <span>Friends</span>
  #     </button>
  #   </div>
  #   """
  # end
