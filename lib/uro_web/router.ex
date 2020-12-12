defmodule UroWeb.Router do
  use UroWeb, :router
  use Pow.Phoenix.Router
  use PowAssent.Phoenix.Router

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
  end

  pipeline :protected_admin do
    plug Uro.Plug.RequireAdmin
  end

  pipeline :not_authenticated do
    plug Pow.Plug.RequireNotAuthenticated,
      error_handler: UroWeb.AuthErrorHandler
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug UroWeb.APIAuthPlug, otp_app: :uro
  end

  pipeline :api_protected do
    plug Pow.Plug.RequireAuthenticated,
      error_handler: UroWeb.APIAuthErrorHandler
  end

  pipeline :dashboard do
    #plug :put_layout, {UroWeb.LayoutView, "dashboard.html"}
  end

  scope "/api/v1", UroWeb.API.V1, as: :api_v1 do
    pipe_through [:remote_ip, :api]

    resources "/registration", RegistrationController, singleton: true, only: [:create]
    resources "/session", SessionController, singleton: true, only: [:create, :delete]
    post "/session/renew", SessionController, :renew

    resources "/shards", ShardController, only: [:index, :create, :update, :delete]

  end

  scope "/api/v1", UroWeb.API.V1, as: :api_v1 do
    pipe_through [:remote_ip, :api, :api_protected]

    # Your protected API endpoints here
    resources "/registration", RegistrationController, singleton: true, only: [:show]
    resources "/identity_proofs", IdentityProofController, as: :identity_proof, only: [:show, :create]
  end

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
    patch "/profile", RegistrationController, :update, as: :profile
    put "/profile", RegistrationController, :update, as: :profile
    delete "/profile", RegistrationController, :delete, as: :profile
  end

  scope "/dashboard", UroWeb, as: :dashboard do
    pipe_through [:browser, :protected, :dashboard]

    get "/", DashboardController, :index, as: :root
    resources "/avatars", UserContent.AvatarController, as: :avatar
  end

  scope "/admin", UroWeb, as: :admin do
    pipe_through [:browser, :protected_admin]

    get "/", Admin.PageController, :index, as: :root

    resources "/avatars", Admin.AvatarController, as: :avatar
    resources "/maps", Admin.MapController, as: :map
    resources "/props", Admin.PropController, as: :prop
    resources "/shards", Admin.ShardController, as: :shard
    resources "/events", Admin.EventController, as: :event
    resources "/users", Admin.UserController, as: :user
  end

  scope "/", UroWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/" do
    pipe_through :skip_csrf_protection

    pow_assent_authorization_post_callback_routes()
  end

  scope "/" do
    pipe_through [:browser]
    pow_assent_routes()
  end

  def swagger_info do
    %{
      info: %{
        version: "0.1",
        title: "Uro"
      }
    }
  end
end
