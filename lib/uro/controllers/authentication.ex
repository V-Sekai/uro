defmodule Uro.AuthenticationController do
  @moduledoc false

  use Uro, :controller

  alias OpenApiSpex.Schema
  alias Plug.Conn
  alias PowAssent.Plug
  alias Uro.Accounts
  alias Uro.Accounts.User
  alias Uro.Accounts.UserPrivilegeRuleset
  alias Uro.Endpoint
  alias Uro.Helpers
  alias Uro.Session

  action_fallback(Uro.FallbackController)

  tags(["authentication"])

  @provider_id_json_schema %Schema{
    title: "ProviderID",
    description: "An ID representing an OAuth2 provider.",
    type: :string,
    example: "github"
  }

  def provider_id_json_schema, do: @provider_id_json_schema

  operation(:login_with_provider,
    operation_id: "loginWithProvider",
    summary: "Login using OAuth2 Provider",
    description: "Create a new session.",
    parameters: [
      provider: [
        in: :path,
        schema: @provider_id_json_schema
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

  defp login_error_native(conn, params) do
    html = make_native_error_page()

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(500, html)
  end

  defp login_success(conn, params) do
    redirect(conn,
      to: "/login?#{URI.encode_query(Map.merge(params, Map.take(conn.params, ["provider"])))}"
    )
  end

  defp login_success_native(conn, params) do
    provider_entry = Map.take(conn.params, ["provider"])

    redirect_uri =
      client_redirect_uri_native(conn) <>
        "?" <> URI.encode_query(Map.merge(params, provider_entry))

    html = make_native_redirect_page(redirect_uri, 5)

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, html)
  end

  def login_with_provider(conn, %{"provider" => provider}) when is_binary(provider) do
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

  operation(:login_with_provider_native,
    operation_id: "loginWithProviderNative",
    summary: "Login using OAuth2 Provider on a Native App",
    description: "Create a new session.",
    parameters: [
      provider: [
        in: :path,
        schema: @provider_id_json_schema
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

  def login_with_provider_native(conn, %{"provider" => provider}) when is_binary(provider) do
    redirect_url = redirect_uri_native(conn)
    {:ok, url, conn} = Plug.authorize_url(conn, provider, redirect_url)

    json(
      conn,
      Map.merge(conn.private[:pow_assent_session_params], %{
        url: url,
        callback_url: redirect_url
      })
    )
  end

  def login_with_provider_native(_, %{"provider" => _}),
    do: {:error, code: :bad_request, message: "Unknown provider"}

  operation(:provider_callback,
    operation_id: "loginProviderCallback",
    summary: "Login Provider Callback",
    description: """
    This endpoint is called by the provider after the user has authenticated. The provider will include a code in the query string if the user has successfully authenticated, or an error if the user has not.

    You should not call this endpoint directly. Instead, you should redirect the user to the URL returned by the `loginWithProvider` endpoint.
    """,
    parameters: [
      provider: [
        in: :path,
        schema: @provider_id_json_schema
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

  operation(:provider_callback_native,
    operation_id: "loginProviderCallbackNative",
    summary: "Login Provider Callback Native",
    description: """
    This endpoint is called by a provider through browser redirect after the user has authenticated. The provider will include a code in the query string if the user has successfully authenticated, or an error if the user has not.

    You should not call this endpoint directly. Instead, you should redirect the user to the URL returned by the `loginWithProviderNative` endpoint.
    """,
    parameters: [
      provider: [
        in: :path,
        schema: @provider_id_json_schema
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

  def provider_callback_native(
        conn,
        %{"provider" => provider, "code" => code, "state" => state} = params
      ) do
    base_params = Map.take(params, ["provider", "state", "code"])
    session_params = %{code: code, state: state}

    case conn
         |> Conn.put_private(:pow_assent_session_params, session_params)
         |> Plug.callback_upsert(provider, base_params, redirect_uri_native(conn)) do
      {:ok, conn} ->
        api_tokens =
          conn.private.pow_assent_callback_params.user_identity["token"]

        token_data =
          Map.take(api_tokens, ["access_token", "expires_in"])

        # TODO: implement  "refresh_token" api endpoint

        params = Map.merge(base_params, token_data)
        login_success_native(conn, params)

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

        api_tokens =
          user_identity_params["token"]

        token_data =
          Map.take(api_tokens, ["access_token", "refresh_token", "expires_in"])

        params = Map.merge(base_params, token_data)
        login_success_native(conn, params)

      {:error,
       conn = %{
         private: %{
           pow_assent_callback_error: {:invalid_user_id_field, %{changes: %{email: email}}}
         }
       }} ->
        login_error_native(
          conn,
          %{
            error: "conflict",
            error_description:
              "An account with the email \"#{email}\" already exists. If you own this account, please login with your email and password",
            email: email
          }
        )

      _ ->
        login_error_native(conn, %{
          error: "invalid_code",
          error_description: "Invalid or expired code, please try again"
        })
    end
  end

  defp redirect_uri(%{params: %{"provider" => provider}}) do
    Endpoint.public_url("login/#{provider}/callback")
  end

  defp redirect_uri_native(%{params: %{"provider" => provider}}) do
    Endpoint.public_url("login/native/#{provider}/callback")
  end

  defp client_redirect_uri_native(%{params: %{"provider" => provider}}) do
    {provider_atom, config} = get_provider_cfg(provider)

    uri =
      case Keyword.fetch(config, :godot_redirect_address) do
        {:ok, address} -> address
        # TODO: replace with error page
        :error -> "http://0.0.0.0/"
      end
  end

  @doc """
  Fetches the config for the given provider name (string or atom).
  Returns the options keyword list or `{}` if not found.
  Atom table is not modified.
  """
  @spec get_provider_cfg(String.t() | atom()) :: {atom(), keyword()} | {}
  defp get_provider_cfg(provider_name) when is_binary(provider_name) do
    Application.get_env(:uro, :pow_assent, [])
    |> Keyword.get(:providers, [])
    |> Enum.find({}, fn {provider_atom, opts} ->
      name = Atom.to_string(provider_atom)

      if name == provider_name do
        true
      end
    end)
  end

  defp get_provider_cfg(provider_name) when is_atom(provider_name) do
    Application.get_env(:uro, :pow_assent, [])
    |> Keyword.get(:providers, [])
    |> Enum.find({}, fn {provider_atom, opts} ->
      if provider_name == provider_atom do
        true
      end
    end)
  end

  @spec make_native_redirect_page(String.t(), integer()) :: String.t()
  defp make_native_redirect_page(redirect_uri, wait_time) do
    escaped_uri =
      redirect_uri
      |> Phoenix.HTML.html_escape()
      |> Phoenix.HTML.safe_to_string()

    wait_time_str = Integer.to_string(wait_time)

    html = ~s"""
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8">
        <meta http-equiv="refresh"
              content="#{wait_time_str};url=#{escaped_uri}">
        <title>V-Sekai OAuth</title>
      </head>
      <body>
        <h1>V-Sekai OAuth</h1>
        <p>V-Sekai OAuth login was successful. Sending data to Godot client in #{wait_time_str} seconds. If not, <a href="#{escaped_uri}">click here</a>.</p>
      </body>
    </html>
    """
  end

  @spec make_native_error_page(String.t()) :: String.t()
  defp make_native_error_page(error_msg \\ "An unexpected error occurred.") do
    escaped_msg =
      error_msg
      |> Phoenix.HTML.html_escape()
      |> Phoenix.HTML.safe_to_string()

    html = ~s"""
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8">
        <title>V-Sekai OAuth</title>
      </head>
      <body>
        <h1>V-Sekai OAuth</h1>
        <p>OAuth login failed. #{escaped_msg}</p>
      </body>
    </html>
    """
  end

  operation(:get_current_session,
    operation_id: "session",
    summary: "Current Session",
    description: "Get the current session.",
    responses: [
      ok: {
        "",
        "application/json",
        Session.json_schema()
      },
      unauthorized: {
        "",
        "application/json",
        error_json_schema()
      }
    ]
  )

  def get_current_session(conn, _) do
    with {:ok, session} <- current_session(conn) do
      json(conn, Session.to_json_schema(session))
    end
  end

  defp validate_credentials(conn, %{"username" => username, "password" => password}) do
    Accounts.get_by_username(username)
    |> case do
      %User{email: email} ->
        Pow.Plug.authenticate_user(conn, %{"email" => email, "password" => password})

      _ ->
        {:error, conn}
    end
  end

  defp validate_credentials(conn, %{
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

  defp validate_credentials(conn, %{"email" => email, "password" => password}) do
    Pow.Plug.authenticate_user(conn, %{"email" => email, "password" => password})
  end

  defp validate_credentials(conn, _), do: {:error, conn}

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
              username: User.sensitive_json_schema().properties.username,
              password: %Schema{type: :string}
            }
          },
          %Schema{
            title: "EmailAndPassword",
            type: :object,
            required: [:email, :password],
            properties: %{
              email: User.sensitive_json_schema().properties.email,
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
        Session.json_schema()
      },
      unauthorized: {
        "Invalid credentials",
        "application/json",
        error_json_schema()
      }
    ]
  )

  def login(conn, credentials) do
    conn
    |> validate_credentials(credentials)
    |> case do
      {:ok, conn} ->
        get_current_session(conn, nil)

      {:error, _} ->
        {:error, :invalid_credentials}
    end
  end

  operation(:loginClient,
    operation_id: "loginClient",
    summary: "Login Game Client",
    description: "Create a new session for game client.",
    request_body: {
      "",
      "application/json",
      %Schema{
        title: "LoginRequestClient",
        description: "Request payload for logging in.",
        type: :object,
        required: [:user],
        properties: %{
          user: %Schema{
            title: "LoginCredentials",
            description: "A set of credentials for logging in.",
            oneOf: [
              %Schema{
                title: "UsernameAndPassword",
                type: :object,
                required: [:username, :password],
                properties: %{
                  username: User.sensitive_json_schema().properties.username,
                  password: %Schema{type: :string}
                }
              },
              %Schema{
                title: "EmailAndPassword",
                type: :object,
                required: [:email, :password],
                properties: %{
                  email: User.sensitive_json_schema().properties.email,
                  password: %Schema{type: :string}
                }
              },
              %Schema{
                title: "UsernameOrEmailAndPassword",
                type: :object,
                required: [:username_or_email, :password],
                properties: %{
                  username_or_email: %Schema{type: :string},
                  password: %Schema{type: :string}
                }
              }
            ]
          }
        }
      }
    },
    responses: [
      ok: {
        "",
        "application/json",
        Session.json_schema()
      },
      unauthorized: {
        "Invalid credentials",
        "application/json",
        error_json_schema()
      }
    ]
  )

  def loginClient(conn, %{"user" => credentials}) do
    conn
    |> validate_credentials(credentials)
    |> case do
      {:ok, conn} ->
        user = Helpers.Auth.get_current_user(conn)
        ruleset = UserPrivilegeRuleset.to_json_schema(user.user_privilege_ruleset)

        conn
        |> put_status(200)
        |> json(%{
          data: %{
            access_token: conn.assigns[:access_token],
            renewal_token: conn.assigns[:access_token],
            user: User.to_json_schema(user, conn),
            user_privilege_ruleset: ruleset
          }
        })

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
    |> json(%{data: %{}})

    # TODO: Remove '{ data : {} }' response requirement from game client, use nil
  end

  operation(:renew,
    operation_id: "renew",
    summary: "Renew Session",
    description: "Renew the current session token.",
    responses: [
      ok: {
        "",
        "application/json",
        Session.json_schema()
      },
      unauthorized: {
        "",
        "application/json",
        error_json_schema()
      }
    ]
  )

  # All tokens are in permanent cache storage and renewal is handled in fetch(),
  # so this is only for game client compatibility
  def renew(conn, _params) do
    config = Pow.Plug.fetch_config(conn)

    conn
    |> Uro.Plug.Authentication.fetch(config)
    |> case do
      {conn, nil} ->
        conn
        |> put_status(401)
        |> json(%{error: %{status: 401, message: "Invalid token"}})

      {conn, user} ->
        ruleset = UserPrivilegeRuleset.to_json_schema(user.user_privilege_ruleset)

        json(conn, %{
          data: %{
            access_token: conn.assigns[:access_token],
            renewal_token: conn.assigns[:access_token],
            user: User.to_json_schema(user, conn),
            user_privilege_ruleset: ruleset
          }
        })
    end
  end
end
