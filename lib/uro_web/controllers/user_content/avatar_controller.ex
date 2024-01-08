defmodule UroWeb.UserContent.AvatarController do
  use UroWeb, :controller

  alias Uro.UserContent

  def index(conn, params) do
    page = UserContent.list_public_avatars_paginated(params)
    render(conn, "index.html", page: page)
  end

  def show(conn, %{"id" => id}) do
    avatar = UserContent.get_avatar!(id)
    render(conn, "show.html", avatar: avatar)
  end
end
