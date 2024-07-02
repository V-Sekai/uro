defmodule Uro.Endpoint do
  use Phoenix.Endpoint, otp_app: :uro

  # socket("/socket", Uro.UserSocket,
  #   websocket: true,
  #   longpoll: false
  # )

  # plug(Plug.Static.IndexHtml, at: "/")

  # plug(Plug.Static,
  #   at: "/",
  #   from: :uro
  # )

  # plug Plug.Static,
  #   at: "/uploads",
  #   from: Path.expand("./uploads")

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket("/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket)

    # plug(Phoenix.LiveReloader)
    plug(Phoenix.CodeReloader)
  end

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

  plug(Plug.Session,
    store: :cookie,
    key: "session",
    signing_salt: "5DeFKvbM"
  )

  # plug Pow.Plug.Session,
  #   otp_app: :uro

  # session_ttl_renewal: :timer.minutes(5),
  # credentials_cache_store: {Pow.Store.CredentialsCache, ttl: :timer.hours(48)}

  # plug PowPersistentSession.Plug.Cookie
  # persistent_session_cookie_key: "p_session"

  plug(CORSPlug)

  plug(Uro.Router)
end
