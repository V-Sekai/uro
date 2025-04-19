defmodule UroWeb.Components.Navbar do
  @moduledoc """
  The `UroWeb.Components.Navbar` module provides a flexible and customizable navigation
  bar component for Phoenix LiveView applications. It allows for a variety of styles,
  colors, and configurations to fit different design needs, including border styles,
  content alignment, and text positioning.

  This component supports nested elements through slots, enabling complex navigation structures.

  It also offers extensive theming options, such as rounded corners, shadow effects,
  and maximum width settings.

  With built-in support for icons and images, the `Navbar` module makes it easy to create
  visually appealing and interactive navigation bars that enhance the user experience.
  """
  use Phoenix.Component

  @doc """
  Renders a customizable navigation bar (`navbar` component) that can include links,
  dropdowns, and other components.

  The navigation bar is designed to handle various styles, colors, and layouts.

  ## Examples

  ```elixir
  <.navbar id="nav-11" color="success" variant="shadow">
    <:list><.link navigate="/">Home</.link></:list>
    <:list><.link navigate="/examples/sidebar">List</.link></:list>

    <:list>
      <.dropdown relative="md:relative" width="w-full" clickable>
        <:trigger width="full" trigger_id="test-31">
          <button class="text-start w-full block">Dropdown</button>
        </:trigger>

        <:content space="small" id="test-31" rounded="large" width="large" padding="extra_small">
          <ul class="space-y-5">
            <li>
              <.dropdown width="w-full" position="right" clickable>
                <:trigger trigger_id="test-19">
                  <button class={[
                    "py-1 px-2 text-start w-full flex items-center justify-between hover:bg-gray-200"
                  ]}
                  >
                    Nested Dropdown <.icon name="hero-chevron-right" />
                  </button>
                </:trigger>

                <:content id="test-19" rounded="large" width="large" padding="extra_small">
                  <ul class="space-y-5">
                    <li>
                      <.link class="py-1 px-2 block hover:bg-gray-200" navigate="/examples/list">
                        Security
                      </.link>
                    </li>

                    <li>
                      <.link class="py-1 px-2 block hover:bg-gray-200" navigate="/examples/dropdown">
                        Memory
                      </.link>
                    </li>

                    <li>
                      <.link class="py-1 px-2 block hover:bg-gray-200" navigate="/examples/image">
                        Design
                      </.link>
                    </li>
                  </ul>
                </:content>
              </.dropdown>
            </li>

            <li>
              <.link class="py-1 px-2 block hover:bg-gray-200" navigate="/examples/dropdown">
                Memory
              </.link>
            </li>

            <li>
              <.link class="py-1 px-2 block hover:bg-gray-200" navigate="/examples/image">
                Design
              </.link>
            </li>
          </ul>
        </:content>
      </.dropdown>
    </:list>

    <:list><.link navigate="/examples/rating">Blog</.link></:list>
    <:list><.link navigate="/examples/sidebar">Calendar</.link></:list>
    <:list><.link navigate="/examples/rating">Booking</.link></:list>
    <:list><.link navigate="/examples/sidebar">Partners</.link></:list>
    <:list><.link navigate="/examples/rating">About</.link></:list>
  </.navbar>
  ```
  """
  @doc type: :component
  attr :id, :string,
    required: true,
    doc: "A unique identifier is used to manage state and interaction"

  attr :variant, :string, default: "base", doc: "Determines the style"
  attr :color, :string, default: "natural", doc: "Determines color theme"
  attr :border, :string, default: "extra_small", doc: "Determines border style"
  attr :text_position, :string, default: "", doc: "Determines the element' text position"
  attr :rounded, :string, default: "", doc: "Determines the border radius"
  attr :max_width, :string, default: "", doc: "Determines the style of element max width"

  attr :content_position, :string,
    default: "between",
    doc: "Determines the alignment of the element's content"

  attr :image, :string, default: nil, doc: "Image displayed alongside of an item"
  attr :image_class, :string, default: nil, doc: "Determines custom class for the image"
  attr :name, :string, default: nil, doc: "Specifies the name of the element"
  attr :relative, :boolean, default: false, doc: ""
  attr :link, :string, default: nil, doc: ""
  attr :space, :string, default: "", doc: "Space between items"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :padding, :string, default: "small", doc: "Determines padding for items"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :start_content,
    required: false,
    doc: "Content to be rendered at the start (start side based on rtl or ltr) of the navbar."

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  slot :end_content,
    required: false,
    doc: "Content to be rendered at the end (end side based on rtl or ltr) of the navbar."

  slot :list, required: false do
    attr :class, :string, doc: "Custom CSS class for additional styling"
    attr :padding, :string, doc: "Determines padding for items"
    attr :icon, :string, doc: "Icon displayed alongside of an item"
    attr :icon_class, :string, doc: "Determines custom class for the icon"
    attr :icon_position, :string, doc: "Determines icon position"
  end

  def navbar(assigns) do
    ~H"""
    <nav
      id={@id}
      class={[
        "relative",
        "[&.show-nav-menu_.nav-menu]:block [&.show-nav-menu_.nav-menu]:opacity-100",
        border_class(@border, @variant),
        content_position(@content_position),
        color_variant(@variant, @color),
        rounded_size(@rounded),
        padding_size(@padding),
        text_position(@text_position),
        maximum_width(@max_width),
        space_class(@space),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <div class="nav-wrapper md:flex items-center gap-2 md:gap-5">
        <div :if={@start_content != [] and !is_nil(@start_content)}>{render_slot(@start_content)}</div>
        <.link
          :if={!is_nil(@link)}
          navigate={@link}
          class="flex items-center space-x-3 rtl:space-x-reverse mb-5 md:mb-0"
        >
          <img :if={!is_nil(@image)} src={@image} class={@image_class} />
          <h1 :if={!is_nil(@name)} class="text-xl font-semibold">
            {@name}
          </h1>
        </.link>

        <div :if={!is_nil(@list) && length(@list) > 0} class={["w-auto"]}>
          <ul class={[
            "flex flex-wrap md:flex-nowrap gap-4",
            @relative && "relative"
          ]}>
            <li
              :for={list <- @list}
              class={[
                "inline-flex items-center",
                list[:icon_position] == "end" && "flex-row-reverse",
                list[:class]
              ]}
            >
              <.icon :if={list[:icon]} name={list[:icon]} class={["list-icon", list[:icon_class]]} />
              {render_slot(list)}
            </li>
          </ul>
        </div>
        {render_slot(@inner_block)}
        <div :if={@end_content != [] and !is_nil(@end_content)}>{render_slot(@end_content)}</div>
      </div>
    </nav>
    """
  end

  @doc """
  Renders a header with title.
  """
  @doc type: :component
  attr :class, :string, default: nil

  slot :inner_block, required: true
  slot :subtitle
  slot :actions

  def header(assigns) do
    ~H"""
    <header class={[@actions != [] && "flex items-center justify-between gap-6", @class]}>
      <div>
        <h1 class="text-lg font-semibold leading-8 text-zinc-800">
          {render_slot(@inner_block)}
        </h1>
        <p :if={@subtitle != []} class="mt-2 text-sm leading-6 text-zinc-600">
          {render_slot(@subtitle)}
        </p>
      </div>
      <div class="flex-none">{render_slot(@actions)}</div>
    </header>
    """
  end

  defp content_position("start") do
    "[&_.nav-wrapper]:justify-start"
  end

  defp content_position("end") do
    "[&_.nav-wrapper]:justify-end"
  end

  defp content_position("center") do
    "[&_.nav-wrapper]:justify-center"
  end

  defp content_position("between") do
    "[&_.nav-wrapper]:justify-between"
  end

  defp content_position("around") do
    "[&_.nav-wrapper]:justify-around"
  end

  defp content_position(params) when is_binary(params), do: params

  defp text_position("left"), do: "text-left"
  defp text_position("right"), do: "text-right"
  defp text_position("center"), do: "text-center"
  defp text_position(params) when is_binary(params), do: params

  defp space_class("extra_small"), do: "space-y-2"

  defp space_class("small"), do: "space-y-3"

  defp space_class("medium"), do: "space-y-4"

  defp space_class("large"), do: "space-y-5"

  defp space_class("extra_large"), do: "space-y-6"

  defp space_class(params) when is_binary(params), do: params

  defp maximum_width("extra_small"), do: "[&_.nav-wrapper]:max-w-3xl	[&_.nav-wrapper]:mx-auto"
  defp maximum_width("small"), do: "[&_.nav-wrapper]:max-w-4xl [&_.nav-wrapper]:mx-auto"
  defp maximum_width("medium"), do: "[&_.nav-wrapper]:max-w-5xl [&_.nav-wrapper]:mx-auto"
  defp maximum_width("large"), do: "[&_.nav-wrapper]:max-w-6xl [&_.nav-wrapper]:mx-auto"
  defp maximum_width("extra_large"), do: "[&_.nav-wrapper]:max-w-7xl [&_.nav-wrapper]:mx-auto"
  defp maximum_width(params) when is_binary(params), do: params

  defp padding_size("extra_small"), do: "p-1"

  defp padding_size("small"), do: "p-2"

  defp padding_size("medium"), do: "p-3"

  defp padding_size("large"), do: "p-4"

  defp padding_size("extra_large"), do: "p-5"

  defp padding_size("none"), do: "p-0"

  defp padding_size(params) when is_binary(params), do: params

  defp border_class(_, variant) when variant in ["default", "shadow", "gradient"],
    do: nil

  defp border_class("none", _), do: "border-b-0"
  defp border_class("extra_small", _), do: "border-b"
  defp border_class("small", _), do: "border-b-2"
  defp border_class("medium", _), do: "border-b-[3px]"
  defp border_class("large", _), do: "border-b-4"
  defp border_class("extra_large", _), do: "border-b-[5px]"
  defp border_class(params, _) when is_binary(params), do: params

  defp rounded_size("extra_small"), do: "rounded-b-sm"

  defp rounded_size("small"), do: "rounded-b"

  defp rounded_size("medium"), do: "rounded-b-md"

  defp rounded_size("large"), do: "rounded-b-lg"

  defp rounded_size("extra_large"), do: "rounded-b-xl"

  defp rounded_size(params) when is_binary(params), do: params

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
