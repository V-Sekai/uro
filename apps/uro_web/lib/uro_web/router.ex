defmodule UroWeb.Router do
  use UroWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {UroWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  if Mix.env() == :dev do
    scope "/" do
      pipe_through([:browser])

      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end

  scope "/" do
    pipe_through :browser

    live "/", UroWeb.LoginLive
  end
end
