defmodule UroWeb.API.V1.ShardView do
  use UroWeb, :view

  def render("index.json", %{shard: shard}) do
    shard
  end

  def render("show.json", %{shard: shard}) do
    shard
  end

  def render("shard.json", %{shard: shard}) do
    shard
  end
end
