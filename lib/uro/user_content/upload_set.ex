defmodule Uro.UserContent.UploadSet do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "upload_set" do
    has_many :uploaded_avatars, Uro.UserContent.Avatar, foreign_key: :uploader_id
    has_many :uploaded_maps, Uro.UserContent.Map, foreign_key: :uploader_id
    has_many :uploaded_props, Uro.UserContent.Prop, foreign_key: :uploader_id

    belongs_to :user, Uro.Accounts.User, foreign_key: :user_id, type: :binary_id
    timestamps()
  end

  @doc false
  def changeset(upload_set, attrs) do
    upload_set
    |> cast(attrs, [])
    |> validate_required([])
  end
end
