defmodule UroWeb.Components.Divider do
  @moduledoc """
  The `UroWeb.Components.Divider` module provides a versatile and customizable divider
  component for creating horizontal and vertical dividers with various styling options
  in a Phoenix LiveView application.

  ## Features:
  - Supports different divider types: `solid`, `dashed`, and `dotted`.
  - Flexible color themes with predefined options such as `primary`, `secondary`,
  `success`, `danger`, and more.
  - Allows for horizontal and vertical orientation.
  - Customizable size, width, height, and margin for precise control over the appearance.
  - Includes slots for adding text or icons with individual styling and positioning options.
  - Global attributes and custom CSS classes can be applied for additional customization.
  """
  use Phoenix.Component

  @doc """
  The `divider` component is used to visually separate content with either a horizontal or
  vertical line. It supports different line styles (like dashed, dotted, or solid) and can
  be customized with various attributes like `size`, `width`, `height`, and `color`.

  ### Examples

  ```elixir
  <.divider type="dashed" size="small" color="primary">
    <:text position="right">Or</:text>
  </.divider>

  <.divider type="dotted" size="extra_large">
    <:icon name="hero-circle-stack" class="p-10 bg-white text-yellow-600" />
  </.divider>
  ```

  This component is ideal for creating visual separations in your layout, whether it’s for breaking
  up text, sections, or other elements in your design.
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :type, :string,
    values: ["dashed", "dotted", "solid"],
    default: "solid",
    doc: "Determines type of element"

  attr :color, :string, default: "base", doc: "Determines color theme"

  attr :size, :string,
    default: "extra_small",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :width, :string, default: "full", doc: "Determines the element width"
  attr :height, :string, default: "auto", doc: "Determines the element width"
  attr :margin, :string, default: "none", doc: "Determines the element margin"

  attr :variation, :string,
    values: ["horizontal", "vertical"],
    default: "horizontal",
    doc: "Defines the layout orientation of the component"

  slot :text, required: false do
    attr :class, :string, doc: "Custom CSS class for additional styling"
    attr :color, :string, doc: "Determines color theme"

    attr :size, :string,
      doc:
        "Determines the overall size of the elements, including padding, font size, and other items"

    attr :position, :string, doc: "Determines the element position"
  end

  slot :icon, required: false do
    attr :name, :string, required: true, doc: "Specifies the name of the element"
    attr :class, :string, doc: "Custom CSS class for additional styling"
    attr :icon_class, :string, doc: "Determines custom class for the icon"
    attr :color, :string, doc: "Determines color theme"

    attr :size, :string,
      doc:
        "Determines the overall size of the elements, including padding, font size, and other items"

    attr :position, :string, doc: "Determines the element position"
  end

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  def divider(%{variation: "vertical"} = assigns) do
    ~H"""
    <div
      id={@id}
      class={
        [
          color_class(@color),
          border_type_class(@type),
          height_class(@height),
          @class
        ] ++ size_class(@size, :vertical) ++ margin_class(@margin, :vertical)
      }
      {@rest}
    >
      <div
        :for={text <- @text}
        class={[
          "divider-content whitespace-nowrap",
          text[:color],
          text[:class] || "bg-transparent",
          text_position(:divider, text[:position]),
          text[:size]
        ]}
      >
        {render_slot(text)}
      </div>
    </div>
    """
  end

  def divider(assigns) do
    ~H"""
    <div
      id={@id}
      class={
        [
          "mx-auto",
          "has-[.divider-content]:flex has-[.divider-content]:items-center has-[.divider-content]:gap-2",
          "has-[.divider-content.devider-middle]:before:content-['']",
          "has-[.divider-content.devider-middle]:before:block has-[.divider-content.devider-middle]:before:w-full",
          "has-[.divider-content.devider-middle]:after:content-['']",
          "has-[.divider-content.devider-middle]:after:block",
          "has-[.divider-content.devider-middle]:after:w-full",
          "has-[.divider-content.devider-right]:before:content-['']",
          "has-[.divider-content.devider-right]:before:block",
          "has-[.divider-content.devider-right]:before:w-full",
          "has-[.divider-content.devider-left]:after:content-['']",
          "has-[.divider-content.devider-left]:after:block has-[.divider-content.devider-left]:after:w-full",
          color_class(@color),
          border_type_class(@type),
          width_class(@width),
          @class
        ] ++ size_class(@size, :horizontal) ++ margin_class(@margin, :horizontal)
      }
      {@rest}
    >
      <div
        :for={icon <- @icon}
        class={[
          "divider-content whitespace-nowrap",
          icon[:size],
          icon[:color],
          icon[:class] || "bg-transparent",
          text_position(:divider, icon[:position])
        ]}
      >
        <.icon name={icon[:name]} class={icon[:icon_class] || size_class(@size, :icon)} />
      </div>
      
      <div
        :for={text <- @text}
        class={[
          "divider-content whitespace-nowrap",
          text[:color],
          text[:class] || "bg-transparent",
          text_position(:divider, text[:position]),
          text[:size]
        ]}
      >
        {render_slot(text)}
      </div>
    </div>
    """
  end

  @doc """
  `UroWeb.Components.Divider.hr` is used to create a horizontal divider with customizable style, color,
  and size options.

  It can also include text or icons to enhance visual separation between content sections.

  ## Examples

  ```elixir
  <.hr type="dashed" color="primary" />
  <.hr type="dotted" size="large" />
  <.hr><:text>Or</:text></.hr>
  <.hr color="dawn"><:icon name="hero-circle-stack" /></.hr>
  <.hr type="dashed" size="small"><:text>Or</:text></.hr>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :type, :string,
    values: ["dashed", "dotted", "solid"],
    default: "solid",
    doc: "Specifies the type of the element"

  attr :color, :string, default: "base", doc: "Determines color theme"

  attr :size, :string,
    default: "extra_small",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :width, :string, default: "full", doc: "Determines the element width"
  attr :margin, :string, default: "none", doc: "Determines the element margin"

  slot :text, required: false do
    attr :class, :string, doc: "Custom CSS class for additional styling"
    attr :color, :string, doc: "Determines color theme"

    attr :size, :string,
      doc:
        "Determines the overall size of the elements, including padding, font size, and other items"

    attr :position, :string, doc: "Determines the element position"
  end

  slot :icon, required: false do
    attr :name, :string, required: true, doc: "Specifies the name of the element"
    attr :class, :string, doc: "Custom CSS class for additional styling"
    attr :icon_class, :string, doc: "Determines custom class for the icon"
    attr :color, :string, doc: "Determines color theme"

    attr :size, :string,
      doc:
        "Determines the overall size of the elements, including padding, font size, and other items"
  end

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  def hr(assigns) do
    ~H"""
    <div class="relative">
      <hr
        id={@id}
        class={
          [
            "mx-auto",
            color_class(@color),
            border_type_class(@type),
            width_class(@width),
            @class
          ] ++ size_class(@size, :horizontal) ++ margin_class(@margin, :horizontal)
        }
        {@rest}
      /> 
      <div
        :for={icon <- @icon}
        class={[
          "flex item-center justify-center absolute p-2",
          "-translate-x-1/2 whitespace-nowrap",
          icon[:size] || size_class(@size, :icon),
          icon[:color] || color_class(@color),
          text_position(:hr, icon[:position]),
          icon[:class] || "bg-white"
        ]}
      >
        <.icon name={icon[:name]} class={icon[:icon_class] || ""} />
      </div>
      
      <div
        :for={text <- @text}
        class={[
          "flex item-center justify-center absolute p-2",
          "-translate-x-1/2 whitespace-nowrap",
          text[:color] || color_class(@color),
          text[:class] || "bg-white",
          text_position(:hr, text[:position]),
          text[:size]
        ]}
      >
        {render_slot(text)}
      </div>
    </div>
    """
  end

  defp size_class("extra_small", :horizontal) do
    [
      "[&:not(:has(.divider-content))]:border-t has-[.divider-content.devider-middle]:before:border-t",
      "has-[.divider-content.devider-middle]:after:border-t has-[.divider-content.devider-right]:before:border-t",
      "has-[.divider-content.devider-left]:after:border-t text-xs my-2"
    ]
  end

  defp size_class("small", :horizontal) do
    [
      "[&:not(:has(.divider-content))]:border-t-2 has-[.divider-content.devider-middle]:before:border-t-2",
      "has-[.divider-content.devider-middle]:after:border-t-2",
      "has-[.divider-content.devider-right]:before:border-t-2",
      "has-[.divider-content.devider-left]:after:border-t-2 text-sm my-3"
    ]
  end

  defp size_class("medium", :horizontal) do
    [
      "[&:not(:has(.divider-content))]:border-t-[3px] has-[.divider-content.devider-middle]:before:border-t-[3px]",
      "has-[.divider-content.devider-middle]:after:border-t-[3px]",
      "has-[.divider-content.devider-right]:before:border-t-[3px]",
      "has-[.divider-content.devider-left]:after:border-t-[3px] text-base my-4"
    ]
  end

  defp size_class("large", :horizontal) do
    [
      "[&:not(:has(.divider-content))]:border-t-4 has-[.divider-content.devider-middle]:before:border-t-4",
      "has-[.divider-content.devider-middle]:after:border-t-4",
      "has-[.divider-content.devider-right]:before:border-t-4",
      "has-[.divider-content.devider-left]:after:border-t-4 text-lg my-5"
    ]
  end

  defp size_class("extra_large", :horizontal) do
    [
      "[&:not(:has(.divider-content))]:border-t-[5px] has-[.divider-content.devider-middle]:before:border-t-[5px]",
      "has-[.divider-content.devider-middle]:after:border-t-[5px]",
      "has-[.divider-content.devider-right]:before:border-t-[5px]",
      "has-[.divider-content.devider-left]:after:border-t-[5px] text-xl my-6"
    ]
  end

  defp size_class("extra_small", :vertical) do
    [
      "[&:not(:has(.divider-content))]:border-l"
    ]
  end

  defp size_class("small", :vertical) do
    [
      "[&:not(:has(.divider-content))]:border-l-2 text-sm"
    ]
  end

  defp size_class("medium", :vertical) do
    [
      "[&:not(:has(.divider-content))]:border-l-[3px] text-base"
    ]
  end

  defp size_class("large", :vertical) do
    [
      "[&:not(:has(.divider-content))]:border-l-4 text-lg"
    ]
  end

  defp size_class("extra_large", :vertical) do
    [
      "[&:not(:has(.divider-content))]:border-l-[5px] text-xl"
    ]
  end

  defp size_class("extra_small", :icon), do: "[&>*]:size-5"

  defp size_class("small", :icon), do: "[&>*]:size-6"

  defp size_class("medium", :icon), do: "[&>*]:size-7"

  defp size_class("large", :icon), do: "[&>*]:size-8"

  defp size_class("extra_large", :icon), do: "[&>*]:size-9"

  defp size_class(params, _) when is_binary(params), do: params

  defp width_class("full"), do: "w-full"

  defp width_class("half"), do: "w-1/2"

  defp width_class(params) when is_binary(params), do: params

  defp height_class("full"), do: "h-screen"

  defp height_class("auto"), do: "h-auto"

  defp height_class("half"), do: "h-1/2"

  defp height_class(params) when is_binary(params), do: params

  defp margin_class("extra_small", :horizontal) do
    ["my-2"]
  end

  defp margin_class("small", :horizontal) do
    ["my-3"]
  end

  defp margin_class("medium", :horizontal) do
    ["my-4"]
  end

  defp margin_class("large", :horizontal) do
    ["my-5"]
  end

  defp margin_class("extra_large", :horizontal) do
    ["my-6"]
  end

  defp margin_class("none", :horizontal) do
    ["my-0"]
  end

  defp margin_class("extra_small", :vertical) do
    ["mx-2"]
  end

  defp margin_class("small", :vertical) do
    ["mx-3"]
  end

  defp margin_class("medium", :vertical) do
    ["mx-4"]
  end

  defp margin_class("large", :vertical) do
    ["mx-5"]
  end

  defp margin_class("extra_large", :vertical) do
    ["mx-6"]
  end

  defp margin_class("none", :vertical) do
    ["mx-0"]
  end

  defp margin_class(params, _) when is_binary(params), do: params

  defp color_class("base") do
    [
      "text-[#09090b] border-[#e4e4e7] dark:text-[#27272a] dark:border-[#27272a]",
      "has-[.divider-content.devider-middle]:before:border-[#e4e4e7] has-[.divider-content.devider-middle]:after:border-[#e4e4e7]",
      "has-[.divider-content.devider-right]:before:border-[#e4e4e7] has-[.divider-content.devider-left]:after:border-[#e4e4e7]",
      "dark:has-[.divider-content.devider-middle]:before:border-[#27272a] dark:has-[.divider-content.devider-middle]:after:border-[#27272a]",
      "dark:has-[.divider-content.devider-right]:before:border-[#27272a] dark:has-[.divider-content.devider-left]:after:border-[#27272a]"
    ]
  end

  defp color_class("white") do
    [
      "text-white border-white",
      "has-[.divider-content.devider-middle]:before:border-white has-[.divider-content.devider-middle]:after:border-white",
      "has-[.divider-content.devider-right]:before:border-white has-[.divider-content.devider-left]:after:border-white"
    ]
  end

  defp color_class("dark") do
    [
      "text-[#282828] border-[#282828]",
      "has-[.divider-content.devider-middle]:before:border-[#282828] has-[.divider-content.devider-middle]:after:border-[#282828]",
      "has-[.divider-content.devider-right]:before:border-[#282828] has-[.divider-content.devider-left]:after:border-[#282828]"
    ]
  end

  defp color_class("natural") do
    [
      "text-[#4B4B4B] border-[#4B4B4B] dark:text-[#DDDDDD] dark:border-[#DDDDDD]",
      "has-[.divider-content.devider-middle]:before:border-[#4B4B4B] has-[.divider-content.devider-middle]:after:border-[#4B4B4B]",
      "has-[.divider-content.devider-right]:before:border-[#4B4B4B] has-[.divider-content.devider-left]:after:border-[#4B4B4B]",
      "dark:has-[.divider-content.devider-middle]:before:border-[#DDDDDD] dark:has-[.divider-content.devider-middle]:after:border-[#DDDDDD]",
      "dark:has-[.divider-content.devider-right]:before:border-[#DDDDDD] dark:has-[.divider-content.devider-left]:after:border-[#DDDDDD]"
    ]
  end

  defp color_class("primary") do
    [
      "text-[#007F8C] border-[#007F8C] dark:text-[#01B8CA] dark:border-[#01B8CA]",
      "has-[.divider-content.devider-middle]:before:border-[#007F8C] has-[.divider-content.devider-middle]:after:border-[#007F8C]",
      "has-[.divider-content.devider-right]:before:border-[#007F8C] has-[.divider-content.devider-left]:after:border-[#007F8C]",
      "dark:has-[.divider-content.devider-middle]:before:border-[#01B8CA] dark:has-[.divider-content.devider-middle]:after:border-[#01B8CA]",
      "dark:has-[.divider-content.devider-right]:before:border-[#01B8CA] dark:has-[.divider-content.devider-left]:after:border-[#01B8CA]"
    ]
  end

  defp color_class("secondary") do
    [
      "text-[#266EF1] border-[#266EF1] dark:text-[#6DAAFB] dark:border-[#6DAAFB]",
      "has-[.divider-content.devider-middle]:before:border-[#266EF1] has-[.divider-content.devider-middle]:after:border-[#266EF1]",
      "has-[.divider-content.devider-right]:before:border-[#266EF1] has-[.divider-content.devider-left]:after:border-[#266EF1]",
      "dark:has-[.divider-content.devider-middle]:before:border-[#6DAAFB] dark:has-[.divider-content.devider-middle]:after:border-[#6DAAFB]",
      "dark:has-[.divider-content.devider-right]:before:border-[#6DAAFB] dark:has-[.divider-content.devider-left]:after:border-[#6DAAFB]"
    ]
  end

  defp color_class("success") do
    [
      "text-[#0E8345] border-[#0E8345] dark:text-[#06C167] dark:border-[#06C167]",
      "has-[.divider-content.devider-middle]:before:border-[#0E8345] has-[.divider-content.devider-middle]:after:border-[#0E8345]",
      "has-[.divider-content.devider-right]:before:border-[#0E8345] has-[.divider-content.devider-left]:after:border-[#0E8345]",
      "dark:has-[.divider-content.devider-middle]:before:border-[#06C167] dark:has-[.divider-content.devider-middle]:after:border-[#06C167]",
      "dark:has-[.divider-content.devider-right]:before:border-[#06C167] dark:has-[.divider-content.devider-left]:after:border-[#06C167]"
    ]
  end

  defp color_class("warning") do
    [
      "text-[#CA8D01] border-[#CA8D01] dark:text-[#FDC034] dark:border-[#FDC034]",
      "has-[.divider-content.devider-middle]:before:border-[#CA8D01] has-[.divider-content.devider-middle]:after:border-[#CA8D01]",
      "has-[.divider-content.devider-right]:before:border-[#CA8D01] has-[.divider-content.devider-left]:after:border-[#CA8D01]",
      "dark:has-[.divider-content.devider-middle]:before:border-[#FDC034] dark:has-[.divider-content.devider-middle]:after:border-[#FDC034]",
      "dark:has-[.divider-content.devider-right]:before:border-[#FDC034] dark:has-[.divider-content.devider-left]:after:border-[#FDC034]"
    ]
  end

  defp color_class("danger") do
    [
      "text-[#DE1135] border-[#DE1135] dark:text-[#FC7F79] dark:border-[#FC7F79]",
      "has-[.divider-content.devider-middle]:before:border-[#DE1135] has-[.divider-content.devider-middle]:after:border-[#DE1135]",
      "has-[.divider-content.devider-right]:before:border-[#DE1135] has-[.divider-content.devider-left]:after:border-[#DE1135]",
      "dark:has-[.divider-content.devider-middle]:before:border-[#FC7F79] dark:has-[.divider-content.devider-middle]:after:border-[#FC7F79]",
      "dark:has-[.divider-content.devider-right]:before:border-[#FC7F79] dark:has-[.divider-content.devider-left]:after:border-[#FC7F79]"
    ]
  end

  defp color_class("info") do
    [
      "text-[#0B84BA] border-[#0B84BA] dark:text-[#3EB7ED] dark:border-[#3EB7ED]",
      "has-[.divider-content.devider-middle]:before:border-[#0B84BA] has-[.divider-content.devider-middle]:after:border-[#0B84BA]",
      "has-[.divider-content.devider-right]:before:border-[#0B84BA] has-[.divider-content.devider-left]:after:border-[#0B84BA]",
      "dark:has-[.divider-content.devider-middle]:before:border-[#3EB7ED] dark:has-[.divider-content.devider-middle]:after:border-[#3EB7ED]",
      "dark:has-[.divider-content.devider-right]:before:border-[#3EB7ED] dark:has-[.divider-content.devider-left]:after:border-[#3EB7ED]"
    ]
  end

  defp color_class("misc") do
    [
      "text-[#8750C5] border-[#8750C5] dark:text-[#BA83F9] dark:border-[#BA83F9]",
      "has-[.divider-content.devider-middle]:before:border-[#8750C5] has-[.divider-content.devider-middle]:after:border-[#8750C5]",
      "has-[.divider-content.devider-right]:before:border-[#8750C5] has-[.divider-content.devider-left]:after:border-[#8750C5]",
      "dark:has-[.divider-content.devider-middle]:before:border-[#BA83F9] dark:has-[.divider-content.devider-middle]:after:border-[#BA83F9]",
      "dark:has-[.divider-content.devider-right]:before:border-[#BA83F9] dark:has-[.divider-content.devider-left]:after:border-[#BA83F9]"
    ]
  end

  defp color_class("dawn") do
    [
      "text-[#A86438] border-[#A86438] dark:text-[#DB976B] dark:border-[#DB976B]",
      "has-[.divider-content.devider-middle]:before:border-[#A86438] has-[.divider-content.devider-middle]:after:border-[#A86438]",
      "has-[.divider-content.devider-right]:before:border-[#A86438] has-[.divider-content.devider-left]:after:border-[#A86438]",
      "dark:has-[.divider-content.devider-middle]:before:border-[#DB976B] dark:has-[.divider-content.devider-middle]:after:border-[#DB976B]",
      "dark:has-[.divider-content.devider-right]:before:border-[#DB976B] dark:has-[.divider-content.devider-left]:after:border-[#DB976B]"
    ]
  end

  defp color_class("silver") do
    [
      "text-[#868686] border-[#868686] dark:text-[#A6A6A6] dark:border-[#A6A6A6]",
      "has-[.divider-content.devider-middle]:before:border-[#868686] has-[.divider-content.devider-middle]:after:border-[#868686]",
      "has-[.divider-content.devider-right]:before:border-[#868686] has-[.divider-content.devider-left]:after:border-[#868686]",
      "dark:has-[.divider-content.devider-middle]:before:border-[#A6A6A6] dark:has-[.divider-content.devider-middle]:after:border-[#A6A6A6]",
      "dark:has-[.divider-content.devider-right]:before:border-[#A6A6A6] dark:has-[.divider-content.devider-left]:after:border-[#A6A6A6]"
    ]
  end

  defp border_type_class("dashed") do
    "border-dashed has-[.divider-content.devider-middle]:before:border-dashed has-[.divider-content.devider-middle]:after:border-dashed has-[.divider-content.devider-right]:before:border-dashed has-[.divider-content.devider-left]:after:border-dashed"
  end

  defp border_type_class("dotted") do
    "border-dotted has-[.divider-content.devider-middle]:before:border-dotted has-[.divider-content.devider-middle]:after:border-dotted has-[.divider-content.devider-right]:before:border-dotted has-[.divider-content.devider-left]:after:border-dotted"
  end

  defp border_type_class("solid") do
    "border-solid has-[.divider-content.devider-middle]:before:border-solid has-[.divider-content.devider-middle]:after:border-solid has-[.divider-content.devider-right]:before:border-solid has-[.divider-content.devider-left]:after:border-solid"
  end

  defp text_position(:hr, "right") do
    "-top-1/2 -translate-y-1/2 -right-5"
  end

  defp text_position(:hr, "left") do
    "-top-1/2 -translate-y-1/2 left-0"
  end

  defp text_position(:hr, "middle") do
    "-top-1/2 -translate-y-1/2 left-1/2"
  end

  defp text_position(:hr, _), do: text_position(:hr, "middle")

  defp text_position(:divider, "right") do
    "devider-right"
  end

  defp text_position(:divider, "left") do
    "devider-left"
  end

  defp text_position(:divider, "middle") do
    "devider-middle"
  end

  defp text_position(:divider, _), do: text_position(:divider, "middle")

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
