defmodule UroWeb.Components.TableContent do
  @moduledoc """
  `UroWeb.Components.TableContent` is a component module designed to create flexible and dynamic
  content within a table. This module allows for a variety of customizations, including styles,
  colors, borders, padding, and animations. It is composed of several subcomponents such as
  `table_content/1`, `content_wrapper/1`, and `content_item/1`, each providing specific
  roles for content display and interaction.

  The `table_content/1` function creates a container with customizable styles and an optional title.
  `content_wrapper/1` and `content_item/1` allow further structuring of content, including icons,
  font weights, and active states, making it easy to build interactive and visually appealing
  layouts within tables. The module leverages slots to enable dynamic content rendering,
  offering high flexibility in the design of complex table layouts.
  """

  use Phoenix.Component
  alias Phoenix.LiveView.JS

  @doc """
  The `table_content` component is used to display organized content with customizable styling
  options such as color, padding, and animation.

  It supports nested content items and wrappers for better content management and display.

  ## Examples

  ```elixir
  <.table_content color="primary" animated>
    <.content_item icon="hero-hashtag">
      <.link href="#prag">Content 1</.link>
    </.content_item>

    <.content_item icon="hero-hashtag">
      <.link href="#home">Content 2</.link>
    </.content_item>

    <.content_item title="Wrapper Content">
      <.content_wrapper>
        <.content_item icon="hero-hashtag">
          <.link href="#home">Content 1</.link>
        </.content_item>

        <.content_item icon="hero-hashtag">
          <.link href="#home">Content 2</.link>
        </.content_item>

        <.content_item icon="hero-hashtag" active>
          <.link href="#home">Content 3</.link>
        </.content_item>
      </.content_wrapper>
    </.content_item>
  </.table_content>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :title, :string, default: nil, doc: "Specifies the title of the element"
  attr :color, :string, default: "natural", doc: "Determines color theme"
  attr :variant, :string, default: "base", doc: "Determines the style"
  attr :space, :string, default: "", doc: "Space between items"
  attr :animated, :boolean, default: false, doc: "Determines whether element's icon has animation"
  attr :padding, :string, default: "", doc: "Determines padding for items"
  attr :rounded, :string, default: "", doc: "Determines the border radius"
  attr :border, :string, default: "extra_small", doc: "Determines border style"

  attr :size, :string,
    default: "small",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  slot :item, required: false do
    attr :class, :string, doc: "Custom CSS class for additional styling"
    attr :title, :string, doc: "Specifies the title of the element"
    attr :icon, :string, doc: "Icon displayed alongside of an item"
    attr :icon_class, :string, doc: "Determines custom class for the icon"
    attr :font_weight, :string, doc: "Determines custom class for the font weight"
    attr :link_title, :string, doc: "Determines link"
    attr :link, :string, doc: "Determines link path"
    attr :active, :boolean, doc: "Indicates whether the element is currently active and visible"
  end

  def table_content(assigns) do
    ~H"""
    <div
      id={@id}
      phx-mounted={@animated && JS.add_class("scroll-smooth", to: "html")}
      class={[
        color_variant(@variant, @color),
        padding_size(@padding),
        rounded_size(@rounded),
        border_class(@border, @variant),
        space_size(@space),
        size_class(@size)
      ]}
      {@rest}
    >
      <h5 class="font-semibold text-sm leading-6">{@title}</h5>

      <div
        :for={item <- @item}
        class={[
          "content-item",
          item[:active] && "font-bold",
          item[:font_weight],
          item[:class]
        ]}
      >
        <div :if={!is_nil(item[:title])}>{item[:title]}</div>
        <div class="flex items-center transition-all hover:font-bold hover:opacity-90">
          <.icon
            :if={!is_nil(item[:icon])}
            name={item[:icon]}
            class={["content-icon me-2 inline-block", item[:icon_class]]}
          />
          <.link :if={item[:link_title] && item[:link]} patch={item[:link]}>{item[:link_title]}</.link>
          <div>
            {render_slot(item)}
          </div>
        </div>
      </div>

      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  The `content_wrapper` component is used to wrap multiple content items, allowing for grouped
  and structured presentation of content. It provides options for custom styling and font
  weight, making it versatile for various use cases.

  ## Examples

  ```elixir
  <.content_wrapper>
    <.content_item icon="hero-hashtag">
      <.link href="#home">Content 1</.link>
    </.content_item>

    <.content_item icon="hero-hashtag">
      <.link href="#home">Content 2</.link>
    </.content_item>

    <.content_item icon="hero-hashtag" active>
      <.link href="#home">Content 3</.link>
    </.content_item>
  </.content_wrapper>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :title, :string, default: nil, doc: "Specifies the title of the element"
  attr :icon, :string, default: nil, doc: "Icon displayed alongside of an item"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def content_wrapper(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "content-wrapper",
        @font_weight,
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  The `content_item` component is used to represent a single content item with an optional
  icon and custom styling.

  It allows for active state management and supports various configurations such as font
  weight and additional CSS classes.

  ## Examples

  ```elixir
  <.content_item icon="hero-hashtag">
    <.link href="#prag">Content 1</.link>
  </.content_item>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :title, :string, default: nil, doc: "Specifies the title of the element"
  attr :icon, :string, default: nil, doc: "Icon displayed alongside of an item"
  attr :icon_class, :string, default: nil, doc: "Determines custom class for the icon"
  attr :link_title, :string, default: nil, doc: "Determines link name"
  attr :link, :string, default: nil, doc: "Determines path of link"

  attr :font_weight, :string,
    default: "font-noraml",
    doc: "Determines custom class for the font weight"

  attr :active, :boolean,
    default: false,
    doc: "Indicates whether the element is currently active and visible"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def content_item(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "content-item",
        @active && "font-bold",
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <div :if={!is_nil(@title)}>{@title}</div>
      <div class="flex items-center transition-all hover:font-bold hover:opacity-90">
        <.icon
          :if={!is_nil(@icon)}
          name={@icon}
          class={["content-icon me-2 inline-block", @icon_class]}
        />
        <.link :if={@link_title && @link} patch={@link}>{@link_title}</.link>
        <div>
          {render_slot(@inner_block)}
        </div>
      </div>
    </div>
    """
  end

  defp size_class("extra_small") do
    [
      "text-xs [&_.content-item]:py-1 [&_.content-item]:px-1.5 [&_.content-icon]:size-2.5"
    ]
  end

  defp size_class("small") do
    [
      "text-sm [&_.content-item]:py-1.5 [&_.content-item]:px-2 [&_.content-icon]:size-3"
    ]
  end

  defp size_class("medium") do
    [
      "text-base [&_.content-item]:py-2 [&_.content-item]:px-2.5 [&_.content-icon]:size-3.5"
    ]
  end

  defp size_class("large") do
    [
      "text-lg [&_.content-item]:py-2.5 [&_.content-item]:px-3 [&_.content-icon]:size-4"
    ]
  end

  defp size_class("extra_large") do
    [
      "text-xl [&_.content-item]:py-3 [&_.content-item]:px-3.5 [&_.content-icon]:size-5"
    ]
  end

  defp size_class(params) when is_binary(params), do: params

  defp space_size("extra_small"), do: "space-y-1"

  defp space_size("small"), do: "space-y-2"

  defp space_size("medium"), do: "space-y-3"

  defp space_size("large"), do: "space-y-4"

  defp space_size("extra_large"), do: "space-y-5"

  defp space_size(params) when is_binary(params), do: params

  defp border_class(_, variant)
       when variant in ["default", "shadow", "transparent", "gradient"],
       do: nil

  defp border_class("none", _), do: "border-0"
  defp border_class("extra_small", _), do: "border"
  defp border_class("small", _), do: "border-2"
  defp border_class("medium", _), do: "border-[3px]"
  defp border_class("large", _), do: "border-4"
  defp border_class("extra_large", _), do: "border-[5px]"
  defp border_class(params, _) when is_binary(params), do: params

  defp padding_size("extra_small"), do: "p-5"

  defp padding_size("small"), do: "p-6"

  defp padding_size("medium"), do: "p-7"

  defp padding_size("large"), do: "p-8"

  defp padding_size("extra_large"), do: "p-9"

  defp padding_size("double_large"), do: "p-10"

  defp padding_size("triple_large"), do: "p-12"

  defp padding_size("quadruple_large"), do: "p-16"

  defp padding_size(params) when is_binary(params), do: params

  defp rounded_size("extra_small"), do: "rounded-sm"

  defp rounded_size("small"), do: "rounded"

  defp rounded_size("medium"), do: "rounded-md"

  defp rounded_size("large"), do: "rounded-lg"

  defp rounded_size("extra_large"), do: "rounded-xl"

  defp rounded_size(params) when is_binary(params), do: params

  defp color_variant("base", _) do
    [
      "bg-white text-[#09090b] border-[#e4e4e7]",
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
      "bg-[#4B4B4B] text-white",
      "dark:bg-[#DDDDDD] dark:text-black"
    ]
  end

  defp color_variant("default", "primary") do
    [
      "bg-[#007F8C] text-white",
      "dark:bg-[#01B8CA] dark:text-black"
    ]
  end

  defp color_variant("default", "secondary") do
    [
      "bg-[#266EF1] text-white",
      "dark:bg-[#6DAAFB] dark:text-black"
    ]
  end

  defp color_variant("default", "success") do
    [
      "bg-[#0E8345] text-white",
      "dark:bg-[#06C167] dark:text-black"
    ]
  end

  defp color_variant("default", "warning") do
    [
      "bg-[#DE1135] text-white",
      "dark:bg-[#FC7F79] dark:text-black"
    ]
  end

  defp color_variant("default", "danger") do
    [
      "bg-[#DE1135] text-white",
      "dark:bg-[#FC7F79] dark:text-black"
    ]
  end

  defp color_variant("default", "info") do
    [
      "bg-[#0B84BA] text-white",
      "dark:bg-[#3EB7ED] dark:text-black"
    ]
  end

  defp color_variant("default", "misc") do
    [
      "bg-[#8750C5] text-white",
      "dark:bg-[#BA83F9] dark:text-black"
    ]
  end

  defp color_variant("default", "dawn") do
    [
      "bg-[#A86438] text-white",
      "dark:bg-[#DB976B] dark:text-black"
    ]
  end

  defp color_variant("default", "silver") do
    [
      "bg-[#868686] text-white",
      "dark:bg-[#A6A6A6] dark:text-black"
    ]
  end

  defp color_variant("outline", "natural") do
    [
      "bg-transparent text-[#4B4B4B] border-[#4B4B4B]",
      "dark:text-[#DDDDDD] dark:border-[#DDDDDD]"
    ]
  end

  defp color_variant("outline", "primary") do
    [
      "bg-transparent text-[#007F8C] border-[#007F8C]",
      "dark:text-[#01B8CA] dark:border-[#01B8CA]"
    ]
  end

  defp color_variant("outline", "secondary") do
    [
      "bg-transparent text-[#266EF1] border-[#266EF1]",
      "dark:text-[#6DAAFB] dark:border-[#6DAAFB]"
    ]
  end

  defp color_variant("outline", "success") do
    [
      "bg-transparent text-[#0E8345] border-[#0E8345]",
      "dark:text-[#06C167] dark:border-[#06C167]"
    ]
  end

  defp color_variant("outline", "warning") do
    [
      "bg-transparent text-[#CA8D01] border-[#CA8D01]",
      "dark:text-[#FDC034] dark:border-[#FDC034]"
    ]
  end

  defp color_variant("outline", "danger") do
    [
      "bg-transparent text-[#DE1135] border-[#DE1135]",
      "dark:text-[#FC7F79] dark:border-[#FC7F79]"
    ]
  end

  defp color_variant("outline", "info") do
    [
      "bg-transparent text-[#0B84BA] border-[#0B84BA]",
      "dark:text-[#3EB7ED] dark:border-[#3EB7ED]"
    ]
  end

  defp color_variant("outline", "misc") do
    [
      "bg-transparent text-[#8750C5] border-[#8750C5]",
      "dark:text-[#BA83F9] dark:border-[#BA83F9]"
    ]
  end

  defp color_variant("outline", "dawn") do
    [
      "bg-transparent text-[#A86438] border-[#A86438]",
      "dark:text-[#DB976B] dark:border-[#DB976B]"
    ]
  end

  defp color_variant("outline", "silver") do
    [
      "bg-transparent text-[#868686] border-[#868686]",
      "dark:text-[#A6A6A6] dark:border-[#A6A6A6]"
    ]
  end

  defp color_variant("transparent", "natural") do
    [
      "bg-transparent text-[#4B4B4B]",
      "dark:text-[#DDDDDD] border-transparent"
    ]
  end

  defp color_variant("transparent", "primary") do
    [
      "bg-transparent text-[#007F8C]",
      "dark:text-[#01B8CA] border-transparent"
    ]
  end

  defp color_variant("transparent", "secondary") do
    [
      "bg-transparent text-[#266EF1]",
      "dark:text-[#6DAAFB] border-transparent"
    ]
  end

  defp color_variant("transparent", "success") do
    [
      "bg-transparent text-[#0E8345]",
      "dark:text-[#06C167] border-transparent"
    ]
  end

  defp color_variant("transparent", "warning") do
    [
      "bg-transparent text-[#CA8D01]",
      "dark:text-[#FDC034] border-transparent"
    ]
  end

  defp color_variant("transparent", "danger") do
    [
      "bg-transparent text-[#DE1135]",
      "dark:text-[#FC7F79] border-transparent"
    ]
  end

  defp color_variant("transparent", "info") do
    [
      "bg-transparent text-[#0B84BA]",
      "dark:text-[#3EB7ED] border-transparent"
    ]
  end

  defp color_variant("transparent", "misc") do
    [
      "bg-transparent text-[#8750C5]",
      "dark:text-[#BA83F9] border-transparent"
    ]
  end

  defp color_variant("transparent", "dawn") do
    [
      "bg-transparent text-[#A86438]",
      "dark:text-[#DB976B] border-transparent"
    ]
  end

  defp color_variant("transparent", "silver") do
    [
      "bg-transparent text-[#868686]",
      "dark:text-[#A6A6A6] border-transparent"
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
