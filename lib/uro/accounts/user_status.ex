defmodule Uro.Accounts.User.Status do
  @moduledoc false

  require OpenApiSpex

  @values [
    :online,
    :offline,
    :away,
    :busy,
    :invisible
  ]

  def values(), do: @values

  OpenApiSpex.schema(%{
    title: "UserStatus",
    type: :string,
    enum: @values
  })
end
