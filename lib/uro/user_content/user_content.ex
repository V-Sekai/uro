defmodule Uro.UserContent.UserContent do
  alias Ecto.Changeset

  @doc false
  defmacro __using__(_config) do
    quote do
      use Ecto.Schema
      @derive {Jason.Encoder, only: [:description, :name, :url, :uploader]}
      import unquote(__MODULE__), only: [user_content_fields: 0]

      @spec user_content_changeset(Ecto.Schema.t() | Changeset.t(), map()) :: Changeset.t()
      def user_content_changeset(changeset, attrs) do
        changeset
        |> cast(attrs, [:name, :description, :url, :uploader_id])
        |> validate_required([:uploader_id, :url])
      end
    end
  end

  @doc false
  defmacro user_content_fields() do
    quote do
      field :description, :string
      field :name, :string
      field :url, :string
      belongs_to :uploader, Uro.Accounts.User, foreign_key: :uploader_id, type: :binary_id
    end
  end
end
