defmodule Uro.Session do
  @moduledoc false

  alias Uro.Accounts.User

  @derive {Jason.Encoder,
           only: [
             :user,
             :access_token,
             :token_type,
             :expires_in
           ]}

  defstruct user: %User{},
            access_token: nil,
            token_type: nil,
            expires_in: nil

  defmodule JSONSchema do
    @moduledoc false

    use Uro.JSONSchema, []
    alias Uro.Accounts.User

    OpenApiSpex.schema(%{
      title: "Session",
      description: "A user session, containing an access token and user information.",
      type: :object,
      required: [
        :user,
        :access_token,
        :token_type,
        :expires_in
      ],
      additional_properties: false,
      properties: %{
        user: User.JSONSchema,
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
    })
  end
end
