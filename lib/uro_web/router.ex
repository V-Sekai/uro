defmodule UroWeb.Router do
  use UroWeb, :router
  use Pow.Phoenix.Router

  use Pow.Extension.Phoenix.Router,
    extensions: [PowResetPassword, PowEmailConfirmation]

  use PowAssent.Phoenix.Router

  @view_commands [:index, :show]
  @modify_commands [:new, :edit, :create, :update, :delete]

  pipeline :remote_ip do
    plug RemoteIp
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :skip_csrf_protection do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_secure_browser_headers
  end

  pipeline :protected do
    plug Pow.Plug.RequireAuthenticated,
      error_handler: UroWeb.AuthErrorHandler

    plug Uro.EnsureUserNotLockedPlug,
      error_handler: UroWeb.AuthErrorHandler
  end

  pipeline :protected_admin do
    plug Uro.Plug.RequireAdmin
  end

  pipeline :protected_avatar_upload do
    plug Uro.Plug.RequireAvatarUploadPermission
  end

  pipeline :protected_map_upload do
    plug Uro.Plug.RequireMapUploadPermission
  end

  pipeline :protected_prop_upload do
    plug Uro.Plug.RequirePropUploadPermission
  end

  pipeline :not_authenticated do
    plug Pow.Plug.RequireNotAuthenticated,
      error_handler: UroWeb.AuthErrorHandler

    plug Uro.EnsureUserNotLockedPlug,
      error_handler: UroWeb.AuthErrorHandler
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug UroWeb.APIAuthPlug, otp_app: :uro
  end

  pipeline :api_protected do
    plug Pow.Plug.RequireAuthenticated,
      error_handler: UroWeb.APIAuthErrorHandler

    plug Uro.EnsureUserNotLockedPlug,
      error_handler: UroWeb.APIAuthErrorHandler
  end

  pipeline :dashboard do
    # plug :put_layout, {UroWeb.LayoutView, "dashboard.html"}
  end

  #######
  # API #
  #######

  scope "/api/v1", UroWeb.API.V1, as: :api_v1 do
    pipe_through [:remote_ip, :api]

    resources "/registration", RegistrationController, singleton: true, only: [:create]
    resources "/session", SessionController, singleton: true, only: [:create, :delete]
    post "/session/renew", SessionController, :renew

    resources "/users", UserController, only: [:show]

    resources "/avatars", UserContent.AvatarController, only: [:show]
    resources "/maps", UserContent.MapController, only: [:show]

    resources "/shards", ShardController, only: [:index, :create, :update, :delete]
  end

  scope "/api/v1", UroWeb.API.V1, as: :api_v1 do
    pipe_through [:remote_ip, :api, :api_protected]

    # Your protected API endpoints here
    get "/profile", RegistrationController, :show, as: :profile

    resources "/identity_proofs", IdentityProofController,
      as: :identity_proof,
      only: [:show, :create]
  end

  scope "/api/v1", UroWeb.API.V1, as: :api_v1_user_content do
    pipe_through [:api]

    resources "/avatars", UserContent.AvatarController, as: :avatar, only: @view_commands
    resources "/maps", UserContent.MapController, as: :map, only: @view_commands
  end

  scope "/api/v1/dashboard", UroWeb.API.V1, as: :api_v1_dashboard do
    pipe_through [:remote_ip, :api, :api_protected, :protected_avatar_upload]

    resources "/avatars", Dashboard.UserContent.AvatarController,
      as: :avatar,
      only: @modify_commands
  end

  scope "/api/v1/dashboard", UroWeb.API.V1, as: :api_v1_dashboard do
    pipe_through [:remote_ip, :api, :api_protected, :protected_map_upload]

    resources "/maps", Dashboard.UserContent.MapController, as: :map, only: @modify_commands
  end

  scope "/api/v1/dashboard", UroWeb.API.V1, as: :api_v1_dashboard do
    pipe_through [:api, :api_protected]

    resources "/avatars", Dashboard.UserContent.AvatarController,
      as: :avatar,
      only: @view_commands

    resources "/maps", Dashboard.UserContent.MapController, as: :map, only: @view_commands
  end

  ########################
  # Session/Registration #
  ########################

  scope "/", UroWeb do
    pipe_through [:browser, :not_authenticated]

    get "/sign-in", SessionController, :new, as: :signin
    post "/sign-in", SessionController, :create, as: :signin

    get "/sign-up", RegistrationController, :new, as: :signup
    post "/sign-up", RegistrationController, :create, as: :signup
  end

  scope "/", UroWeb do
    pipe_through [:browser, :protected]

    delete "/", SessionController, :delete, as: :signin
    post "/sign-out", SessionController, :delete, as: :signout

    get "/profile", RegistrationController, :show, as: :profile
    get "/profile/edit", RegistrationController, :edit, as: :profile
    put "/profile/edit", RegistrationController, :update, as: :profile
    # delete "/profile", RegistrationController, :delete, as: :profile
  end

  #############
  # Dashboard #
  #############

  scope "/dashboard", UroWeb, as: :dashboard do
    pipe_through [:browser, :protected, :dashboard, :protected_avatar_upload]

    resources "/avatars", Dashboard.UserContent.AvatarController,
      as: :avatar,
      only: @modify_commands
  end

  scope "/dashboard", UroWeb, as: :dashboard do
    pipe_through [:browser, :protected, :dashboard, :protected_map_upload]

    resources "/maps", Dashboard.UserContent.MapController, as: :map, only: @modify_commands
  end

  scope "/dashboard", UroWeb, as: :dashboard do
    pipe_through [:browser, :protected, :dashboard]

    get "/", DashboardController, :index, as: :root

    resources "/avatars", Dashboard.UserContent.AvatarController,
      as: :avatar,
      only: @view_commands

    resources "/maps", Dashboard.UserContent.MapController, as: :map, only: @view_commands
  end

  #########
  # Admin #
  #########

  scope "/admin", UroWeb, as: :admin do
    pipe_through [:browser, :protected_admin]

    get "/", Admin.PageController, :index, as: :root

    resources "/avatars", Admin.AvatarController, as: :avatar
    resources "/maps", Admin.MapController, as: :map
    resources "/props", Admin.PropController, as: :prop
    resources "/shards", Admin.ShardController, as: :shard
    resources "/events", Admin.EventController, as: :event
    resources "/users", Admin.UserController, as: :user
    post "/users/:id/lock", Admin.UserController, :lock
  end

  ################
  # User Content #
  ################

  scope "/", UroWeb, as: :user_content do
    pipe_through :browser

    resources "/avatars", UserContent.AvatarController, as: :avatar
    resources "/maps", UserContent.MapController, as: :map
  end

  ########
  # Root #
  ########

  scope "/", UroWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/about", PageController, :about
    get "/download", PageController, :download
  end

  scope "/" do
    pipe_through :skip_csrf_protection

    pow_assent_authorization_post_callback_routes()
  end

  scope "/" do
    pipe_through [:browser]

    pow_extension_routes()
    pow_assent_routes()
  end

  ###########
  # Swagger #
  ###########

  def swagger_info do
    %{
      info: %{
        version: "0.1",
        title: "Uro"
      }
    }
  end
end
