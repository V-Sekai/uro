defmodule UroWeb.Router do
  use UroWeb, :router
  use Plug.ErrorHandler
  use UroWeb.Helpers.API

  defp handle_errors(conn, %{reason: reason}) do
    json_error(conn, Exception.message(reason), status: 500)
  end

  defp handle_errors(conn, _) do
    json_error(conn, "Internal server error.", status: 500)
  end

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :skip_csrf_protection do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:put_secure_browser_headers)
  end

  #  pipeline :protected do
  #    plug Pow.Plug.RequireAuthenticated,
  #      error_handler: UroWeb.AuthErrorHandler
  #
  #    plug Uro.EnsureUserNotLockedPlug,
  #      error_handler: UroWeb.AuthErrorHandler
  #  end
  #
  #  pipeline :protected_admin do
  #    plug Uro.Plug.RequireAdmin
  #  end
  #
  #  pipeline :protected_avatar_upload do
  #    plug Uro.Plug.RequireAvatarUploadPermission
  #  end
  #
  #  pipeline :protected_map_upload do
  #    plug Uro.Plug.RequireMapUploadPermission
  #  end
  #
  #  pipeline :protected_prop_upload do
  #    plug Uro.Plug.RequirePropUploadPermission
  #  end
  #
  #  pipeline :not_authenticated do
  #    plug Pow.Plug.RequireNotAuthenticated,
  #      error_handler: UroWeb.AuthErrorHandler
  #
  #    plug Uro.EnsureUserNotLockedPlug,
  #      error_handler: UroWeb.AuthErrorHandler
  #  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:fetch_session)

    plug(RemoteIp)
    plug(Uro.Plug.Authentication, otp_app: :uro)

    plug(OpenApiSpex.Plug.PutApiSpec, module: UroWeb.API.V1.Spec)
  end

  pipeline :api_v1 do
    # plug OpenApiSpex.Plug.CastAndValidate, json_render_error_v2: true
  end

  pipeline :not_authenticated do
    # plug Pow.Plug.RequireAuthenticated,
    #  error_handler: UroWeb.APIAuthErrorHandler

    # plug Uro.EnsureUserNotLockedPlug,
    #  error_handler: UroWeb.APIAuthErrorHandler
  end

  pipeline :authenticated do
    plug(Pow.Plug.RequireAuthenticated,
      error_handler: UroWeb.APIAuthErrorHandler
    )

    # plug Uro.EnsureUserNotLockedPlug,
    #  error_handler: UroWeb.APIAuthErrorHandler
  end

  if Mix.env() == :dev do
    scope "/-" do
      pipe_through([:browser])

      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end

  pipe_through([:api])

  get("/", OpenApiSpex.Plug.RenderSpec, [])
  get("/docs", UroWeb.OpenAPIViewer, pathname: "/api/v1")

  scope "/" do
    pipe_through([:authenticated])

    resources("/session", UroWeb.API.V1.SessionController,
      singleton: true,
      only: [:show, :delete]
    )
  end

  post("/session", UroWeb.API.V1.SessionController, :create)

  scope "/oauth" do
    get("/", UroWeb.API.V1.AuthController, :index)

    scope "/:provider" do
      get("/", UroWeb.API.V1.AuthController, :new)
      get("/callback", UroWeb.API.V1.AuthController, :callback)
    end
  end

  resources("/avatars", UserContent.AvatarController, only: [:show])
  resources("/maps", UroWeb.API.V1.MapController, only: [:show])

  resources("/shards", UroWeb.API.V1.ShardController, only: [:index, :create, :update, :delete])

  scope "/users" do
    resources("/", UroWeb.API.V1.UserController, only: [:show, :create])

    scope "/:user_id" do
      pipe_through([:authenticated])

      put "/email", UroWeb.API.V1.UserController, :update_email
      patch "/email", UroWeb.API.V1.UserController, :resend_confirmation_email
      post "/email", UroWeb.API.V1.UserController, :confirm_email
    end
  end
end
