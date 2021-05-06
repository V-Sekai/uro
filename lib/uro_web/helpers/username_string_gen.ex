defmodule UroWeb.Helpers.UsernameStringGen do
  use(Puid, bits: 64)
end
