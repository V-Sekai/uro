defmodule Uro.UserContent.UserContent do
  alias Ecto.Changeset

  @doc false
  defmacro __using__(_config) do
    quote do
      @behaviour unquote(__MODULE__)
      import unquote(__MODULE__), only: [user_content_fields: 0]

      @spec user_content_changeset(Ecto.Schema.t() | Changeset.t(), map()) :: Changeset.t()
      def user_content_changeset(changeset, attrs) do
        changeset
        |> cast(attrs, [:name, :description, :url])
        |> validate_required([:name, :description, :url])
      end

      @behaviour unquote(__MODULE__)
    end
  end

  @doc false
  defmacro user_content_fields() do
    quote do
      field :description, :string
      field :name, :string
      field :url, :string
      belongs_to :uploader, Accounts.User
    end
  end
end
