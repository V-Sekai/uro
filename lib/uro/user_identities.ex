defmodule Uro.UserIdentities do
  use PowAssent.Ecto.UserIdentities.Context,
    repo: Uro.Repo,
    user: Uro.Accounts.User

  def all(user) do
    pow_assent_all(user)
  end

  def create_user(user_identity_params, user_params, user_id_params) do
    pow_assent_create_user(user_identity_params, user_params, user_id_params)
  end
end
