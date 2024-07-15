defmodule Uro.Session do
  @moduledoc false

  alias OpenApiSpex.Schema
  alias Uro.Accounts.User

  defstruct user: %User{},
            access_token: nil,
            token_type: nil,
            expires_in: nil

  @json_schema %Schema{
    title: "Session",
    description: "A user session, containing an access token and user information.",
    type: :object,
    required: [
      :user,
      :access_token,
      :token_type,
      :expires_in
    ],
    properties: %{
      user: User.sensitive_json_schema(),
      access_token: %Schema{
        description:
          "The access token, used for authenticating requests. Sent as a cookie `cookie: session=<access_token>`, or alternatively, in the `authorization` header, like so `authorization: Bearer <access_token>`.",
        type: :string
      },
      token_type: %Schema{
        type: :string,
        description: "The type of token. Used in the `authorization` header.",
        example: "Bearer"
      },
      expires_in: %Schema{
        type: :integer,
        description:
          "The number of milliseconds until `access_token` expires. You'll usually be automatically assigned a new `access_token` via the `set-cookie` header before this time."
      }
    }
  }

  def json_schema, do: @json_schema

  def to_json_schema(%__MODULE__{} = session) do
    %{
      user: User.to_sensitive_json_schema(session.user),
      access_token: session.access_token,
      token_type: session.token_type,
      expires_in: session.expires_in
    }
  end
end
