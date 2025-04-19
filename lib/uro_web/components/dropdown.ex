defmodule UroWeb.Components.Dropdown do
  @moduledoc """
  The `UroWeb.Components.Dropdown` module provides a customizable dropdown component
  built using Phoenix LiveView. It allows you to create dropdown menus with different styles,
  positions, and behaviors, supporting various customization options through attributes and slots.

  This module facilitates creating and managing dropdown components in a
  Phoenix LiveView application with flexible customization options.
  """

  use Phoenix.Component
  alias Phoenix.LiveView.JS

  @doc """
  A `dropdown` component that displays a list of options or content when triggered.
  It can be activated by a click or hover, and positioned in various directions relative to its parent.

  ## Examples

  ```elixir
  <.dropdown relative="relative" position="right">
    <:trigger>
      <.button color="primary" icon="hero-chevron-down" right_icon>
        Dropdown Right
      </.button>
    </:trigger>

    <:content space="small" rounded="large" width="full" padding="extra_small">
      <.list size="small">
        <:item padding="extra_small" icon="hero-envelope">Dashboard</:item>
        <:item padding="extra_small" icon="hero-camera">Settings</:item>
        <:item padding="extra_small" icon="hero-camera">Earning</:item>
        <:item padding="extra_small" icon="hero-calendar">Sign out</:item>
      </.list>
    </:content>
  </.dropdown>

  <.dropdown relative="relative" clickable>
    <:trigger trigger_id="test-1">
      <.button color="primary" icon="hero-chevron-down" right_icon>
        Dropdown Button
      </.button>
    </:trigger>

    <:content id="test-1" space="small" rounded="large" width="full" padding="extra_small">
      <.list size="small">
        <:item padding="extra_small" icon="hero-envelope">Dashboard</:item>
        <:item padding="extra_small" icon="hero-camera">Settings</:item>
        <:item padding="extra_small" icon="hero-camera">Earning</:item>
        <:item padding="extra_small" icon="hero-calendar">Sign out</:item>
      </.list>
    </:content>
  </.dropdown>
  ```
  """
  @doc type: :component
  attr :id, :string,
    required: true,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :width, :string, default: "w-fit", doc: "Determines the element width"
  attr :position, :string, default: "bottom", doc: "Determines the element position"
  attr :relative, :string, default: nil, doc: "Custom relative position for the dropdown"

  attr :clickable, :boolean,
    default: false,
    doc: "Determines if the element can be activated on click"

  attr :nomobile, :boolean,
    default: false,
    doc: "Controls whether the dropdown is disabled on mobile devices"

  attr :variant, :string, default: "base", doc: "Determines the style"
  attr :color, :string, default: "natural", doc: "Determines color theme"
  attr :rounded, :string, default: "", doc: "Determines the border radius"
  attr :content_width, :string, default: "extra_large", doc: "Determines the element width"

  attr :size, :string,
    default: "",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :space, :string, default: "", doc: "Space between items"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :padding, :string, default: "none", doc: "Determines padding for items"
  attr :border, :string, default: "extra_small", doc: "Determines border style"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  slot :trigger, required: false do
    attr :class, :string, doc: "Custom CSS class for additional styling"
  end

  slot :content, required: false do
    attr :class, :string, doc: "Custom CSS class for additional styling"
  end

  def dropdown(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "[&>.dropdown-content]:invisible [&>.dropdown-content]:opacity-0",
        "[&>.dropdown-content.show-dropdown]:visible [&>.dropdown-content.show-dropdown]:opacity-100",
        !@clickable && tirgger_dropdown(),
        !@nomobile && dropdown_position(@position),
        (!@nomobile && @position == "left") ||
          (@position == "right" && dropdown_mobile_position(@position)),
        @relative,
        @width,
        @class
      ]}
      {@rest}
    >
      <div
        :for={trigger <- @trigger}
        phx-click={
          @clickable &&
            JS.toggle_class("show-dropdown",
              to: "##{@id}-dropdown-content",
              transition: "duration-100"
            )
        }
        class={["dropdown-trigger [&>*]:cursor-pointer", trigger[:class]]}
        {@rest}
      >
        {render_slot(trigger)}
      </div>

      <div
        :for={content <- @content}
        id={"#{@id}-dropdown-content"}
        phx-click-away={
          @id &&
            JS.remove_class("show-dropdown", to: "##{@id}-dropdown-content", transition: "duration-300")
        }
        class={[
          "dropdown-content absolute z-20 transition-all ease-in-out delay-100 duratio-500 w-full",
          "invisible opacity-0",
          space_class(@space),
          color_variant(@variant, @color),
          rounded_size(@rounded),
          size_class(@size),
          width_class(@content_width),
          border_class(@border, @variant),
          padding_size(@padding),
          @font_weight,
          content[:class]
        ]}
        {@rest}
      >
        {render_slot(content)}
      </div>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Defines a trigger for the dropdown component. When the element is clicked,
  it toggles the visibility of the associated dropdown content.

  ## Examples

  ```elixir
  <.dropdown_trigger>
    <.button color="primary" icon="hero-chevron-down" right_icon>Dropdown Right</.button>
  </.dropdown_trigger>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :trigger_id, :string, default: nil, doc: "Identifies what is the triggered element id"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  def dropdown_trigger(assigns) do
    ~H"""
    <div
      id={@id}
      phx-click={
        @trigger_id &&
          JS.toggle_class("show-dropdown",
            to: "##{@trigger_id}-dropdown-content",
            transition: "duration-100"
          )
      }
      class={["cursor-pointer dropdown-trigger", @class]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Defines the content area of a dropdown component. The content appears when the dropdown trigger
  is activated and can be customized with various styles such as size, color, padding, and border.

  ## Examples

  ```elixir
  <.dropdown_content space="small" rounded="large" width="full" padding="extra_small">
    <.list size="small">
      <:item padding="extra_small" icon="hero-envelope">Dashboard</:item>
      <:item padding="extra_small" icon="hero-camera">Settings</:item>
      <:item padding="extra_small" icon="hero-camera">Earning</:item>
      <:item padding="extra_small" icon="hero-calendar">Sign out</:item>
    </.list>
  </.dropdown_content>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :variant, :string, default: "base", doc: "Determines the style"
  attr :color, :string, default: "natural", doc: "Determines color theme"
  attr :rounded, :string, default: "", doc: "Determines the border radius"

  attr :size, :string,
    default: "",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :space, :string, default: "", doc: "Space between items"
  attr :width, :string, default: "extra_large", doc: "Determines the element width"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :padding, :string, default: "none", doc: "Determines padding for items"
  attr :border, :string, default: "extra_small", doc: "Determines border style"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def dropdown_content(assigns) do
    ~H"""
    <div
      id={@id && "#{@id}-dropdown-content"}
      phx-click-away={
        @id &&
          JS.remove_class("show-dropdown", to: "##{@id}-dropdown-content", transition: "duration-300")
      }
      class={[
        "dropdown-content absolute z-20 transition-all ease-in-out delay-100 duratio-500 w-full",
        "invisible opacity-0",
        space_class(@space),
        color_variant(@variant, @color),
        rounded_size(@rounded),
        size_class(@size),
        width_class(@width),
        border_class(@border, @variant),
        padding_size(@padding),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp tirgger_dropdown(),
    do: "[&>.dropdown-content]:hover:visible [&>.dropdown-content]:hover:opacity-100"

  defp dropdown_position("bottom") do
    [
      "[&>.dropdown-content]:top-full [&>.dropdown-content]:left-1/2",
      "[&>.dropdown-content]:-translate-x-1/2 [&>.dropdown-content]:translate-y-[6px]"
    ]
  end

  defp dropdown_position("left") do
    [
      "[&>.dropdown-content]:right-full [&>.dropdown-content]:top-0",
      "[&>.dropdown-content]:-translate-x-[5%]"
    ]
  end

  defp dropdown_position("right") do
    [
      "[&>.dropdown-content]:left-full [&>.dropdown-content]:top-0",
      "[&>.dropdown-content]:translate-x-[5%]"
    ]
  end

  defp dropdown_position("top") do
    [
      "[&>.dropdown-content]:bottom-full [&>.dropdown-content]:left-1/2",
      "[&>.dropdown-content]:-translate-x-1/2 [&>.dropdown-content]:-translate-y-[4px]"
    ]
  end

  defp dropdown_position("top-left") do
    [
      "[&>.dropdown-content]:bottom-full [&>.dropdown-content]:right-0",
      "[&>.dropdown-content]:translate-x-0 [&>.dropdown-content]:-translate-y-[4px]"
    ]
  end

  defp dropdown_position("top-right") do
    [
      "[&>.dropdown-content]:bottom-full [&>.dropdown-content]:left-0",
      "[&>.dropdown-content]:translate-x-0 [&>.dropdown-content]:-translate-y-[4px]"
    ]
  end

  defp dropdown_position("bottom-left") do
    [
      "[&>.dropdown-content]:top-full [&>.dropdown-content]:right-0",
      "[&>.dropdown-content]:-translate-x-0 [&>.dropdown-content]:translate-y-[6px]"
    ]
  end

  defp dropdown_position("bottom-right") do
    [
      "[&>.dropdown-content]:top-full [&>.dropdown-content]:left-0",
      "[&>.dropdown-content]:-translate-x-0 [&>.dropdown-content]:translate-y-[6px]"
    ]
  end

  defp dropdown_mobile_position("left") do
    [
      "md:[&>.dropdown-content]:right-full md:[&>.dropdown-content]:top-0",
      "md:[&>.dropdown-content]:-translate-x-[5%]",
      "[&>.dropdown-content]:top-full [&>.dropdown-content]:left-1/2",
      "[&>.dropdown-content]:translate-x-1/2 [&>.dropdown-content]:translate-y-[6px]"
    ]
  end

  defp dropdown_mobile_position("right") do
    [
      "md:[&>.dropdown-content]:left-full md:[&>.dropdown-content]:top-0",
      "md:[&>.dropdown-content]:translate-x-[5%]",
      "[&>.dropdown-content]:top-full [&>.dropdown-content]:left-1/2",
      "[&>.dropdown-content]:-translate-x-1/2 [&>.dropdown-content]:translate-y-[6px]"
    ]
  end

  defp border_class(_, variant) when variant in ["default", "shadow"], do: nil

  defp border_class("none", _), do: nil
  defp border_class("extra_small", _), do: "border"
  defp border_class("small", _), do: "border-2"
  defp border_class("medium", _), do: "border-[3px]"
  defp border_class("large", _), do: "border-4"
  defp border_class("extra_large", _), do: "border-[5px]"
  defp border_class(params, _) when is_binary(params), do: params

  defp rounded_size("extra_small"), do: "rounded-sm"

  defp rounded_size("small"), do: "rounded"

  defp rounded_size("medium"), do: "rounded-md"

  defp rounded_size("large"), do: "rounded-lg"

  defp rounded_size("extra_large"), do: "rounded-xl"

  defp rounded_size("none"), do: nil

  defp rounded_size(params) when is_binary(params), do: params

  defp size_class("extra_small"), do: "text-[12px]"

  defp size_class("small"), do: "text-[13px]"

  defp size_class("medium"), do: "text-[14px]"

  defp size_class("large"), do: "text-[15px]"

  defp size_class("extra_large"), do: "text-[16px]"

  defp size_class(params) when is_binary(params), do: params

  defp padding_size("extra_small"), do: "p-2"

  defp padding_size("small"), do: "p-3"

  defp padding_size("medium"), do: "p-4"

  defp padding_size("large"), do: "p-5"

  defp padding_size("extra_large"), do: "p-6"

  defp padding_size("none"), do: nil

  defp padding_size(params) when is_binary(params), do: params

  defp width_class("extra_small"), do: "min-w-48"
  defp width_class("small"), do: "min-w-52"
  defp width_class("medium"), do: "min-w-56"
  defp width_class("large"), do: "min-w-60"
  defp width_class("extra_large"), do: "min-w-64"
  defp width_class("double_large"), do: "min-w-72"
  defp width_class("triple_large"), do: "min-w-80"
  defp width_class("quadruple_large"), do: "min-w-96"
  defp width_class("full"), do: "w-full"
  defp width_class(params) when is_binary(params), do: params

  defp space_class("extra_small"), do: "space-y-2"

  defp space_class("small"), do: "space-y-3"

  defp space_class("medium"), do: "space-y-4"

  defp space_class("large"), do: "space-y-5"

  defp space_class("extra_large"), do: "space-y-6"

  defp space_class(params) when is_binary(params), do: params

  defp color_variant("base", _) do
    [
      "bg-white text-[#09090b] border-[#e4e4e7] shadow-sm",
      "dark:bg-[#18181B] dark:text-[#FAFAFA] dark:border-[#27272a]"
    ]
  end

  defp color_variant("default", "white") do
    [
      "bg-white text-black"
    ]
  end

  defp color_variant("default", "dark") do
    [
      "bg-[#282828] text-white"
    ]
  end

  defp color_variant("default", "natural") do
    [
      "bg-[#4B4B4B] text-white dark:bg-[#DDDDDD] dark:text-black"
    ]
  end

  defp color_variant("default", "primary") do
    [
      "bg-[#007F8C] text-white dark:bg-[#01B8CA] dark:text-black"
    ]
  end

  defp color_variant("default", "secondary") do
    [
      "bg-[#266EF1] text-white dark:bg-[#6DAAFB] dark:text-black"
    ]
  end

  defp color_variant("default", "success") do
    [
      "bg-[#0E8345] text-white dark:bg-[#06C167] dark:text-black"
    ]
  end

  defp color_variant("default", "warning") do
    [
      "bg-[#CA8D01] text-white dark:bg-[#FDC034] dark:text-black"
    ]
  end

  defp color_variant("default", "danger") do
    [
      "bg-[#DE1135] text-white dark:bg-[#FC7F79] dark:text-black"
    ]
  end

  defp color_variant("default", "info") do
    [
      "bg-[#0B84BA] text-white dark:bg-[#3EB7ED] dark:text-black"
    ]
  end

  defp color_variant("default", "misc") do
    [
      "bg-[#8750C5] text-white dark:bg-[#BA83F9] dark:text-black"
    ]
  end

  defp color_variant("default", "dawn") do
    [
      "bg-[#A86438] text-white dark:bg-[#DB976B] dark:text-black"
    ]
  end

  defp color_variant("default", "silver") do
    [
      "bg-[#868686] text-white dark:bg-[#A6A6A6] dark:text-black"
    ]
  end

  defp color_variant("outline", "natural") do
    [
      "text-[#4B4B4B] border-[#4B4B4B] dark:text-[#DDDDDD] dark:border-[#DDDDDD]"
    ]
  end

  defp color_variant("outline", "primary") do
    [
      "text-[#007F8C] border-[#007F8C]  dark:text-[#01B8CA] dark:border-[#01B8CA]"
    ]
  end

  defp color_variant("outline", "secondary") do
    [
      "text-[#266EF1] border-[#266EF1] dark:text-[#6DAAFB] dark:border-[#6DAAFB]"
    ]
  end

  defp color_variant("outline", "success") do
    [
      "text-[#0E8345] border-[#0E8345] dark:text-[#06C167] dark:border-[#06C167]"
    ]
  end

  defp color_variant("outline", "warning") do
    [
      "text-[#CA8D01] border-[#CA8D01] dark:text-[#FDC034] dark:border-[#FDC034]"
    ]
  end

  defp color_variant("outline", "danger") do
    [
      "text-[#DE1135] border-[#DE1135] dark:text-[#FC7F79] dark:border-[#FC7F79]"
    ]
  end

  defp color_variant("outline", "info") do
    [
      "text-[#0B84BA] border-[#0B84BA] dark:text-[#3EB7ED] dark:border-[#3EB7ED]"
    ]
  end

  defp color_variant("outline", "misc") do
    [
      "text-[#8750C5] border-[#8750C5] dark:text-[#BA83F9] dark:border-[#BA83F9]"
    ]
  end

  defp color_variant("outline", "dawn") do
    [
      "text-[#A86438] border-[#A86438] dark:text-[#DB976B] dark:border-[#DB976B]"
    ]
  end

  defp color_variant("outline", "silver") do
    [
      "text-[#868686] border-[#868686] dark:text-[#A6A6A6] dark:border-[#A6A6A6]"
    ]
  end

  defp color_variant("shadow", "natural") do
    [
      "bg-[#4B4B4B] text-white dark:bg-[#DDDDDD] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(134,134,134,0.5)] shadow-[0px_10px_15px_-3px_rgba(134,134,134,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "primary") do
    [
      "bg-[#007F8C] text-white dark:bg-[#01B8CA] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(0,149,164,0.5)] shadow-[0px_10px_15px_-3px_rgba(0,149,164,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "secondary") do
    [
      "bg-[#266EF1] text-white dark:bg-[#6DAAFB] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(6,139,238,0.5)] shadow-[0px_10px_15px_-3px_rgba(6,139,238,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "success") do
    [
      "bg-[#0E8345] text-white hover:bg-[#166C3B] dark:bg-[#06C167] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(0,154,81,0.5)] shadow-[0px_10px_15px_-3px_rgba(0,154,81,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "warning") do
    [
      "bg-[#CA8D01] text-white dark:bg-[#FDC034] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(252,176,1,0.5)] shadow-[0px_10px_15px_-3px_rgba(252,176,1,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "danger") do
    [
      "bg-[#DE1135] text-white dark:bg-[#FC7F79] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(248,52,70,0.5)] shadow-[0px_10px_15px_-3px_rgba(248,52,70,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "info") do
    [
      "bg-[#0B84BA] text-white dark:bg-[#3EB7ED] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(14,165,233,0.5)] shadow-[0px_10px_15px_-3px_rgba(14,165,233,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "misc") do
    [
      "bg-[#8750C5] text-white dark:bg-[#BA83F9] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(169,100,247,0.5)] shadow-[0px_10px_15px_-3px_rgba(169,100,247,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "dawn") do
    [
      "bg-[#A86438] text-white dark:bg-[#DB976B] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(210,125,70,0.5)] shadow-[0px_10px_15px_-3px_rgba(210,125,70,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "silver") do
    [
      "bg-[#868686] text-white dark:bg-[#A6A6A6] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(134,134,134,0.5)] shadow-[0px_10px_15px_-3px_rgba(134,134,134,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("bordered", "white") do
    [
      "bg-white text-black border-[#DDDDDD]"
    ]
  end

  defp color_variant("bordered", "dark") do
    [
      "bg-[#282828] text-white border-[#727272]"
    ]
  end

  defp color_variant("bordered", "natural") do
    [
      "text-[#282828] border-[#282828] bg-[#F3F3F3]",
      "dark:text-[#E8E8E8] dark:border-[#E8E8E8] dark:bg-[#4B4B4B]"
    ]
  end

  defp color_variant("bordered", "primary") do
    [
      "text-[#016974] border-[#016974] bg-[#E2F8FB]",
      "dark:text-[#77D5E3] dark:border-[#77D5E3] dark:bg-[#002D33]"
    ]
  end

  defp color_variant("bordered", "secondary") do
    [
      "text-[#175BCC] border-[#175BCC] bg-[#EFF4FE]",
      "dark:text-[#A9C9FF] dark:border-[#A9C9FF] dark:bg-[#002661]"
    ]
  end

  defp color_variant("bordered", "success") do
    [
      "text-[#166C3B] border-[#166C3B] bg-[#EAF6ED]",
      "dark:text-[#7FD99A] dark:border-[#7FD99A] dark:bg-[#002F14]"
    ]
  end

  defp color_variant("bordered", "warning") do
    [
      "text-[#976A01] border-[#976A01] bg-[#FFF7E6]",
      "dark:text-[#FDD067] dark:border-[#FDD067] dark:bg-[#322300]"
    ]
  end

  defp color_variant("bordered", "danger") do
    [
      "text-[#BB032A] border-[#BB032A] bg-[#FFF0EE]",
      "dark:text-[#FFB2AB] dark:border-[#FFB2AB] dark:bg-[#520810]"
    ]
  end

  defp color_variant("bordered", "info") do
    [
      "text-[#0B84BA] border-[#0B84BA] bg-[#E7F6FD]",
      "dark:text-[#6EC9F2] dark:border-[#6EC9F2] dark:bg-[#03212F]"
    ]
  end

  defp color_variant("bordered", "misc") do
    [
      "text-[#653C94] border-[#653C94] bg-[#F6F0FE]",
      "dark:text-[#CBA2FA] dark:border-[#CBA2FA] dark:bg-[#221431]"
    ]
  end

  defp color_variant("bordered", "dawn") do
    [
      "text-[#7E4B2A] border-[#7E4B2A] bg-[#FBF2ED]",
      "dark:text-[#E4B190] dark:border-[#E4B190] dark:bg-[#2A190E]"
    ]
  end

  defp color_variant("bordered", "silver") do
    [
      "text-[#727272] border-[#727272] bg-[#F3F3F3]",
      "dark:text-[#BBBBBB] dark:border-[#BBBBBB] dark:bg-[#4B4B4B]"
    ]
  end

  defp color_variant("gradient", "natural") do
    [
      "bg-gradient-to-br from-[#282828] to-[#727272] text-white",
      "dark:from-[#A6A6A6] dark:to-[#FFFFFF] dark:text-black"
    ]
  end

  defp color_variant("gradient", "primary") do
    [
      "bg-gradient-to-br from-[#016974] to-[#01B8CA] text-white",
      "dark:from-[#01B8CA] dark:to-[#B0E7EF] dark:text-black"
    ]
  end

  defp color_variant("gradient", "secondary") do
    [
      "bg-gradient-to-br from-[#175BCC] to-[#6DAAFB] text-white",
      "dark:from-[#6DAAFB] dark:to-[#CDDEFF] dark:text-black"
    ]
  end

  defp color_variant("gradient", "success") do
    [
      "bg-gradient-to-br from-[#166C3B] to-[#06C167] text-white",
      "dark:from-[#06C167] dark:to-[#B1EAC2] dark:text-black"
    ]
  end

  defp color_variant("gradient", "warning") do
    [
      "bg-gradient-to-br from-[#976A01] to-[#FDC034] text-white",
      "dark:from-[#FDC034] dark:to-[#FEDF99] dark:text-black"
    ]
  end

  defp color_variant("gradient", "danger") do
    [
      "bg-gradient-to-br from-[#BB032A] to-[#FC7F79] text-white",
      "dark:from-[#FC7F79] dark:to-[#FFD2CD] dark:text-black"
    ]
  end

  defp color_variant("gradient", "info") do
    [
      "bg-gradient-to-br from-[#08638C] to-[#3EB7ED] text-white",
      "dark:from-[#3EB7ED] dark:to-[#9FDBF6] dark:text-black"
    ]
  end

  defp color_variant("gradient", "misc") do
    [
      "bg-gradient-to-br from-[#653C94] to-[#BA83F9] text-white",
      "dark:from-[#BA83F9] dark:to-[#DDC1FC] dark:text-black"
    ]
  end

  defp color_variant("gradient", "dawn") do
    [
      "bg-gradient-to-br from-[#7E4B2A] to-[#DB976B] text-white",
      "dark:from-[#DB976B] dark:to-[#EDCBB5] dark:text-black"
    ]
  end

  defp color_variant("gradient", "silver") do
    [
      "bg-gradient-to-br from-[#5E5E5E] to-[#A6A6A6] text-white",
      "dark:from-[#868686] dark:to-[#BBBBBB] dark:text-black"
    ]
  end

  defp color_variant(params, _) when is_binary(params), do: params
end
