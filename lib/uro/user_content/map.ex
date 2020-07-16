defmodule Uro.UserContent.Map do
  import Ecto.Changeset
  use Ecto.Schema
  use Uro.UserContent.UserContent
  @derive {Jason.Encoder, only: [:description, :name, :url, :uploader]}

  schema "maps" do
    user_content_fields()

    timestamps()
  end

  @doc false
  def changeset(map, attrs) do
    user_content_changeset(map, attrs)
  end
end
