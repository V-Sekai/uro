defmodule UroWeb.Components.Card do
  @moduledoc """
  Provides a set of card components for the `UroWeb.Components.Card` project. These components
  allow for flexible and customizable card layouts, including features such as card titles,
  media, content sections, and footers.

  ## Components

    - `card/1`: Renders a basic card container with customizable size, color, border,
    padding, and other styling options.
    - `card_title/1`: Renders a title section for the card with support for icons and
    custom positioning.
    - `card_media/1`: Renders a media section within the card, such as an image or other media types.
    - `card_content/1`: Renders a content section within the card to display various information.
    - `card_footer/1`: Renders a footer section for the card, suitable for additional
    information or actions.

  ## Configuration Options

  The module supports various attributes such as size, color, variant, and border
  styles to match different design requirements. Components can be nested and
  combined to create complex card layouts with ease.

  This module offers a powerful and easy-to-use way to create cards with consistent
  styling and behavior while providing the flexibility to adapt to various use cases.
  """

  use Phoenix.Component

  @positions [
    "start",
    "center",
    "end",
    "between",
    "around"
  ]

  @doc """
  The `card` component is used to display content in a structured container with various customization options such as `variant`, `color`, and `padding`. It supports an inner block for rendering nested content like media, titles, and footers, allowing for flexible layout designs.

  ## Examples

  ```elixir
  <.card>
    <.card_title title="This is a title in inner content" icon="hero-home" size="extra_large" />
    <.card_content>
      Lorem ipsum dolor sit amet consectetur adipisicing elit. Commodi ea atque soluta praesentium
      quidem dicta sapiente accusamus nihil.
    </.card_content>
  </.card>

  <.card>
    <.card_media src="https://example.com/bg.png" alt="test"/>
    <.card_content padding="large">
      <p>
        Lorem ipsum dolor sit amet consectetur adipisicing elit. Commodi ea atque soluta praesentium
        quidem dicta sapiente accusamus nihil.
      </p>
    </.card_content>
    <.card_footer padding="large">
      <.button size="full">See more</.button>
    </.card_footer>
  </.card>

  <.card padding="small">
    <.card_title class="flex items-center gap-2 justify-between">
      <div>Title</div>
      <div>Link</div>
    </.card_title>
    <.hr />
    <.card_content space="large">
      <.card_media rounded="large" src="https://example.com/bg.png" alt="test"/>
      <p>
        Lorem ipsum dolor sit amet consectetur adipisicing elit. Commodi ea atque soluta
        praesentium quidem dicta sapiente accusamus nihil.
      </p>
    </.card_content>
    <.hr />
    <.card_footer class="flex items-center gap-2">
      <.card_media src="https://example.com/bg.png" alt="test"/>
      <.card_media src="https://example.com/bg.png" alt="test"/>
      <.card_media src="https://example.com/bg.png" alt="test"/>
    </.card_footer>
  </.card>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :variant, :string, default: "base", doc: "Determines the style"
  attr :color, :string, default: "natural", doc: "Determines color theme"
  attr :border, :string, default: "extra_small", doc: "Determines border style"
  attr :rounded, :string, default: "", doc: "Determines the border radius"
  attr :space, :string, default: "", doc: "Space between items"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :padding, :string, default: "", doc: "Determines padding for items"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def card(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "overflow-hidden [&:has(.overlay)]:relative",
        space_class(@space),
        border_class(@border, @variant),
        color_variant(@variant, @color),
        rounded_size(@rounded),
        wrapper_padding(@padding),
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
  The `card_title` component is used to display the title section of a card with customizable
  attributes such as `position`, `size`, and `padding`.

  It supports adding an optional icon alongside the title and includes an inner block for additional content.

  ## Examples

  ```elixir
  <.card_title class="border-b" padding="small" position="between">
    <div>Title</div>
    <div><.icon name="hero-ellipsis-horizontal" /></div>
  </.card_title>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :title, :string, default: nil, doc: "Specifies the title of the element"
  attr :icon, :string, default: nil, doc: "Icon displayed alongside of an item"

  attr :position, :string,
    values: @positions,
    default: "start",
    doc: "Determines the element position"

  attr :font_weight, :string,
    default: "font-semibold",
    doc: "Determines custom class for the font weight"

  attr :size, :string,
    default: "large",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :padding, :string, default: "", doc: "Determines padding for items"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def card_title(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "card-section flex items-center gap-2",
        padding_size(@padding),
        content_position(@position),
        size_class(@size),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <div :if={@title || @icon} class="flex gap-2 items-center">
        <.icon :if={@icon} name={@icon} class="card-title-icon" />
        <h3 :if={@title}>{@title}</h3>
      </div>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  The `card_media` component is used to display media elements, such as images, within a card.

  It supports customizable attributes like `rounded` and `class` for styling and can include an inner
  block for additional content.

  ## Examples

  ```elixir
  <.card_media src="https://example.com/bg.png" alt="test"/>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :alt, :string, doc: "Media link description"
  attr :src, :string, required: true, doc: "Media link"
  attr :width, :string, default: "w-full", doc: "Media width"
  attr :rounded, :string, default: "", doc: "Determines the border radius"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def card_media(assigns) do
    ~H"""
     <div id={@id} class={["card-media overflow-hidden", rounded_size(@rounded), @width, @class]}>
      <img
        src={@src}
        alt={@alt}
        class={[
          "max-w-full"
        ]}
      />
    </div>
    """
  end

  @doc """
  The `card_content` component is used to display the main content of a card with customizable attributes
  such as `padding` and `space` between items.

  It supports an inner block for rendering additional content, allowing for flexible layout and styling.

  ## Examples

  ```elixir
  <.card_content padding="large">
    <p>
      Lorem ipsum dolor sit amet consectetur adipisicing elit. Commodi ea atque soluta praesentium
      quidem dicta sapiente accusamus nihil.
    </p>
  </.card_content>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :space, :string, default: "", doc: "Space between items"
  attr :padding, :string, default: "", doc: "Determines padding for items"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def card_content(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "card-section",
        space_class(@space),
        padding_size(@padding),
        @class
      ]}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  The `card_footer` component is used to display the footer section of a card, allowing for
  additional actions or information at the bottom of the card.

  It supports customizable attributes such as `padding` and `class` for styling and includes an
  inner block for rendering content.

  ## Examples

  ```elixir
  <.card_footer padding="large">
    <.button size="full">See more</.button>
  </.card_footer>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :padding, :string, default: "", doc: "Determines padding for items"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def card_footer(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "card-section",
        padding_size(@padding),
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp border_class(_, variant) when variant in ["default", "shadow", "transparent", "gradient"],
    do: nil

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

  defp size_class("extra_small"), do: "text-xs [&_.card-title-icon]:size-3"

  defp size_class("small"), do: "text-sm [&_.card-title-icon]:size-3.5"

  defp size_class("medium"), do: "text-base [&_.card-title-icon]:size-4"

  defp size_class("large"), do: "text-lg [&_.card-title-icon]:size-5"

  defp size_class("extra_large"), do: "text-xl [&_.card-title-icon]:size-6"

  defp size_class(params) when is_binary(params), do: params

  defp content_position("start") do
    "justify-start"
  end

  defp content_position("end") do
    "justify-end"
  end

  defp content_position("center") do
    "justify-center"
  end

  defp content_position("between") do
    "justify-between"
  end

  defp content_position("around") do
    "justify-around"
  end

  defp content_position(params) when is_binary(params), do: params

  defp wrapper_padding("extra_small"),
    do: "[&:has(.card-section)>.card-section]:p-1 [&:not(:has(.card-section))]:p-1"

  defp wrapper_padding("small"),
    do: "[&:has(.card-section)>.card-section]:p-2 [&:not(:has(.card-section))]:p-2"

  defp wrapper_padding("medium"),
    do: "[&:has(.card-section)>.card-section]:p-3 [&:not(:has(.card-section))]:p-3"

  defp wrapper_padding("large"),
    do: "[&:has(.card-section)>.card-section]:p-4 [&:not(:has(.card-section))]:p-4"

  defp wrapper_padding("extra_large"),
    do: "[&:has(.card-section)>.card-section]:p-5 [&:not(:has(.card-section))]:p-5"

  defp wrapper_padding(params) when is_binary(params), do: params

  defp padding_size("extra_small"), do: "p-1"

  defp padding_size("small"), do: "p-2"

  defp padding_size("medium"), do: "p-3"

  defp padding_size("large"), do: "p-4"

  defp padding_size("extra_large"), do: "p-5"

  defp padding_size(params) when is_binary(params), do: params

  defp space_class("extra_small"), do: "space-y-2"

  defp space_class("small"), do: "space-y-3"

  defp space_class("medium"), do: "space-y-4"

  defp space_class("large"), do: "space-y-5"

  defp space_class("extra_large"), do: "space-y-6"

  defp space_class("none"), do: nil

  defp space_class(params) when is_binary(params), do: params

  defp color_variant("base", _) do
    [
      "[&:not(:has(.overlay))]:bg-white text-[#09090b] border-[#e4e4e7] shadow-sm",
      "dark:[&:not(:has(.overlay))]:bg-[#18181B] dark:text-[#FAFAFA] dark:border-[#27272a]"
    ]
  end

  defp color_variant("default", "white") do
    [
      "[&:not(:has(.overlay))]:bg-white text-black"
    ]
  end

  defp color_variant("default", "dark") do
    [
      "[&:not(:has(.overlay))]:bg-[#282828] text-white"
    ]
  end

  defp color_variant("default", "natural") do
    [
      "[&:not(:has(.overlay))]:bg-[#4B4B4B] text-white dark:[&:not(:has(.overlay))]:bg-[#DDDDDD] dark:text-black"
    ]
  end

  defp color_variant("default", "primary") do
    [
      "[&:not(:has(.overlay))]:bg-[#007F8C] text-white dark:[&:not(:has(.overlay))]:bg-[#01B8CA] dark:text-black"
    ]
  end

  defp color_variant("default", "secondary") do
    [
      "[&:not(:has(.overlay))]:bg-[#266EF1] text-white dark:[&:not(:has(.overlay))]:bg-[#6DAAFB] dark:text-black"
    ]
  end

  defp color_variant("default", "success") do
    [
      "[&:not(:has(.overlay))]:bg-[#0E8345] text-white dark:[&:not(:has(.overlay))]:bg-[#06C167] dark:text-black"
    ]
  end

  defp color_variant("default", "warning") do
    [
      "[&:not(:has(.overlay))]:bg-[#CA8D01] text-white dark:[&:not(:has(.overlay))]:bg-[#FDC034] dark:text-black"
    ]
  end

  defp color_variant("default", "danger") do
    [
      "[&:not(:has(.overlay))]:bg-[#DE1135] text-white dark:[&:not(:has(.overlay))]:bg-[#FC7F79] dark:text-black"
    ]
  end

  defp color_variant("default", "info") do
    [
      "[&:not(:has(.overlay))]:bg-[#0B84BA] text-white dark:[&:not(:has(.overlay))]:bg-[#3EB7ED] dark:text-black"
    ]
  end

  defp color_variant("default", "misc") do
    [
      "[&:not(:has(.overlay))]:bg-[#8750C5] text-white dark:[&:not(:has(.overlay))]:bg-[#BA83F9] dark:text-black"
    ]
  end

  defp color_variant("default", "dawn") do
    [
      "[&:not(:has(.overlay))]:bg-[#A86438] text-white dark:[&:not(:has(.overlay))]:bg-[#DB976B] dark:text-black"
    ]
  end

  defp color_variant("default", "silver") do
    [
      "[&:not(:has(.overlay))]:bg-[#868686] text-white dark:[&:not(:has(.overlay))]:bg-[#A6A6A6] dark:text-black"
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
      "[&:not(:has(.overlay))]:bg-[#4B4B4B] text-white dark:[&:not(:has(.overlay))]:bg-[#DDDDDD] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(134,134,134,0.5)] shadow-[0px_10px_15px_-3px_rgba(134,134,134,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "primary") do
    [
      "[&:not(:has(.overlay))]:bg-[#007F8C] text-white dark:[&:not(:has(.overlay))]:bg-[#01B8CA] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(0,149,164,0.5)] shadow-[0px_10px_15px_-3px_rgba(0,149,164,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "secondary") do
    [
      "[&:not(:has(.overlay))]:bg-[#266EF1] text-white dark:[&:not(:has(.overlay))]:bg-[#6DAAFB] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(6,139,238,0.5)] shadow-[0px_10px_15px_-3px_rgba(6,139,238,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "success") do
    [
      "[&:not(:has(.overlay))]:bg-[#0E8345] text-white hover:[&:not(:has(.overlay))]:bg-[#166C3B] dark:[&:not(:has(.overlay))]:bg-[#06C167] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(0,154,81,0.5)] shadow-[0px_10px_15px_-3px_rgba(0,154,81,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "warning") do
    [
      "[&:not(:has(.overlay))]:bg-[#CA8D01] text-white dark:[&:not(:has(.overlay))]:bg-[#FDC034] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(252,176,1,0.5)] shadow-[0px_10px_15px_-3px_rgba(252,176,1,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "danger") do
    [
      "[&:not(:has(.overlay))]:bg-[#DE1135] text-white dark:[&:not(:has(.overlay))]:bg-[#FC7F79] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(248,52,70,0.5)] shadow-[0px_10px_15px_-3px_rgba(248,52,70,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "info") do
    [
      "[&:not(:has(.overlay))]:bg-[#0B84BA] text-white dark:[&:not(:has(.overlay))]:bg-[#3EB7ED] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(14,165,233,0.5)] shadow-[0px_10px_15px_-3px_rgba(14,165,233,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "misc") do
    [
      "[&:not(:has(.overlay))]:bg-[#8750C5] text-white dark:[&:not(:has(.overlay))]:bg-[#BA83F9] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(169,100,247,0.5)] shadow-[0px_10px_15px_-3px_rgba(169,100,247,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "dawn") do
    [
      "[&:not(:has(.overlay))]:bg-[#A86438] text-white dark:[&:not(:has(.overlay))]:bg-[#DB976B] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(210,125,70,0.5)] shadow-[0px_10px_15px_-3px_rgba(210,125,70,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "silver") do
    [
      "[&:not(:has(.overlay))]:bg-[#868686] text-white dark:[&:not(:has(.overlay))]:bg-[#A6A6A6] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(134,134,134,0.5)] shadow-[0px_10px_15px_-3px_rgba(134,134,134,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("bordered", "white") do
    [
      "[&:not(:has(.overlay))]:bg-white text-black border-[#DDDDDD]"
    ]
  end

  defp color_variant("bordered", "dark") do
    [
      "[&:not(:has(.overlay))]:bg-[#282828] text-white border-[#727272]"
    ]
  end

  defp color_variant("bordered", "natural") do
    [
      "text-[#282828] border-[#282828] [&:not(:has(.overlay))]:bg-[#F3F3F3]",
      "dark:text-[#E8E8E8] dark:border-[#E8E8E8] dark:[&:not(:has(.overlay))]:bg-[#4B4B4B]"
    ]
  end

  defp color_variant("bordered", "primary") do
    [
      "text-[#016974] border-[#016974] [&:not(:has(.overlay))]:bg-[#E2F8FB]",
      "dark:text-[#77D5E3] dark:border-[#77D5E3] dark:[&:not(:has(.overlay))]:bg-[#002D33]"
    ]
  end

  defp color_variant("bordered", "secondary") do
    [
      "text-[#175BCC] border-[#175BCC] [&:not(:has(.overlay))]:bg-[#EFF4FE]",
      "dark:text-[#A9C9FF] dark:border-[#A9C9FF] dark:[&:not(:has(.overlay))]:bg-[#002661]"
    ]
  end

  defp color_variant("bordered", "success") do
    [
      "text-[#166C3B] border-[#166C3B] [&:not(:has(.overlay))]:bg-[#EAF6ED]",
      "dark:text-[#7FD99A] dark:border-[#7FD99A] dark:[&:not(:has(.overlay))]:bg-[#002F14]"
    ]
  end

  defp color_variant("bordered", "warning") do
    [
      "text-[#976A01] border-[#976A01] [&:not(:has(.overlay))]:bg-[#FFF7E6]",
      "dark:text-[#FDD067] dark:border-[#FDD067] dark:[&:not(:has(.overlay))]:bg-[#322300]"
    ]
  end

  defp color_variant("bordered", "danger") do
    [
      "text-[#BB032A] border-[#BB032A] [&:not(:has(.overlay))]:bg-[#FFF0EE]",
      "dark:text-[#FFB2AB] dark:border-[#FFB2AB] dark:[&:not(:has(.overlay))]:bg-[#520810]"
    ]
  end

  defp color_variant("bordered", "info") do
    [
      "text-[#0B84BA] border-[#0B84BA] [&:not(:has(.overlay))]:bg-[#E7F6FD]",
      "dark:text-[#6EC9F2] dark:border-[#6EC9F2] dark:[&:not(:has(.overlay))]:bg-[#03212F]"
    ]
  end

  defp color_variant("bordered", "misc") do
    [
      "text-[#653C94] border-[#653C94] [&:not(:has(.overlay))]:bg-[#F6F0FE]",
      "dark:text-[#CBA2FA] dark:border-[#CBA2FA] dark:[&:not(:has(.overlay))]:bg-[#221431]"
    ]
  end

  defp color_variant("bordered", "dawn") do
    [
      "text-[#7E4B2A] border-[#7E4B2A] [&:not(:has(.overlay))]:bg-[#FBF2ED]",
      "dark:text-[#E4B190] dark:border-[#E4B190] dark:[&:not(:has(.overlay))]:bg-[#2A190E]"
    ]
  end

  defp color_variant("bordered", "silver") do
    [
      "text-[#727272] border-[#727272] [&:not(:has(.overlay))]:bg-[#F3F3F3]",
      "dark:text-[#BBBBBB] dark:border-[#BBBBBB] dark:[&:not(:has(.overlay))]:bg-[#4B4B4B]"
    ]
  end

  defp color_variant("transparent", "natural") do
    [
      "text-[#4B4B4B] dark:text-[#DDDDDD]"
    ]
  end

  defp color_variant("transparent", "primary") do
    [
      "text-[#007F8C] dark:text-[#01B8CA]"
    ]
  end

  defp color_variant("transparent", "secondary") do
    [
      "text-[#266EF1] dark:text-[#6DAAFB]"
    ]
  end

  defp color_variant("transparent", "success") do
    [
      "text-[#0E8345] dark:text-[#06C167]"
    ]
  end

  defp color_variant("transparent", "warning") do
    [
      "text-[#CA8D01] dark:text-[#FDC034]"
    ]
  end

  defp color_variant("transparent", "danger") do
    [
      "text-[#DE1135] dark:text-[#FC7F79]"
    ]
  end

  defp color_variant("transparent", "info") do
    [
      "text-[#0B84BA] dark:text-[#3EB7ED]"
    ]
  end

  defp color_variant("transparent", "misc") do
    [
      "text-[#8750C5] dark:text-[#BA83F9]"
    ]
  end

  defp color_variant("transparent", "dawn") do
    [
      "text-[#A86438] dark:text-[#DB976B]"
    ]
  end

  defp color_variant("transparent", "silver") do
    [
      "text-[#868686] dark:text-[#A6A6A6]"
    ]
  end

  defp color_variant("gradient", "natural") do
    [
      "[&:not(:has(.overlay))]:bg-gradient-to-br from-[#282828] to-[#727272] text-white",
      "dark:from-[#A6A6A6] dark:to-[#FFFFFF] dark:text-black"
    ]
  end

  defp color_variant("gradient", "primary") do
    [
      "[&:not(:has(.overlay))]:bg-gradient-to-br from-[#016974] to-[#01B8CA] text-white",
      "dark:from-[#01B8CA] dark:to-[#B0E7EF] dark:text-black"
    ]
  end

  defp color_variant("gradient", "secondary") do
    [
      "[&:not(:has(.overlay))]:bg-gradient-to-br from-[#175BCC] to-[#6DAAFB] text-white",
      "dark:from-[#6DAAFB] dark:to-[#CDDEFF] dark:text-black"
    ]
  end

  defp color_variant("gradient", "success") do
    [
      "[&:not(:has(.overlay))]:bg-gradient-to-br from-[#166C3B] to-[#06C167] text-white",
      "dark:from-[#06C167] dark:to-[#B1EAC2] dark:text-black"
    ]
  end

  defp color_variant("gradient", "warning") do
    [
      "[&:not(:has(.overlay))]:bg-gradient-to-br from-[#976A01] to-[#FDC034] text-white",
      "dark:from-[#FDC034] dark:to-[#FEDF99] dark:text-black"
    ]
  end

  defp color_variant("gradient", "danger") do
    [
      "[&:not(:has(.overlay))]:bg-gradient-to-br from-[#BB032A] to-[#FC7F79] text-white",
      "dark:from-[#FC7F79] dark:to-[#FFD2CD] dark:text-black"
    ]
  end

  defp color_variant("gradient", "info") do
    [
      "[&:not(:has(.overlay))]:bg-gradient-to-br from-[#08638C] to-[#3EB7ED] text-white",
      "dark:from-[#3EB7ED] dark:to-[#9FDBF6] dark:text-black"
    ]
  end

  defp color_variant("gradient", "misc") do
    [
      "[&:not(:has(.overlay))]:bg-gradient-to-br from-[#653C94] to-[#BA83F9] text-white",
      "dark:from-[#BA83F9] dark:to-[#DDC1FC] dark:text-black"
    ]
  end

  defp color_variant("gradient", "dawn") do
    [
      "[&:not(:has(.overlay))]:bg-gradient-to-br from-[#7E4B2A] to-[#DB976B] text-white",
      "dark:from-[#DB976B] dark:to-[#EDCBB5] dark:text-black"
    ]
  end

  defp color_variant("gradient", "silver") do
    [
      "[&:not(:has(.overlay))]:bg-gradient-to-br from-[#5E5E5E] to-[#A6A6A6] text-white",
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
