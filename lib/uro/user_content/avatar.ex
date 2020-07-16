defmodule Uro.UserContent.Avatar do
  import Ecto.Changeset
  use Ecto.Schema
  use Uro.UserContent.UserContent
  @derive {Jason.Encoder, only: [:description, :name, :url, :uploader]}

  schema "avatars" do
    user_content_fields()

    timestamps()
  end

  @doc false
  def changeset(avatar, attrs) do
    user_content_changeset(avatar, attrs)
  end
end
