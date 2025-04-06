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

  pipeline :authenticated_admin do
    plug(Pow.Plug.RequireAuthenticated, error_handler: Uro.FallbackController)
    plug(Uro.Plug.RequireAdmin)
  end

  pipeline :authenticated_shared_file do
    plug(Uro.Plug.RequireSharedFileUploadPermission)
  end

  pipeline :authenticated_user do
    plug(Uro.Plug.ChooseAuth)
  end

  pipeline :dashboard_avatars do
    plug(Uro.Plug.RequireAvatarUploadPermission)
  end

  pipeline :dashboard_maps do
    plug(Uro.Plug.RequireMapUploadPermission)
  end

  pipeline :dashboard_props do
    plug(Uro.Plug.RequirePropUploadPermission)
  end

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

  pipe_through([:api])

  get("/health", Uro.HealthController, :index)

  get("/openapi", OpenApiSpex.Plug.RenderSpec, [])
  get("/docs", Uro.OpenAPI.Viewer, [])

  #### Used by game client only ####
  # TODO: merge into other routes

  # User signup using apiKey client secret
  scope "/registration" do
    post "/", Uro.UserController, :createClient
  end

  scope "/profile" do
    pipe_through([:authenticated_user])
    get("/", Uro.UserController, :showCurrent)
  end

  ##################################

  scope "/session" do
    # TODO: used by game client only, move to '/login' route
    post("/", Uro.AuthenticationController, :loginClient)

    scope "/renew" do
      post("/", Uro.AuthenticationController, :renew)
    end

    pipe_through([:authenticated_user])

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

  resources("/avatars", Uro.AvatarController, only: [:index, :show])
  resources("/maps", Uro.MapController, only: [:index, :show])

  resources("/shards", Uro.ShardController, only: [:index, :create, :update, :delete])

  scope "/admin" do
    pipe_through([:authenticated_admin])

    get("/", Uro.AdminController, :status)
  end

  scope "/storage" do
    scope "/tag" do
      get "/:tag", Uro.StorageController, :indexByTag
    end

    get "/:id", Uro.StorageController, :show

    ################## Auth ##################
    pipe_through([:authenticated_shared_file])

    get "/", Uro.StorageController, :index
    post "/", Uro.StorageController, :create
    put "/:id", Uro.StorageController, :update
    delete "/:id", Uro.StorageController, :delete
  end

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

  scope "/dashboard" do
    pipe_through([:authenticated_user])

    get("/", Uro.AuthenticationController, :get_current_session)
    delete("/", Uro.AuthenticationController, :logout)

    scope "/avatars" do
      pipe_through([:dashboard_avatars])

      get "/", Uro.AvatarController, :indexUploads
      get "/:id", Uro.AvatarController, :showUpload
      post "/", Uro.AvatarController, :create
      put "/:id", Uro.AvatarController, :update
      delete "/:id", Uro.AvatarController, :delete
    end

    scope "/maps" do
      pipe_through([:dashboard_maps])

      get "/", Uro.MapController, :indexUploads
      get "/:id", Uro.MapController, :showUpload
      post "/", Uro.MapController, :create
      put "/:id", Uro.MapController, :update
      delete "/:id", Uro.MapController, :delete
    end

    scope "/props" do
      pipe_through([:dashboard_props])

      get "/", Uro.PropController, :indexUploads
      get "/:id", Uro.PropController, :showUpload
      post "/", Uro.PropController, :create
      put "/:id", Uro.PropController, :update
      delete "/:id", Uro.PropController, :delete
    end
  end
end
