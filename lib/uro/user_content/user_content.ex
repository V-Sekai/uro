defmodule Uro.UserContent.UserContent do
  alias Ecto.Changeset

  @doc false
  @spec __using__([join_table_name: String.t(), schema_atom: atom()]) :: any()
  defmacro __using__(config) do
    join_table_name = Keyword.fetch!(config, :join_table_name)
    schema_atom = Keyword.fetch!(config, :schema_atom)
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

      defmodule BackpackEntry do
	use Ecto.Schema
	import Ecto.Changeset

	@join_table_name unquote(join_table_name)
	@schema_atom unquote(schema_atom)

	schema unquote(join_table_name) do
	  belongs_to :backpack, Uro.Inventory.Backpack
	  belongs_to unquote(schema_atom), __MODULE__
	end

	defmacro backpack_entry_fields() do
	  quote do
	    many_to_many unquote(@schema_atom), __MODULE__, join_through: unquote(@join_table_name)
	  end
	end
      end
    end
  end

  @doc false
  defmacro user_content_fields() do
    quote do
      field :description, :string
      field :name, :string
      field :user_content_data, Uro.Uploaders.UserContentData.Type
      field :user_content_preview, Uro.Uploaders.UserContentPreview.Type
      field :is_public, :boolean

      many_to_many :owners, Uro.Accounts.User, join_through: Uro.Inventory.Backpack
      many_to_many :backpacks, Uro.Accounts.User, join_through: Uro.Inventory.Backpack
      belongs_to :uploader, Uro.Accounts.User, foreign_key: :uploader_id, type: :binary_id
    end
  end
end
