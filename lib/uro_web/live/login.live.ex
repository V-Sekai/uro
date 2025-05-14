defmodule UroWeb.LoginLive do
  use Uro, :live_view

  def render(assigns) do
    ~H"""
    <div class="flex mt-25">
        <.form_wrapper for={@login_form} phx-submit="going" class="p-4 rounded-sm m-auto w-6/12">
            <.email_field class="mb-4" field={@login_form[:email]} required name="email" label="Email" placeholder="Email" value="" floating="inner" color="red-300" />
            <.password_field class="mb-8" field={@login_form[:password]} required name="password" label="Password" value="" floating="inner" />

            <:actions>
              <.button class="m-auto">Let's go</.button>
            </:actions>
        </.form_wrapper>
    </div>
    """
  end

  def mount(_params, _, socket) do
    login_form = to_form(%{"email" => nil, "password" => nil})
    {:ok, socket |> assign(:login_form, login_form)}
  end
end
