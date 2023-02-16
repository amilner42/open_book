defmodule OpenBookWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use OpenBookWeb, :controller
      use OpenBookWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: OpenBookWeb

      import Plug.Conn
      import OpenBookWeb.Gettext
      alias OpenBookWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/open_book_web/templates",
        namespace: OpenBookWeb

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

      # Include shared imports and aliases for views
      unquote(view_helpers())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {OpenBookWeb.LayoutView, "live.html"}

      unquote(view_helpers())
    end
  end

  # Me editing phoenix to add some boilerplate around mounting / handle_params getting called twice on page load:
  #  - on page-load (no websocket)
  #  - on websocket connection
  def live_view_connected do
    quote do
      unquote(live_view())

      def mount(params, session, socket) do
        if(Phoenix.LiveView.connected?(socket)) do
          {:ok, socket} = mount_live(params, session, socket)

          IO.puts("GOT HERE")

          socket = assign(socket, :page_loading, false)

          {:ok, socket}
        else
          mount_dead(params, session, socket)
        end
      end

      def mount_dead(_params, _session, socket) do
        socket =
          socket
          |> assign(:page_loading, true)

        {:ok, socket}
      end

      def handle_params(params, url, socket) do
        if(Phoenix.LiveView.connected?(socket)) do
          handle_params_live(params, url, socket)
        else
          handle_params_dead(params, url, socket)
        end
      end

      def handle_params_dead(_params, _url, socket) do
        {:noreply, socket}
      end
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(view_helpers())
    end
  end

  def component do
    quote do
      use Phoenix.Component

      unquote(view_helpers())
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import OpenBookWeb.Gettext
    end
  end

  defp view_helpers do
    quote do
      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      # Import LiveView and .heex helpers (live_render, live_patch, <.form>, etc)
      import Phoenix.Component

      # Import basic rendering functionality (render, render_layout, etc)
      import Phoenix.View

      import OpenBookWeb.ErrorHelpers
      import OpenBookWeb.Gettext
      alias OpenBookWeb.Router.Helpers, as: Routes
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
