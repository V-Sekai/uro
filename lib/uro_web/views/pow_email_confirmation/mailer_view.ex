defmodule UroWeb.PowEmailConfirmation.MailerView do
  use UroWeb, :mailer_view

  def subject(:email_confirmation, _assigns), do: "Confirm your email address"
end
