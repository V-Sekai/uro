defmodule UroWeb.Components.Badge do
  @moduledoc """
  Provides customizable and flexible badge components for use in Phoenix LiveView.

  The `UroWeb.Components.Badge` module allows you to create badge elements with various styles,
  sizes, and colors. You can add icons, indicators, and dismiss buttons, and configure
  the badge's appearance and behavior using a range of attributes.
  This module also provides helper functions to show and hide badges with smooth transition effects.

  > The badges can be customized further with global attributes such as position, padding, and more.
  > Utilize the built-in helper functions to dynamically show and hide badges as needed.

  This module is designed to be highly customizable, enabling you to create badges
  that fit your application's needs seamlessly.
  """

  use Phoenix.Component
  alias Phoenix.LiveView.JS

  @icon_positions [
    "right_icon",
    "left_icon"
  ]

  @indicator_positions [
    "indicator",
    "right_indicator",
    "left_indicator",
    "top_left_indicator",
    "top_center_indicator",
    "top_right_indicator",
    "middle_left_indicator",
    "middle_right_indicator",
    "bottom_left_indicator",
    "bottom_center_indicator",
    "bottom_right_indicator"
  ]

  @dismiss_positions ["dismiss", "right_dismiss", "left_dismiss"]

  @doc """
  The `badge` component is used to display badges with various styles and indicators.

  It supports customization of attributes such as `variant`, `size`, and `color`,
  along with optional icons and indicator styles.

  ## Examples

  ```elixir
  <.badge icon="hero-arrow-down-tray" color="warning" dismiss indicator>Default warning</.badge>
  <.badge variant="shadow" rounded="large" indicator>Active</.badge>

  <.badge icon="hero-square-2-stack" color="danger" size="medium" bottom_center_indicator pinging>
    Duplicate
  </.badge>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :variant, :string, default: "base", doc: "Determines the style"

  attr :size, :string,
    default: "extra_small",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :rounded, :string, default: "small", doc: "Determines the border radius"

  attr :color, :string, default: "natural", doc: "Determines color theme"
  attr :border, :string, default: "extra_small", doc: "Determines border style"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :icon, :string, default: nil, doc: "Icon displayed alongside of an item"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :icon_class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :content_class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :badge_position, :string, default: "", doc: "poistion of badge"

  attr :indicator_class, :string,
    default: nil,
    doc: "CSS class for additional styling of the badge indicator"

  attr :indicator_size, :string, default: "", doc: "Specifies the size of the badge indicator"

  attr :params, :map,
    default: %{kind: "badge"},
    doc: "A map of additional parameters used for element configuration, such as type or kind"

  attr :rest, :global,
    include:
      ["pinging", "circle"] ++ @dismiss_positions ++ @indicator_positions ++ @icon_positions,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def badge(assigns) do
    ~H"""
    <div
      id={@id}
      class={
        default_classes(@rest[:pinging]) ++
          size_class(@size, @rest[:circle]) ++
          [
            color_variant(@variant, @color),
            border_size(@border, @variant),
            rounded_size(@rounded),
            badge_position(@badge_position),
            @badge_position != "" && "absolute",
            @font_weight,
            @class
          ]
      }
      {drop_rest(@rest)}
    >
      <.badge_dismiss :if={dismiss_position(@rest) == "left"} id={@id} params={@params} />
      <.badge_indicator position="left" size={@indicator_size} class={@indicator_class} {@rest} />
      <.icon :if={icon_position(@icon, @rest) == "left"} name={@icon} class={["badge-icon", @icon_class]} />
      <div class={["leading-5", @content_class]}>{render_slot(@inner_block)}</div>
      <.icon :if={icon_position(@icon, @rest) == "right"} name={@icon} class={["badge-icon", @icon_class]} />
      <.badge_indicator size={@indicator_size} class={@indicator_class} {@rest} />
      <.badge_dismiss :if={dismiss_position(@rest) == "right"} id={@id} params={@params} />
    </div>
    """
  end

  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :dismiss, :boolean,
    default: false,
    doc: "Determines if the badge should include a dismiss button"

  attr :icon_class, :string, default: "size-4", doc: "Determines custom class for the icon"

  attr :params, :map,
    default: %{kind: "badge"},
    doc: "A map of additional parameters used for badge configuration, such as type or kind"

  defp badge_dismiss(assigns) do
    ~H"""
    <button
      class="dismmiss-button inline-flex justify-center items-center w-fit shrink-0"
      phx-click={JS.push("dismiss", value: Map.merge(%{id: @id}, @params)) |> hide_badge("##{@id}")}
    >
      <.icon name="hero-x-mark" class={"#{@icon_class}"} />
    </button>
    """
  end

  @doc type: :component
  attr :position, :string, default: "none", doc: "Determines the element position"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :size, :string,
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  defp badge_indicator(%{position: "left", rest: %{left_indicator: true}} = assigns) do
    ~H"""
    <span class={["indicator", indicator_size(@size), @class]} />
    """
  end

  defp badge_indicator(%{position: "left", rest: %{indicator: true}} = assigns) do
    ~H"""
    <span class={["indicator", indicator_size(@size), @class]} />
    """
  end

  defp badge_indicator(%{position: "none", rest: %{right_indicator: true}} = assigns) do
    ~H"""
    <span class={["indicator", indicator_size(@size), @class]} />
    """
  end

  defp badge_indicator(%{position: "none", rest: %{top_left_indicator: true}} = assigns) do
    ~H"""
    <span class={[
      "indicator",
      indicator_size(@size),
      @class || "absolute -translate-y-1/2 -translate-x-1/2 right-auto top-0 left-0"
    ]} />
    """
  end

  defp badge_indicator(%{position: "none", rest: %{top_center_indicator: true}} = assigns) do
    ~H"""
    <span class={[
      "indicator",
      indicator_size(@size),
      @class || "absolute top-0 -translate-y-1/2 translate-x-1/2 right-1/2"
    ]} />
    """
  end

  defp badge_indicator(%{position: "none", rest: %{top_right_indicator: true}} = assigns) do
    ~H"""
    <span class={[
      "indicator",
      indicator_size(@size),
      @class || "absolute -translate-y-1/2 translate-x-1/2 left-auto top-0 right-0"
    ]} />
    """
  end

  defp badge_indicator(%{position: "none", rest: %{middle_left_indicator: true}} = assigns) do
    ~H"""
    <span class={[
      "indicator",
      indicator_size(@size),
      @class || "absolute -translate-y-1/2 -translate-x-1/2 right-auto left-0 top-2/4"
    ]} />
    """
  end

  defp badge_indicator(%{position: "none", rest: %{middle_right_indicator: true}} = assigns) do
    ~H"""
    <span class={[
      "indicator",
      indicator_size(@size),
      @class || "absolute -translate-y-1/2 translate-x-1/2 left-auto right-0 top-2/4"
    ]} />
    """
  end

  defp badge_indicator(%{position: "none", rest: %{bottom_left_indicator: true}} = assigns) do
    ~H"""
    <span class={[
      "indicator",
      indicator_size(@size),
      @class || "absolute translate-y-1/2 -translate-x-1/2 right-auto bottom-0 left-0"
    ]} />
    """
  end

  defp badge_indicator(%{position: "none", rest: %{bottom_center_indicator: true}} = assigns) do
    ~H"""
    <span class={[
      "indicator",
      indicator_size(@size),
      @class || "absolute translate-y-1/2 translate-x-1/2 bottom-0 right-1/2"
    ]} />
    """
  end

  defp badge_indicator(%{position: "none", rest: %{bottom_right_indicator: true}} = assigns) do
    ~H"""
    <span class={[
      "indicator",
      indicator_size(@size),
      @class || "absolute translate-y-1/2 translate-x-1/2 left-auto bottom-0 right-0"
    ]} />
    """
  end

  defp badge_indicator(assigns) do
    ~H"""
    """
  end

  defp badge_position("top-left"), do: "-translate-y-1/2 -translate-x-1/2 right-auto top-0 left-0"

  defp badge_position("top-right"), do: "-translate-y-1/2 translate-x-1/2 left-auto top-0 right-0"

  defp badge_position("bottom-left"),
    do: "translate-y-1/2 -translate-x-1/2 right-auto bottom-0 left-0"

  defp badge_position("bottom-right"),
    do: "translate-y-1/2 translate-x-1/2 left-auto bottom-0 right-0"

  defp badge_position(params) when is_binary(params), do: params

  defp color_variant("base", _) do
    [
      "bg-white text-[#09090b] border-[#e4e4e7] shadow-sm [&>.indicator]:bg-[#e4e4e7]",
      "dark:bg-[#18181B] dark:text-[#FAFAFA] dark:border-[#27272a] dark:[&>.indicator]:bg-[#27272a]"
    ]
  end

  defp color_variant("default", "white") do
    ["bg-white text-black [&>.indicator]:bg-black"]
  end

  defp color_variant("default", "dark") do
    ["bg-[#282828] text-white [&>.indicator]:bg-white"]
  end

  defp color_variant("default", "natural") do
    [
      "bg-[#4B4B4B] text-white dark:bg-[#DDDDDD] dark:text-black",
      "[&>.indicator]:bg-white dark:[&>.indicator]:bg-black "
    ]
  end

  defp color_variant("default", "primary") do
    [
      "bg-[#007F8C] text-white dark:bg-[#01B8CA] dark:text-black",
      "[&>.indicator]:bg-[#1A535A] dark:[&>.indicator]:bg-[#B0E7EF]"
    ]
  end

  defp color_variant("default", "secondary") do
    [
      "bg-[#266EF1] text-white dark:bg-[#6DAAFB] dark:text-black",
      "[&>.indicator]:bg-[#1948A3] dark:[&>.indicator]:bg-[#CDDEFF]"
    ]
  end

  defp color_variant("default", "success") do
    [
      "bg-[#0E8345] text-white dark:bg-[#06C167] dark:text-black",
      "[&>.indicator]:bg-[#047857] dark:[&>.indicator]:bg-[#B1EAC2]"
    ]
  end

  defp color_variant("default", "warning") do
    [
      "bg-[#CA8D01] text-white dark:bg-[#FDC034] dark:text-black",
      "[&>.indicator]:bg-[#FF8B08] dark:[&>.indicator]:bg-[#FEDF99]"
    ]
  end

  defp color_variant("default", "danger") do
    [
      "bg-[#DE1135] text-white dark:bg-[#FC7F79] dark:text-black",
      "[&>.indicator]:bg-[#E73B3B] dark:[&>.indicator]:bg-[#FFD2CD]"
    ]
  end

  defp color_variant("default", "info") do
    [
      "bg-[#0B84BA] text-white dark:bg-[#3EB7ED] dark:text-black",
      "[&>.indicator]:bg-[#004FC4] dark:[&>.indicator]:bg-[#9FDBF6]"
    ]
  end

  defp color_variant("default", "misc") do
    [
      "bg-[#8750C5] text-white dark:bg-[#BA83F9] dark:text-black",
      "[&>.indicator]:bg-[#52059C] dark:[&>.indicator]:bg-[#DDC1FC]"
    ]
  end

  defp color_variant("default", "dawn") do
    [
      "bg-[#A86438] text-white dark:bg-[#DB976B] dark:text-black",
      "[&>.indicator]:bg-[#4D4137] dark:[&>.indicator]:bg-[#EDCBB5]"
    ]
  end

  defp color_variant("default", "silver") do
    [
      "bg-[#868686] text-white dark:bg-[#A6A6A6] dark:text-black",
      "[&>.indicator]:bg-[#707483] dark:[&>.indicator]:bg-[#DDDDDD]"
    ]
  end

  defp color_variant("outline", "natural") do
    [
      "bg-transparent text-[#4B4B4B] border-[#4B4B4B]",
      "dark:text-[#DDDDDD] dark:border-[#DDDDDD]",
      "[&>.indicator]:bg-black dark:[&>.indicator]:bg-white"
    ]
  end

  defp color_variant("outline", "primary") do
    [
      "bg-transparent text-[#007F8C] border-[#007F8C]",
      "dark:text-[#01B8CA] dark:border-[#01B8CA]",
      "[&>.indicator]:bg-[#1A535A] dark:[&>.indicator]:bg-[#B0E7EF]"
    ]
  end

  defp color_variant("outline", "secondary") do
    [
      "bg-transparent text-[#266EF1] border-[#266EF1]",
      "dark:text-[#6DAAFB] dark:border-[#6DAAFB]",
      "[&>.indicator]:bg-[#1948A3] dark:[&>.indicator]:bg-[#CDDEFF]"
    ]
  end

  defp color_variant("outline", "success") do
    [
      "bg-transparent text-[#0E8345] border-[#0E8345]",
      "dark:text-[#06C167] dark:border-[#06C167]",
      "[&>.indicator]:bg-[#0D572D] dark:[&>.indicator]:bg-[#B1EAC2]"
    ]
  end

  defp color_variant("outline", "warning") do
    [
      "bg-transparent text-[#CA8D01] border-[#CA8D01]",
      "dark:text-[#FDC034] dark:border-[#FDC034]",
      "[&>.indicator]:bg-[#654600] dark:[&>.indicator]:bg-[#FEDF99]"
    ]
  end

  defp color_variant("outline", "danger") do
    [
      "bg-transparent text-[#DE1135] border-[#DE1135]",
      "dark:text-[#FC7F79] dark:border-[#FC7F79]",
      "[&>.indicator]:bg-[#950F22] dark:[&>.indicator]:bg-[#FFD2CD]"
    ]
  end

  defp color_variant("outline", "info") do
    [
      "bg-transparent text-[#0B84BA] border-[#0B84BA]",
      "dark:text-[#3EB7ED] dark:border-[#3EB7ED]",
      "[&>.indicator]:bg-[#06425D] dark:[&>.indicator]:bg-[#9FDBF6]"
    ]
  end

  defp color_variant("outline", "misc") do
    [
      "bg-transparent text-[#8750C5] border-[#8750C5]",
      "dark:text-[#BA83F9] dark:border-[#BA83F9]",
      "[&>.indicator]:bg-[#442863] dark:[&>.indicator]:bg-[#DDC1FC]"
    ]
  end

  defp color_variant("outline", "dawn") do
    [
      "bg-transparent text-[#A86438] border-[#A86438]",
      "dark:text-[#DB976B] dark:border-[#DB976B]",
      "[&>.indicator]:bg-[#54321C] dark:[&>.indicator]:bg-[#EDCBB5]"
    ]
  end

  defp color_variant("outline", "silver") do
    [
      "bg-transparent text-[#868686] border-[#868686]",
      "dark:text-[#A6A6A6] dark:border-[#A6A6A6]",
      "[&>.indicator]:bg-[#5E5E5E] dark:[&>.indicator]:bg-[#DDDDDD]"
    ]
  end

  defp color_variant("transparent", "natural") do
    [
      "bg-transparent text-[#4B4B4B]",
      "dark:text-[#DDDDDD] border-transparent",
      "[&>.indicator]:bg-black dark:[&>.indicator]:bg-white"
    ]
  end

  defp color_variant("transparent", "primary") do
    [
      "bg-transparent text-[#007F8C]",
      "dark:text-[#01B8CA] border-transparent",
      "[&>.indicator]:bg-[#1A535A] dark:[&>.indicator]:bg-[#B0E7EF]"
    ]
  end

  defp color_variant("transparent", "secondary") do
    [
      "bg-transparent text-[#266EF1]",
      "dark:text-[#6DAAFB] border-transparent",
      "[&>.indicator]:bg-[#1948A3] dark:[&>.indicator]:bg-[#CDDEFF]"
    ]
  end

  defp color_variant("transparent", "success") do
    [
      "bg-transparent text-[#0E8345]",
      "dark:text-[#06C167] border-transparent",
      "[&>.indicator]:bg-[#0D572D] dark:[&>.indicator]:bg-[#B1EAC2]"
    ]
  end

  defp color_variant("transparent", "warning") do
    [
      "bg-transparent text-[#CA8D01]",
      "dark:text-[#FDC034] border-transparent",
      "[&>.indicator]:bg-[#654600] dark:[&>.indicator]:bg-[#FEDF99]"
    ]
  end

  defp color_variant("transparent", "danger") do
    [
      "bg-transparent text-[#DE1135]",
      "dark:text-[#FC7F79] border-transparent",
      "[&>.indicator]:bg-[#950F22] dark:[&>.indicator]:bg-[#FFD2CD]"
    ]
  end

  defp color_variant("transparent", "info") do
    [
      "bg-transparent text-[#0B84BA]",
      "dark:text-[#3EB7ED] border-transparent",
      "[&>.indicator]:bg-[#06425D] dark:[&>.indicator]:bg-[#9FDBF6]"
    ]
  end

  defp color_variant("transparent", "misc") do
    [
      "bg-transparent text-[#8750C5]",
      "dark:text-[#BA83F9] border-transparent",
      "[&>.indicator]:bg-[#442863] dark:[&>.indicator]:bg-[#DDC1FC]"
    ]
  end

  defp color_variant("transparent", "dawn") do
    [
      "bg-transparent text-[#A86438]",
      "dark:text-[#DB976B] border-transparent",
      "[&>.indicator]:bg-[#54321C] dark:[&>.indicator]:bg-[#EDCBB5]"
    ]
  end

  defp color_variant("transparent", "silver") do
    [
      "bg-transparent text-[#868686]",
      "dark:text-[#A6A6A6] border-transparent",
      "[&>.indicator]:bg-[#5E5E5E] dark:[&>.indicator]:bg-[#DDDDDD]"
    ]
  end

  defp color_variant("shadow", "natural") do
    [
      "bg-[#4B4B4B] text-white dark:bg-[#DDDDDD] dark:text-black",
      "[&>.indicator]:bg-white dark:[&>.indicator]:bg-black",
      "shadow-[0px_4px_6px_-4px_rgba(134,134,134,0.5)] shadow-[0px_10px_15px_-3px_rgba(134,134,134,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "primary") do
    [
      "bg-[#007F8C] text-white dark:bg-[#01B8CA] dark:text-black",
      "[&>.indicator]:bg-[#1A535A] dark:[&>.indicator]:bg-[#B0E7EF]",
      "shadow-[0px_4px_6px_-4px_rgba(0,149,164,0.5)] shadow-[0px_10px_15px_-3px_rgba(0,149,164,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "secondary") do
    [
      "bg-[#266EF1] text-white dark:bg-[#6DAAFB] dark:text-black",
      "[&>.indicator]:bg-[#1948A3] dark:[&>.indicator]:bg-[#CDDEFF]",
      "shadow-[0px_4px_6px_-4px_rgba(6,139,238,0.5)] shadow-[0px_10px_15px_-3px_rgba(6,139,238,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "success") do
    [
      "bg-[#0E8345] text-white dark:bg-[#06C167] dark:text-black",
      "[&>.indicator]:bg-[#047857] dark:[&>.indicator]:bg-[#B1EAC2]",
      "shadow-[0px_4px_6px_-4px_rgba(0,154,81,0.5)] shadow-[0px_10px_15px_-3px_rgba(0,154,81,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "warning") do
    [
      "bg-[#CA8D01] text-white dark:bg-[#FDC034] dark:text-black",
      "[&>.indicator]:bg-[#FF8B08] dark:[&>.indicator]:bg-[#FEDF99]",
      "shadow-[0px_4px_6px_-4px_rgba(252,176,1,0.5)] shadow-[0px_10px_15px_-3px_rgba(252,176,1,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "danger") do
    [
      "bg-[#DE1135] text-white dark:bg-[#FC7F79] dark:text-black",
      "[&>.indicator]:bg-[#E73B3B] dark:[&>.indicator]:bg-[#FFD2CD]",
      "shadow-[0px_4px_6px_-4px_rgba(248,52,70,0.5)] shadow-[0px_10px_15px_-3px_rgba(248,52,70,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "info") do
    [
      "bg-[#0B84BA] text-white dark:bg-[#3EB7ED] dark:text-black",
      "[&>.indicator]:bg-[#004FC4] dark:[&>.indicator]:bg-[#9FDBF6]",
      "shadow-[0px_4px_6px_-4px_rgba(14,165,233,0.5)] shadow-[0px_10px_15px_-3px_rgba(14,165,233,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "misc") do
    [
      "bg-[#8750C5] text-white dark:bg-[#BA83F9] dark:text-black",
      "[&>.indicator]:bg-[#52059C dark:[&>.indicator]:bg-[#DDC1FC]]",
      "shadow-[0px_4px_6px_-4px_rgba(169,100,247,0.5)] shadow-[0px_10px_15px_-3px_rgba(169,100,247,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "dawn") do
    [
      "bg-[#A86438] text-white dark:bg-[#DB976B] dark:text-black",
      "[&>.indicator]:bg-[#4D4137] dark:[&>.indicator]:bg-[#EDCBB5]",
      "shadow-[0px_4px_6px_-4px_rgba(210,125,70,0.5)] shadow-[0px_10px_15px_-3px_rgba(210,125,70,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "silver") do
    [
      "bg-[#868686] text-white dark:bg-[#A6A6A6] dark:text-black",
      "[&>.indicator]:bg-[#707483] dark:[&>.indicator]:bg-[#DDDDDD]",
      "shadow-[0px_4px_6px_-4px_rgba(134,134,134,0.5)] shadow-[0px_10px_15px_-3px_rgba(134,134,134,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("bordered", "white") do
    ["bg-white text-black border-[#DDDDDD] [&>.indicator]:bg-black"]
  end

  defp color_variant("bordered", "dark") do
    ["bg-[#282828] text-white border-[#727272] [&>.indicator]:bg-white"]
  end

  defp color_variant("bordered", "natural") do
    [
      "text-[#282828] border-[#282828] bg-[#F3F3F3]",
      "dark:text-[#E8E8E8] dark:border-[#E8E8E8] dark:bg-[#4B4B4B]",
      "[&>.indicator]:bg-black dark:[&>.indicator]:bg-white"
    ]
  end

  defp color_variant("bordered", "primary") do
    [
      "text-[#016974] border-[#016974] bg-[#E2F8FB]",
      "dark:text-[#77D5E3] dark:border-[#77D5E3] dark:bg-[#002D33]",
      "[&>.indicator]:bg-[#1A535A] dark:[&>.indicator]:bg-[#B0E7EF]"
    ]
  end

  defp color_variant("bordered", "secondary") do
    [
      "text-[#175BCC] border-[#175BCC] bg-[#EFF4FE]",
      "dark:text-[#A9C9FF] dark:border-[#A9C9FF] dark:bg-[#002661]",
      "[&>.indicator]:bg-[#1948A3] dark:[&>.indicator]:bg-[#CDDEFF]"
    ]
  end

  defp color_variant("bordered", "success") do
    [
      "text-[#166C3B] border-[#166C3B] bg-[#EAF6ED]",
      "dark:text-[#7FD99A] dark:border-[#7FD99A] dark:bg-[#002F14]",
      "[&>.indicator]:bg-[#0D572D] dark:[&>.indicator]:bg-[#B1EAC2]"
    ]
  end

  defp color_variant("bordered", "warning") do
    [
      "text-[#976A01] border-[#976A01] bg-[#FFF7E6]",
      "dark:text-[#FDD067] dark:border-[#FDD067] dark:bg-[#322300]",
      "[&>.indicator]:bg-[#654600] dark:[&>.indicator]:bg-[#FEDF99]"
    ]
  end

  defp color_variant("bordered", "danger") do
    [
      "text-[#BB032A] border-[#BB032A] bg-[#FFF0EE]",
      "dark:text-[#FFB2AB] dark:border-[#FFB2AB] dark:bg-[#520810]",
      "[&>.indicator]:bg-[#950F22] dark:[&>.indicator]:bg-[#FFD2CD]"
    ]
  end

  defp color_variant("bordered", "info") do
    [
      "text-[#0B84BA] border-[#0B84BA] bg-[#E7F6FD]",
      "dark:text-[#6EC9F2] dark:border-[#6EC9F2] dark:bg-[#03212F]",
      "[&>.indicator]:bg-[#06425D] dark:[&>.indicator]:bg-[#9FDBF6]"
    ]
  end

  defp color_variant("bordered", "misc") do
    [
      "text-[#653C94] border-[#653C94] bg-[#F6F0FE]",
      "dark:text-[#CBA2FA] dark:border-[#CBA2FA] dark:bg-[#221431]",
      "[&>.indicator]:bg-[#442863] dark:[&>.indicator]:bg-[#DDC1FC]"
    ]
  end

  defp color_variant("bordered", "dawn") do
    [
      "text-[#7E4B2A] border-[#7E4B2A] bg-[#FBF2ED]",
      "dark:text-[#E4B190] dark:border-[#E4B190] dark:bg-[#2A190E]",
      "[&>.indicator]:bg-[#54321C] dark:[&>.indicator]:bg-[#EDCBB5]"
    ]
  end

  defp color_variant("bordered", "silver") do
    [
      "text-[#727272] border-[#727272] bg-[#F3F3F3]",
      "dark:text-[#BBBBBB] dark:border-[#BBBBBB] dark:bg-[#4B4B4B]",
      "[&>.indicator]:bg-[#5E5E5E] dark:[&>.indicator]:bg-[#DDDDDD]"
    ]
  end

  defp color_variant("gradient", "natural") do
    [
      "bg-gradient-to-br from-[#282828] to-[#727272] text-white",
      "dark:from-[#A6A6A6] dark:to-[#FFFFFF] dark:text-black",
      "[&>.indicator]:bg-white dark:[&>.indicator]:bg-black"
    ]
  end

  defp color_variant("gradient", "primary") do
    [
      "bg-gradient-to-br from-[#016974] to-[#01B8CA] text-white",
      "dark:from-[#01B8CA] dark:to-[#B0E7EF] dark:text-black",
      "[&>.indicator]:bg-[#1A535A] dark:[&>.indicator]:bg-[#CDEEF3]"
    ]
  end

  defp color_variant("gradient", "secondary") do
    [
      "bg-gradient-to-br from-[#175BCC] to-[#6DAAFB] text-white",
      "dark:from-[#6DAAFB] dark:to-[#CDDEFF] dark:text-black",
      "[&>.indicator]:bg-[#1948A3] dark:[&>.indicator]:bg-[#DEE9FE]"
    ]
  end

  defp color_variant("gradient", "success") do
    [
      "bg-gradient-to-br from-[#166C3B] to-[#06C167] text-white",
      "dark:from-[#06C167] dark:to-[#B1EAC2] dark:text-black",
      "[&>.indicator]:bg-[#0D572D] dark:[&>.indicator]:bg-[#D3EFDA]"
    ]
  end

  defp color_variant("gradient", "warning") do
    [
      "bg-gradient-to-br from-[#976A01] to-[#FDC034] text-white",
      "dark:from-[#FDC034] dark:to-[#FEDF99] dark:text-black",
      "[&>.indicator]:bg-[#654600] dark:[&>.indicator]:bg-[#FEEFCC]"
    ]
  end

  defp color_variant("gradient", "danger") do
    [
      "bg-gradient-to-br from-[#BB032A] to-[#FC7F79] text-white",
      "dark:from-[#FC7F79] dark:to-[#FFD2CD] dark:text-black",
      "[&>.indicator]:bg-[#950F22] dark:[&>.indicator]:bg-[#FFE1DE]"
    ]
  end

  defp color_variant("gradient", "info") do
    [
      "bg-gradient-to-br from-[#08638C] to-[#3EB7ED] text-white",
      "dark:from-[#3EB7ED] dark:to-[#9FDBF6] dark:text-black",
      "[&>.indicator]:bg-[#06425D] dark:[&>.indicator]:bg-[#CFEDFB]"
    ]
  end

  defp color_variant("gradient", "misc") do
    [
      "bg-gradient-to-br from-[#653C94] to-[#BA83F9] text-white",
      "dark:from-[#BA83F9] dark:to-[#DDC1FC] dark:text-black",
      "[&>.indicator]:bg-[#442863] dark:[&>.indicator]:bg-[#EEE0FD]"
    ]
  end

  defp color_variant("gradient", "dawn") do
    [
      "bg-gradient-to-br from-[#7E4B2A] to-[#DB976B] text-white",
      "dark:from-[#DB976B] dark:to-[#EDCBB5] dark:text-black",
      "[&>.indicator]:bg-[#54321C] dark:[&>.indicator]:bg-[#F6E5DA]"
    ]
  end

  defp color_variant("gradient", "silver") do
    [
      "bg-gradient-to-br from-[#5E5E5E] to-[#A6A6A6] text-white",
      "dark:from-[#868686] dark:to-[#BBBBBB] dark:text-black",
      "[&>.indicator]:bg-[#4B4B4B] dark:[&>.indicator]:bg-[#E8E8E8]"
    ]
  end

  defp color_variant(params, _) when is_binary(params), do: params

  defp rounded_size("extra_small"), do: "rounded-sm"

  defp rounded_size("small"), do: "rounded"

  defp rounded_size("medium"), do: "rounded-md"

  defp rounded_size("large"), do: "rounded-lg"

  defp rounded_size("extra_large"), do: "rounded-xl"

  defp rounded_size("full"), do: "rounded-full"

  defp rounded_size("none"), do: nil

  defp rounded_size(params) when is_binary(params), do: params

  defp border_size(_, variant) when variant in ["default", "shadow", "transparent", "gradient"],
    do: nil

  defp border_size("none", _), do: nil
  defp border_size("extra_small", _), do: "border"
  defp border_size("small", _), do: "border-2"
  defp border_size("medium", _), do: "border-[3px]"
  defp border_size("large", _), do: "border-4"
  defp border_size("extra_large", _), do: "border-[5px]"
  defp border_size(params, _) when is_binary(params), do: params

  defp indicator_size("extra_small"), do: "!size-2"
  defp indicator_size("small"), do: "!size-2.5"
  defp indicator_size("medium"), do: "!size-3"
  defp indicator_size("large"), do: "!size-3.5"
  defp indicator_size("extra_large"), do: "!size-4"
  defp indicator_size(params) when is_binary(params), do: params

  defp size_class("extra_small", circle) do
    [
      is_nil(circle) && "px-2 py-px",
      "text-[12px] [&>.indicator]:size-1",
      !is_nil(circle) && "size-6"
    ]
  end

  defp size_class("small", circle) do
    [
      is_nil(circle) && "px-2.5 py-0.5",
      "text-[13px] [&>.indicator]:size-1.5",
      !is_nil(circle) && "size-7"
    ]
  end

  defp size_class("medium", circle) do
    [
      is_nil(circle) && "px-2.5 py-1",
      "text-[14px] [&>.indicator]:size-2",
      !is_nil(circle) && "size-8"
    ]
  end

  defp size_class("large", circle) do
    [
      is_nil(circle) && "px-3 py-1.5",
      "text-[15px] [&>.indicator]:size-2.5",
      !is_nil(circle) && "size-9"
    ]
  end

  defp size_class("extra_large", circle) do
    [
      is_nil(circle) && "px-3.5 py-2",
      "text-[16px] [&>.indicator]:size-3",
      !is_nil(circle) && "size-10"
    ]
  end

  defp size_class(params, _circle) when is_binary(params), do: [params]

  defp icon_position(nil, _), do: false
  defp icon_position(_icon, %{left_icon: true}), do: "left"
  defp icon_position(_icon, %{right_icon: true}), do: "right"
  defp icon_position(_icon, _), do: "left"

  defp dismiss_position(%{right_dismiss: true}), do: "right"
  defp dismiss_position(%{left_dismiss: true}), do: "left"
  defp dismiss_position(%{dismiss: true}), do: "right"
  defp dismiss_position(_), do: false

  defp default_classes(pinging) do
    [
      "has-[.indicator]:relative inline-flex gap-1.5 justify-center items-center",
      "[&>.indicator]:inline-block [&>.indicator]:shrink-0 [&>.indicator]:rounded-full",
      !is_nil(pinging) && "[&>.indicator]:animate-ping"
    ]
  end

  defp drop_rest(rest) do
    all_rest =
      (["pinging", "circle"] ++ @dismiss_positions ++ @indicator_positions ++ @icon_positions)
      |> Enum.map(&if(is_binary(&1), do: String.to_atom(&1), else: &1))

    Map.drop(rest, all_rest)
  end

  ## JS Commands
  @doc """
  Displays a badge element by applying a transition effect.

  ## Parameters

    - `js`: (optional) An existing `Phoenix.LiveView.JS` structure to apply
    transformations on. Defaults to a new `%JS{}`.
    - `selector`: A string representing the CSS selector of the badge element to be shown.

  ## Returns

    - A `Phoenix.LiveView.JS` structure with commands to show the badge element with a
    smooth transition effect.

  ## Transition Details

    - The element transitions from an initial state of reduced opacity and
    scale (`opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95`) to full opacity
    and scale (`opacity-100 translate-y-0 sm:scale-100`) over a duration of 300 milliseconds.

  ## Example

  ```elixir
  show_badge(%JS{}, "#badge-element")
  ```

  This example will show the badge element with the ID badge-element using the defined transition effect.
  """
  def show_badge(js \\ %JS{}, selector) do
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
  Hides a badge element by applying a transition effect.

  ## Parameters

    - `js`: (optional) An existing `Phoenix.LiveView.JS` structure to apply transformations on.
    Defaults to a new `%JS{}`.
    - `selector`: A string representing the CSS selector of the badge element to be hidden.

  ## Returns

    - A `Phoenix.LiveView.JS` structure with commands to hide the badge element
    with a smooth transition effect.

  ## Transition Details

    - The element transitions from full opacity and scale (`opacity-100 translate-y-0 sm:scale-100`)
    to reduced opacity and scale (`opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95`)
    over a duration of 200 milliseconds.

  ## Example

  ```elixir
  hide_badge(%JS{}, "#badge-element")
  ```

  This example will hide the badge element with the ID badge-element using the defined transition effect.
  """

  def hide_badge(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all transform ease-in duration-200",
         "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
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
