defmodule UroWeb.LoginLive do
  use Uro, :live_view

  def render(assigns) do
    ~H"""
    <p class="text-orange orange bg-red">Hellop</p>
    """
  end

  def mount(socket, _opts) do
    {:ok, socket}
  end
end
