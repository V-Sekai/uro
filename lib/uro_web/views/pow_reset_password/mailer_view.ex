defmodule UroWeb.PowResetPassword.MailerView do
  use UroWeb, :mailer_view

  def subject(:reset_password, _assigns), do: "Reset password link"
end
