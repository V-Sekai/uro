defmodule UroWeb.Components.Popover do
  @moduledoc """
  The `UroWeb.Components.Popover` module provides a versatile popover component for Phoenix LiveView
  applications. It allows developers to create interactive and visually appealing popover elements
  with various customization options.

  This component supports different display configurations, such as inline and block styles, and
  can be triggered by various user interactions like clicks or hover events. The popover can be
  styled using predefined color schemes and variants, including options for shadowed elements.

  The module also offers control over positioning, size, and spacing of the popover content, making
  it adaptable to different use cases. It is built to be highly configurable while maintaining a
  consistent design system across the application.

  By utilizing `slots`, it allows developers to include custom content within the popover and
  trigger elements, enhancing its flexibility and usability for complex UI scenarios.
  """
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  @doc """
  Renders a customizable `popover` component that can display additional information when an element is
  hovered or clicked.

  You can choose between inline and block rendering, and include rich content within the popover.

  ## Examples

  ```elixir
  <p>
    Due to its central geographic location in Southern Europe,
    <.popover inline clickable>
      <:trigger trigger_id="popover-1" inline class="text-blue-400">Italy</:trigger>
      <:content
        id="popover-1"
        rounded="large"
        width="quadruple_large"
        color="light"
        padding="none"
        class="grid grid-cols-5"
        inline
      >
        <span class="block p-2 space-y-5 col-span-3">
          <span class="font-semibold block">About Italy</span>
          <span class="block">
            Italy is located in the middle of the Mediterranean Sea, in Southern Europe,
            and it is also considered part of Western Europe. It is a unitary parliamentary
            republic with Rome as its capital and largest city.
          </span>
          <a href="/" class="block text-blue-400">Read more <.icon name="hero-link" /></a>
        </span>
        <img
          src="https://example.com/italy.png"
          class="h-full w-full col-span-2"
          alt="Map of Italy"
        />
      </:content>
    </.popover>
    has historically been home to myriad peoples and cultures. In addition to the various ancient peoples dispersed throughout what is now modern-day Italy, the most predominant being the Indo-European Italic peoples who gave the peninsula its name, beginning from the classical era, Phoenicians and Carthaginians founded colonies mostly in insular Italy.
  </p>

  <.popover clickable>
    <:trigger trigger_id="popover-2" class="text-blue-400">Hover or Click here</:trigger>
    <:content id="popover-2" color="light" rounded="large" padding="medium">
      <div class="p-4">
        <h4 class="text-lg font-semibold">Popover Title</h4>
        <p class="mt-2">This is a simple popover example with content that can be customized.</p>
      </div>
    </:content>
  </.popover>
  ```
  """
  @doc type: :component
  attr :id, :string,
    required: true,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :inline, :boolean, default: false, doc: "Determines whether this element is inline"

  attr :clickable, :boolean,
    default: false,
    doc: "Determines if the element can be activated on click"

  attr :position, :string, default: "top", doc: "Determines the element position"
  attr :variant, :string, default: "base", doc: "Determines the style"
  attr :color, :string, default: "natural", doc: "Determines color theme"
  attr :rounded, :string, default: "", doc: "Determines the border radius"
  attr :show_arrow, :boolean, default: true, doc: "Show or hide arrow of popover"
  attr :border, :string, default: "extra_small", doc: "Determines border style"

  attr :size, :string,
    default: "",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :space, :string, default: "", doc: "Space between items"
  attr :width, :string, default: "extra_large", doc: "Determines the element width"
  attr :text_position, :string, default: "start", doc: "Determines the element' text position"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :padding, :string, default: "", doc: "Determines padding for items"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  slot :content, required: false do
    attr :class, :string, doc: "Custom CSS class for additional styling"
  end

  slot :trigger, required: false do
    attr :class, :string, doc: "Custom CSS class for additional styling"
  end

  def popover(assigns) do
    ~H"""
    <span
      :if={@inline}
      id={@id}
      class={[
        "inline-block relative w-fit",
        "[&_.popover-content]:invisible [&_.popover-content]:opacity-0",
        "[&_.popover-content.show-popover]:visible [&_.popover-content.show-popover]:opacity-100",
        !@clickable && tirgger_popover(),
        @class
      ]}
      {@rest}
    >
      <span
        :for={trigger <- @trigger}
        phx-click-away={JS.remove_class("show-popover", to: "##{@id}-popover-content")}
        phx-click={JS.toggle_class("show-popover", to: "##{@id}-popover-content")}
        class={["inline-block cursor-pointer popover-trigger", trigger[:class]]}
        {@rest}
      >
        {render_slot(trigger)}
      </span>

      <span
        :for={content <- @content}
        id={"#{@id}-popover-content"}
        role="dialog"
        class={[
          "popover-content absolute z-10 w-full",
          "transition-all ease-in-out delay-100 duratio-500",
          space_class(@space),
          color_variant(@variant, @color),
          rounded_size(@rounded),
          size_class(@size),
          position_class(@position),
          text_position(@text_position),
          @variant == "bordered" || (@variant == "base" && border_class(@border)),
          width_class(@width),
          wrapper_padding(@padding),
          @font_weight,
          content[:class]
        ]}
        {@rest}
      >
        {render_slot(content)}
        <span
          :if={@show_arrow && @variant != "bordered" && @variant != "base"}
          class={["block absolute size-[8px] bg-inherit rotate-45 -z-[1] popover-arrow"]}
        >
        </span>
      </span>
      {render_slot(@inner_block)}
    </span>

    <div
      :if={!@inline}
      id={@id}
      class={[
        "relative w-fit",
        "[&_.popover-content]:invisible [&_.popover-content]:opacity-0",
        "[&_.popover-content.show-popover]:visible [&_.popover-content.show-popover]:opacity-100",
        !@clickable && tirgger_popover(),
        @class
      ]}
      {@rest}
    >
      <div
        :for={trigger <- @trigger}
        phx-click-away={JS.remove_class("show-popover", to: "##{@id}-popover-content")}
        phx-click={JS.toggle_class("show-popover", to: "##{@id}-popover-content")}
        class={["cursor-pointer popover-trigger", trigger[:class]]}
        {@rest}
      >
        {render_slot(trigger)}
      </div>

      <div
        :for={content <- @content}
        role="dialog"
        id={"#{@id}-popover-content"}
        class={[
          "popover-content absolute z-10 w-full",
          "transition-all ease-in-out delay-100 duratio-500",
          space_class(@space),
          color_variant(@variant, @color),
          rounded_size(@rounded),
          size_class(@size),
          position_class(@position),
          text_position(@text_position),
          @variant == "bordered" || (@variant == "base" && border_class(@border)),
          width_class(@width),
          wrapper_padding(@padding),
          @font_weight,
          content[:class]
        ]}
        {@rest}
      >
        {render_slot(content)}
        <span
          :if={@show_arrow && @variant != "bordered" && @variant != "base"}
          class={["block absolute size-[8px] bg-inherit rotate-45 -z-[1] popover-arrow"]}
        >
        </span>
      </div>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders a `popover_trigger` element, which is used to show or hide a popover content element.
  The trigger can be rendered as either an inline or block element. When the trigger is clicked,
  it toggles the visibility of the associated popover content.

  ## Examples

  ```elixir
  <p>
    Discover more about
    <.popover_trigger trigger_id="popover-1" inline class="text-blue-400">Italy</.popover_trigger>
    by clicking on the name.
    <.popover_content
      id="popover-1"
      inline
      rounded="large"
      width="quadruple_large"
      color="light"
      padding="none"
      class="grid grid-cols-5"
    >
      <span class="block p-2 space-y-5 col-span-3">
        <span class="font-semibold block">About Italy</span>
        <span class="block">
          Italy is located in the middle of the Mediterranean Sea, in Southern Europe, and it is also considered part of Western Europe. It is a unitary parliamentary republic with Rome as its capital and largest city.
        </span>
        <a href="/" class="block text-blue-400">Read more <.icon name="hero-link" /></a>
      </span>
      <img
        src="https://flowbite.com/docs/images/popovers/italy.png"
        class="h-full w-full col-span-2"
        alt="Map of Italy"
      />
    </.popover_content>
  </p>

  <.popover_trigger trigger_id="popover-2" class="text-blue-400">
    Hover or Click here to show the popover
  </.popover_trigger>
  <.popover_content id="popover-2" color="light" rounded="large" padding="medium">
    <div class="p-4">
      <h4 class="text-lg font-semibold">Popover Title</h4>
      <p class="mt-2">This is a simple popover example with content that can be customized.</p>
    </div>
  </.popover_content>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :trigger_id, :string, default: nil, doc: "Identifies what is the triggered element id"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :inline, :boolean, default: false, doc: "Determines whether this element is inline"
  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  def popover_trigger(%{inline: true} = assigns) do
    ~H"""
    <span
      id={@id}
      phx-click-away={@trigger_id && JS.remove_class("show-popover", to: "##{@trigger_id}")}
      phx-click={@trigger_id && JS.toggle_class("show-popover", to: "##{@trigger_id}")}
      class={["inline-block cursor-pointer popover-trigger", @class]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </span>
    """
  end

  def popover_trigger(assigns) do
    ~H"""
    <div
      id={@id}
      phx-click-away={@trigger_id && JS.remove_class("show-popover", to: "##{@trigger_id}")}
      phx-click={@trigger_id && JS.toggle_class("show-popover", to: "##{@trigger_id}")}
      class={["cursor-pointer popover-trigger", @class]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders a `popover_content` element, which displays additional information when the associated
  popover trigger is activated.

  The content can be positioned relative to the trigger and customized with various styles,
  such as color, padding, and size.

  ## Examples

  ```elixir
  <.popover_content id="popover-3" inline position="top" color="dark" rounded="small" padding="small">
    <span class="block text-white p-2">This is a tooltip message!</span>
  </.popover_content>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :inline, :boolean, default: false, doc: "Determines whether this element is inline"
  attr :position, :string, default: "top", doc: "Determines the element position"
  attr :variant, :string, default: "base", doc: "Determines the style"
  attr :color, :string, default: "natural", doc: "Determines color theme"
  attr :rounded, :string, default: "", doc: "Determines the border radius"
  attr :show_arrow, :boolean, default: true, doc: "Show or hide arrow of popover"
  attr :border, :string, default: "extra_small", doc: "Determines border style"

  attr :size, :string,
    default: "",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :space, :string, default: "", doc: "Space between items"
  attr :width, :string, default: "extra_large", doc: "Determines the element width"
  attr :text_position, :string, default: "start", doc: "Determines the element' text position"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :padding, :string, default: "", doc: "Determines padding for items"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def popover_content(%{inline: true} = assigns) do
    ~H"""
    <span
      role="tooltip"
      id={@id}
      class={[
        "popover-content absolute z-10 w-full",
        "transition-all ease-in-out delay-100 duratio-500",
        space_class(@space),
        color_variant(@variant, @color),
        rounded_size(@rounded),
        size_class(@size),
        position_class(@position),
        text_position(@text_position),
        @variant == "bordered" && border_class(@border),
        width_class(@width),
        wrapper_padding(@padding),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <span
        :if={@show_arrow && @variant != "bordered" && @variant != "base"}
        class={["block absolute size-[8px] bg-inherit rotate-45 -z-[1] popover-arrow"]}
      >
      </span>
      {render_slot(@inner_block)}
    </span>
    """
  end

  def popover_content(assigns) do
    ~H"""
    <div
      role="dialog "
      id={@id}
      class={[
        "popover-content absolute z-10 w-full",
        "transition-all ease-in-out delay-100 duratio-500",
        space_class(@space),
        color_variant(@variant, @color),
        rounded_size(@rounded),
        size_class(@size),
        position_class(@position),
        text_position(@text_position),
        @variant == "bordered" && border_class(@border),
        width_class(@width),
        wrapper_padding(@padding),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <span
        :if={@show_arrow && @variant != "bordered" && @variant != "base"}
        class={["block absolute size-[8px] bg-inherit rotate-45 -z-[1] popover-arrow"]}
      >
      </span>
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp tirgger_popover(),
    do: "[&_.popover-content]:hover:visible [&_.popover-content]:hover:opacity-100"

  defp border_class("extra_small"), do: "border"

  defp border_class("small"), do: "border-2"

  defp border_class("medium"), do: "border-[3px]"

  defp border_class("large"), do: "border-4"

  defp border_class("extra_large"), do: "border-[5px]"

  defp border_class("none"), do: nil

  defp border_class(params) when is_binary(params), do: params

  defp rounded_size("extra_small"), do: "rounded-sm"

  defp rounded_size("small"), do: "rounded"

  defp rounded_size("medium"), do: "rounded-md"

  defp rounded_size("large"), do: "rounded-lg"

  defp rounded_size("extra_large"), do: "rounded-xl"

  defp rounded_size(params) when is_binary(params), do: params

  defp position_class("top") do
    [
      "bottom-full left-1/2 -translate-x-1/2 -translate-y-[6px]",
      "[&>.popover-arrow]:-bottom-[4px] [&>.popover-arrow]:-translate-x-1/2 [&>.popover-arrow]:left-1/2"
    ]
  end

  defp position_class("bottom") do
    [
      "top-full left-1/2 -translate-x-1/2 translate-y-[6px]",
      "[&>.popover-arrow]:-top-[4px] [&>.popover-arrow]:-translate-x-1/2 [&>.popover-arrow]:left-1/2"
    ]
  end

  defp position_class("left") do
    [
      "right-full top-1/2 -translate-y-1/2 -translate-x-[6px]",
      "[&>.popover-arrow]:-right-[4px] [&>.popover-arrow]:translate-y-1/2 [&>.popover-arrow]:top-1/3"
    ]
  end

  defp position_class("right") do
    [
      "left-full top-1/2 -translate-y-1/2 translate-x-[6px]",
      "[&>.popover-arrow]:-left-[4px] [&>.popover-arrow]:translate-y-1/2 [&>.popover-arrow]:top-1/3"
    ]
  end

  defp size_class("extra_small"), do: "text-xs max-w-60 [&_.popover-title-icon]:size-3"

  defp size_class("small"), do: "text-sm max-w-64 [&_.popover-title-icon]:size-3.5"

  defp size_class("medium"), do: "text-base max-w-72 [&_.popover-title-icon]:size-4"

  defp size_class("large"), do: "text-lg max-w-80 [&_.popover-title-icon]:size-5"

  defp size_class("extra_large"), do: "text-xl max-w-96 [&_.popover-title-icon]:size-6"

  defp size_class(params) when is_binary(params), do: params

  defp text_position("left"), do: "text-left"
  defp text_position("right"), do: "text-right"
  defp text_position("center"), do: "text-center"
  defp text_position("justify"), do: "text-justify"
  defp text_position("start"), do: "text-start"
  defp text_position("end"), do: "text-end"
  defp text_position(params) when is_binary(params), do: params

  defp width_class("extra_small"), do: "min-w-48"
  defp width_class("small"), do: "min-w-52"
  defp width_class("medium"), do: "min-w-56"
  defp width_class("large"), do: "min-w-60"
  defp width_class("extra_large"), do: "min-w-64"
  defp width_class("double_large"), do: "min-w-72"
  defp width_class("triple_large"), do: "min-w-80"
  defp width_class("quadruple_large"), do: "min-w-96"
  defp width_class(params) when is_binary(params), do: params

  defp wrapper_padding("extra_small") do
    "[&:has(.popover-section)>.popover-section]:p-1 [&:not(:has(.popover-section))]:p-1"
  end

  defp wrapper_padding("small") do
    "[&:has(.popover-section)>.popover-section]:p-2 [&:not(:has(.popover-section))]:p-2"
  end

  defp wrapper_padding("medium") do
    "[&:has(.popover-section)>.popover-section]:p-3 [&:not(:has(.popover-section))]:p-3"
  end

  defp wrapper_padding("large") do
    "[&:has(.popover-section)>.popover-section]:p-4 [&:not(:has(.popover-section))]:p-4"
  end

  defp wrapper_padding("extra_large") do
    "[&:has(.popover-section)>.popover-section]:p-5 [&:not(:has(.popover-section))]:p-5"
  end

  defp wrapper_padding(params) when is_binary(params), do: params

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
end
