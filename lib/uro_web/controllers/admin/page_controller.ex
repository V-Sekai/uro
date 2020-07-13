defmodule UroWeb.Admin.PageController do
  use UroWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
