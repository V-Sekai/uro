defmodule UroWeb.Router do
  use UroWeb, :router
  use Pow.Phoenix.Router
  use PowAssent.Phoenix.Router

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
    plug Pow.Plug.RequireAuthenticated, error_handler: UroWeb.APIAuthErrorHandler
  end

  scope "/api/v1", UroWeb.API.V1, as: :api_v1 do
    pipe_through :api

    get "/sign-in", SessionController, :new, as: :signin
    post "/sign-in", SessionController, :create, as: :signin

    get "/sign-up", RegistrationController, :new, as: :signup
    post "/sign-up", RegistrationController, :create, as: :signup

    resources "/avatars", AvatarController, only: [:show]
    resources "/shards", ShardController, only: [:index, :create, :update, :delete]

  end

  scope "/api/v1", UroWeb.API.V1, as: :api_v1 do
    pipe_through [:api, :api_protected]

    # Your protected API endpoints here
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

    delete "/sign-out", SessionController, :delete, as: :signin

    get "/profile/edit", RegistrationController, :edit
    patch "/profile", RegistrationController, :update
    put "/profile", RegistrationController, :update
    delete "/profile", RegistrationController, :delete
  end

  scope "/admin", UroWeb, as: :admin do
    pipe_through [:browser, :protected_admin]

    get "/", Admin.PageController, :index

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
