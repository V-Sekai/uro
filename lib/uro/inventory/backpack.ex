defmodule Uro.Inventory.Backpack do
  alias Uro.Accounts.User
  import Ecto.Changeset
  use Ecto.Schema

  require Uro.UserContent.Avatar.BackpackEntry
  require Uro.UserContent.Map.BackpackEntry
  require Uro.UserContent.Prop.BackpackEntry

  schema "backpacks" do
    belongs_to :owner, User, foreign_key: :owner_id, type: :binary_id

    Uro.UserContent.Avatar.BackpackEntry.backpack_entry_fields()
    Uro.UserContent.Map.BackpackEntry.backpack_entry_fields()
    Uro.UserContent.Prop.BackpackEntry.backpack_entry_fields()

    timestamps()
  end
end
