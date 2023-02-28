defmodule OpenBookWeb.Router do
  use OpenBookWeb, :router

  import OpenBook.Plugs.Auth,
    only: [
      get_current_user_from_session: 2,
      redirect_if_logged_in: 2,
      authenticate_user: 2
    ]

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {OpenBookWeb.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:get_current_user_from_session)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  # Logged out routes.
  scope "/", OpenBookWeb do
    pipe_through([:browser, :redirect_if_logged_in])

    get("/", PageController, :index)
    get("/login/:code", SessionController, :login_through_url_with_verification_code)
  end

  # Logged in routes.
  scope "/", OpenBookWeb do
    pipe_through([:browser, :authenticate_user])

    live("/log/exercise", ExerciseLogLive)
    live("/log/nutrition", NutritionLogLive)
    live("/home", HomeLive)

    # Session Routes
    get("/logout", SessionController, :delete)
  end

  # Other scopes may use custom stacks.
  # scope "/api", OpenBookWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: OpenBookWeb.Telemetry)
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through(:browser)

      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end
end
