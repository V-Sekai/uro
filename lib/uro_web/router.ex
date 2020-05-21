defmodule UroWeb.Router do
  use UroWeb, :router
  use Pow.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :protected do
    plug Pow.Plug.RequireAuthenticated,
      error_handler: UroWeb.AuthErrorHandler
  end

  pipeline :not_authenticated do
    plug Pow.Plug.RequireNotAuthenticated,
      error_handler: UroWeb.AuthErrorHandler
  end

  pipeline :api do
    plug :accepts, ["json"]
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

  scope "/", UroWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", UroWeb do
  #   pipe_through :api
  # end
end
