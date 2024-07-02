defmodule Uro.AuthenticationController do
  @moduledoc false

  use Uro, :controller
  use Uro.Helpers.API
  use OpenApiSpex.ControllerSpecs

  alias OpenApiSpex.Schema
  alias Plug.Conn
  alias PowAssent.Plug
  alias Uro.Accounts
  alias Uro.Accounts.User
  alias Uro.Endpoint
  alias Uro.Error
  alias Uro.Session

  tags(["authentication"])

  @pow_assent Application.compile_env(:uro, :pow_assent)

  @supported_providers @pow_assent[:providers]
  @supported_provider_names @supported_providers
                            |> Keyword.keys()
                            |> Enum.map(&Atom.to_string/1)

  def supported_providers(), do: @supported_provider_names

  defmodule ProviderID do
    @moduledoc """
    An ID representing an OAuth2 provider.`.
    """

    use Uro.JSONSchema

    OpenApiSpex.schema(%{
      title: "ProviderID",
      description: @moduledoc,
      type: :string,
      example: "github"
    })
  end

  operation(:login_with_provider,
    operation_id: "loginWithProvider",
    summary: "Login using OAuth2 Provider",
    description: "Create a new session.",
    parameters: [
      provider: [
        in: :path,
        schema: ProviderID
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
          required: [
            :url,
            :state,
            :callback_url
          ],
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

  def login_with_provider(conn, %{"provider" => provider})
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

  def login_with_provider(_, %{"provider" => _}),
    do: {:error, code: :bad_request, message: "Unknown provider"}

  operation(:provider_callback,
    operation_id: "providerCallback",
    summary: "OAuth2 Provider Callback",
    parameters: [
      provider: [
        in: :path,
        schema: ProviderID
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

  def provider_callback(conn, %{"error" => _} = params) do
    login_error(conn, Map.drop(params, ["state"]))
  end

  def provider_callback(conn, %{"provider" => provider} = params) do
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

        suffix = for(_ <- 1..4, into: "", do: <<Enum.random(~c"0123456789abcdef")>>)
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
    Endpoint.url()
    |> URI.merge("/api/v1/oauth/#{provider}/callback")
    |> URI.to_string()
  end

  operation(:current_session,
    operation_id: "session",
    summary: "Current Session",
    description: "Get the current session.",
    responses: [
      ok: {
        "",
        "application/json",
        Session.JSONSchema
      },
      unauthorized: {
        "",
        "application/json",
        Error.JSONSchema
      }
    ]
  )

  def current_session(conn, _),
    do:
      json(
        conn,
        Uro.Plug.Authentication.current_session(conn)
      )

  def validate_credentials(conn, %{"username" => username, "password" => password}) do
    Accounts.get_by_username(username)
    |> case do
      %User{email: email} ->
        Pow.Plug.authenticate_user(conn, %{"email" => email, "password" => password})

      _ ->
        {:error, conn}
    end
  end

  def validate_credentials(conn, %{
        "username_or_email" => username_or_email,
        "password" => password
      }) do
    Accounts.get_by_username_or_email(username_or_email)
    |> case do
      %User{email: email} ->
        Pow.Plug.authenticate_user(conn, %{"email" => email, "password" => password})

      _ ->
        {:error, conn}
    end
  end

  def validate_credentials(conn, %{"email" => email, "password" => password}) do
    Pow.Plug.authenticate_user(conn, %{"email" => email, "password" => password})
  end

  def validate_credentials(conn, _), do: {:error, conn}

  operation(:login,
    operation_id: "login",
    summary: "Login",
    description: "Create a new session.",
    request_body: {
      "",
      "application/json",
      %Schema{
        title: "LoginCredentials",
        description: "A set of credentials for logging in.",
        oneOf: [
          %Schema{
            title: "UsernameAndPassword",
            type: :object,
            required: [:username, :password],
            properties: %{
              username: User.JSONSchema.shape(:username),
              password: %Schema{type: :string}
            }
          },
          %Schema{
            title: "EmailAndPassword",
            type: :object,
            required: [:email, :password],
            properties: %{
              email: User.JSONSchema.shape(:email),
              password: %Schema{type: :string}
            }
          },
          %Schema{
            title: "UsernameOrEmailAndPassword.",
            type: :object,
            required: [:username_or_email, :password],
            properties: %{
              username_or_email: %Schema{type: :string},
              password: %Schema{type: :string}
            }
          }
        ]
      }
    },
    responses: [
      ok: {
        "",
        "application/json",
        Session.JSONSchema
      },
      unauthorized: {
        "Invalid credentials",
        "application/json",
        Error.JSONSchema
      }
    ]
  )

  def login(conn, credentials) do
    conn
    |> validate_credentials(credentials)
    |> case do
      {:ok, conn} ->
        current_session(conn, nil)

      {:error, _} ->
        {:error, :invalid_credentials}
    end
  end

  operation(:logout,
    operation_id: "logout",
    summary: "Logout",
    description: "Delete the current session.",
    responses: [
      ok: {
        "",
        "application/json",
        %Schema{type: :null}
      }
    ]
  )

  def logout(conn, _) do
    conn
    |> Pow.Plug.delete()
    |> json(nil)
  end
end
