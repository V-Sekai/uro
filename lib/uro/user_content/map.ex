defmodule Uro.UserContent.Map do
  import Ecto.Changeset
  use Uro.UserContent.UserContent

  schema "maps" do
    user_content_fields()

    timestamps()
  end

  @doc false
  def changeset(map, attrs) do
    user_content_changeset(map, attrs)
  end
end
