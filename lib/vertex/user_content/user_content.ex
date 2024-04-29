defmodule Vertex.UserContent.UserContent do
  alias Ecto.Changeset

  @doc false
  defmacro __using__(_config) do
    quote do
      use Ecto.Schema
      use Waffle.Ecto.Schema

      @derive {Jason.Encoder,
               only: [
                 :description,
                 :name,
                 :user_content_data,
                 :user_content_preview,
                 :uploader_id,
                 :is_public
               ]}
      import unquote(__MODULE__), only: [user_content_fields: 0]

      @spec user_content_changeset(Ecto.Schema.t() | Changeset.t(), map()) :: Changeset.t()
      def user_content_changeset(changeset, attrs) do
        changeset
        |> cast(attrs, [:name, :description, :uploader_id, :is_public])
        |> foreign_key_constraint(:uploader_id)
      end

      def user_content_upload_changeset(changeset, attrs) do
        changeset
        |> cast_attachments(attrs, [:user_content_data, :user_content_preview])
        |> validate_required([:name, :uploader_id, :user_content_data])
      end
    end
  end

  @doc false
  defmacro user_content_fields() do
    quote do
      field :description, :string
      field :name, :string
      field :user_content_data, Vertex.Uploaders.UserContentData.Type
      field :user_content_preview, Vertex.Uploaders.UserContentPreview.Type
      field :is_public, :boolean
      belongs_to :uploader, Vertex.Accounts.User, foreign_key: :uploader_id, type: :binary_id
    end
  end
end
