defmodule UroWeb.Components.Chat do
  @moduledoc """
  `UroWeb.Components.Chat` is a Phoenix LiveView component module for creating customizable chat interfaces.

  This module provides components to display chat messages with various styles, colors,
  sizes, and configurations. The main component, `chat/1`, acts as a container for chat
  messages, and `chat_section/1` is used to render individual chat messages with optional
  metadata and status information.
  """
  use Phoenix.Component

  @doc """
  The `chat` component is used to create a chat message container with customizable attributes such
  as `variant`, `color`, and `position`.

  It supports different layouts for normal and flipped chat bubbles and allows for nested content
  using an inner block for flexible message design.

  ## Examples

  ```elixir
  <.chat>
    <.avatar
      src="example.com/images/1.jpg"
      size="extra_large"
      rounded="full"
      border="small"
    />

    <.chat_section>
      <div class="flex items-center space-x-2 rtl:space-x-reverse">
        <div class="">Bonnie Green</div>
      </div>
      <p class="">
        That's awesome. I think our users will really appreciate the improvements.
      </p>
      <:status time="22:10" deliver="Delivered" />
      <:meta><div class="">Bonnie Green</div></:meta>
    </.chat_section>
    <div><.icon name="hero-ellipsis-vertical" class="size-4" /></div>
  </.chat>

  <.chat position="flipped">
    <.avatar src="https://example.com/picture.jpg" size="extra_large" rounded="full" border="small"/>

    <.chat_section>
      <div class="flex items-center space-x-2 rtl:space-x-reverse">
        <div class="">Bonnie Green</div>
      </div>
      <p class="">
        That's awesome. I think our users will really appreciate the improvements.
      </p>
      <:status time="22:10" deliver="Delivered" />
    </.chat_section>
    <div><.icon name="hero-ellipsis-vertical" class="size-4" /></div>
  </.chat>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :variant, :string, default: "base", doc: "Determines the style"
  attr :color, :string, default: "natural", doc: "Determines color theme"
  attr :border, :string, default: "extra_small", doc: "Determines border style"
  attr :rounded, :string, default: "extra_large", doc: "Determines the border radius"

  attr :size, :string,
    default: "medium",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :space, :string, default: "extra_small", doc: "Space between items"

  attr :position, :string,
    values: ["normal", "flipped"],
    default: "normal",
    doc: "Determines the element position"

  attr :padding, :string, default: "small", doc: "Determines padding for items"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def chat(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "flex items-start gap-3",
        position_class(@position),
        rounded_size(@rounded, @position),
        border_class(@border, @variant),
        color_variant(@variant, @color),
        space_class(@space),
        padding_size(@padding),
        size_class(@size),
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  The `chat_section` component is used to display individual chat messages or sections with customizable
  attributes such as `font_weight` and `class`.

  It supports slots for adding status information and metadata, making it easy to create detailed
  chat message layouts.

  ## Examples

  ```elixir
  <.chat_section>
    <div class="flex items-center space-x-2 rtl:space-x-reverse">
      <div class="">Bonnie Green</div>
    </div>
    <p class="">
      That's awesome. I think our users will really appreciate the improvements.
    </p>
    <:status time="22:10" deliver="Delivered" />
    <:meta><div class="">Bonnie Green</div></:meta>
  </.chat_section>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :status, required: false, doc: "Defines a slot for displaying status information" do
    attr :time, :string, doc: "Displays the time"
    attr :deliver, :string, doc: "Indicates the delivery status"
  end

  slot :meta,
    required: false,
    doc: "Defines a slot for adding custom metadata or additional information"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def chat_section(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "chat-section-bubble leading-1.5 overflow-hidden",
        @font_weight,
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
      <div :for={status <- @status} class="flex items-center justify-between gap-2 text-xs">
        <div :if={status[:time]}>{status[:time]}</div>
        <div :if={status[:deliver]} class="font-semibold">{status[:deliver]}</div>
      </div>

      <div :for={meta <- @meta}>{render_slot(meta)}</div>
    </div>
    """
  end

  defp position_class("normal"), do: "justify-start flex-row"
  defp position_class("flipped"), do: "justify-start flex-row-reverse"
  defp position_class(params) when is_binary(params), do: params

  defp rounded_size("extra_small", "normal") do
    [
      "[&>.chat-section-bubble]:rounded-e-sm [&>.chat-section-bubble]:rounded-es-sm"
    ]
  end

  defp rounded_size("small", "normal") do
    [
      "[&>.chat-section-bubble]:rounded-e [&>.chat-section-bubble]:rounded-es"
    ]
  end

  defp rounded_size("medium", "normal") do
    [
      "[&>.chat-section-bubble]:rounded-e-md [&>.chat-section-bubble]:rounded-es-md"
    ]
  end

  defp rounded_size("large", "normal") do
    [
      "[&>.chat-section-bubble]:rounded-e-lg [&>.chat-section-bubble]:rounded-es-lg"
    ]
  end

  defp rounded_size("extra_large", "normal") do
    [
      "[&>.chat-section-bubble]:rounded-e-xl [&>.chat-section-bubble]:rounded-es-xl"
    ]
  end

  defp rounded_size("extra_small", "flipped") do
    [
      "[&>.chat-section-bubble]:rounded-s-sm [&>.chat-section-bubble]:rounded-ee-sm"
    ]
  end

  defp rounded_size("small", "flipped") do
    [
      "[&>.chat-section-bubble]:rounded-s [&>.chat-section-bubble]:rounded-ee"
    ]
  end

  defp rounded_size("medium", "flipped") do
    [
      "[&>.chat-section-bubble]:rounded-s-md [&>.chat-section-bubble]:rounded-ee-md"
    ]
  end

  defp rounded_size("large", "flipped") do
    [
      "[&>.chat-section-bubble]:rounded-s-lg [&>.chat-section-bubble]:rounded-ee-lg"
    ]
  end

  defp rounded_size("extra_large", "flipped") do
    [
      "[&>.chat-section-bubble]:rounded-s-xl [&>.chat-section-bubble]:rounded-ee-xl"
    ]
  end

  defp rounded_size("none", _), do: nil

  defp rounded_size(params, _) when is_binary(params), do: params

  defp space_class("extra_small"), do: "[&>.chat-section-bubble]:space-y-2"

  defp space_class("small"), do: "[&>.chat-section-bubble]:space-y-3"

  defp space_class("medium"), do: "[&>.chat-section-bubble]:space-y-4"

  defp space_class("large"), do: "[&>.chat-section-bubble]:space-y-5"

  defp space_class("extra_large"), do: "[&>.chat-section-bubble]:space-y-6"

  defp space_class("none"), do: nil

  defp space_class(params) when is_binary(params), do: params

  defp padding_size("extra_small"), do: "[&>.chat-section-bubble]:p-1"

  defp padding_size("small"), do: "[&>.chat-section-bubble]:p-2"

  defp padding_size("medium"), do: "[&>.chat-section-bubble]:p-3"

  defp padding_size("large"), do: "[&>.chat-section-bubble]:p-4"

  defp padding_size("extra_large"), do: "[&>.chat-section-bubble]:p-5"

  defp padding_size(params) when is_binary(params), do: params

  defp border_class(_, variant) when variant in ["default", "shadow", "transparent", "gradient"],
    do: nil

  defp border_class("extra_small", _), do: "[&>.chat-section-bubble]:border"
  defp border_class("small", _), do: "[&>.chat-section-bubble]:border-2"
  defp border_class("medium", _), do: "[&>.chat-section-bubble]:border-[3px]"
  defp border_class("large", _), do: "[&>.chat-section-bubble]:border-4"
  defp border_class("extra_large", _), do: "[&>.chat-section-bubble]:border-[5px]"
  defp border_class("none", _), do: "[&>.chat-section-bubble]:border-0"
  defp border_class(params, _) when is_binary(params), do: params

  defp size_class("extra_small"), do: "text-xs [&>.chat-section-bubble]:max-w-[12rem]"

  defp size_class("small"), do: "text-sm [&>.chat-section-bubble]:max-w-[14rem]"

  defp size_class("medium"), do: "text-base [&>.chat-section-bubble]:max-w-[16rem]"

  defp size_class("large"), do: "text-lg [&>.chat-section-bubble]:max-w-[18rem]"

  defp size_class("extra_large"), do: "text-xl [&>.chat-section-bubble]:max-w-[20rem]"

  defp size_class(params) when is_binary(params), do: params

  defp color_variant("base", _) do
    [
      "[&>.chat-section-bubble]:bg-white [&>.chat-section-bubble]:text-[#09090b]",
      "[&>.chat-section-bubble]:border-[#e4e4e7] [&>.chat-section-bubble]:shadow-sm",
      "dark:[&>.chat-section-bubble]:bg-[#18181B] dark:[&>.chat-section-bubble]:text-[#FAFAFA]",
      "dark:[&>.chat-section-bubble]:border-[#27272a]"
    ]
  end

  defp color_variant("default", "white") do
    [
      "[&>.chat-section-bubble]:bg-white text-black"
    ]
  end

  defp color_variant("default", "dark") do
    [
      "[&>.chat-section-bubble]:bg-[#282828] [&>.chat-section-bubble]:text-white"
    ]
  end

  defp color_variant("default", "natural") do
    [
      "[&>.chat-section-bubble]:bg-[#4B4B4B] [&>.chat-section-bubble]:text-white",
      "dark:[&>.chat-section-bubble]:bg-[#DDDDDD] dark:[&>.chat-section-bubble]:text-black"
    ]
  end

  defp color_variant("default", "primary") do
    [
      "[&>.chat-section-bubble]:bg-[#007F8C] [&>.chat-section-bubble]:text-white",
      "dark:[&>.chat-section-bubble]:bg-[#01B8CA] dark:[&>.chat-section-bubble]:text-black"
    ]
  end

  defp color_variant("default", "secondary") do
    [
      "[&>.chat-section-bubble]:bg-[#266EF1] [&>.chat-section-bubble]:text-white",
      "dark:[&>.chat-section-bubble]:bg-[#6DAAFB] dark:[&>.chat-section-bubble]:text-black"
    ]
  end

  defp color_variant("default", "success") do
    [
      "[&>.chat-section-bubble]:bg-[#0E8345] [&>.chat-section-bubble]:text-white",
      "dark:[&>.chat-section-bubble]:bg-[#06C167] dark:[&>.chat-section-bubble]:text-black"
    ]
  end

  defp color_variant("default", "warning") do
    [
      "[&>.chat-section-bubble]:bg-[#CA8D01] [&>.chat-section-bubble]:text-white",
      "dark:[&>.chat-section-bubble]:bg-[#FDC034] dark:[&>.chat-section-bubble]:text-black"
    ]
  end

  defp color_variant("default", "danger") do
    [
      "[&>.chat-section-bubble]:bg-[#DE1135] [&>.chat-section-bubble]:text-white",
      "dark:[&>.chat-section-bubble]:bg-[#FC7F79] dark:[&>.chat-section-bubble]:text-black"
    ]
  end

  defp color_variant("default", "info") do
    [
      "[&>.chat-section-bubble]:bg-[#0B84BA] [&>.chat-section-bubble]:text-white",
      "dark:[&>.chat-section-bubble]:bg-[#3EB7ED] dark:[&>.chat-section-bubble]:text-black"
    ]
  end

  defp color_variant("default", "misc") do
    [
      "[&>.chat-section-bubble]:bg-[#8750C5] [&>.chat-section-bubble]:text-white",
      "dark:[&>.chat-section-bubble]:bg-[#BA83F9] dark:[&>.chat-section-bubble]:text-black"
    ]
  end

  defp color_variant("default", "dawn") do
    [
      "[&>.chat-section-bubble]:bg-[#A86438] [&>.chat-section-bubble]:text-white",
      "dark:[&>.chat-section-bubble]:bg-[#DB976B] dark:[&>.chat-section-bubble]:text-black"
    ]
  end

  defp color_variant("default", "silver") do
    [
      "[&>.chat-section-bubble]:bg-[#868686] [&>.chat-section-bubble]:text-white",
      "dark:[&>.chat-section-bubble]:bg-[#A6A6A6] dark:[&>.chat-section-bubble]:text-black"
    ]
  end

  defp color_variant("outline", "natural") do
    [
      "[&>.chat-section-bubble]:text-[#4B4B4B] [&>.chat-section-bubble]:border-[#4B4B4B]",
      "dark:[&>.chat-section-bubble]:text-[#DDDDDD] dark:[&>.chat-section-bubble]:border-[#DDDDDD]"
    ]
  end

  defp color_variant("outline", "primary") do
    [
      "[&>.chat-section-bubble]:text-[#007F8C] [&>.chat-section-bubble]:border-[#007F8C] ",
      "dark:[&>.chat-section-bubble]:text-[#01B8CA] dark:[&>.chat-section-bubble]:border-[#01B8CA]"
    ]
  end

  defp color_variant("outline", "secondary") do
    [
      "[&>.chat-section-bubble]:text-[#266EF1] [&>.chat-section-bubble]:border-[#266EF1]",
      "dark:[&>.chat-section-bubble]:text-[#6DAAFB] dark:[&>.chat-section-bubble]:border-[#6DAAFB]"
    ]
  end

  defp color_variant("outline", "success") do
    [
      "[&>.chat-section-bubble]:text-[#0E8345] [&>.chat-section-bubble]:border-[#0E8345]",
      "dark:[&>.chat-section-bubble]:text-[#06C167] dark:[&>.chat-section-bubble]:border-[#06C167]"
    ]
  end

  defp color_variant("outline", "warning") do
    [
      "[&>.chat-section-bubble]:text-[#CA8D01] [&>.chat-section-bubble]:border-[#CA8D01]",
      "dark:[&>.chat-section-bubble]:text-[#FDC034] dark:[&>.chat-section-bubble]:border-[#FDC034]"
    ]
  end

  defp color_variant("outline", "danger") do
    [
      "[&>.chat-section-bubble]:text-[#DE1135] [&>.chat-section-bubble]:border-[#DE1135]",
      "dark:[&>.chat-section-bubble]:text-[#FC7F79] dark:[&>.chat-section-bubble]:border-[#FC7F79]"
    ]
  end

  defp color_variant("outline", "info") do
    [
      "[&>.chat-section-bubble]:text-[#0B84BA] [&>.chat-section-bubble]:border-[#0B84BA]",
      "dark:[&>.chat-section-bubble]:text-[#3EB7ED] dark:[&>.chat-section-bubble]:border-[#3EB7ED]"
    ]
  end

  defp color_variant("outline", "misc") do
    [
      "[&>.chat-section-bubble]:text-[#8750C5] [&>.chat-section-bubble]:border-[#8750C5]",
      "dark:[&>.chat-section-bubble]:text-[#BA83F9] dark:[&>.chat-section-bubble]:border-[#BA83F9]"
    ]
  end

  defp color_variant("outline", "dawn") do
    [
      "[&>.chat-section-bubble]:text-[#A86438] [&>.chat-section-bubble]:border-[#A86438]",
      "dark:[&>.chat-section-bubble]:text-[#DB976B] dark:[&>.chat-section-bubble]:border-[#DB976B]"
    ]
  end

  defp color_variant("outline", "silver") do
    [
      "[&>.chat-section-bubble]:text-[#868686] [&>.chat-section-bubble]:border-[#868686]",
      "dark:[&>.chat-section-bubble]:text-[#A6A6A6] dark:[&>.chat-section-bubble]:border-[#A6A6A6]"
    ]
  end

  defp color_variant("shadow", "natural") do
    [
      "[&>.chat-section-bubble]:bg-[#4B4B4B] [&>.chat-section-bubble]:text-white",
      "dark:[&>.chat-section-bubble]:bg-[#DDDDDD] dark:[&>.chat-section-bubble]:text-black",
      "[&>.chat-section-bubble]:shadow-[0px_4px_6px_-4px_rgba(134,134,134,0.5)]",
      "[&>.chat-section-bubble]:shadow-[0px_10px_15px_-3px_rgba(134,134,134,0.5)] [&>.chat-section-bubble]:dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "primary") do
    [
      "[&>.chat-section-bubble]:bg-[#007F8C] [&>.chat-section-bubble]:text-white",
      "dark:[&>.chat-section-bubble]:bg-[#01B8CA] dark:[&>.chat-section-bubble]:text-black",
      "[&>.chat-section-bubble]:shadow-[0px_4px_6px_-4px_rgba(0,149,164,0.5)]",
      "[&>.chat-section-bubble]:shadow-[0px_10px_15px_-3px_rgba(0,149,164,0.5)] [&>.chat-section-bubble]:dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "secondary") do
    [
      "[&>.chat-section-bubble]:bg-[#266EF1] [&>.chat-section-bubble]:text-white",
      "dark:[&>.chat-section-bubble]:bg-[#6DAAFB] dark:[&>.chat-section-bubble]:text-black",
      "[&>.chat-section-bubble]:shadow-[0px_4px_6px_-4px_rgba(6,139,238,0.5)]",
      "[&>.chat-section-bubble]:shadow-[0px_10px_15px_-3px_rgba(6,139,238,0.5)] [&>.chat-section-bubble]:dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "success") do
    [
      "[&>.chat-section-bubble]:bg-[#0E8345] [&>.chat-section-bubble]:text-white",
      "dark:[&>.chat-section-bubble]:bg-[#06C167] dark:[&>.chat-section-bubble]:text-black",
      "[&>.chat-section-bubble]:shadow-[0px_4px_6px_-4px_rgba(0,154,81,0.5)]",
      "[&>.chat-section-bubble]:shadow-[0px_10px_15px_-3px_rgba(0,154,81,0.5)] [&>.chat-section-bubble]:dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "warning") do
    [
      "[&>.chat-section-bubble]:bg-[#CA8D01] [&>.chat-section-bubble]:text-white",
      "dark:[&>.chat-section-bubble]:bg-[#FDC034] dark:[&>.chat-section-bubble]:text-black",
      "[&>.chat-section-bubble]:shadow-[0px_4px_6px_-4px_rgba(252,176,1,0.5)]",
      "[&>.chat-section-bubble]:shadow-[0px_10px_15px_-3px_rgba(252,176,1,0.5)] [&>.chat-section-bubble]:dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "danger") do
    [
      "[&>.chat-section-bubble]:bg-[#DE1135] [&>.chat-section-bubble]:text-white",
      "dark:[&>.chat-section-bubble]:bg-[#FC7F79] dark:[&>.chat-section-bubble]:text-black",
      "[&>.chat-section-bubble]:shadow-[0px_4px_6px_-4px_rgba(248,52,70,0.5)]",
      "[&>.chat-section-bubble]:shadow-[0px_10px_15px_-3px_rgba(248,52,70,0.5)] [&>.chat-section-bubble]:dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "info") do
    [
      "[&>.chat-section-bubble]:bg-[#0B84BA] [&>.chat-section-bubble]:text-white",
      "dark:[&>.chat-section-bubble]:bg-[#3EB7ED] dark:[&>.chat-section-bubble]:text-black",
      "[&>.chat-section-bubble]:shadow-[0px_4px_6px_-4px_rgba(14,165,233,0.5)]",
      "[&>.chat-section-bubble]:shadow-[0px_10px_15px_-3px_rgba(14,165,233,0.5)] [&>.chat-section-bubble]:dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "misc") do
    [
      "[&>.chat-section-bubble]:bg-[#8750C5] [&>.chat-section-bubble]:text-white",
      "dark:[&>.chat-section-bubble]:bg-[#BA83F9] dark:[&>.chat-section-bubble]:text-black",
      "[&>.chat-section-bubble]:shadow-[0px_4px_6px_-4px_rgba(169,100,247,0.5)]",
      "[&>.chat-section-bubble]:shadow-[0px_10px_15px_-3px_rgba(169,100,247,0.5)] [&>.chat-section-bubble]:dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "dawn") do
    [
      "[&>.chat-section-bubble]:bg-[#A86438] [&>.chat-section-bubble]:text-white",
      "dark:[&>.chat-section-bubble]:bg-[#DB976B] dark:[&>.chat-section-bubble]:text-black",
      "[&>.chat-section-bubble]:shadow-[0px_4px_6px_-4px_rgba(210,125,70,0.5)]",
      "[&>.chat-section-bubble]:shadow-[0px_10px_15px_-3px_rgba(210,125,70,0.5)] [&>.chat-section-bubble]:dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "silver") do
    [
      "[&>.chat-section-bubble]:bg-[#868686] [&>.chat-section-bubble]:text-white",
      "dark:[&>.chat-section-bubble]:bg-[#A6A6A6] dark:[&>.chat-section-bubble]:text-black",
      "[&>.chat-section-bubble]:shadow-[0px_4px_6px_-4px_rgba(134,134,134,0.5)]",
      "[&>.chat-section-bubble]:shadow-[0px_10px_15px_-3px_rgba(134,134,134,0.5)] [&>.chat-section-bubble]:dark:shadow-none"
    ]
  end

  defp color_variant("bordered", "white") do
    [
      "[&>.chat-section-bubble]:bg-white [&>.chat-section-bubble]:text-black [&>.chat-section-bubble]:border-[#DDDDDD]"
    ]
  end

  defp color_variant("bordered", "dark") do
    [
      "[&>.chat-section-bubble]:bg-[#282828] [&>.chat-section-bubble]:text-white [&>.chat-section-bubble]:border-[#727272]"
    ]
  end

  defp color_variant("bordered", "natural") do
    [
      "[&>.chat-section-bubble]:text-[#282828] [&>.chat-section-bubble]:border-[#282828] [&>.chat-section-bubble]:bg-[#F3F3F3]",
      "dark:[&>.chat-section-bubble]:text-[#E8E8E8] dark:[&>.chat-section-bubble]:border-[#E8E8E8] dark:[&>.chat-section-bubble]:bg-[#4B4B4B]"
    ]
  end

  defp color_variant("bordered", "primary") do
    [
      "[&>.chat-section-bubble]:text-[#016974] [&>.chat-section-bubble]:border-[#016974] [&>.chat-section-bubble]:bg-[#E2F8FB]",
      "dark:[&>.chat-section-bubble]:text-[#77D5E3] dark:[&>.chat-section-bubble]:border-[#77D5E3] dark:[&>.chat-section-bubble]:bg-[#002D33]"
    ]
  end

  defp color_variant("bordered", "secondary") do
    [
      "[&>.chat-section-bubble]:text-[#175BCC] [&>.chat-section-bubble]:border-[#175BCC] [&>.chat-section-bubble]:bg-[#EFF4FE]",
      "dark:[&>.chat-section-bubble]:text-[#A9C9FF] dark:[&>.chat-section-bubble]:border-[#A9C9FF] dark:[&>.chat-section-bubble]:bg-[#002661]"
    ]
  end

  defp color_variant("bordered", "success") do
    [
      "[&>.chat-section-bubble]:text-[#166C3B] [&>.chat-section-bubble]:border-[#166C3B] [&>.chat-section-bubble]:bg-[#EAF6ED]",
      "dark:[&>.chat-section-bubble]:text-[#7FD99A] dark:[&>.chat-section-bubble]:border-[#7FD99A] dark:[&>.chat-section-bubble]:bg-[#002F14]"
    ]
  end

  defp color_variant("bordered", "warning") do
    [
      "[&>.chat-section-bubble]:text-[#976A01] [&>.chat-section-bubble]:border-[#976A01] [&>.chat-section-bubble]:bg-[#FFF7E6]",
      "dark:[&>.chat-section-bubble]:text-[#FDD067] dark:[&>.chat-section-bubble]:border-[#FDD067] dark:[&>.chat-section-bubble]:bg-[#322300]"
    ]
  end

  defp color_variant("bordered", "danger") do
    [
      "[&>.chat-section-bubble]:text-[#BB032A] [&>.chat-section-bubble]:border-[#BB032A] [&>.chat-section-bubble]:bg-[#FFF0EE]",
      "dark:[&>.chat-section-bubble]:text-[#FFB2AB] dark:[&>.chat-section-bubble]:border-[#FFB2AB] dark:[&>.chat-section-bubble]:bg-[#520810]"
    ]
  end

  defp color_variant("bordered", "info") do
    [
      "[&>.chat-section-bubble]:text-[#0B84BA] [&>.chat-section-bubble]:border-[#0B84BA] [&>.chat-section-bubble]:bg-[#E7F6FD]",
      "dark:[&>.chat-section-bubble]:text-[#6EC9F2] dark:[&>.chat-section-bubble]:border-[#6EC9F2] dark:[&>.chat-section-bubble]:bg-[#03212F]"
    ]
  end

  defp color_variant("bordered", "misc") do
    [
      "[&>.chat-section-bubble]:text-[#653C94] [&>.chat-section-bubble]:border-[#653C94] [&>.chat-section-bubble]:bg-[#F6F0FE]",
      "dark:[&>.chat-section-bubble]:text-[#CBA2FA] dark:[&>.chat-section-bubble]:border-[#CBA2FA] dark:[&>.chat-section-bubble]:bg-[#221431]"
    ]
  end

  defp color_variant("bordered", "dawn") do
    [
      "[&>.chat-section-bubble]:text-[#7E4B2A] [&>.chat-section-bubble]:border-[#7E4B2A] [&>.chat-section-bubble]:bg-[#FBF2ED]",
      "dark:[&>.chat-section-bubble]:text-[#E4B190] dark:[&>.chat-section-bubble]:border-[#E4B190] dark:[&>.chat-section-bubble]:bg-[#2A190E]"
    ]
  end

  defp color_variant("bordered", "silver") do
    [
      "[&>.chat-section-bubble]:text-[#727272] [&>.chat-section-bubble]:border-[#727272] [&>.chat-section-bubble]:bg-[#F3F3F3]",
      "dark:[&>.chat-section-bubble]:text-[#BBBBBB] dark:[&>.chat-section-bubble]:border-[#BBBBBB] dark:[&>.chat-section-bubble]:bg-[#4B4B4B]"
    ]
  end

  defp color_variant("transparent", "natural") do
    [
      "[&>.chat-section-bubble]:text-[#4B4B4B] dark:[&>.chat-section-bubble]:text-[#DDDDDD]"
    ]
  end

  defp color_variant("transparent", "primary") do
    [
      "[&>.chat-section-bubble]:text-[#007F8C] dark:[&>.chat-section-bubble]:text-[#01B8CA]"
    ]
  end

  defp color_variant("transparent", "secondary") do
    [
      "[&>.chat-section-bubble]:text-[#266EF1] dark:[&>.chat-section-bubble]:text-[#6DAAFB]"
    ]
  end

  defp color_variant("transparent", "success") do
    [
      "[&>.chat-section-bubble]:text-[#0E8345] dark:[&>.chat-section-bubble]:text-[#06C167]"
    ]
  end

  defp color_variant("transparent", "warning") do
    [
      "[&>.chat-section-bubble]:text-[#CA8D01] dark:[&>.chat-section-bubble]:text-[#FDC034]"
    ]
  end

  defp color_variant("transparent", "danger") do
    [
      "[&>.chat-section-bubble]:text-[#DE1135] dark:[&>.chat-section-bubble]:text-[#FC7F79]"
    ]
  end

  defp color_variant("transparent", "info") do
    [
      "[&>.chat-section-bubble]:text-[#0B84BA] dark:[&>.chat-section-bubble]:text-[#3EB7ED]"
    ]
  end

  defp color_variant("transparent", "misc") do
    [
      "[&>.chat-section-bubble]:text-[#8750C5] dark:[&>.chat-section-bubble]:text-[#BA83F9]"
    ]
  end

  defp color_variant("transparent", "dawn") do
    [
      "[&>.chat-section-bubble]:text-[#A86438] dark:[&>.chat-section-bubble]:text-[#DB976B]"
    ]
  end

  defp color_variant("transparent", "silver") do
    [
      "[&>.chat-section-bubble]:text-[#868686] dark:[&>.chat-section-bubble]:text-[#A6A6A6]"
    ]
  end

  defp color_variant("gradient", "natural") do
    [
      "[&>.chat-section-bubble]:bg-gradient-to-br from-[#282828] to-[#727272] [&>.chat-section-bubble]:text-white",
      "dark:from-[#A6A6A6] dark:to-[#FFFFFF] dark:[&>.chat-section-bubble]:text-black"
    ]
  end

  defp color_variant("gradient", "primary") do
    [
      "[&>.chat-section-bubble]:bg-gradient-to-br from-[#016974] to-[#01B8CA] [&>.chat-section-bubble]:text-white",
      "dark:from-[#01B8CA] dark:to-[#B0E7EF] dark:[&>.chat-section-bubble]:text-black"
    ]
  end

  defp color_variant("gradient", "secondary") do
    [
      "[&>.chat-section-bubble]:bg-gradient-to-br from-[#175BCC] to-[#6DAAFB] [&>.chat-section-bubble]:text-white",
      "dark:from-[#6DAAFB] dark:to-[#CDDEFF] dark:[&>.chat-section-bubble]:text-black"
    ]
  end

  defp color_variant("gradient", "success") do
    [
      "[&>.chat-section-bubble]:bg-gradient-to-br from-[#166C3B] to-[#06C167] [&>.chat-section-bubble]:text-white",
      "dark:from-[#06C167] dark:to-[#B1EAC2] dark:[&>.chat-section-bubble]:text-black"
    ]
  end

  defp color_variant("gradient", "warning") do
    [
      "[&>.chat-section-bubble]:bg-gradient-to-br from-[#976A01] to-[#FDC034] [&>.chat-section-bubble]:text-white",
      "dark:from-[#FDC034] dark:to-[#FEDF99] dark:[&>.chat-section-bubble]:text-black"
    ]
  end

  defp color_variant("gradient", "danger") do
    [
      "[&>.chat-section-bubble]:bg-gradient-to-br from-[#BB032A] to-[#FC7F79] [&>.chat-section-bubble]:text-white",
      "dark:from-[#FC7F79] dark:to-[#FFD2CD] dark:[&>.chat-section-bubble]:text-black"
    ]
  end

  defp color_variant("gradient", "info") do
    [
      "[&>.chat-section-bubble]:bg-gradient-to-br from-[#08638C] to-[#3EB7ED] [&>.chat-section-bubble]:text-white",
      "dark:from-[#3EB7ED] dark:to-[#9FDBF6] dark:[&>.chat-section-bubble]:text-black"
    ]
  end

  defp color_variant("gradient", "misc") do
    [
      "[&>.chat-section-bubble]:bg-gradient-to-br from-[#653C94] to-[#BA83F9] [&>.chat-section-bubble]:text-white",
      "dark:from-[#BA83F9] dark:to-[#DDC1FC] dark:[&>.chat-section-bubble]:text-black"
    ]
  end

  defp color_variant("gradient", "dawn") do
    [
      "[&>.chat-section-bubble]:bg-gradient-to-br from-[#7E4B2A] to-[#DB976B] [&>.chat-section-bubble]:text-white",
      "dark:from-[#DB976B] dark:to-[#EDCBB5] dark:[&>.chat-section-bubble]:text-black"
    ]
  end

  defp color_variant("gradient", "silver") do
    [
      "[&>.chat-section-bubble]:bg-gradient-to-br from-[#5E5E5E] to-[#A6A6A6] [&>.chat-section-bubble]:text-white",
      "dark:from-[#868686] dark:to-[#BBBBBB] dark:[&>.chat-section-bubble]:text-black"
    ]
  end

  defp color_variant(params, _) when is_binary(params), do: params
end
