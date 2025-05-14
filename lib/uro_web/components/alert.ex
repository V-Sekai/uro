defmodule UroWeb.Components.Alert do
  @moduledoc """
  UroWeb.Components.Alert module provides collection of alert components and helper functions for managing and displaying alerts
  in a **Phoenix LiveView** application.

  This module provides a set of customizable components for rendering various types of alerts,
  such as information, warning, and error messages. It also includes functions to show and hide
  alerts with smooth transition effects.

  ## Components

    - `flash/1`: Renders a flash notice with support for different styles and sizes.
    - `flash_group/1`: Renders a group of flash messages with predefined content.
    - `alert/1`: Renders a generic alert component with customizable styles and icons.

  ## Functions

    - `show_alert/2`: Displays an alert element using a defined transition effect.
    - `hide_alert/2`: Hides an alert element using a defined transition effect.

  ## Configuration

  The module offers various configuration options through attributes and slots to allow
  fine-grained control over the appearance and behavior of alerts. Attributes like `variant`,
  `kind`, `position`, and `rounded` can be used to modify the styling, while slots provide
  flexibility in rendering custom content within alerts.
  """
  use Phoenix.Component
  use Gettext, backend: UroWeb.Gettext
  alias Phoenix.LiveView.JS
  import UroWeb.Components.Icon, only: [icon: 1]
  import Phoenix.LiveView.Utils, only: [random_id: 0]

  @doc type: :component
  @doc """
  The `flash` component is used to display flash messages with various styling options.
  It supports customizable attributes such as `kind`, `variant`, and `position` for tailored appearance.

  ## Examples

  ```elixir
  <.flash kind={:info} title="This is info titlee" width="full" size="large">
    <p>This is info Description</p>
  </.flash>

  <.flash kind={:error} title="This is misc titlee" width="large" size="large" flash={@flash} />

  <.flash_group flash={@flash} />

  <.flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.flash>
  ```
  """
  attr :id, :string, doc: "A unique identifier is used to manage state and interaction"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :title, :string, default: nil, doc: "Specifies the title of the element"
  attr :kind, :atom, default: :natural, doc: "used for styling and flash lookup"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  attr :variant, :string, default: "base", doc: "Determines the style"
  attr :position, :string, default: "", doc: "Determines the element position"
  attr :width, :string, default: "full", doc: "Determines the element width"
  attr :border, :string, default: "extra_small", doc: "Determines the element border width"
  attr :z_index, :string, default: "z-50", doc: "custom z-index"
  attr :padding, :string, default: "small", doc: "Determines the element padding size"

  attr :size, :string,
    default: "medium",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :rounded, :string, default: "small", doc: "Determines the border radius"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :icon, :any,
    default: "hero-chat-bubble-bottom-center-text",
    doc: "Icon displayed alongside of an item"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :content_class, :string,
    default: nil,
    doc: "Custom CSS class for additional styling for contnet"

  attr :title_class, :string,
    default: "flex items-center gap-1.5 leading-6 font-semibold mb-1",
    doc: "Custom CSS class for additional styling to tile"

  attr :button_class, :string,
    default: "p-2",
    doc: "Custom CSS class for additional styling to tile"

  slot :inner_block, doc: "Inner block that renders HEEx content"

  def flash(assigns) do
    assigns = assign_new(assigns, :id, fn -> "flash-#{assigns.variant}-#{assigns.kind}" end)

    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide_alert("##{@id}")}
      role="alert"
      aria-live="assertive"
      aria-labelledby={@title && @id && "#{@id}-title"}
      class={[
        "flash-alert leading-5",
        border_class(@border, @variant),
        color_variant(@variant, @kind),
        position_class(@position),
        rounded_size(@rounded),
        width_class(@width),
        padding_size(@padding),
        content_size(@size),
        @font_weight,
        @z_index,
        @class
      ]}
      {@rest}
    >
      <div class="flex items-center justify-between gap-2">
        <div>
          <div :if={@title} class={@title_class} id={@id && "#{@id}-title"}>
            <.icon :if={!is_nil(@icon)} name={@icon} class="aler-icon" aria-hidden="true" /> {@title}
          </div>

          <div class={@content_class}>{msg}</div>
        </div>

        <button type="button" class={["group shrink-0", @button_class]} aria-label={gettext("close")}>
          <.icon name="hero-x-mark-solid" class="aler-icon opacity-40 group-hover:opacity-70" />
        </button>
      </div>
    </div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Example
  ```
  <.flash_group flash={@flash} />
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: "flash-group",
    doc: "A unique identifier is used to manage state and interaction"

  attr :variant, :string, default: "bordered", doc: "Determines the style"
  attr :position, :string, default: "top_right", doc: "Position of flashes"
  attr :class, :string, default: nil, doc: "Custom classes"
  attr :z_index, :string, default: "z-50", doc: "custom z-index"
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  def flash_group(assigns) do
    ~H"""
     <div
      id={@id}
      class={["[&_.flash-alert:not(:first-child)]:mt-3", position_class(@position), @z_index, @class]}
      {@rest}
    >
      <.flash
        kind={:info}
        title={gettext("Success!")}
        flash={@flash}
        variant={@variant}
        width="medium"
      />
      <.flash
        kind={:error}
        title={gettext("Error!")}
        flash={@flash}
        variant={@variant}
        width="medium"
      />
      <.flash
        id="client-error"
        kind={:error}
        variant={@variant}
        title={gettext("We can't find the internet")}
        phx-disconnected={show_alert(".phx-client-error #client-error")}
        phx-connected={hide_alert("#client-error")}
        width="medium"
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ms-1 h-3 w-3 animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        variant={@variant}
        title={gettext("Something went wrong!")}
        phx-disconnected={show_alert(".phx-server-error #server-error")}
        phx-connected={hide_alert("#server-error")}
        width="medium"
        hidden
      >
        {gettext("Hang in there while we get back on track")}
        <.icon name="hero-arrow-path" class="ms-1 h-3 w-3 animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  The `alert` component is used to display alert messages with various styling options.
  It supports attributes like `kind`, `variant`, and `position` to control its appearance and behavior.

  ## Examples

  ```elixir
  <.alert kind={:info} title="This is info titlee" width="full" size="large">
    <p>This is info Description</p>
  </.alert>

  <.alert kind={:misc} title="This is misc titlee" width="full" />

  <.alert kind={:danger} title="This is title" width="large" size="extra_small" rounded="extra_large">
    This is Danger
  </.alert>

  <.alert kind={:success} title="This is success title" size="extra_large" icon={nil}>
    This is Success
  </.alert>

  <.alert kind={:primary}>This is Primary</.alert>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :title, :string, default: nil, doc: "Specifies the title of the element"
  attr :kind, :atom, default: :natural, doc: "used for styling and flash lookup"
  attr :variant, :string, default: "default", doc: "Determines the style"
  attr :position, :string, default: "", doc: "Determines the element position"
  attr :width, :string, default: "full", doc: "Determines the element width"
  attr :border, :string, default: "extra_small", doc: "Determines the element border width"
  attr :padding, :string, default: "small", doc: "Determines the element padding size"
  attr :z_index, :string, default: "z-50", doc: "custom z-index"

  attr :size, :string,
    default: "medium",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :rounded, :string, default: "small", doc: "Determines the border radius"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :icon, :any,
    default: "hero-chat-bubble-bottom-center-text",
    doc: "Icon displayed alongside of an item"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :title_class, :string,
    default: "flex items-center gap-1.5 leading-6 font-semibold mb-1",
    doc: "Custom CSS class for additional styling to tile"

  attr :icon_class, :string,
    default: nil,
    doc: "Custom CSS class for additional styling to icon"

  slot :inner_block, doc: "Inner block that renders HEEx content"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  def alert(assigns) do
    assigns = assigns |> assign_new(:id, fn -> "alert-#{random_id()}" end)

    ~H"""
    <div
      id={@id}
      role="alert"
      aria-live="assertive"
      aria-labelledby={@title && @id && "#{@id}-title"}
      class={[
        border_class(@border, @variant),
        color_variant(@variant, @kind),
        position_class(@position),
        rounded_size(@rounded),
        width_class(@width),
        padding_size(@padding),
        content_size(@size),
        @font_weight,
        @z_index,
        @class
      ]}
      {@rest}
    >
      <div :if={@title} class={@title_class} id={@id && "#{@id}-title"}>
        <.icon
          :if={!is_nil(@icon)}
          name={@icon}
          class={["aler-icon", @icon_class]}
          aria-hidden="true"
        /> {@title}
      </div>

      {render_slot(@inner_block)}
    </div>
    """
  end

  defp padding_size("extra_small"), do: "p-2"

  defp padding_size("small"), do: "p-3"

  defp padding_size("medium"), do: "p-4"

  defp padding_size("large"), do: "p-5"

  defp padding_size("extra_large"), do: "p-6"

  defp padding_size("none"), do: nil

  defp padding_size(params) when is_binary(params), do: params

  defp rounded_size("extra_small"), do: "rounded-sm"

  defp rounded_size("small"), do: "rounded"

  defp rounded_size("medium"), do: "rounded-md"

  defp rounded_size("large"), do: "rounded-lg"

  defp rounded_size("extra_large"), do: "rounded-xl"

  defp rounded_size("full"), do: "rounded-full"

  defp rounded_size("none"), do: nil

  defp rounded_size(params) when is_binary(params), do: params

  defp width_class("extra_small"), do: "w-60"
  defp width_class("small"), do: "w-64"
  defp width_class("medium"), do: "w-72"
  defp width_class("large"), do: "w-80"
  defp width_class("extra_large"), do: "w-96"
  defp width_class("full"), do: "w-full"
  defp width_class("fit"), do: "w-fit"
  defp width_class(params) when is_binary(params), do: params

  defp content_size("extra_small"), do: "text-[12px] [&_.aler-icon]:size-3.5"

  defp content_size("small"), do: "text-[13px] [&_.aler-icon]:size-4"

  defp content_size("medium"), do: "text-[14px] [&_.aler-icon]:size-5"

  defp content_size("large"), do: "text-[15px] [&_.aler-icon]:size-6"

  defp content_size("extra_large"), do: "text-[16px] [&_.aler-icon]:size-7"

  defp content_size(params) when is_binary(params), do: params

  defp position_class("top_left"), do: "fixed top-2 left-0 ml-2"
  defp position_class("top_right"), do: "fixed top-2 right-0 mr-2"
  defp position_class("bottom_left"), do: "fixed bottom-2 left-0 ml-2"
  defp position_class("bottom_right"), do: "fixed bottom-2 right-0 mr-2"
  defp position_class(params) when is_binary(params), do: params

  defp border_class(_, variant)
       when variant in [
              "default",
              "shadow",
              "gradient"
            ],
       do: nil

  defp border_class("none", _), do: nil
  defp border_class("extra_small", _), do: "border"
  defp border_class("small", _), do: "border-2"
  defp border_class("medium", _), do: "border-[3px]"
  defp border_class("large", _), do: "border-4"
  defp border_class("extra_large", _), do: "border-[5px]"
  defp border_class(params, _) when is_binary(params), do: params

  defp color_variant("base", _) do
    [
      "bg-white text-[#09090b] border-[#e4e4e7] shadow-sm",
      "dark:bg-[#18181B] dark:text-[#FAFAFA] dark:border-[#27272a]"
    ]
  end

  defp color_variant("default", :white) do
    ["bg-white text-black"]
  end

  defp color_variant("default", :dark) do
    ["bg-[#282828] text-white"]
  end

  defp color_variant("default", :natural) do
    ["bg-[#4B4B4B] text-white dark:bg-[#DDDDDD] dark:text-black"]
  end

  defp color_variant("default", :primary) do
    ["bg-[#007F8C] text-white dark:bg-[#01B8CA] dark:text-black"]
  end

  defp color_variant("default", :secondary) do
    ["bg-[#266EF1] text-white dark:bg-[#6DAAFB] dark:text-black"]
  end

  defp color_variant("default", :success) do
    ["bg-[#0E8345] text-white dark:bg-[#06C167] dark:text-black"]
  end

  defp color_variant("default", :warning) do
    ["bg-[#CA8D01] text-white dark:bg-[#FDC034] dark:text-black"]
  end

  defp color_variant("default", type) when type in [:error, :danger] do
    ["bg-[#DE1135] text-white dark:bg-[#FC7F79] dark:text-black"]
  end

  defp color_variant("default", :info) do
    ["bg-[#0B84BA] text-white dark:bg-[#3EB7ED] dark:text-black"]
  end

  defp color_variant("default", :misc) do
    ["bg-[#8750C5] text-white dark:bg-[#BA83F9] dark:text-black"]
  end

  defp color_variant("default", :dawn) do
    ["bg-[#A86438] text-white dark:bg-[#DB976B] dark:text-black"]
  end

  defp color_variant("default", :silver) do
    ["bg-[#868686] text-white dark:bg-[#A6A6A6] dark:text-black"]
  end

  defp color_variant("outline", :natural) do
    [
      "text-[#4B4B4B] border-[#4B4B4B]",
      "dark:text-[#DDDDDD] dark:border-[#DDDDDD]"
    ]
  end

  defp color_variant("outline", :primary) do
    [
      "text-[#007F8C] border-[#007F8C] ",
      "dark:text-[#01B8CA] dark:border-[#01B8CA]"
    ]
  end

  defp color_variant("outline", :secondary) do
    [
      "text-[#266EF1] border-[#266EF1]",
      "dark:text-[#6DAAFB] dark:border-[#6DAAFB]"
    ]
  end

  defp color_variant("outline", :success) do
    [
      "text-[#0E8345] border-[#0E8345]",
      "dark:text-[#06C167] dark:border-[#06C167]"
    ]
  end

  defp color_variant("outline", :warning) do
    [
      "text-[#CA8D01] border-[#CA8D01]",
      "dark:text-[#FDC034] dark:border-[#FDC034]"
    ]
  end

  defp color_variant("outline", type) when type in [:error, :danger] do
    [
      "text-[#DE1135] border-[#DE1135]",
      "dark:text-[#FC7F79] dark:border-[#FC7F79]"
    ]
  end

  defp color_variant("outline", :info) do
    [
      "text-[#0B84BA] border-[#0B84BA]",
      "dark:text-[#3EB7ED] dark:border-[#3EB7ED]"
    ]
  end

  defp color_variant("outline", :misc) do
    [
      "text-[#8750C5] border-[#8750C5]",
      "dark:text-[#BA83F9] dark:border-[#BA83F9]"
    ]
  end

  defp color_variant("outline", :dawn) do
    [
      "text-[#A86438] border-[#A86438]",
      "dark:text-[#DB976B] dark:border-[#DB976B]"
    ]
  end

  defp color_variant("outline", :silver) do
    [
      "text-[#868686] border-[#868686]",
      "dark:text-[#A6A6A6] dark:border-[#A6A6A6]"
    ]
  end

  defp color_variant("shadow", :natural) do
    [
      "bg-[#4B4B4B] text-white dark:bg-[#DDDDDD] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(134,134,134,0.5)] shadow-[0px_10px_15px_-3px_rgba(134,134,134,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", :primary) do
    [
      "bg-[#007F8C] text-white dark:bg-[#01B8CA] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(0,149,164,0.5)] shadow-[0px_10px_15px_-3px_rgba(0,149,164,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", :secondary) do
    [
      "bg-[#266EF1] text-white dark:bg-[#6DAAFB] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(6,139,238,0.5)] shadow-[0px_10px_15px_-3px_rgba(6,139,238,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", :success) do
    [
      "bg-[#0E8345] text-white hover:bg-[#166C3B] dark:bg-[#06C167] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(0,154,81,0.5)] shadow-[0px_10px_15px_-3px_rgba(0,154,81,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", :warning) do
    [
      "bg-[#CA8D01] text-white dark:bg-[#FDC034] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(252,176,1,0.5)] shadow-[0px_10px_15px_-3px_rgba(252,176,1,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", type) when type in [:error, :danger] do
    [
      "bg-[#DE1135] text-white dark:bg-[#FC7F79] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(248,52,70,0.5)] shadow-[0px_10px_15px_-3px_rgba(248,52,70,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", :info) do
    [
      "bg-[#0B84BA] text-white dark:bg-[#3EB7ED] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(14,165,233,0.5)] shadow-[0px_10px_15px_-3px_rgba(14,165,233,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", :misc) do
    [
      "bg-[#8750C5] text-white dark:bg-[#BA83F9] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(169,100,247,0.5)] shadow-[0px_10px_15px_-3px_rgba(169,100,247,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", :dawn) do
    [
      "bg-[#A86438] text-white dark:bg-[#DB976B] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(210,125,70,0.5)] shadow-[0px_10px_15px_-3px_rgba(210,125,70,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", :silver) do
    [
      "bg-[#868686] text-white dark:bg-[#A6A6A6] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(134,134,134,0.5)] shadow-[0px_10px_15px_-3px_rgba(134,134,134,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("bordered", :white) do
    ["bg-white text-black border-[#DDDDDD]"]
  end

  defp color_variant("bordered", :dark) do
    ["bg-[#282828] text-white border-[#727272]"]
  end

  defp color_variant("bordered", :natural) do
    [
      "text-[#282828] border-[#282828] bg-[#F3F3F3]",
      "dark:text-[#E8E8E8] dark:border-[#E8E8E8] dark:bg-[#4B4B4B]"
    ]
  end

  defp color_variant("bordered", :primary) do
    [
      "text-[#016974] border-[#016974] bg-[#E2F8FB]",
      "dark:text-[#77D5E3] dark:border-[#77D5E3] dark:bg-[#002D33]"
    ]
  end

  defp color_variant("bordered", :secondary) do
    [
      "text-[#175BCC] border-[#175BCC] bg-[#EFF4FE]",
      "dark:text-[#A9C9FF] dark:border-[#A9C9FF] dark:bg-[#002661]"
    ]
  end

  defp color_variant("bordered", :success) do
    [
      "text-[#166C3B] border-[#166C3B] bg-[#EAF6ED]",
      "dark:text-[#7FD99A] dark:border-[#7FD99A] dark:bg-[#002F14]"
    ]
  end

  defp color_variant("bordered", :warning) do
    [
      "text-[#976A01] border-[#976A01] bg-[#FFF7E6]",
      "dark:text-[#FDD067] dark:border-[#FDD067] dark:bg-[#322300]"
    ]
  end

  defp color_variant("bordered", type) when type in [:error, :danger] do
    [
      "text-[#BB032A] border-[#BB032A] bg-[#FFF0EE]",
      "dark:text-[#FFB2AB] dark:border-[#FFB2AB] dark:bg-[#520810]"
    ]
  end

  defp color_variant("bordered", :info) do
    [
      "text-[#0B84BA] border-[#0B84BA] bg-[#E7F6FD]",
      "dark:text-[#6EC9F2] dark:border-[#6EC9F2] dark:bg-[#03212F]"
    ]
  end

  defp color_variant("bordered", :misc) do
    [
      "text-[#653C94] border-[#653C94] bg-[#F6F0FE]",
      "dark:text-[#CBA2FA] dark:border-[#CBA2FA] dark:bg-[#221431]"
    ]
  end

  defp color_variant("bordered", :dawn) do
    [
      "text-[#7E4B2A] border-[#7E4B2A] bg-[#FBF2ED]",
      "dark:text-[#E4B190] dark:border-[#E4B190] dark:bg-[#2A190E]"
    ]
  end

  defp color_variant("bordered", :silver) do
    [
      "text-[#727272] border-[#727272] bg-[#F3F3F3]",
      "dark:text-[#BBBBBB] dark:border-[#BBBBBB] dark:bg-[#4B4B4B]"
    ]
  end

  defp color_variant("gradient", :natural) do
    [
      "bg-gradient-to-br from-[#282828] to-[#727272] text-white",
      "dark:from-[#A6A6A6] dark:to-[#FFFFFF] dark:text-black"
    ]
  end

  defp color_variant("gradient", :primary) do
    [
      "bg-gradient-to-br from-[#016974] to-[#01B8CA] text-white",
      "dark:from-[#01B8CA] dark:to-[#B0E7EF] dark:text-black"
    ]
  end

  defp color_variant("gradient", :secondary) do
    [
      "bg-gradient-to-br from-[#175BCC] to-[#6DAAFB] text-white",
      "dark:from-[#6DAAFB] dark:to-[#CDDEFF] dark:text-black"
    ]
  end

  defp color_variant("gradient", :success) do
    [
      "bg-gradient-to-br from-[#166C3B] to-[#06C167] text-white",
      "dark:from-[#06C167] dark:to-[#B1EAC2] dark:text-black"
    ]
  end

  defp color_variant("gradient", :warning) do
    [
      "bg-gradient-to-br from-[#976A01] to-[#FDC034] text-white",
      "dark:from-[#FDC034] dark:to-[#FEDF99] dark:text-black"
    ]
  end

  defp color_variant("gradient", type) when type in [:error, :danger] do
    [
      "bg-gradient-to-br from-[#BB032A] to-[#FC7F79] text-white",
      "dark:from-[#FC7F79] dark:to-[#FFD2CD] dark:text-black"
    ]
  end

  defp color_variant("gradient", :info) do
    [
      "bg-gradient-to-br from-[#08638C] to-[#3EB7ED] text-white",
      "dark:from-[#3EB7ED] dark:to-[#9FDBF6] dark:text-black"
    ]
  end

  defp color_variant("gradient", :misc) do
    [
      "bg-gradient-to-br from-[#653C94] to-[#BA83F9] text-white",
      "dark:from-[#BA83F9] dark:to-[#DDC1FC] dark:text-black"
    ]
  end

  defp color_variant("gradient", :dawn) do
    [
      "bg-gradient-to-br from-[#7E4B2A] to-[#DB976B] text-white",
      "dark:from-[#DB976B] dark:to-[#EDCBB5] dark:text-black"
    ]
  end

  defp color_variant("gradient", :silver) do
    [
      "bg-gradient-to-br from-[#5E5E5E] to-[#A6A6A6] text-white",
      "dark:from-[#868686] dark:to-[#BBBBBB] dark:text-black"
    ]
  end

  defp color_variant(params, _) when is_binary(params), do: params

  ## JS Commands

  @doc """
  Displays an alert element by applying a transition effect.

  ## Parameters

    - `js`: (optional) An existing `Phoenix.LiveView.JS` structure to apply transformations on.
    Defaults to a new `%JS{}`.
    - `selector`: A string representing the CSS selector of the alert element to be shown.

  ## Returns

    - A `Phoenix.LiveView.JS` structure with commands to show the alert element with a
    smooth transition effect.

  ## Transition Details

    - The element transitions from an initial state of reduced opacity and scale
    (`opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95`) to full opacity and scale
    (`opacity-100 translate-y-0 sm:scale-100`) over a duration of 300 milliseconds.

  ## Example

    ```elixir
    show_alert(%JS{}, "#alert-box")
    ```

  This example will show the alert element with the ID `alert-box` using the defined transition effect.
  """

  def show_alert(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      time: 300,
      transition:
        {"transition-all transform ease-out duration-300",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  @doc """
  Hides an alert element by applying a transition effect.

  ## Parameters

    - `js`: (optional) An existing `Phoenix.LiveView.JS` structure to apply transformations on.
    Defaults to a new `%JS{}`.
    - `selector`: A string representing the CSS selector of the alert element to be hidden.

  ## Returns

    - A `Phoenix.LiveView.JS` structure with commands to hide the alert element with
    a smooth transition effect.

  ## Transition Details

    - The element transitions from full opacity and scale (`opacity-100 translate-y-0 sm:scale-100`)
    to reduced opacity and scale (`opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95`)
    over a duration of 200 milliseconds.

  ## Example

    ```elixir
    hide_alert(%JS{}, "#alert-box")
    ```

  This example will hide the alert element with the ID `alert-box` using the defined transition effect.
  """

  def hide_alert(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all transform ease-in duration-200",
         "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end
end
