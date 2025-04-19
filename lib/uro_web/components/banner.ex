defmodule UroWeb.Components.Banner do
  @moduledoc """
  UroWeb.Components.Banner module provides components for rendering customizable banners in your **Phoenix LiveView**
  application.

  ## Features

  - **Banner Component**: Create visually appealing banners with various styles, colors, and sizes.
  - **Dismissable Banners**: Add dismiss buttons to banners to allow users to hide them with a
  smooth transition.
  - **Positioning Options**: Control the positioning of the banners on the screen with flexible
  vertical and horizontal alignment options.
  - **Custom Styles**: Customize the look and feel of your banners using various attributes for size,
  border, padding, and more.
  - **Animation Transitions**: Use built-in JavaScript commands to show and hide banners with
  smooth animation transitions.

  > The main component for rendering a banner with optional inner content and dismiss functionality.

  ## JS Commands

  - `show_banner/2`: Displays the banner element with a smooth transition.
  - `hide_banner/2`: Hides the banner element with a smooth transition.

  Use this module to create interactive and aesthetically pleasing banner elements for
  your **LiveView** applications.
  """

  use Phoenix.Component
  alias Phoenix.LiveView.JS
  use Gettext, backend: UroWeb.Gettext

  @positions ["top_left", "top_right", "bottom_left", "bottom_right", "center", "full"]

  @doc """
  The `banner` component is used to display fixed position banners with various customization
  options such as size, color, and position. It supports displaying content through an inner block,
  and attributes like `vertical_position` and `rounded_position` for flexible layout configuration.

  ## Examples

  ```elixir
  <.banner id="banner">
    <div>
      Lorem ipsum dolor sit amet consectetur adipisicing elit. Commodi ea
      atque soluta praesentium quidem dicta sapiente accusamus nihil.
    </div>
  </.banner>

  <.banner id="banner" color="primary" space="large" vertical_position="bottom">
    <div>
      Lorem ipsum dolor sit amet consectetur adipisicing elit. Commodi ea atque soluta
      praesentium quidem dicta sapiente accusamus nihil.
    </div>
    <div>
      Lorem ipsum dolor sit amet consectetur adipisicing elit. Commodi ea atque
      soluta praesentium quidem dicta sapiente accusamus nihil.
    </div>
  </.banner>

  <.banner id="banner" color="secondary" space="large" vertical_position="top" vertical_size="top-24">
    <div>
      Lorem ipsum dolor sit amet consectetur adipisicing elit. Commodi ea atque soluta praesentium quidem dicta sapiente accusamus nihil.
    </div>
    <div>
      Lorem ipsum dolor sit amet consectetur adipisicing elit. Commodi ea atque soluta praesentium quidem dicta sapiente accusamus nihil.
    </div>
  </.banner>
  ```
  """
  @doc type: :component
  attr :id, :string,
    required: true,
    doc: "A unique identifier is used to manage state and interaction"

  attr :size, :string,
    default: "large",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :variant, :string, default: "base", doc: "Determines the style"
  attr :color, :string, default: "natural", doc: "Determines color theme"
  attr :border, :string, default: "extra_small", doc: "Determines border style"

  attr :border_position, :string,
    values: ["top", "bottom", "full", "none"],
    default: "top",
    doc: ""

  attr :rounded, :string, default: "none", doc: "Determines the border radius"

  attr :rounded_position, :string,
    values: ["top", "bottom", "all", "none"],
    default: "none",
    doc: ""

  attr :space, :string, default: "extra_small", doc: "Space between items"

  attr :vertical_position, :string, values: ["top", "bottom"], default: "top", doc: ""
  attr :vertical_size, :string, default: "none", doc: "Specifies the vertical size of the element"

  attr :hide_dismiss, :boolean, default: false, doc: "Show or hide dismiss classes"

  attr :dismiss_size, :string,
    default: "small",
    doc: "Add custom classes to control dismiss sizes"

  attr :position, :string,
    values: @positions,
    default: "full",
    doc: "Determines the element position"

  attr :position_size, :string,
    default: "none",
    doc: "Determines the size for positioning the element"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :padding, :string, default: "extra_small", doc: "Determines padding for items"

  attr :class, :string, default: "", doc: "Custom CSS class for additional styling"

  attr :params, :map,
    default: %{kind: "banner"},
    doc: "A map of additional parameters used for element configuration, such as type or kind"

  attr :rest, :global,
    include: ~w(right_dismiss left_dismiss),
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def banner(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "overflow-hidden fixed z-50",
        vertical_position(@vertical_size, @vertical_position),
        rounded_size(@rounded, @rounded_position),
        border_class(@border, @border_position, @variant),
        color_variant(@variant, @color),
        position_class(@position_size, @position),
        space_class(@space),
        padding_size(@padding),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <div class="flex gap-2 items-center justify-between">
        <div>
          {render_slot(@inner_block)}
        </div>
        <.banner_dismiss :if={!@hide_dismiss} id={@id} dismiss_size={@dismiss_size} params={@params} />
      </div>
    </div>
    """
  end

  @doc type: :component
  attr :id, :string,
    required: true,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :dismiss_size, :string,
    default: "small",
    doc: "Add custom classes to control dismiss sizes"

  attr :params, :map,
    default: %{kind: "badge"},
    doc: "A map of additional parameters used for element configuration, such as type or kind"

  defp banner_dismiss(assigns) do
    ~H"""
    <button
      type="button"
      class="group shrink-0"
      aria-label={gettext("close")}
      phx-click={JS.push("dismiss", value: Map.merge(%{id: @id}, @params)) |> hide_banner("##{@id}")}
    >
      <.icon
        name="hero-x-mark-solid"
        class={[
          "banner-icon opacity-80 group-hover:opacity-70",
          dismiss_size(@dismiss_size),
          @class
        ]}
      />
    </button>
    """
  end

  defp dismiss_size("extra_small"), do: "size-3.5"

  defp dismiss_size("small"), do: "size-4"

  defp dismiss_size("medium"), do: "size-5"

  defp dismiss_size("large"), do: "size-6"

  defp dismiss_size("extra_large"), do: "size-7"

  defp dismiss_size(params) when is_binary(params), do: params

  defp padding_size("extra_small"), do: "p-2"

  defp padding_size("small"), do: "p-3"

  defp padding_size("medium"), do: "p-4"

  defp padding_size("large"), do: "p-5"

  defp padding_size("extra_large"), do: "p-6"

  defp padding_size("none"), do: "p-0"

  defp padding_size(params) when is_binary(params), do: params

  defp vertical_position("none", "top"), do: "top-0"
  defp vertical_position("extra_small", "top"), do: "top-1"
  defp vertical_position("small", "top"), do: "top-2"
  defp vertical_position("medium", "top"), do: "top-3"
  defp vertical_position("large", "top"), do: "top-4"
  defp vertical_position("extra_large", "top"), do: "top-5"

  defp vertical_position("none", "bottom"), do: "bottom-0"
  defp vertical_position("extra_small", "bottom"), do: "bottom-1"
  defp vertical_position("small", "bottom"), do: "bottom-2"
  defp vertical_position("medium", "bottom"), do: "bottom-3"
  defp vertical_position("large", "bottom"), do: "bottom-4"
  defp vertical_position("extra_large", "bottom"), do: "bottom-5"

  defp vertical_position(params, _) when is_binary(params), do: params

  defp position_class("none", "top_left"), do: "left-0 ml-0"
  defp position_class("extra_small", "top_left"), do: "left-1 ml-1"
  defp position_class("small", "top_left"), do: "left-2 ml-2"
  defp position_class("medium", "top_left"), do: "left-3 ml-3"
  defp position_class("large", "top_left"), do: "left-4 ml-4"
  defp position_class("extra_large", "top_left"), do: "left-5 ml-5"

  defp position_class("none", "top_right"), do: "right-0"
  defp position_class("extra_small", "top_right"), do: "right-1"
  defp position_class("small", "top_right"), do: "right-2"
  defp position_class("medium", "top_right"), do: "right-3"
  defp position_class("large", "top_right"), do: "right-4"
  defp position_class("extra_large", "top_right"), do: "right-5"

  defp position_class("none", "bottom_left"), do: "left-0 ml-0"
  defp position_class("extra_small", "bottom_left"), do: "left-1 ml-1"
  defp position_class("small", "bottom_left"), do: "left-2 ml-2"
  defp position_class("medium", "bottom_left"), do: "left-3 ml-3"
  defp position_class("large", "bottom_left"), do: "left-4 ml-4"
  defp position_class("extra_large", "bottom_left"), do: "left-5 ml-5"

  defp position_class("none", "bottom_right"), do: "right-0"
  defp position_class("extra_small", "bottom_right"), do: "right-1"
  defp position_class("small", "bottom_right"), do: "right-2"
  defp position_class("medium", "bottom_right"), do: "right-3"
  defp position_class("large", "bottom_right"), do: "right-4"
  defp position_class("extra_large", "bottom_right"), do: "right-5"

  defp position_class(_, "center"), do: "mx-auto"
  defp position_class(_, "full"), do: "inset-x-0"

  defp position_class(params, _) when is_binary(params), do: params

  defp rounded_size("extra_small", "top"), do: "rounded-b-sm"

  defp rounded_size("small", "top"), do: "rounded-b"

  defp rounded_size("medium", "top"), do: "rounded-b-md"

  defp rounded_size("large", "top"), do: "rounded-b-lg"

  defp rounded_size("extra_large", "top"), do: "rounded-b-xl"

  defp rounded_size("extra_small", "bottom"), do: "rounded-t-sm"

  defp rounded_size("small", "bottom"), do: "rounded-t"

  defp rounded_size("medium", "bottom"), do: "rounded-t-md"

  defp rounded_size("large", "bottom"), do: "rounded-t-lg"

  defp rounded_size("extra_large", "bottom"), do: "rounded-t-xl"

  defp rounded_size("extra_small", "all"), do: "rounded-sm"

  defp rounded_size("small", "all"), do: "rounded"

  defp rounded_size("medium", "all"), do: "rounded-md"

  defp rounded_size("large", "all"), do: "rounded-lg"

  defp rounded_size("extra_large", "all"), do: "rounded-xl"

  defp rounded_size("none", _), do: nil

  defp rounded_size(params, _) when is_binary(params), do: params

  defp space_class("none"), do: nil

  defp space_class("extra_small"), do: "space-y-2"

  defp space_class("small"), do: "space-y-3"

  defp space_class("medium"), do: "space-y-4"

  defp space_class("large"), do: "space-y-5"

  defp space_class("extra_large"), do: "space-y-6"

  defp space_class(params) when is_binary(params), do: params

  defp border_class(_, _, variant)
       when variant in ["default", "shadow", "transparent", "gradient"],
       do: nil

  defp border_class("none", _, _), do: nil
  defp border_class("extra_small", "top", _), do: "border-b"
  defp border_class("small", "top", _), do: "border-b-2"
  defp border_class("medium", "top", _), do: "border-b-[3px]"
  defp border_class("large", "top", _), do: "border-b-4"
  defp border_class("extra_large", "top", _), do: "border-b-[5px]"

  defp border_class("extra_small", "bottom", _), do: "border"
  defp border_class("small", "bottom", _), do: "border-b-2"
  defp border_class("medium", "bottom", _), do: "border-b-[3px]"
  defp border_class("large", "bottom", _), do: "border-b-4"
  defp border_class("extra_large", "bottom", _), do: "border-b-[5px]"

  defp border_class("extra_small", "full", _), do: "border"
  defp border_class("small", "full", _), do: "border-2"
  defp border_class("medium", "full", _), do: "border-[3px]"
  defp border_class("large", "full", _), do: "border-4"
  defp border_class("extra_large", "full", _), do: "border-[5px]"

  defp border_class(params, _, _) when is_binary(params), do: params

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
    ["bg-[#4B4B4B] text-white dark:bg-[#DDDDDD] dark:text-black"]
  end

  defp color_variant("default", "primary") do
    ["bg-[#007F8C] text-white dark:bg-[#01B8CA] dark:text-black"]
  end

  defp color_variant("default", "secondary") do
    ["bg-[#266EF1] text-white dark:bg-[#6DAAFB] dark:text-black"]
  end

  defp color_variant("default", "success") do
    ["bg-[#0E8345] text-white dark:bg-[#06C167] dark:text-black"]
  end

  defp color_variant("default", "warning") do
    ["bg-[#CA8D01] text-white dark:bg-[#FDC034] dark:text-black"]
  end

  defp color_variant("default", "danger") do
    ["bg-[#DE1135] text-white dark:bg-[#FC7F79] dark:text-black"]
  end

  defp color_variant("default", "info") do
    ["bg-[#0B84BA] text-white dark:bg-[#3EB7ED] dark:text-black"]
  end

  defp color_variant("default", "misc") do
    ["bg-[#8750C5] text-white dark:bg-[#BA83F9] dark:text-black"]
  end

  defp color_variant("default", "dawn") do
    ["bg-[#A86438] text-white dark:bg-[#DB976B] dark:text-black"]
  end

  defp color_variant("default", "silver") do
    ["bg-[#868686] text-white dark:bg-[#A6A6A6] dark:text-black"]
  end

  defp color_variant("outline", "natural") do
    [
      "text-[#4B4B4B] border-[#4B4B4B]",
      "dark:text-[#DDDDDD] dark:border-[#DDDDDD]"
    ]
  end

  defp color_variant("outline", "primary") do
    [
      "text-[#007F8C] border-[#007F8C]",
      "dark:text-[#01B8CA] dark:border-[#01B8CA]"
    ]
  end

  defp color_variant("outline", "secondary") do
    [
      "text-[#266EF1] border-[#266EF1]",
      "dark:text-[#6DAAFB] dark:border-[#6DAAFB]"
    ]
  end

  defp color_variant("outline", "success") do
    [
      "text-[#0E8345] border-[#0E8345]",
      "dark:text-[#06C167] dark:border-[#06C167]"
    ]
  end

  defp color_variant("outline", "warning") do
    [
      "text-[#CA8D01] border-[#CA8D01]",
      "dark:text-[#FDC034] dark:border-[#FDC034]"
    ]
  end

  defp color_variant("outline", "danger") do
    [
      "text-[#DE1135] border-[#DE1135]",
      "dark:text-[#FC7F79] dark:border-[#FC7F79]"
    ]
  end

  defp color_variant("outline", "info") do
    [
      "text-[#0B84BA] border-[#0B84BA]",
      "dark:text-[#3EB7ED] dark:border-[#3EB7ED]"
    ]
  end

  defp color_variant("outline", "misc") do
    [
      "text-[#8750C5] border-[#8750C5]",
      "dark:text-[#BA83F9] dark:border-[#BA83F9]"
    ]
  end

  defp color_variant("outline", "dawn") do
    [
      "text-[#A86438] border-[#A86438]",
      "dark:text-[#DB976B] dark:border-[#DB976B]"
    ]
  end

  defp color_variant("outline", "silver") do
    [
      "text-[#868686] border-[#868686]",
      "dark:text-[#A6A6A6] dark:border-[#A6A6A6]"
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

  defp color_variant("transparent", "natural") do
    ["text-[#4B4B4B] dark:text-[#DDDDDD]"]
  end

  defp color_variant("transparent", "primary") do
    ["text-[#007F8C] dark:text-[#01B8CA]"]
  end

  defp color_variant("transparent", "secondary") do
    ["text-[#266EF1] dark:text-[#6DAAFB]"]
  end

  defp color_variant("transparent", "success") do
    ["text-[#0E8345] dark:text-[#06C167]"]
  end

  defp color_variant("transparent", "warning") do
    ["text-[#CA8D01] dark:text-[#FDC034]"]
  end

  defp color_variant("transparent", "danger") do
    ["text-[#DE1135] dark:text-[#FC7F79]"]
  end

  defp color_variant("transparent", "info") do
    ["text-[#0B84BA] dark:text-[#3EB7ED]"]
  end

  defp color_variant("transparent", "misc") do
    ["text-[#8750C5] dark:text-[#BA83F9]"]
  end

  defp color_variant("transparent", "dawn") do
    ["text-[#A86438] dark:text-[#DB976B]"]
  end

  defp color_variant("transparent", "silver") do
    ["text-[#868686] dark:text-[#A6A6A6]"]
  end

  defp color_variant("bordered", "white") do
    ["bg-white text-black border-[#DDDDDD]"]
  end

  defp color_variant("bordered", "dark") do
    ["bg-[#282828] text-white border-[#727272]"]
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

  ## JS Commands
  @doc """
  Displays a banner element with a smooth transition effect.

  ## Parameters

    - `js` (optional): An existing `Phoenix.LiveView.JS` structure to apply transformations on.
    Defaults to a new `%JS{}`.
    - `selector`: A string representing the CSS selector of the banner element to be shown.

  ## Returns

    - A `Phoenix.LiveView.JS` structure with commands to show the banner element with a
    smooth transition effect.

  ## Transition Details

    - The element transitions from an initial state of reduced opacity and scale
    (`opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95`) to full opacity and scale
    (`opacity-100 translate-y-0 sm:scale-100`) over a duration of 300 milliseconds.

  ## Example

    ```elixir
    show_banner(%JS{}, "#banner-element")
    ```

    This example will show the banner element with the ID banner-element using the defined transition effect.
  """
  def show_banner(js \\ %JS{}, selector) do
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
  Hides a banner element with a smooth transition effect.

  ## Parameters

    - `js` (optional): An existing `Phoenix.LiveView.JS` structure to apply transformations on.
    Defaults to a new `%JS{}`.
    - `selector`: A string representing the CSS selector of the banner element to be hidden.

  ## Returns

    - A `Phoenix.LiveView.JS` structure with commands to hide the banner element with a
    smooth transition effect.

  ## Transition Details

    - The element transitions from full opacity and scale (`opacity-100 translate-y-0 sm:scale-100`)
    to reduced opacity and scale (`opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95`)
    over a duration of 200 milliseconds.

  ## Example

    ```elixir
    hide_banner(%JS{}, "#banner-element")
    ```

  This example will hide the banner element with the ID banner-element using the defined transition effect.
  """
  def hide_banner(js \\ %JS{}, selector) do
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
