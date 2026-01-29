defmodule UroWeb.Components.MishkaComponents do
  defmacro __using__(_) do
    quote do
      import UroWeb.Components.FormWrapper, only: [form_wrapper: 1, simple_form: 1]
      import UroWeb.Components.EmailField, only: [email_field: 1]

      import UroWeb.Components.Button,
        only: [button_group: 1, button: 1, input_button: 1, button_link: 1, back: 1]

      import UroWeb.Components.PasswordField, only: [password_field: 1]

      import UroWeb.Components.Alert,
        only: [
          flash: 1,
          flash_group: 1,
          alert: 1,
          show_alert: 1,
          show_alert: 2,
          hide_alert: 1,
          hide_alert: 2
        ]

      import UroWeb.Components.Icon, only: [icon: 1]
    end
  end
end
