defmodule UroWeb.Router do
  use UroWeb, :router
  use Plug.ErrorHandler
  use UroWeb.Helpers.API

  import Redirect

  # use PowAssent.Phoenix.Router

  # @view_commands [:index, :show]
  # @modify_commands [:new, :edit, :create, :update, :delete]

  # defp handle_errors(conn, %{reason: %{message: message}}) do
  #   json_error(conn, message, status: 500)
  # end
  #
  # defp handle_errors(conn, %{reason: %{description: message}}) do
  #   json_error(conn, message, status: 500)
  # end

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
  end

  pipeline :api_v1 do
    plug(OpenApiSpex.Plug.PutApiSpec, module: UroWeb.API.V1.Spec)
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

  scope "/" do
    get("/", UroWeb.A, :index)
  end

  # plug(Plug.Static.IndexHtml, at: "/")
  # plug(Plug.Static, at: "/", from: :uro)

  scope "/api" do
    pipe_through([:api])

    redirect("/", "/api/v1", :temporary)

    scope "/v1" do
      pipe_through([:api_v1])

      get("/", OpenApiSpex.Plug.RenderSpec, [])
      get("/docs", UroWeb.OpenAPIViewer, pathname: "/api/v1")

      post("/session", UroWeb.API.V1.SessionController, :create)

      resources("/avatars", UserContent.AvatarController, only: [:show])
      resources("/maps", UroWeb.API.V1.MapController, only: [:show])

      resources("/shards", UroWeb.API.V1.ShardController,
        only: [:index, :create, :update, :delete]
      )

      resources("/users", UroWeb.API.V1.UserController, only: [:show])

      scope "/" do
        pipe_through([:authenticated])

        resources("/session", UroWeb.API.V1.SessionController,
          singleton: true,
          only: [:show, :delete]
        )
      end
    end
  end
end
