defmodule UroWeb.Components.SpeedDial do
  @moduledoc """
  The `UroWeb.Components.SpeedDial` module provides a versatile speed dial component for Phoenix
  LiveView applications. This component enhances user interactions by offering a dynamic
  menu of actions that can be triggered from a single button. The speed dial is
  especially useful for applications that need to offer quick access to multiple
  actions without cluttering the UI.

  ## Features

  - **Customizable Appearance:** Supports various size, color, and style options, including
  `default`, `outline`,`shadow`, and `unbordered` variants. Users can control the
  overall size, border radius, padding, and spacing between elements to fit different design requirements.
  - **Action Configuration:** The `SpeedDial` component can hold multiple action items,
  each with individual icons, colors, and navigation paths. Items can link to different parts
  of the application, trigger patches, or direct to external URLs.
  - **Interactive Control:** The speed dial can be toggled to show or hide the list of actions.
  This makes it easy to manage the visibility of the component based on user interactions.
  - **Flexible Positioning:** Allows placement at various positions on the screen, such as
  `top-start`, `top-end`, `bottom-start`, and `bottom-end`. The position can be adjusted
  based on the container's size and requirements.
  - **Animation and Icon Support:** Includes built-in animation options for icons and button
  states, creating an engaging user experience. Icons can be added or animated when hovering
  over the speed dial button.

  This component is perfect for implementing quick action menus in applications where users need
  to perform frequent operations from a single access point.
  """

  use Phoenix.Component
  use Gettext, backend: UroWeb.Gettext
  alias Phoenix.LiveView.JS

  @doc """
  Renders a customizable `speed_dial` component that provides quick access to multiple actions.
  The speed dial can be configured with various styles, sizes, and colors.

  It supports navigation, icons, and custom content in each item.

  ## Examples

  ```elixir
  <.speed_dial icon="hero-plus" space="large" icon_animated id="test-1" size="extra_small" clickable>
    <:item icon="hero-home" href="/examples/navbar" color="danger"></:item>
    <:item icon="hero-bars-3" href="/examples/navbar" variant="shadow" color="misc">11</:item>
    <:item icon="hero-chart-bar" href="/examples/navbar" variant="unbordered" color="warning">
    </:item>
  </.speed_dial>
  ```
  """
  @doc type: :component
  attr :id, :string,
    required: true,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :action_position, :string, default: "bottom-end", doc: ""
  attr :position_size, :string, default: "large", doc: ""
  attr :wrapper_position, :string, default: "top", doc: ""
  attr :rounded, :string, default: "full", doc: "Determines the border radius"

  attr :size, :string,
    default: "medium",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :color, :string, default: "natural", doc: "Determines color theme"
  attr :variant, :string, default: "base", doc: "Determines the style"
  attr :space, :string, default: "extra_small", doc: "Space between items"
  attr :width, :string, default: "fit", doc: "Determines the element width"
  attr :border, :string, default: "extra_small", doc: "Determines border style"
  attr :padding, :string, default: "extra_small", doc: "Determines padding for items"

  attr :clickable, :boolean,
    default: false,
    doc: "Determines if the element can be activated on click"

  attr :icon, :string, default: nil, doc: "Icon displayed alongside of an item"

  attr :icon_animated, :boolean,
    default: false,
    doc: "Determines whether element's icon has animation"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :item, required: false, doc: "Specifies item slot of a speed dial" do
    attr :icon, :string, doc: "Icon displayed alongside of an item"
    attr :class, :string, doc: "Custom CSS class for additional styling"

    attr :navigate, :string,
      doc: "Defines the path for navigation within the application using a `navigate` attribute."

    attr :patch, :string, doc: "Specifies the path for navigation using a LiveView patch."
    attr :href, :string, doc: "Sets the URL for an external link."
    attr :icon_class, :string, doc: "Determines custom class for the icon"
    attr :content_class, :string, doc: "Determines custom class for the content"
    attr :color, :string, doc: "Determines color theme"
    attr :variant, :string, doc: "Determines the style"
    attr :icon_position, :string, doc: "Determines icon position"
  end

  slot :trigger_content, required: false, doc: "Determines triggered content" do
    attr :class, :string, doc: "Custom CSS class for additional styling"
  end

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def speed_dial(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "fixed group",
        "[&_.speed-dial-content]:invisible [&_.speed-dial-content]:opacity-0",
        "[&_.speed-dial-content.show-speed-dial]:visible [&_.speed-dial-content.show-speed-dial]:opacity-100",
        "[&_.speed-dial-base]:flex [&_.speed-dial-base]:items-center [&_.speed-dial-base]:justify-center",
        !@clickable && trigger_dial(),
        action_position(@position_size, @action_position),
        space_class(@space, @wrapper_position),
        position_class(@wrapper_position),
        rounded_size(@rounded),
        border_class(@border, @variant),
        padding_class(@padding),
        width_class(@width),
        size_class(@size)
      ]}
      {@rest}
    >
      <div
        class={[
          "speed-dial-content flex items-center",
          "absolute z-10 w-full transition-all ease-in-out delay-100 duratio-500",
          (@wrapper_position == "top" || @wrapper_position == "bottom") && "flex-col"
        ]}
        id={@id && "#{@id}-speed-dial-content"}
        phx-click-away={
          @id &&
            JS.remove_class("show-speed-dial",
              to: "##{@id}-speed-dial-content",
              transition: "duration-300"
            )
        }
      >
        <div
          :for={{item, index} <- Enum.with_index(@item, 1)}
          id={"#{@id}-item-#{index}"}
          class={[
            "speed-dial-item w-fit h-fit",
            item[:icon_position] == "end" && "flex-row-reverse",
            item[:class]
          ]}
        >
          <.speed_dial_content id={@id} index={index} {item}>
            {render_slot(item)}
          </.speed_dial_content>
        </div>
        {render_slot(@inner_block)}
      </div>

      <button
        type="button"
        class={["speed-dial-base", color_variant(@variant, @color)]}
        phx-click={
          @id &&
            JS.toggle_class("show-speed-dial",
              to: "##{@id}-speed-dial-content",
              transition: "duration-100"
            )
        }
      >
        <.icon
          :if={!is_nil(@icon)}
          name={@icon}
          class={[
            "speed-dial-icon-base",
            @icon_animated && "transition-transform group-hover:rotate-45"
          ]}
        />
        <span :if={is_nil(@icon)} class={@trigger_content[:class]}>{@trigger_content}</span>
        <span class="sr-only">{gettext("Open actions menu")}</span>
      </button>
    </div>
    """
  end

  @doc type: :component
  attr :id, :string,
    required: true,
    doc: "A unique identifier is used to manage state and interaction"

  attr :navigate, :string,
    default: nil,
    doc: "Defines the path for navigation within the application using a `navigate` attribute."

  attr :patch, :string,
    default: nil,
    doc: "Specifies the path for navigation using a LiveView patch."

  attr :href, :string, default: nil, doc: "Sets the URL for an external link."
  attr :color, :string, default: "primary", doc: "Determines color theme"
  attr :variant, :string, default: "default", doc: "Determines the style"
  attr :icon, :string, default: nil, doc: "Icon displayed alongside of an item"
  attr :icon_class, :string, default: nil, doc: "Determines custom class for the icon"
  attr :content_class, :string, default: nil, doc: "Determines custom class for the content"
  attr :index, :integer, required: true, doc: "Determines item index"
  attr :icon_position, :string, doc: "Determines icon position"
  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  defp speed_dial_content(%{navigate: nav, patch: pat, href: hrf} = assigns)
       when is_binary(nav) or is_binary(pat) or is_binary(hrf) do
    ~H"""
    <.link
      id={"#{@id}-speed-dial-item-#{@index}"}
      class={["block speed-dial-base flex flex-col", color_variant(@variant, @color)]}
      navigate={@navigate}
      patch={@patch}
      href={@href}
    >
      <.icon :if={@icon} name={@icon} class={["speed-dial-icon-base", @icon_class]} />
      <span :if={is_nil(@icon)} class={["block text-xs text-center", @content_class]}>
        {render_slot(@inner_block)}
      </span>
    </.link>
    """
  end

  defp speed_dial_content(assigns) do
    ~H"""
    <div
      id={"#{@id}-speed-dial-item-#{@index}"}
      class={["speed-dial-base flex flex-col", color_variant(@variant, @color)]}
    >
      <.icon :if={@icon} name={@icon} class={["speed-dial-icon-base", @icon_class]} />
      <span :if={is_nil(@icon)} class={["block text-xs text-center", @content_class]}>
        {render_slot(@inner_block)}
      </span>
    </div>
    """
  end

  defp trigger_dial(),
    do: "[&_.speed-dial-content]:hover:visible [&_.speed-dial-content]:hover:opacity-100"

  defp position_class("top") do
    [
      "[&_.speed-dial-content]:bottom-full [&_.speed-dial-content]:left-1/2",
      "[&_.speed-dial-content]:-translate-x-1/2 [&_.speed-dial-content]:-translate-y-[6px]"
    ]
  end

  defp position_class("bottom") do
    [
      "[&_.speed-dial-content]:top-full [&_.speed-dial-content]:left-1/2",
      "[&_.speed-dial-content]:-translate-x-1/2 [&_.speed-dial-content]:translate-y-[6px]"
    ]
  end

  defp position_class("left") do
    [
      "[&_.speed-dial-content]:right-full [&_.speed-dial-content]:top-1/2",
      "[&_.speed-dial-content]:-translate-y-1/2 [&_.speed-dial-content]:-translate-x-[6px]"
    ]
  end

  defp position_class("right") do
    [
      "[&_.speed-dial-content]:left-full [&_.speed-dial-content]:top-1/2",
      "[&_.speed-dial-content]:-translate-y-1/2 [&_.speed-dial-content]:translate-x-[6px]"
    ]
  end

  defp width_class("extra_small"), do: "[&_.speed-dial-content]:w-48"
  defp width_class("small"), do: "[&_.speed-dial-content]:w-52"
  defp width_class("medium"), do: "[&_.speed-dial-content]:w-56"
  defp width_class("large"), do: "[&_.speed-dial-content]:w-60"
  defp width_class("extra_large"), do: "[&_.speed-dial-content]:w-64"
  defp width_class("double_large"), do: "[&_.speed-dial-content]:w-72"
  defp width_class("triple_large"), do: "[&_.speed-dial-content]:w-80"
  defp width_class("quadruple_large"), do: "[&_.speed-dial-content]:w-96"
  defp width_class("fit"), do: "[&_.speed-dial-content]:w-fit"
  defp width_class(params) when is_binary(params), do: params

  defp space_class("extra_small", "top"), do: "[&_.speed-dial-content]:space-y-2"

  defp space_class("small", "top"), do: "[&_.speed-dial-content]:space-y-3"

  defp space_class("medium", "top"), do: "[&_.speed-dial-content]:space-y-4"

  defp space_class("large", "top"), do: "[&_.speed-dial-content]:space-y-5"

  defp space_class("extra_large", "top"), do: "[&_.speed-dial-content]:space-y-6"

  defp space_class("extra_small", "bottom"), do: "[&_.speed-dial-content]:space-y-2"

  defp space_class("small", "bottom"), do: "[&_.speed-dial-content]:space-y-3"

  defp space_class("medium", "bottom"), do: "[&_.speed-dial-content]:space-y-4"

  defp space_class("large", "bottom"), do: "[&_.speed-dial-content]:space-y-5"

  defp space_class("extra_large", "bottom"), do: "[&_.speed-dial-content]:space-y-6"

  defp space_class("extra_small", "left"), do: "[&_.speed-dial-content]:space-x-2"

  defp space_class("small", "left"), do: "[&_.speed-dial-content]:space-x-3"

  defp space_class("medium", "left"), do: "[&_.speed-dial-content]:space-x-4"

  defp space_class("large", "left"), do: "[&_.speed-dial-content]:space-x-5"

  defp space_class("extra_large", "left"), do: "[&_.speed-dial-content]:space-x-6"

  defp space_class("extra_small", "right"), do: "[&_.speed-dial-content]:space-x-2"

  defp space_class("small", "right"), do: "[&_.speed-dial-content]:space-x-3"

  defp space_class("medium", "right"), do: "[&_.speed-dial-content]:space-x-4"

  defp space_class("large", "right"), do: "[&_.speed-dial-content]:space-x-5"

  defp space_class("extra_large", "right"), do: "[&_.speed-dial-content]:space-x-6"

  defp space_class(params, _) when is_binary(params), do: params

  defp padding_class("none"), do: "[&_.speed-dial-content]:p-0"

  defp padding_class("extra_small"), do: "[&_.speed-dial-content]:p-1"

  defp padding_class("small"), do: "[&_.speed-dial-content]:p-1.5"

  defp padding_class("medium"), do: "[&_.speed-dial-content]:p-2"

  defp padding_class("large"), do: "[&_.speed-dial-content]:p-2.5"

  defp padding_class("extra_large"), do: "[&_.speed-dial-content]:p-3"

  defp padding_class(params) when is_binary(params), do: params

  defp rounded_size("none"), do: nil

  defp rounded_size("extra_small"), do: "[&_.speed-dial-base]:rounded-sm"

  defp rounded_size("small"), do: "[&_.speed-dial-base]:rounded"

  defp rounded_size("medium"), do: "[&_.speed-dial-base]:rounded-md"

  defp rounded_size("large"), do: "[&_.speed-dial-base]:rounded-lg"

  defp rounded_size("extra_large"), do: "[&_.speed-dial-base]:rounded-xl"

  defp rounded_size("full"), do: "[&_.speed-dial-base]:rounded-full"

  defp rounded_size(params) when is_binary(params), do: params

  defp size_class("extra_small") do
    [
      "[&_.speed-dial-content]:max-w-60 [&_.speed-dial-icon-base]:size-2.5 [&_.speed-dial-base]:size-7"
    ]
  end

  defp size_class("small") do
    [
      "[&_.speed-dial-content]:max-w-64 [&_.speed-dial-icon-base]:size-3 [&_.speed-dial-base]:size-8"
    ]
  end

  defp size_class("medium") do
    [
      "[&_.speed-dial-content]:max-w-72 [&_.speed-dial-icon-base]:size-3.5 [&_.speed-dial-base]:size-9"
    ]
  end

  defp size_class("large") do
    [
      "[&_.speed-dial-content]:max-w-80 [&_.speed-dial-icon-base]:size-4 [&_.speed-dial-base]:size-10"
    ]
  end

  defp size_class("extra_large") do
    [
      "[&_.speed-dial-content]:max-w-96 [&_.speed-dial-icon-base]:size-5 [&_.speed-dial-base]:size-11"
    ]
  end

  defp size_class("double_large") do
    [
      "[&_.speed-dial-content]:max-w-96 [&_.speed-dial-icon-base]:size-6 [&_.speed-dial-base]:size-12"
    ]
  end

  defp size_class("triple_large") do
    [
      "[&_.speed-dial-content]:max-w-96 [&_.speed-dial-icon-base]:size-7 [&_.speed-dial-base]:size-14"
    ]
  end

  defp size_class("quadruple_large") do
    [
      "[&_.speed-dial-content]:max-w-96 [&_.speed-dial-icon-base]:size-8 [&_.speed-dial-base]:size-16"
    ]
  end

  defp size_class(params) when is_binary(params), do: params

  defp border_class(_, variant) when variant in ["default", "shadow", "gradient"],
    do: nil

  defp border_class("none", _), do: "[&_.speed-dial-base]:border-0"
  defp border_class("extra_small", _), do: "[&_.speed-dial-base]:border"
  defp border_class("small", _), do: "[&_.speed-dial-base]:border-2"
  defp border_class("medium", _), do: "[&_.speed-dial-base]:border-[3px]"
  defp border_class("large", _), do: "[&_.speed-dial-base]:border-4"
  defp border_class("extra_large", _), do: "[&_.speed-dial-base]:border-[5px]"
  defp border_class(params, _) when is_binary(params), do: params

  defp action_position("none", "top-start"), do: "top-0 start-0"
  defp action_position("extra_small", "top-start"), do: "top-1 start-4"
  defp action_position("small", "top-start"), do: "top-2 start-5"
  defp action_position("medium", "top-start"), do: "top-3 start-6"
  defp action_position("large", "top-start"), do: "top-4 start-7"
  defp action_position("extra_large", "top-start"), do: "top-8 start-8"

  defp action_position("none", "top-end"), do: "top-0 end-0"
  defp action_position("extra_small", "top-end"), do: "top-4 end-4"
  defp action_position("small", "top-end"), do: "top-5 end-5"
  defp action_position("medium", "top-end"), do: "top-6 end-6"
  defp action_position("large", "top-end"), do: "top-7 end-7"
  defp action_position("extra_large", "top-end"), do: "top-8 end-8"

  defp action_position("none", "[&_.speed-dial-content]:start"), do: "bottom-0 start-0"
  defp action_position("extra_small", "bottom-start"), do: "bottom-4 start-4"
  defp action_position("small", "bottom-start"), do: "bottom-5 start-5"
  defp action_position("medium", "bottom-start"), do: "bottom-6 start-6"
  defp action_position("large", "bottom-start"), do: "bottom-8 start-8"
  defp action_position("extra_large", "bottom-start"), do: "bottom-9 start-9"

  defp action_position("none", "bottom-end"), do: "bottom-0 end-0"
  defp action_position("extra_small", "bottom-end"), do: "bottom-4 end-4"
  defp action_position("small", "bottom-end"), do: "bottom-5 end-5"
  defp action_position("medium", "bottom-end"), do: "bottom-6 end-6"
  defp action_position("large", "bottom-end"), do: "bottom-8 end-8"
  defp action_position("extra_large", "bottom-end"), do: "bottom-9 end-9"
  defp action_position(params, _) when is_binary(params), do: params

  defp color_variant("base", _) do
    [
      "bg-white text-[#09090b] border-[#e4e4e7] shadow-sm",
      "dark:bg-[#18181B] dark:text-[#FAFAFA] dark:border-[#27272a]"
    ]
  end

  defp color_variant("default", "white") do
    ["bg-white text-black"]
  end

  defp color_variant("default", "dark") do
    ["bg-[#282828] text-white"]
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

  attr :name, :string, required: true, doc: "Specifies the name of the element"
  attr :class, :any, default: nil, doc: "Custom CSS class for additional styling"

  defp icon(%{name: "hero-" <> _, class: class} = assigns) when is_list(class) do
    ~H"""
    <span class={[@name] ++ @class} />
    """
  end

  defp icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end
end
