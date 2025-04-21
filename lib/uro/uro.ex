defmodule Uro do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use Uro, :controller
      use Uro, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def mailer_view do
    quote do
      use Phoenix.View,
        root: "lib/uro_web/templates",
        namespace: Uro

      use Phoenix.HTML
    end
  end

  def controller do
    quote do
      use Phoenix.Controller, namespace: Uro
      use Uro.Helpers.API
      use OpenApiSpex.ControllerSpecs

      import Plug.Conn
      import Uro.Helpers.User

      use Gettext, backend: Uro.Gettext 

      # alias Uro.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/uro_web/templates",
        namespace: Uro

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 1, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import Uro.ErrorHelpers

      use Gettext, backend: Uro.Gettext 

      alias Uro.Router.Helpers, as: Routes
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

  def html do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # Translation
      use Gettext, backend: Uro.Gettext

      # HTML escaping functionality
      import Phoenix.HTML
      # Core UI components
      use UroWeb.Components.MishkaComponents

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS

      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: Uro.Endpoint,
        router: Uro.Router,
        statics: Uro.static_paths()
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {UroWeb.Layouts, :app}

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      use Gettext, backend: Uro.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)
end
