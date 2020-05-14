defmodule UroWeb.Router do
  use UroWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :protected do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", UroWeb do
    pipe_through :browser

    get "/", PageController, :index

    get "/sign-in", SessionController, :new
    post "/sign-in", SessionController, :create
    delete "/sign-out", SessionController, :delete

    get "/sign-up", UserController, :new
    post "/sign-up", UserController, :create
  end

  # Other scopes may use custom stacks.
  # scope "/api", UroWeb do
  #   pipe_through :api
  # end
end
