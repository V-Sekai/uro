defmodule UroWeb.Router do
  use UroWeb, :router
  use Plug.ErrorHandler
  use UroWeb.Helpers.API

  defp handle_errors(conn, %{reason: reason}) do
    json_error(conn,
      code: :internal_server_error,
      message: Exception.message(reason)
    )
  end

  defp handle_errors(conn, _) do
    json_error(conn, code: :internal_server_error)
  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:fetch_session)

    plug(RemoteIp)
    plug(Uro.Plug.Authentication, otp_app: :uro)

    plug(OpenApiSpex.Plug.PutApiSpec, module: UroWeb.OpenAPI.Specification)
  end

  pipeline :authenticated do
    plug(Pow.Plug.RequireAuthenticated, error_handler: UroWeb.FallbackController)
  end

  if Mix.env() == :dev do
    pipeline :browser do
      plug(:accepts, ["html"])
      plug(:fetch_session)
      plug(:fetch_flash)
      plug(:protect_from_forgery)
      plug(:put_secure_browser_headers)
    end

    scope "/-" do
      pipe_through([:browser])

      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end

  pipe_through([:api])

  get("/", OpenApiSpex.Plug.RenderSpec, [])
  get("/docs", UroWeb.OpenAPIViewer, pathname: "/api/v1")

  post("/session", UroWeb.AuthenticationController, :login)

  scope "/session" do
    pipe_through([:authenticated])

    get("/", UroWeb.AuthenticationController, :current_session)
    delete("/", UroWeb.AuthenticationController, :logout)
  end

  scope "/oauth" do
    scope "/:provider" do
      get("/", UroWeb.AuthenticationController, :login_with_provider)
      get("/callback", UroWeb.AuthenticationController, :provider_callback)
    end
  end

  # resources("/avatars", UserContent.AvatarController, only: [:show])
  resources("/maps", UroWeb.MapController, only: [:show])

  resources("/shards", UroWeb.ShardController, only: [:index, :create, :update, :delete])

  scope "/users" do
    resources("/", UroWeb.UserController, only: [:show, :create])

    scope "/:user_id" do
      post "/email", UroWeb.UserController, :confirm_email

      scope "/" do
        pipe_through([:authenticated])

        patch "/", UroWeb.UserController, :update

        put "/email", UroWeb.UserController, :update_email
        patch "/email", UroWeb.UserController, :resend_confirmation_email
      end
    end
  end
end
