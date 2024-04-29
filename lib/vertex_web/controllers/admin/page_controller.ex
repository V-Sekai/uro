defmodule VertexWeb.Admin.PageController do
  use VertexWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
