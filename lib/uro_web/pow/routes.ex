defmodule UroWeb.Pow.Routes do
  use Pow.Phoenix.Routes
  alias UroWeb.Router.Helpers, as: Routes

  def session_path(conn, verb, query_params \\ []),
    do: Routes.signin_path(conn, verb, query_params)

  def registration_path(conn, verb, query_params \\ []),
    do: Routes.signup_path(conn, verb, query_params)
end
