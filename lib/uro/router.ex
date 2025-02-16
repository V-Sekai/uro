defmodule Uro.Router do
  use Uro, :router
  use Plug.ErrorHandler
  use Uro.Helpers.API

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

    plug(OpenApiSpex.Plug.PutApiSpec, module: Uro.OpenAPI.Specification)
  end

  pipeline :authenticated do
    plug(Pow.Plug.RequireAuthenticated, error_handler: Uro.FallbackController)
  end

  pipe_through([:api])

  get("/health", Uro.HealthController, :index)

  get("/openapi", OpenApiSpex.Plug.RenderSpec, [])
  get("/docs", Uro.OpenAPI.Viewer, [])

  if Mix.env() == :dev do
    pipeline :browser do
      plug(:accepts, ["html"])
      plug(:fetch_session)
      plug(:fetch_flash)
      plug(:protect_from_forgery)
      plug(:put_secure_browser_headers)
    end

    scope "/" do
      pipe_through([:browser])

      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end

  scope "/session" do
    pipe_through([:authenticated])

    get("/", Uro.AuthenticationController, :get_current_session)
    delete("/", Uro.AuthenticationController, :logout)
  end

  scope "/login" do
    post("/", Uro.AuthenticationController, :login)

    scope "/:provider" do
      get("/", Uro.AuthenticationController, :login_with_provider)
      get("/callback", Uro.AuthenticationController, :provider_callback)
    end
  end

  # resources("/avatars", UserContent.AvatarController, only: [:show])
  resources("/maps", Uro.MapController, only: [:show])

  resources("/shards", Uro.ShardController, only: [:index, :create, :update, :delete])

  scope "/users" do
    post "/", Uro.UserController, :create

    scope "/" do
      pipe_through([:authenticated])
      get "/", Uro.UserController, :index
    end

    scope "/:user_id" do
      get "/", Uro.UserController, :show
      post "/email", Uro.UserController, :confirm_email

      scope "/" do
        pipe_through([:authenticated])

        patch "/", Uro.UserController, :update

        put "/email", Uro.UserController, :update_email
        patch "/email", Uro.UserController, :resend_confirmation_email

        resources("/friend", Uro.FriendController,
          singleton: true,
          only: [:show, :create, :delete]
        )
      end
    end
  end
end
