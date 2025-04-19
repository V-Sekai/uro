defmodule Uro.Endpoint do
  use Phoenix.Endpoint, otp_app: :uro

  def public_url(pathname \\ "") do
    URI.to_string(Application.fetch_env!(:uro, :url)) <> pathname
  end

  if Mix.env() == :dev do
    plug(Phoenix.CodeReloader)
  end

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_uro_key",
    signing_salt: "JifcOOjX",
    same_site: "Lax"
  ]
  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]],
    longpoll: [connect_info: [session: @session_options]]

  plug(Plug.Static,
    at: "/",
    from: :uro,
    gzip: false,
    only: Uro.static_paths()
  )
  plug(Plug.Static,
    at: "/uploads",
    from: Path.expand("./uploads"),
    gzip: false
  )

  plug(Plug.RequestId, assign_as: :request_id)
  plug(Plug.Telemetry, event_prefix: [:phoenix, :endpoint])

  # Max upload size, 200mb
  plug(Plug.Parsers,
    parsers: [:urlencoded, {:multipart, length: 200_000_000}, :json],
    query_string_length: 1_000_000,
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()
  )

  plug(Plug.MethodOverride)
  plug(Plug.Head)
  plug Plug.Session, @session_options
  plug Uro.Router
end
