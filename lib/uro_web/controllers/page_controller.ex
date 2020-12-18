defmodule UroWeb.PageController do
  use UroWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def about(conn, _params) do
    render(conn, "about.html")
  end

  def download(conn, _params) do
    render(conn, "download.html")
  end
end
