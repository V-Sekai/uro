defmodule UroWeb.Router do
  use UroWeb, :router

  pipeline :browser do
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

    get "/sign-in", UserController, :sign_in
    post "/sign-in", UserController, :create_session

    get "/sign-up", UserController, :sign_up
    post "/sign-up", UserController, :create_user
  end

  # Other scopes may use custom stacks.
  # scope "/api", UroWeb do
  #   pipe_through :api
  # end
end
