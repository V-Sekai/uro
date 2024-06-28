defmodule UroWeb.API.V1.AuthController do
  @moduledoc false

  alias Plug.Conn
  alias UroWeb.Endpoint

  use UroWeb, :controller
  use UroWeb.Helpers.API
  use OpenApiSpex.ControllerSpecs

  alias OpenApiSpex.Schema
  alias PowAssent.Plug

  tags(["authentication"])

  @pow_assent Application.compile_env(:uro, :pow_assent)

  @supported_providers @pow_assent[:providers]
  @supported_provider_names @pow_assent[:providers]
                            |> Keyword.keys()
                            |> Enum.map(&Atom.to_string/1)

  def supported_providers(), do: @supported_provider_names

  defmodule SchemaProviderID do
    @moduledoc """
    A string representing a provider ID, e.g. `discord`.
    """

    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "ProviderID",
      description: @moduledoc,
      type: :string
    })
  end

  operation(:index,
    operation_id: "getOAuthConfiguration",
    responses: %{
      :ok => {
        "",
        "application/json",
        %Schema{
          type: :object,
          required: ["supported_providers"],
          properties: %{
            supported_providers: %Schema{
              type: :array,
              items: %Schema{
                type: :object,
                required: ["id", "name"],
                properties: %{
                  id: SchemaProviderID,
                  name: %Schema{type: :string}
                }
              }
            }
          }
        }
      }
    }
  )

  def index(conn, _) do
    json(conn, %{
      supported_providers:
        @supported_provider_names
        |> Enum.map(fn provider_id ->
          provider =
            @supported_providers
            |> Keyword.get(String.to_atom(provider_id))

          %{
            id: provider_id,
            name: Keyword.get(provider, :label)
          }
        end)
    })
  end

  operation(:new,
    operation_id: "loginWithProvider",
    summary: "Login using OAuth2 Provider",
    description: "Create a new session.",
    parameters: [
      provider: [
        in: :path,
        schema: SchemaProviderID
      ],
      state: [
        in: :query,
        schema: %Schema{type: :string}
      ]
    ],
    responses: %{
      :ok => {
        "",
        "application/json",
        %Schema{
          type: :object,
          required: ["url", "state", "callback_url"],
          properties: %{
            url: %Schema{type: :string},
            state: %Schema{type: :string},
            callback_url: %Schema{type: :string}
          }
        }
      }
    }
  )

  defp login_error(conn, params) do
    redirect(conn,
      to: "/login?#{URI.encode_query(Map.merge(params, Map.take(conn.params, ["provider"])))}"
    )
  end

  defp login_success(conn, params) do
    redirect(conn,
      to: "/login?#{URI.encode_query(Map.merge(params, Map.take(conn.params, ["provider"])))}"
    )
  end

  def new(conn, %{"provider" => provider})
      when is_binary(provider) and provider in @supported_provider_names do
    redirect_url = redirect_uri(conn)
    {:ok, url, conn} = Plug.authorize_url(conn, provider, redirect_url)

    json(
      conn,
      Map.merge(conn.private[:pow_assent_session_params], %{
        url: url,
        callback_url: redirect_url
      })
    )
  end

  def new(conn, %{"provider" => _}) do
    json_error(
      conn,
      "Unsupported provider",
      status: :bad_request
    )
  end

  operation(:callback,
    operation_id: "providerCallback",
    summary: "OAuth2 Provider Callback",
    parameters: [
      provider: [
        in: :path,
        schema: SchemaProviderID
      ]
    ],
    responses: %{
      :ok => {
        "",
        "application/json",
        %Schema{
          type: :object
        }
      }
    }
  )

  def callback(conn, %{"error" => _} = params) do
    login_error(conn, Map.drop(params, ["state"]))
  end

  def callback(conn, %{"provider" => provider} = params) do
    params = Map.take(params, ["provider", "state", "code"])

    case conn
         |> Conn.put_private(:pow_assent_session_params, params)
         |> Plug.callback_upsert(provider, params, redirect_uri(conn)) do
      {:ok, conn} ->
        login_success(conn, params)

      {:error,
       conn = %{
         private: %{
           pow_assent_callback_state: {:error, :create_user},
           pow_assent_callback_error: changeset = %Ecto.Changeset{},
           pow_assent_callback_params: %{
             user: user_params,
             user_identity: user_identity_params
           }
         }
       }} ->
        {_, username_error_options} = Keyword.get(changeset.errors, :username)
        :unique = Keyword.get(username_error_options, :constraint)

        suffix = for(_ <- 1..4, into: "", do: <<Enum.random('0123456789abcdef')>>)
        user_params = %{user_params | "username" => "#{user_params["username"]}_#{suffix}"}

        {:ok, _, conn} = Plug.create_user(conn, user_identity_params, user_params)
        login_success(conn, params)

      {:error,
       conn = %{
         private: %{
           pow_assent_callback_error: {:invalid_user_id_field, %{changes: %{email: email}}}
         }
       }} ->
        login_error(
          conn,
          %{
            error: "conflict",
            error_description:
              "An account with the email \"#{email}\" already exists. If you own this account, please login with your email and password",
            email: email
          }
        )

      _ ->
        login_error(conn, %{
          error: "invalid_code",
          error_description: "Invalid or expired code, please try again"
        })
    end
  end

  defp redirect_uri(%{params: %{"provider" => provider}}) do
    URI.merge(Endpoint.url(), "/api/v1/oauth/#{provider}/callback")
    |> URI.to_string()
  end
end
