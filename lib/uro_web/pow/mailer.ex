defmodule UroWeb.Pow.Mailer do
  use Pow.Phoenix.Mailer
  use Swoosh.Mailer, otp_app: :uro

  import Swoosh.Email

  require Logger

  @impl true
  def cast(%{user: user, subject: subject, text: text, html: html}) do
    %Swoosh.Email{}
    |> to({user.display_name, user.email})
    |> from({"V-Sekai", "Verification@v-sekai.cloud"})
    |> subject(subject)
    |> html_body(html)
    |> text_body(text)
  end

  def start_delivery_task(email) do
    # An asynchronous process should be used here to prevent enumeration
    # attacks. Synchronous e-mail delivery can reveal whether a user already
    # exists in the system or not.
    Task.start(fn ->
      email
      |> deliver()
      |> log_warnings()
    end)
  end

  @impl true
  def process(email) do
    start_delivery_task(email)
    :ok
  end

  defp log_warnings({:error, reason}) do
    Logger.warn("Mailer backend failed with: #{inspect(reason)}")
  end

  defp log_warnings({:ok, response}), do: {:ok, response}
end
