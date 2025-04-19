defmodule UroWeb.Components.Avatar do
  @moduledoc """
  The `UroWeb.Components.Avatar` module provides a set of components for creating and
  managing avatar elements in your **Phoenix LiveView** applications.

  It supports various avatar types, including standard avatars, placeholders, and placeholder icons.
  You can customize the appearance and behavior of avatars using attributes such as size, color,
  border, and shadow.

  ### Components

  - **Avatar (`avatar/1`)**: Renders an individual avatar element, which can include an image,
  icon, or text content. The component supports several attributes for customization,
  such as size, color, shadow, and border radius. Slots are available for adding additional
  content like icons.

  - **Avatar Group (`avatar_group/1`)**: Renders a group of avatar elements arranged in a flex container.
  You can control the spacing between avatars and provide custom styling using the
  available attributes and slots.
  """

  use Phoenix.Component

  @doc """
  The `avatar` component is used to display user avatars with various customization options,
  including size, shape, and styling.

  It supports displaying an image or an icon with optional inner content.

  ## Examples

  ```elixir
  <.avatar size="medium" rounded="full" color="silver">
    <:icon name="hero-user" />
    <.indicator size="small" bottom_right />
  </.avatar>

  <.avatar src="https://example.com/profile.jpg" size="extra_small" rounded="full">
    <.indicator size="extra_small" bottom_left />
  </.avatar>

  <.avatar src="https://example.com/profile.jpg" size="extra_large" rounded="full">
    <.indicator size="extra_small" color="success" top_left />
  </.avatar>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :src, :string, default: nil, doc: "Media link"

  attr :color, :string, default: "transparent", doc: "Determines color theme"

  attr :size, :string,
    default: "small",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :shadow, :string, default: "none", doc: "Determines shadow style"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :rounded, :string, default: "medium", doc: "Determines the border radius"

  attr :border, :string, default: "none", doc: "Determines border style"

  slot :icon, required: false do
    attr :name, :string, required: true, doc: "Specifies the name of the element"
    attr :class, :string, doc: "Custom CSS class for additional styling"
    attr :icon_class, :string, doc: "Determines custom class for the icon"
    attr :color, :string, doc: "Determines color theme"

    attr :size, :string,
      doc:
        "Determines the overall size of the elements, including padding, font size, and other items"
  end

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def avatar(%{src: src, rounded: "full"} = assigns) when not is_nil(src) do
    ~H"""
    <div class={[
      "relative w-fit",
      size_class(@size, :image)
    ]}>
      <img
        id={@id}
        src={@src}
        class={[
          image_color(@color),
          rounded_size(@rounded),
          border_class(@border),
          shadow_class(@shadow),
          @class
        ]}
        {@rest}
      />
      {render_slot(@inner_block)}
    </div>
    """
  end

  def avatar(%{src: src, rounded: "full"} = assigns) when is_nil(src) do
    ~H"""
    <div class={
      default_classes() ++
        [
          color_class(@color),
          rounded_size(@rounded),
          size_class(@size, :text),
          border_class(@border),
          shadow_class(@shadow),
          @font_weight,
          @class
        ]
    }>
      <div :for={icon <- @icon} class={[icon[:size], icon[:color], icon[:class]]}>
        <.icon name={icon[:name]} class={icon[:icon_class] || size_class(@size, :icon)} />
      </div>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def avatar(%{src: src} = assigns) when not is_nil(src) do
    ~H"""
    <div class="relative">
      <img
        id={@id}
        src={@src}
        class={[
          image_color(@color),
          rounded_size(@rounded),
          size_class(@size),
          border_class(@border),
          shadow_class(@shadow),
          @class
        ]}
        {@rest}
      />
      {render_slot(@inner_block)}
    </div>
    """
  end

  def avatar(assigns) do
    ~H"""
    <div class={
      default_classes() ++
        [
          color_class(@color),
          rounded_size(@rounded),
          size_class(@size),
          border_class(@border),
          shadow_class(@shadow),
          @font_weight,
          @class
        ]
    }>
      <div :for={icon <- @icon} class={[icon[:size], icon[:color], icon[:class]]}>
        <.icon name={icon[:name]} class={icon[:icon_class] || size_class(@size, :icon)} />
      </div>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  The `avatar_group` component is used to display a group of avatars with customizable spacing and layout.
  It supports different types of avatars such as `default`, `placeholder`, and `placeholder_icon`,
  allowing for flexible content presentation within a group.

  ## Examples

  ```elixir
  <.avatar_group>
    <.avatar src="https://example.com/profile.jpg" size="large" rounded="full"/>
    <.avatar src="https://example.com/profile.jpg" size="large" border="extra_large" rounded="full"/>
    <.avatar src="https://example.com/profile.jpg" size="large" color="warning" rounded="full"/>
    <.avatar src="https://example.com/profile.jpg" size="large" rounded="full"/>
    <.avatar size="large" rounded="full" border="medium">+20</.avatar>
  </.avatar_group>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :space, :string, default: "medium", doc: "Space between items"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def avatar_group(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "flex items-center rtl:space-x-reverse",
        space_class(@space),
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp image_color("transparent") do
    nil
  end

  defp image_color("base") do
    "border-[#e4e4e7] dark:border-[#27272a]"
  end

  defp image_color("white") do
    "border-white"
  end

  defp image_color("dark") do
    "border-[#282828]"
  end

  defp image_color("natural") do
    "border-[#282828] dark:border-[#E8E8E8]"
  end

  defp image_color("primary") do
    "border-[#016974] dark:border-[#77D5E3]"
  end

  defp image_color("secondary") do
    "border-[#175BCC] dark:border-[#A9C9FF]"
  end

  defp image_color("success") do
    "border-[#166C3B] dark:border-[#7FD99A]"
  end

  defp image_color("warning") do
    "border-[#FFF7E6] dark:border-[#FDD067]"
  end

  defp image_color("danger") do
    "border-[#BB032A] dark:border-[#FFB2AB]"
  end

  defp image_color("info") do
    "border-[#08638C] dark:border-[#6EC9F2]"
  end

  defp image_color("misc") do
    "border-[#653C94] dark:border-[#653C94]"
  end

  defp image_color("dawn") do
    "border-[#7E4B2A] dark:border-[#E4B190]"
  end

  defp image_color("silver") do
    "border-[#727272] dark:border-[#BBBBBB]"
  end

  defp image_color(params), do: params

  defp color_class("base") do
    [
      "bg-white text-[#09090b] border-[#e4e4e7]",
      "dark:bg-[#18181B] dark:text-[#FAFAFA] dark:border-[#27272a]"
    ]
  end

  defp color_class("white") do
    ["bg-white text-black border-[#DDDDDD]"]
  end

  defp color_class("dark") do
    ["bg-[#282828] text-white border-[#727272]"]
  end

  defp color_class("natural") do
    [
      "text-[#282828] border-[#282828] bg-[#F3F3F3]",
      "dark:text-[#E8E8E8] dark:border-[#E8E8E8] dark:bg-[#4B4B4B]"
    ]
  end

  defp color_class("primary") do
    [
      "text-[#016974] border-[#016974] bg-[#E2F8FB]",
      "dark:text-[#77D5E3] dark:border-[#77D5E3] dark:bg-[#002D33]"
    ]
  end

  defp color_class("secondary") do
    [
      "text-[#175BCC] border-[#175BCC] bg-[#EFF4FE]",
      "dark:text-[#A9C9FF] dark:border-[#A9C9FF] dark:bg-[#002661]"
    ]
  end

  defp color_class("success") do
    [
      "text-[#166C3B] border-[#166C3B] bg-[#EAF6ED]",
      "dark:text-[#7FD99A] dark:border-[#7FD99A] dark:bg-[#002F14]"
    ]
  end

  defp color_class("warning") do
    [
      "text-[#976A01] border-[#976A01] bg-[#FFF7E6]",
      "dark:text-[#FDD067] dark:border-[#FDD067] dark:bg-[#322300]"
    ]
  end

  defp color_class("danger") do
    [
      "text-[#BB032A] border-[#BB032A] bg-[#FFF0EE]",
      "dark:text-[#FFB2AB] dark:border-[#FFB2AB] dark:bg-[#520810]"
    ]
  end

  defp color_class("info") do
    [
      "text-[#0B84BA] border-[#0B84BA] bg-[#E7F6FD]",
      "dark:text-[#6EC9F2] dark:border-[#6EC9F2] dark:bg-[#03212F]"
    ]
  end

  defp color_class("misc") do
    [
      "text-[#653C94] border-[#653C94] bg-[#F6F0FE]",
      "dark:text-[#CBA2FA] dark:border-[#CBA2FA] dark:bg-[#221431]"
    ]
  end

  defp color_class("dawn") do
    [
      "text-[#7E4B2A] border-[#7E4B2A] bg-[#FBF2ED]",
      "dark:text-[#E4B190] dark:border-[#E4B190] dark:bg-[#2A190E]"
    ]
  end

  defp color_class("silver") do
    [
      "text-[#727272] border-[#727272] bg-[#F3F3F3]",
      "dark:text-[#BBBBBB] dark:border-[#BBBBBB] dark:bg-[#4B4B4B]"
    ]
  end

  defp color_class(params) when is_binary(params), do: params

  defp border_class("extra_small"), do: "border-avatar border"
  defp border_class("small"), do: "border-avatar border-2"
  defp border_class("medium"), do: "border-avatar border-[3px]"
  defp border_class("large"), do: "border-avatar border-4"
  defp border_class("extra_large"), do: "border-avatar border-[5px]"
  defp border_class("none"), do: nil
  defp border_class(params) when is_binary(params), do: params

  defp rounded_size("extra_small"), do: "rounded-sm"

  defp rounded_size("small"), do: "rounded"

  defp rounded_size("medium"), do: "rounded-md"

  defp rounded_size("large"), do: "rounded-lg"

  defp rounded_size("extra_large"), do: "rounded-xl"

  defp rounded_size("full"), do: "rounded-full"

  defp rounded_size("none"), do: nil

  defp rounded_size(params) when is_binary(params), do: params

  defp size_class("extra_small"), do: "size-8 text-xs"

  defp size_class("small"), do: "size-9 text-sm"

  defp size_class("medium"), do: "size-10 text-base"

  defp size_class("large"), do: "size-12 text-lg"

  defp size_class("extra_large"), do: "size-14 text-xl"

  defp size_class(params) when is_binary(params), do: params
  defp size_class(_), do: size_class("small")

  defp size_class("extra_small", :icon), do: "size-4"

  defp size_class("small", :icon), do: "size-5"

  defp size_class("medium", :icon), do: "size-6"

  defp size_class("large", :icon), do: "size-7"

  defp size_class("extra_large", :icon), do: "size-8"

  defp size_class(params, :icon) when is_binary(params), do: params
  defp size_class(_, :icon), do: size_class("small", :icon)

  defp size_class("extra_small", :image) do
    [
      "[&>img]:size-8 [&_.indicator-top-left]:!top-0 [&_.indicator-top-left]:!left-0",
      "[&_.indicator-top-right]:!top-0 [&_.indicator-top-right]:!right-0",
      "[&_.indicator-bottom-right]:!bottom-0 [&_.indicator-bottom-right]:!right-0",
      "[&_.indicator-bottom-left]:!bottom-0 [&_.indicator-bottom-left]:!left-0",
      "[&_.indicator-top-left]:!translate-y-0 [&_.indicator-top-left]:!translate-x-0",
      "[&_.indicator-top-right]:!translate-y-0 [&_.indicator-top-right]:!translate-x-0",
      "[&_.indicator-bottom-right]:!translate-y-0 [&_.indicator-bottom-right]:!translate-x-0",
      "[&_.indicator-bottom-left]:!translate-y-0 [&_.indicator-bottom-left]:!translate-x-0"
    ]
  end

  defp size_class("small", :image) do
    [
      "[&>img]:size-9 [&_.indicator-top-left]:!top-0 [&_.indicator-top-left]:!left-0",
      "[&_.indicator-top-right]:!top-0 [&_.indicator-top-right]:!right-0",
      "[&_.indicator-bottom-right]:!bottom-0 [&_.indicator-bottom-right]:!right-0",
      "[&_.indicator-bottom-left]:!bottom-0 [&_.indicator-bottom-left]:!left-0",
      "[&_.indicator-top-left]:!translate-y-0 [&_.indicator-top-left]:!translate-x-0",
      "[&_.indicator-top-right]:!translate-y-0 [&_.indicator-top-right]:!translate-x-0",
      "[&_.indicator-bottom-right]:!translate-y-0 [&_.indicator-bottom-right]:!translate-x-0",
      "[&_.indicator-bottom-left]:!translate-y-0 [&_.indicator-bottom-left]:!translate-x-0"
    ]
  end

  defp size_class("medium", :image) do
    [
      "[&>img]:size-10 [&_.indicator-top-left]:!top-0 [&_.indicator-top-left]:!left-0",
      "[&_.indicator-top-right]:!top-0 [&_.indicator-top-right]:!right-0",
      "[&_.indicator-bottom-right]:!bottom-0 [&_.indicator-bottom-right]:!right-0",
      "[&_.indicator-bottom-left]:!bottom-0 [&_.indicator-bottom-left]:!left-0",
      "[&_.indicator-top-left]:!translate-y-0 [&_.indicator-top-left]:!translate-x-0",
      "[&_.indicator-top-right]:!translate-y-0 [&_.indicator-top-right]:!translate-x-0",
      "[&_.indicator-bottom-right]:!translate-y-0 [&_.indicator-bottom-right]:!translate-x-0",
      "[&_.indicator-bottom-left]:!translate-y-0 [&_.indicator-bottom-left]:!translate-x-0"
    ]
  end

  defp size_class("large", :image) do
    [
      "[&>img]:size-11 [&_.indicator-top-left]:!top-0.5 [&_.indicator-top-left]:!left-0.5",
      "[&_.indicator-top-right]:!top-0.5 [&_.indicator-top-right]:!right-0.5",
      "[&_.indicator-bottom-right]:!bottom-0.5 [&_.indicator-bottom-right]:!right-0.5",
      "[&_.indicator-bottom-left]:!bottom-0.5 [&_.indicator-bottom-left]:!left-0.5",
      "[&_.indicator-top-left]:!translate-y-0 [&_.indicator-top-left]:!translate-x-0",
      "[&_.indicator-top-right]:!translate-y-0 [&_.indicator-top-right]:!translate-x-0",
      "[&_.indicator-bottom-right]:!translate-y-0 [&_.indicator-bottom-right]:!translate-x-0",
      "[&_.indicator-bottom-left]:!translate-y-0 [&_.indicator-bottom-left]:!translate-x-0"
    ]
  end

  defp size_class("extra_large", :image) do
    [
      "[&>img]:size-12 [&_.indicator-top-left]:!top-0.5 [&_.indicator-top-left]:!left-0.5",
      "[&_.indicator-top-right]:!top-0.5 [&_.indicator-top-right]:!right-0.5",
      "[&_.indicator-bottom-right]:!bottom-0.5 [&_.indicator-bottom-right]:!right-0.5",
      "[&_.indicator-bottom-left]:!bottom-0.5 [&_.indicator-bottom-left]:!left-0.5",
      "[&_.indicator-top-left]:!translate-y-0 [&_.indicator-top-left]:!translate-x-0",
      "[&_.indicator-top-right]:!translate-y-0 [&_.indicator-top-right]:!translate-x-0",
      "[&_.indicator-bottom-right]:!translate-y-0 [&_.indicator-bottom-right]:!translate-x-0",
      "[&_.indicator-bottom-left]:!translate-y-0 [&_.indicator-bottom-left]:!translate-x-0"
    ]
  end

  defp size_class(params, :image) when is_binary(params), do: params
  defp size_class(_, :image), do: size_class("small", :image)

  defp size_class("extra_small", :text) do
    [
      "size-8 text-xs [&_.indicator-top-left]:!top-0 [&_.indicator-top-left]:!left-0",
      "[&_.indicator-top-right]:!top-0 [&_.indicator-top-right]:!right-0",
      "[&_.indicator-bottom-right]:!bottom-0 [&_.indicator-bottom-right]:!right-0",
      "[&_.indicator-bottom-left]:!bottom-0 [&_.indicator-bottom-left]:!left-0",
      "[&_.indicator-top-left]:!translate-y-0 [&_.indicator-top-left]:!translate-x-0",
      "[&_.indicator-top-right]:!translate-y-0 [&_.indicator-top-right]:!translate-x-0",
      "[&_.indicator-bottom-right]:!translate-y-0 [&_.indicator-bottom-right]:!translate-x-0",
      "[&_.indicator-bottom-left]:!translate-y-0 [&_.indicator-bottom-left]:!translate-x-0"
    ]
  end

  defp size_class("small", :text) do
    [
      "size-9 text-sm [&_.indicator-top-left]:!top-0 [&_.indicator-top-left]:!left-0",
      "[&_.indicator-top-right]:!top-0 [&_.indicator-top-right]:!right-0",
      "[&_.indicator-bottom-right]:!bottom-0 [&_.indicator-bottom-right]:!right-0",
      "[&_.indicator-bottom-left]:!bottom-0 [&_.indicator-bottom-left]:!left-0",
      "[&_.indicator-top-left]:!translate-y-0 [&_.indicator-top-left]:!translate-x-0",
      "[&_.indicator-top-right]:!translate-y-0 [&_.indicator-top-right]:!translate-x-0",
      "[&_.indicator-bottom-right]:!translate-y-0 [&_.indicator-bottom-right]:!translate-x-0",
      "[&_.indicator-bottom-left]:!translate-y-0 [&_.indicator-bottom-left]:!translate-x-0"
    ]
  end

  defp size_class("medium", :text) do
    [
      "size-10 text-base [&_.indicator-top-left]:!top-0 [&_.indicator-top-left]:!left-0",
      "[&_.indicator-top-right]:!top-0 [&_.indicator-top-right]:!right-0",
      "[&_.indicator-bottom-right]:!bottom-0 [&_.indicator-bottom-right]:!right-0",
      "[&_.indicator-bottom-left]:!bottom-0 [&_.indicator-bottom-left]:!left-0",
      "[&_.indicator-top-left]:!translate-y-0 [&_.indicator-top-left]:!translate-x-0",
      "[&_.indicator-top-right]:!translate-y-0 [&_.indicator-top-right]:!translate-x-0",
      "[&_.indicator-bottom-right]:!translate-y-0 [&_.indicator-bottom-right]:!translate-x-0",
      "[&_.indicator-bottom-left]:!translate-y-0 [&_.indicator-bottom-left]:!translate-x-0"
    ]
  end

  defp size_class("large", :text) do
    [
      "size-11 text-lg [&_.indicator-top-left]:!top-0.5 [&_.indicator-top-left]:!left-0.5",
      "[&_.indicator-top-right]:!top-0.5 [&_.indicator-top-right]:!right-0.5",
      "[&_.indicator-bottom-right]:!bottom-0.5 [&_.indicator-bottom-right]:!right-0.5",
      "[&_.indicator-bottom-left]:!bottom-0.5 [&_.indicator-bottom-left]:!left-0.5",
      "[&_.indicator-top-left]:!translate-y-0 [&_.indicator-top-left]:!translate-x-0",
      "[&_.indicator-top-right]:!translate-y-0 [&_.indicator-top-right]:!translate-x-0",
      "[&_.indicator-bottom-right]:!translate-y-0 [&_.indicator-bottom-right]:!translate-x-0",
      "[&_.indicator-bottom-left]:!translate-y-0 [&_.indicator-bottom-left]:!translate-x-0"
    ]
  end

  defp size_class("extra_large", :text) do
    [
      "size-12 text-xl [&_.indicator-top-left]:!top-0.5 [&_.indicator-top-left]:!left-0.5",
      "[&_.indicator-top-right]:!top-0.5 [&_.indicator-top-right]:!right-0.5",
      "[&_.indicator-bottom-right]:!bottom-0.5 [&_.indicator-bottom-right]:!right-0.5",
      "[&_.indicator-bottom-left]:!bottom-0.5 [&_.indicator-bottom-left]:!left-0.5",
      "[&_.indicator-top-left]:!translate-y-0 [&_.indicator-top-left]:!translate-x-0",
      "[&_.indicator-top-right]:!translate-y-0 [&_.indicator-top-right]:!translate-x-0",
      "[&_.indicator-bottom-right]:!translate-y-0 [&_.indicator-bottom-right]:!translate-x-0",
      "[&_.indicator-bottom-left]:!translate-y-0 [&_.indicator-bottom-left]:!translate-x-0"
    ]
  end

  defp size_class(params, :text) when is_binary(params), do: params

  defp shadow_class("extra_small"), do: "shadow-sm"
  defp shadow_class("small"), do: "shadow"
  defp shadow_class("medium"), do: "shadow-md"
  defp shadow_class("large"), do: "shadow-lg"
  defp shadow_class("extra_large"), do: "shadow-xl"
  defp shadow_class("none"), do: "shadow-none"
  defp shadow_class(params) when is_binary(params), do: params

  defp space_class("extra_small"), do: "-space-x-2"

  defp space_class("small"), do: "-space-x-3"

  defp space_class("medium"), do: "-space-x-4"

  defp space_class("large"), do: "-space-x-5"

  defp space_class("extra_large"), do: "-space-x-6"

  defp space_class("none"), do: nil

  defp space_class(params) when is_binary(params), do: params

  defp default_classes() do
    [
      "relative inline-flex items-center justify-center p-0.5 [&.border-avatar:has(.indicator)]:box-content"
    ]
  end

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
