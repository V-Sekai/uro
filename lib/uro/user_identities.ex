defmodule Uro.UserIdentities do
  use PowAssent.Ecto.UserIdentities.Context,
    repo: Uro.Repo,
    user: Uro.Accounts.User

  def all(user) do
    pow_assent_all(user)
  end
end
