defmodule Uro.Oauth.Vroid do
  use Assent.Strategy.OAuth2.Base

  @impl true
  def default_config(_config) do
    config = Application.get_env(:uro, :pow_assent)[:providers][:vroid]

    [
      base_url: "https://hub.vroid.com",
      authorize_url: "/oauth/authorize",
      token_url: "/oauth/token",
      user_url: "/api/account",
      base_headers: [{"X-Api-Version", "11"}],
      authorization_params: [response_type: "code", scope: "default"],
      token_params: [grant_type: "authorization_code"],
      auth_method: :client_secret_post
    ]
  end

  @impl true
  def normalize(_config, %{
        "data" => %{
          "user_detail" => %{
            "user" => user
          }
        }
      }) do
    avatar = get_in(user, ["icon", "sq170", "url"])
    IO.inspect(avatar)

    {:ok,
     %{
       "sub" => user["id"],
       "name" => user["name"],
       "picture" => avatar,

       # Placeholder
       "email" => "#{user["id"]}@vroid.vsekai.local"
     }}
  end
end
