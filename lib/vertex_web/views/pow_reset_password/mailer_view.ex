defmodule VertexWeb.PowResetPassword.MailerView do
  use VertexWeb, :mailer_view

  def subject(:reset_password, _assigns), do: "Reset password link"
end
