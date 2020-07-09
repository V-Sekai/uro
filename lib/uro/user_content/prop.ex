defmodule Uro.UserContent.Prop do
  import Ecto.Changeset
  use Ecto.Schema
  use Uro.UserContent.UserContent

  schema "props" do
    user_content_fields()

    timestamps()
  end

  @doc false
  def changeset(prop, attrs) do
    user_content_changeset(prop, attrs)
  end
end
