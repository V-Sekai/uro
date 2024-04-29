defmodule Vertex.UserIdentities do
  use PowAssent.Ecto.UserIdentities.Context,
    repo: Vertex.Repo,
    user: Vertex.Accounts.User

  def all(user) do
    pow_assent_all(user)
  end
end
