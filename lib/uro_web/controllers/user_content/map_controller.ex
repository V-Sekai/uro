defmodule UroWeb.UserContent.MapController do
  use UroWeb, :controller

  alias Uro.UserContent

  def index(conn, params) do
    page = UserContent.list_public_maps_paginated(params)
    render(conn, "index.html", page: page)
  end

  def show(conn, %{"id" => id}) do
    map = UserContent.get_map!(id)
    render(conn, "show.html", map: map)
  end
end
