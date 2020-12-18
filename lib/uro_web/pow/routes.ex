defmodule UroWeb.Pow.Routes do
  use Pow.Phoenix.Routes
  alias UroWeb.Router.Helpers, as: Routes

  def session_path(conn, _verb, _query_params \\ []), do: Routes.signin_path(conn, :new)
  def registration_path(conn, _verb, _query_params \\ []), do: Routes.signup_path(conn, :new)
end
