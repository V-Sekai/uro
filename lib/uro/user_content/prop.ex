defmodule Uro.UserContent.Prop do
  import Ecto.Changeset
  use Ecto.Schema
  use Uro.UserContent.UserContent
  @derive {Jason.Encoder, only: [:description, :name, :url, :uploader]}

  schema "props" do
    user_content_fields()

    timestamps()
  end

  @doc false
  def changeset(prop, attrs) do
    user_content_changeset(prop, attrs)
  end
end
