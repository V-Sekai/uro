defmodule Uro do
  @moduledoc """
  The entrypoint for defining your API interface, such
  as controllers and so on.

  This can be used in your application as:

      use Uro, :controller

  The definitions below will be executed for every controller,
  so keep them short and clean, focused on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: Uro
      use Uro.Helpers.API
      use OpenApiSpex.ControllerSpecs

      import Plug.Conn
      import Uro.Helpers.User

      use Gettext, backend: Uro.Gettext
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      use Gettext, backend: Uro.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
