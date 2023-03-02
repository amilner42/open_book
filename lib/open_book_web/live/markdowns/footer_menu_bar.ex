defmodule OpenBookWeb.Markdowns.FooterMenuBar do
  use OpenBookWeb, :component

  alias Phoenix.LiveView.JS

  alias OpenBookWeb.BookLive
  alias OpenBookWeb.ChallengesLive
  alias OpenBookWeb.FriendsLive
  alias OpenBookWeb.ViewUtils
  alias OpenBookWeb.WriteLive

  def footer_menu_bar(assigns) do
    ~H"""
    <div class="new_entry_footer">
      <p
        class="buttons"
        style="border-top: 0.5px solid #DDD"
      >
        <button
          class={ViewUtils.class_list(
              "button is_quarter_width has-text-grey b-0 m-0 pt-0 mt-0",
              %{"has_text_purple" => @active_tab == "challenges", "has-text-grey" => @active_tab != "challenges"}
            )
          }
          style="height: 55px;"
          phx-click={JS.navigate(Routes.live_path(OpenBookWeb.Endpoint, ChallengesLive))}
        >
          <div style="position: absolute; top: 5px;">
            <i class="fas fa-trophy"></i>
          </div>

          <div class="is_size_8" style="position: absolute; bottom: 14px;">
            Challenges
          </div>
        </button>

        <button
          class={ViewUtils.class_list(
              "button is_quarter_width has-text-grey b-0 m-0 pt-0 mt-0",
              %{"has_text_purple" => @active_tab == "book", "has-text-grey" => @active_tab != "book"}
            )
          }
          style="height: 55px;"
          phx-click={JS.navigate(Routes.live_path(OpenBookWeb.Endpoint, BookLive))}
        >
          <div style="position: absolute; top: 5px;">
            <i class="fas fa-book"></i>
          </div>

          <div class="is_size_8" style="position: absolute; bottom: 14px;">
            OpenBook
          </div>
        </button>

        <button
          class={ViewUtils.class_list(
              "button is_quarter_width has-text-grey b-0 m-0 pt-0 mt-0",
              %{"has_text_purple" => @active_tab == "write", "has-text-grey" => @active_tab != "write"}
            )
          }
          style="height: 55px;"
          phx-click={JS.navigate(Routes.live_path(OpenBookWeb.Endpoint, WriteLive))}
        >
          <div style="position: absolute; top: 5px;">
            <i class="fas fa-pencil-alt"></i>
          </div>

          <div class="is_size_8" style="position: absolute; bottom: 14px;">
            Write
          </div>
        </button>

        <button
          class={ViewUtils.class_list(
              "button is_quarter_width has-text-grey b-0 m-0 pt-0 mt-0",
              %{"has_text_purple" => @active_tab == "friends", "has-text-grey" => @active_tab != "friends"}
            )
          }
          style="height: 55px;"
          phx-click={JS.navigate(Routes.live_path(OpenBookWeb.Endpoint, FriendsLive))}
        >
          <div style="position: absolute; top: 5px;">
            <i class="fas fa-user-friends"></i>
          </div>

          <div class="is_size_8" style="position: absolute; bottom: 14px;">
            Friends
          </div>
        </button>

      </p>
    </div>
    """
  end
end
