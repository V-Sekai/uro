defmodule UroWeb.LoginLive do
  use Uro, :live_view

  def render(assigns) do
    ~H"""
    Hello, world
    """
  end

  def mount(socket, _opts) do
    {:ok, socket}
  end
end
