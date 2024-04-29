defmodule VertexWeb.PowEmailConfirmation.MailerView do
  use VertexWeb, :mailer_view

  def subject(:email_confirmation, _assigns), do: "Confirm your email address"
end
