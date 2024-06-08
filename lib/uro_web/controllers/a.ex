defmodule UroWeb.A do
  use UroWeb, :controller

  def index(conn, _params) do
    text(conn, "Hello, world!")
  end
end
