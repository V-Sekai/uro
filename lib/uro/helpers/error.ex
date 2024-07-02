defmodule Uro.Error do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  defmodule JSONSchema do
    @moduledoc """
    A representation of an error response.
    """

    require OpenApiSpex
    alias OpenApiSpex.Schema

    @doc """
      A list of HTTP status codes and their corresponding reason phrases.
      These were taken from the `Plug.Conn.Status` module since they are
      not exposed in the public API.
    """
    @statuses %{
      400 => "Bad Request",
      401 => "Unauthorized",
      402 => "Payment Required",
      403 => "Forbidden",
      404 => "Not Found",
      405 => "Method Not Allowed",
      406 => "Not Acceptable",
      407 => "Proxy Authentication Required",
      408 => "Request Timeout",
      409 => "Conflict",
      410 => "Gone",
      411 => "Length Required",
      412 => "Precondition Failed",
      413 => "Request Entity Too Large",
      414 => "Request-URI Too Long",
      415 => "Unsupported Media Type",
      416 => "Requested Range Not Satisfiable",
      417 => "Expectation Failed",
      418 => "I'm a teapot",
      421 => "Misdirected Request",
      422 => "Unprocessable Entity",
      423 => "Locked",
      424 => "Failed Dependency",
      425 => "Too Early",
      426 => "Upgrade Required",
      428 => "Precondition Required",
      429 => "Too Many Requests",
      431 => "Request Header Fields Too Large",
      451 => "Unavailable For Legal Reasons",
      500 => "Internal Server Error",
      501 => "Not Implemented",
      502 => "Bad Gateway",
      503 => "Service Unavailable",
      504 => "Gateway Timeout",
      505 => "HTTP Version Not Supported",
      506 => "Variant Also Negotiates",
      507 => "Insufficient Storage",
      508 => "Loop Detected",
      510 => "Not Extended",
      511 => "Network Authentication Required"
    }

    @status_atoms @statuses
                  |> Map.values()
                  |> Enum.map(fn reason_phrase ->
                    reason_phrase
                    |> String.downcase()
                    |> String.replace("'", "")
                    |> String.replace(~r/[^a-z0-9]/, "_")
                    |> String.to_atom()
                  end)

    def status_atoms(), do: @status_atoms

    OpenApiSpex.schema(%{
      title: "Error",
      type: :object,
      required: [:message, :status],
      properties: %{
        message: %Schema{
          type: :string,
          description: "A human-readable message describing the error.",
          example: "Bad request"
        },
        code: %Schema{
          type: :integer,
          example: "bad_request",
          enum: @status_atoms
        },
        properties: %Schema{
          type: :object,
          description: "Property specific errors, in response to invalid requests.",
          example: %{
            username: ["should be at least 3 character(s)"],
            password: ["was already taken"]
          },
          additionalProperties: %Schema{
            type: :array,
            items: %Schema{
              type: :string
            }
          }
        }
      }
    })
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate "is invalid" in the "errors" domain
    #     dgettext("errors", "is invalid")
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    # This requires us to call the Gettext module passing our gettext
    # backend as first argument.
    #
    # Note we use the "errors" domain, which means translations
    # should be written to the errors.po file. The :count option is
    # set by Ecto and indicates we should also apply plural rules.
    if count = opts[:count] do
      Gettext.dngettext(Uro.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(Uro.Gettext, "errors", msg, opts)
    end
  end
end
