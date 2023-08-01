defmodule OpenBookWeb.Router do
  use OpenBookWeb, :router

  import OpenBook.Plugs.Auth,
    only: [
      get_current_user_from_session: 2,
      redirect_if_logged_in: 2,
      authenticate_user: 2
    ]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {OpenBookWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :get_current_user_from_session
  end

  pipeline :browser_logged_in_user do
    plug :browser
    plug :authenticate_user, %{redirect_to: "/"}
  end

  pipeline :browser_logged_out_user do
    plug :browser
    plug :redirect_if_logged_in, %{redirect_to: "/home"}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Logged-out-only routes. Will redirect if logged in.
  scope "/", OpenBookWeb do
    pipe_through :browser_logged_out_user

    get "/", PageController, :home
    get "/login/:code", SessionController, :login_through_url_with_verification_code
  end

  # Logged-in-only routes. Will redirect if logged out.
  scope "/", OpenBookWeb do
    pipe_through :browser_logged_in_user

    live "/home", HomeLive

    get "/logout", SessionController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", OpenBookWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:open_book, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: OpenBookWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
