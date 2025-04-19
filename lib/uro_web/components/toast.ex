defmodule UroWeb.Components.Toast do
  @moduledoc """
  A module for creating toast notifications in a Phoenix application.

  This module provides components for rendering toast messages, including
  options for customization such as size, color, and dismiss behavior. It
  supports a variety of visual styles and positions, allowing for
  flexible integration into any user interface.

  Toasts can be used to provide feedback to users or display
  informational messages without interrupting their workflow. The
  components defined in this module handle the presentation and
  interaction logic, enabling developers to easily implement toast
  notifications within their applications.

  > You can create a toast notification with various styles and
  > configurations to suit your application's needs.
  """
  use Phoenix.Component
  alias Phoenix.LiveView.JS
  use Gettext, backend: UroWeb.Gettext

  @doc """
  The `toast` component displays temporary notifications or messages, usually at the top
  or bottom of the screen.

  It supports customization for size, color, border, and positioning, allowing you to
  style the toast as needed.

  ## Examples

  ```elixir
  <.toast id="toast-1">
    <div>Lorem ipsum dolor sit amet consectetur adipisicing elit.</div>
  </.toast>

  <.toast
    id="toast-2"
    color="success"
    content_border="small"
    border_position="end"
    horizontal="center"
    vertical_space="large"
  >
    <div>Lorem ipsum dolor sit amet consectetur adipisicing elit.</div>
  </.toast>

  <.toast
    id="toast-3"
    color="misc"
    horizontal="left"
    content_border="extra_small"
    border_position="start"
    rounded="medium"
    width="extra_large"
  >
    <div>Lorem ipsum dolor sit amet consectetur adipisicing elit.</div>
  </.toast>
  ```
  """
  @doc type: :component
  attr :id, :string,
    required: true,
    doc: "A unique identifier is used to manage state and interaction"

  attr :fixed, :boolean, default: true, doc: "Determines whether the element is fixed"
  attr :variant, :string, default: "base", doc: "Determines the style"
  attr :color, :string, default: "natural", doc: "Determines color theme"
  attr :border, :string, default: "extra_small", doc: "Determines border style"
  attr :rounded, :string, default: "medium", doc: "Determines the border radius"
  attr :width, :string, default: "medium", doc: "Determines the element width"
  attr :space, :string, default: "extra_small", doc: "Space between items"
  attr :vertical, :string, values: ["top", "bottom"], default: "top", doc: "Type of vertical"
  attr :vertical_space, :string, default: "extra_small", doc: "Space between vertical items"

  attr :horizontal, :string,
    values: ["left", "right", "center"],
    default: "right",
    doc: "Type of horizontal"

  attr :horizontal_space, :string, default: "extra_small", doc: "Space between horizontal items"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :class, :string, default: "", doc: "Additional CSS classes to be added to the toast."

  attr :params, :map,
    default: %{kind: "toast"},
    doc: "A map of additional parameters used for element configuration"

  attr :rest, :global,
    include: ~w(right_dismiss left_dismiss),
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  attr :content_border, :string, default: "none", doc: "Determines the content border style"
  attr :border_position, :string, default: "start", doc: "Determines the border position style"
  attr :row_direction, :string, default: "none", doc: "Determines row direction"
  attr :padding, :string, default: "extra_small", doc: "Determines padding for items"
  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def toast(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "overflow-hidden z-50",
        @fixed && "fixed",
        width_class(@width),
        rounded_size(@rounded),
        border_class(@border, @variant),
        color_variant(@variant, @color),
        position_class(@horizontal_space, @horizontal),
        vertical_position(@vertical_space, @vertical),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <div class={[
        "toast-content-wrapper relative",
        "before:block before:absolute before:inset-y-0 before:rounded-full before:my-1",
        content_border(@content_border),
        @content_border != "none" && boder_position(@border_position)
      ]}>
        <div class={[
          "flex gap-2 items-center justify-between",
          row_direction(@row_direction),
          padding_size(@padding)
        ]}>
          <div
            class={[
                space_class(@space),
            ]}
          >
            {render_slot(@inner_block)}
          </div>
          <.toast_dismiss id={@id} params={@params} />
        </div>
      </div>
    </div>
    """
  end

  @doc """
  The `toast_group` component is used to group multiple `toast` elements together,
  allowing for coordinated display and positioning of toast notifications.

  ## Examples

  ```elixir
  <.toast_group vertical_space="large" horizontal_space="extra_large">
    <.toast
      id="toast-1"
      color="success"
      content_border="small"
      border_position="end"
      fixed={false}
    >
      <div>
        Lorem ipsum dolor sit amet consectetur adipisicing elit.
      </div>
    </.toast>

    <.toast
      id="toast-2"
      variant="outline"
      color="danger"
      content_border="small"
      border_position="start"
      fixed={false}
    >
      <div>
        Lorem ipsum dolor sit amet consectetur adipisicing elit.
      </div>
    </.toast>

    <.toast
      id="toast-3"
      variant="unbordered"
      color="warning"
      content_border="small"
      border_position="start"
      fixed={false}
    >
      <div>
        Lorem ipsum dolor sit amet consectetur adipisicing elit.
      </div>
    </.toast>
  </.toast_group>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :space, :string, default: "small", doc: "Space between items"
  attr :vertical, :string, values: ["top", "bottom"], default: "bottom", doc: "Type of vertical"
  attr :vertical_space, :string, default: "extra_small", doc: "Space between vertical items"

  attr :horizontal, :string,
    values: ["left", "right", "center"],
    default: "right",
    doc: "Type of horizontal"

  attr :horizontal_space, :string, default: "extra_small", doc: "Space between horizontal items"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def toast_group(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "fixed z-50",
        space_class(@space),
        position_class(@horizontal_space, @horizontal),
        vertical_position(@vertical_space, @vertical),
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc type: :component
  attr :id, :string,
    required: true,
    doc: "A unique identifier is used to manage state and interaction"

  attr :dismiss, :boolean,
    default: false,
    doc: "Determines if the toast should include a dismiss button"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :size, :string,
    default: "small",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :params, :map,
    default: %{kind: "toast"},
    doc: "A map of additional parameters used for element configuration"

  defp toast_dismiss(assigns) do
    ~H"""
    <button
      type="button"
      class="group shrink-0"
      aria-label={gettext("close")}
      phx-click={JS.push("dismiss", value: Map.merge(%{id: @id}, @params)) |> hide_toast("##{@id}")}
    >
      <.icon
        name="hero-x-mark-solid"
        class={[
          "toast-icon opacity-80 group-hover:opacity-70",
          dismiss_size(@size),
          @class
        ]}
      />
    </button>
    """
  end

  defp boder_position("end"), do: "pe-1.5 before:end-1"
  defp boder_position("start"), do: "ps-1.5 before:start-1"
  defp boder_position(params) when is_binary(params), do: params

  defp content_border("extra_small"), do: "before:w-px"
  defp content_border("small"), do: "before:w-0.5"
  defp content_border("medium"), do: "before:w-[3px]"
  defp content_border("large"), do: "before:w-1"
  defp content_border("extra_large"), do: "before:w-[5px]"
  defp content_border("none"), do: "before:content-none"
  defp content_border(params) when is_binary(params), do: params

  defp row_direction("none"), do: "flex-row"
  defp row_direction("reverse"), do: "flex-row-reverse"
  defp row_direction(_), do: row_direction("none")

  defp padding_size("extra_small"), do: "p-2"

  defp padding_size("small"), do: "p-3"

  defp padding_size("medium"), do: "p-4"

  defp padding_size("large"), do: "p-5"

  defp padding_size("extra_large"), do: "p-6"

  defp padding_size("none"), do: "p-0"

  defp padding_size(params) when is_binary(params), do: params

  defp width_class("extra_small"), do: "max-w-60"
  defp width_class("small"), do: "max-w-64"
  defp width_class("medium"), do: "max-w-72"
  defp width_class("large"), do: "max-w-80"
  defp width_class("extra_large"), do: "max-w-96"
  defp width_class("full"), do: "w-[calc(100%-10px)]"
  defp width_class(params) when is_binary(params), do: params

  defp dismiss_size("extra_small"), do: "size-3.5"
  defp dismiss_size("small"), do: "size-4"
  defp dismiss_size("medium"), do: "size-5"
  defp dismiss_size("large"), do: "size-6"
  defp dismiss_size("extra_large"), do: "size-7"
  defp dismiss_size(params) when is_binary(params), do: params

  defp vertical_position("extra_small", "top"), do: "top-1"
  defp vertical_position("small", "top"), do: "top-2"
  defp vertical_position("medium", "top"), do: "top-3"
  defp vertical_position("large", "top"), do: "top-4"
  defp vertical_position("extra_large", "top"), do: "top-5"

  defp vertical_position("extra_small", "bottom"), do: "bottom-1"
  defp vertical_position("small", "bottom"), do: "bottom-2"
  defp vertical_position("medium", "bottom"), do: "bottom-3"
  defp vertical_position("large", "bottom"), do: "bottom-4"
  defp vertical_position("extra_large", "bottom"), do: "bottom-5"

  defp vertical_position(params, _) when is_binary(params), do: params

  defp position_class("extra_small", "left"), do: "left-1 ml-1"
  defp position_class("small", "left"), do: "left-2 ml-2"
  defp position_class("medium", "left"), do: "left-3 ml-3"
  defp position_class("large", "left"), do: "left-4 ml-4"
  defp position_class("extra_large", "left"), do: "left-5 ml-5"

  defp position_class("extra_small", "right"), do: "right-1 mr-1"
  defp position_class("small", "right"), do: "right-2 mr-2"
  defp position_class("medium", "right"), do: "right-3 mr-3"
  defp position_class("large", "right"), do: "right-4 mr-4"
  defp position_class("extra_large", "right"), do: "right-5 mr-5"

  defp position_class(_, "center"), do: "left-1/2 -translate-x-1/2"

  defp position_class(params, _) when is_binary(params), do: params

  defp rounded_size("extra_small"), do: "rounded-sm"

  defp rounded_size("small"), do: "rounded"

  defp rounded_size("medium"), do: "rounded-md"

  defp rounded_size("large"), do: "rounded-lg"

  defp rounded_size("extra_large"), do: "rounded-xl"

  defp rounded_size("none"), do: "rounded-none"

  defp rounded_size(params) when is_binary(params), do: params

  defp space_class("none"), do: nil

  defp space_class("extra_small"), do: "space-y-2"

  defp space_class("small"), do: "space-y-3"

  defp space_class("medium"), do: "space-y-4"

  defp space_class("large"), do: "space-y-5"

  defp space_class("extra_large"), do: "space-y-6"

  defp space_class(params) when is_binary(params), do: params

  defp border_class(_, variant) when variant in ["default", "shadow", "gradient"],
    do: nil

  defp border_class("extra_small", _), do: "border"
  defp border_class("small", _), do: "border-2"
  defp border_class("medium", _), do: "border-[3px]"
  defp border_class("large", _), do: "border-4"
  defp border_class("extra_large", _), do: "border-[5px]"
  defp border_class(params, _) when is_binary(params), do: params

  defp color_variant("base", _) do
    [
      "bg-white text-[#09090b] dark:bg-[#18181B] dark:text-[#FAFAFA]",
      "[&>.toast-content-wrapper]:before:bg-[#09090b] dark:[&>.toast-content-wrapper]:before:bg-[#FAFAFA]",
      "border-[#e4e4e7] dark:border-[#27272a]"
    ]
  end

  defp color_variant("default", "white") do
    ["bg-white text-black [&>.toast-content-wrapper]:before:bg-black"]
  end

  defp color_variant("default", "dark") do
    ["bg-[#282828] text-white [&>.toast-content-wrapper]:before:bg-white"]
  end

  defp color_variant("default", "natural") do
    [
      "bg-[#4B4B4B] text-white dark:bg-[#DDDDDD] dark:text-black",
      "[&>.toast-content-wrapper]:before:bg-white dark:[&>.toast-content-wrapper]:before:bg-black"
    ]
  end

  defp color_variant("default", "primary") do
    [
      "bg-[#007F8C] text-white dark:bg-[#01B8CA] dark:text-black",
      "[&>.toast-content-wrapper]:before:bg-white dark:[&>.toast-content-wrapper]:before:bg-black"
    ]
  end

  defp color_variant("default", "secondary") do
    [
      "bg-[#266EF1] text-white dark:bg-[#6DAAFB] dark:text-black",
      "[&>.toast-content-wrapper]:before:bg-white dark:[&>.toast-content-wrapper]:before:bg-black"
    ]
  end

  defp color_variant("default", "success") do
    [
      "bg-[#0E8345] text-white dark:bg-[#06C167] dark:text-black",
      "[&>.toast-content-wrapper]:before:bg-white dark:[&>.toast-content-wrapper]:before:bg-black"
    ]
  end

  defp color_variant("default", "warning") do
    [
      "bg-[#CA8D01] text-white dark:bg-[#FDC034] dark:text-black",
      "[&>.toast-content-wrapper]:before:bg-white dark:[&>.toast-content-wrapper]:before:bg-black"
    ]
  end

  defp color_variant("default", "danger") do
    [
      "bg-[#DE1135] text-white dark:bg-[#FC7F79] dark:text-black",
      "[&>.toast-content-wrapper]:before:bg-white dark:[&>.toast-content-wrapper]:before:bg-black"
    ]
  end

  defp color_variant("default", "info") do
    [
      "bg-[#0B84BA] text-white dark:bg-[#3EB7ED] dark:text-black",
      "[&>.toast-content-wrapper]:before:bg-white dark:[&>.toast-content-wrapper]:before:bg-black"
    ]
  end

  defp color_variant("default", "misc") do
    [
      "bg-[#8750C5] text-white dark:bg-[#BA83F9] dark:text-black",
      "[&>.toast-content-wrapper]:before:bg-white dark:[&>.toast-content-wrapper]:before:bg-black"
    ]
  end

  defp color_variant("default", "dawn") do
    [
      "bg-[#A86438] text-white dark:bg-[#DB976B] dark:text-black",
      "[&>.toast-content-wrapper]:before:bg-white dark:[&>.toast-content-wrapper]:before:bg-black"
    ]
  end

  defp color_variant("default", "silver") do
    [
      "bg-[#868686] text-white dark:bg-[#A6A6A6] dark:text-black",
      "[&>.toast-content-wrapper]:before:bg-white dark:[&>.toast-content-wrapper]:before:bg-black"
    ]
  end

  defp color_variant("outline", "natural") do
    [
      "text-[#4B4B4B] border-[#4B4B4B]",
      "dark:text-[#DDDDDD] dark:border-[#DDDDDD]",
      "[&>.toast-content-wrapper]:before:bg-[#4B4B4B] dark:[&>.toast-content-wrapper]:before:bg-[#DDDDDD]"
    ]
  end

  defp color_variant("outline", "primary") do
    [
      "text-[#007F8C] border-[#007F8C]",
      "dark:text-[#01B8CA] dark:border-[#01B8CA]",
      "[&>.toast-content-wrapper]:before:bg-[#007F8C] dark:[&>.toast-content-wrapper]:before:bg-[#01B8CA]"
    ]
  end

  defp color_variant("outline", "secondary") do
    [
      "text-[#266EF1] border-[#266EF1]",
      "dark:text-[#6DAAFB] dark:border-[#6DAAFB]",
      "[&>.toast-content-wrapper]:before:bg-[#266EF1] dark:[&>.toast-content-wrapper]:before:bg-[#6DAAFB]"
    ]
  end

  defp color_variant("outline", "success") do
    [
      "text-[#0E8345] border-[#0E8345]",
      "dark:text-[#06C167] dark:border-[#06C167]",
      "[&>.toast-content-wrapper]:before:bg-[#0E8345] dark:[&>.toast-content-wrapper]:before:bg-[#06C167]"
    ]
  end

  defp color_variant("outline", "warning") do
    [
      "text-[#CA8D01] border-[#CA8D01]",
      "dark:text-[#FDC034] dark:border-[#FDC034]",
      "[&>.toast-content-wrapper]:before:bg-[#CA8D01] dark:[&>.toast-content-wrapper]:before:bg-[#FDC034]"
    ]
  end

  defp color_variant("outline", "danger") do
    [
      "text-[#DE1135] border-[#DE1135]",
      "dark:text-[#FC7F79] dark:border-[#FC7F79]",
      "[&>.toast-content-wrapper]:before:bg-[#DE1135] dark:[&>.toast-content-wrapper]:before:bg-[#FC7F79]"
    ]
  end

  defp color_variant("outline", "info") do
    [
      "text-[#0B84BA] border-[#0B84BA]",
      "dark:text-[#3EB7ED] dark:border-[#3EB7ED]",
      "[&>.toast-content-wrapper]:before:bg-[#0B84BA] dark:[&>.toast-content-wrapper]:before:bg-[#3EB7ED]"
    ]
  end

  defp color_variant("outline", "misc") do
    [
      "text-[#8750C5] border-[#8750C5]",
      "dark:text-[#BA83F9] dark:border-[#BA83F9]",
      "[&>.toast-content-wrapper]:before:bg-[#8750C5] dark:[&>.toast-content-wrapper]:before:bg-[#BA83F9]"
    ]
  end

  defp color_variant("outline", "dawn") do
    [
      "text-[#A86438] border-[#A86438]",
      "dark:text-[#DB976B] dark:border-[#DB976B]",
      "[&>.toast-content-wrapper]:before:bg-[#A86438] dark:[&>.toast-content-wrapper]:before:bg-[#DB976B]"
    ]
  end

  defp color_variant("outline", "silver") do
    [
      "text-[#868686] border-[#868686]",
      "dark:text-[#A6A6A6] dark:border-[#A6A6A6]",
      "[&>.toast-content-wrapper]:before:bg-[#868686] dark:[&>.toast-content-wrapper]:before:bg-[#A6A6A6]"
    ]
  end

  defp color_variant("shadow", "natural") do
    [
      "bg-[#4B4B4B] text-white dark:bg-[#DDDDDD] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(134,134,134,0.5)] shadow-[0px_10px_15px_-3px_rgba(134,134,134,0.5)] dark:shadow-none",
      "[&>.toast-content-wrapper]:before:bg-white dark:[&>.toast-content-wrapper]:before:bg-black"
    ]
  end

  defp color_variant("shadow", "primary") do
    [
      "bg-[#007F8C] text-white dark:bg-[#01B8CA] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(0,149,164,0.5)] shadow-[0px_10px_15px_-3px_rgba(0,149,164,0.5)] dark:shadow-none",
      "[&>.toast-content-wrapper]:before:bg-white dark:[&>.toast-content-wrapper]:before:bg-black"
    ]
  end

  defp color_variant("shadow", "secondary") do
    [
      "bg-[#266EF1] text-white dark:bg-[#6DAAFB] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(6,139,238,0.5)] shadow-[0px_10px_15px_-3px_rgba(6,139,238,0.5)] dark:shadow-none",
      "[&>.toast-content-wrapper]:before:bg-white dark:[&>.toast-content-wrapper]:before:bg-black"
    ]
  end

  defp color_variant("shadow", "success") do
    [
      "bg-[#0E8345] text-white hover:bg-[#166C3B] dark:bg-[#06C167] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(0,154,81,0.5)] shadow-[0px_10px_15px_-3px_rgba(0,154,81,0.5)] dark:shadow-none",
      "[&>.toast-content-wrapper]:before:bg-white dark:[&>.toast-content-wrapper]:before:bg-black"
    ]
  end

  defp color_variant("shadow", "warning") do
    [
      "bg-[#CA8D01] text-white dark:bg-[#FDC034] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(252,176,1,0.5)] shadow-[0px_10px_15px_-3px_rgba(252,176,1,0.5)] dark:shadow-none",
      "[&>.toast-content-wrapper]:before:bg-white dark:[&>.toast-content-wrapper]:before:bg-black"
    ]
  end

  defp color_variant("shadow", "danger") do
    [
      "bg-[#DE1135] text-white dark:bg-[#FC7F79] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(248,52,70,0.5)] shadow-[0px_10px_15px_-3px_rgba(248,52,70,0.5)] dark:shadow-none",
      "[&>.toast-content-wrapper]:before:bg-white dark:[&>.toast-content-wrapper]:before:bg-black"
    ]
  end

  defp color_variant("shadow", "info") do
    [
      "bg-[#0B84BA] text-white dark:bg-[#3EB7ED] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(14,165,233,0.5)] shadow-[0px_10px_15px_-3px_rgba(14,165,233,0.5)] dark:shadow-none",
      "[&>.toast-content-wrapper]:before:bg-white dark:[&>.toast-content-wrapper]:before:bg-black"
    ]
  end

  defp color_variant("shadow", "misc") do
    [
      "bg-[#8750C5] text-white dark:bg-[#BA83F9] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(169,100,247,0.5)] shadow-[0px_10px_15px_-3px_rgba(169,100,247,0.5)] dark:shadow-none",
      "[&>.toast-content-wrapper]:before:bg-white dark:[&>.toast-content-wrapper]:before:bg-black"
    ]
  end

  defp color_variant("shadow", "dawn") do
    [
      "bg-[#A86438] text-white dark:bg-[#DB976B] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(210,125,70,0.5)] shadow-[0px_10px_15px_-3px_rgba(210,125,70,0.5)] dark:shadow-none",
      "[&>.toast-content-wrapper]:before:bg-white dark:[&>.toast-content-wrapper]:before:bg-black"
    ]
  end

  defp color_variant("shadow", "silver") do
    [
      "bg-[#868686] text-white dark:bg-[#A6A6A6] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(134,134,134,0.5)] shadow-[0px_10px_15px_-3px_rgba(134,134,134,0.5)] dark:shadow-none",
      "[&>.toast-content-wrapper]:before:bg-white dark:[&>.toast-content-wrapper]:before:bg-black"
    ]
  end

  defp color_variant("bordered", "white") do
    [
      "bg-white text-black border-[#DDDDDD]",
      "[&>.toast-content-wrapper]:before:bg-black"
    ]
  end

  defp color_variant("bordered", "dark") do
    [
      "bg-[#282828] text-white border-[#727272]",
      "[&>.toast-content-wrapper]:before:bg-white"
    ]
  end

  defp color_variant("bordered", "natural") do
    [
      "text-[#282828] border-[#282828] bg-[#F3F3F3]",
      "dark:text-[#E8E8E8] dark:border-[#E8E8E8] dark:bg-[#4B4B4B]",
      "[&>.toast-content-wrapper]:before:bg-[#282828] dark:[&>.toast-content-wrapper]:before:bg-[#E8E8E8]"
    ]
  end

  defp color_variant("bordered", "primary") do
    [
      "text-[#016974] border-[#016974] bg-[#E2F8FB]",
      "dark:text-[#77D5E3] dark:border-[#77D5E3] dark:bg-[#002D33]",
      "[&>.toast-content-wrapper]:before:bg-[#016974] dark:[&>.toast-content-wrapper]:before:bg-[#77D5E3]"
    ]
  end

  defp color_variant("bordered", "secondary") do
    [
      "text-[#175BCC] border-[#175BCC] bg-[#EFF4FE]",
      "dark:text-[#A9C9FF] dark:border-[#A9C9FF] dark:bg-[#002661]",
      "[&>.toast-content-wrapper]:before:bg-[#175BCC] dark:[&>.toast-content-wrapper]:before:bg-[#A9C9FF]"
    ]
  end

  defp color_variant("bordered", "success") do
    [
      "text-[#166C3B] border-[#166C3B] bg-[#EAF6ED]",
      "dark:text-[#7FD99A] dark:border-[#7FD99A] dark:bg-[#002F14]",
      "[&>.toast-content-wrapper]:before:bg-[#166C3B] dark:[&>.toast-content-wrapper]:before:bg-[#7FD99A]"
    ]
  end

  defp color_variant("bordered", "warning") do
    [
      "text-[#976A01] border-[#976A01] bg-[#FFF7E6]",
      "dark:text-[#FDD067] dark:border-[#FDD067] dark:bg-[#322300]",
      "[&>.toast-content-wrapper]:before:bg-[#976A01] dark:[&>.toast-content-wrapper]:before:bg-[#FDD067]"
    ]
  end

  defp color_variant("bordered", "danger") do
    [
      "text-[#BB032A] border-[#BB032A] bg-[#FFF0EE]",
      "dark:text-[#FFB2AB] dark:border-[#FFB2AB] dark:bg-[#520810]",
      "[&>.toast-content-wrapper]:before:bg-[#BB032A] dark:[&>.toast-content-wrapper]:before:bg-[#FFB2AB]"
    ]
  end

  defp color_variant("bordered", "info") do
    [
      "text-[#0B84BA] border-[#0B84BA] bg-[#E7F6FD]",
      "dark:text-[#6EC9F2] dark:border-[#6EC9F2] dark:bg-[#03212F]",
      "[&>.toast-content-wrapper]:before:bg-[#0B84BA] dark:[&>.toast-content-wrapper]:before:bg-[#6EC9F2]"
    ]
  end

  defp color_variant("bordered", "misc") do
    [
      "text-[#653C94] border-[#653C94] bg-[#F6F0FE]",
      "dark:text-[#CBA2FA] dark:border-[#CBA2FA] dark:bg-[#221431]",
      "[&>.toast-content-wrapper]:before:bg-[#653C94] dark:[&>.toast-content-wrapper]:before:bg-[#CBA2FA]"
    ]
  end

  defp color_variant("bordered", "dawn") do
    [
      "text-[#7E4B2A] border-[#7E4B2A] bg-[#FBF2ED]",
      "dark:text-[#E4B190] dark:border-[#E4B190] dark:bg-[#2A190E]",
      "[&>.toast-content-wrapper]:before:bg-[#7E4B2A] dark:[&>.toast-content-wrapper]:before:bg-[#E4B190]"
    ]
  end

  defp color_variant("bordered", "silver") do
    [
      "text-[#727272] border-[#727272] bg-[#F3F3F3]",
      "dark:text-[#BBBBBB] dark:border-[#BBBBBB] dark:bg-[#4B4B4B]",
      "[&>.toast-content-wrapper]:before:bg-[#727272] dark:[&>.toast-content-wrapper]:before:bg-[#BBBBBB]"
    ]
  end

  defp color_variant("gradient", "natural") do
    [
      "bg-gradient-to-br from-[#282828] to-[#727272] text-white",
      "dark:from-[#A6A6A6] dark:to-[#FFFFFF] dark:text-black",
      "[&>.toast-content-wrapper]:before:bg-white dark:[&>.toast-content-wrapper]:before:bg-black"
    ]
  end

  defp color_variant("gradient", "primary") do
    [
      "bg-gradient-to-br from-[#016974] to-[#01B8CA] text-white",
      "dark:from-[#01B8CA] dark:to-[#B0E7EF] dark:text-black",
      "[&>.toast-content-wrapper]:before:bg-white dark:[&>.toast-content-wrapper]:before:bg-black"
    ]
  end

  defp color_variant("gradient", "secondary") do
    [
      "bg-gradient-to-br from-[#175BCC] to-[#6DAAFB] text-white",
      "dark:from-[#6DAAFB] dark:to-[#CDDEFF] dark:text-black",
      "[&>.toast-content-wrapper]:before:bg-white dark:[&>.toast-content-wrapper]:before:bg-black"
    ]
  end

  defp color_variant("gradient", "success") do
    [
      "bg-gradient-to-br from-[#166C3B] to-[#06C167] text-white",
      "dark:from-[#06C167] dark:to-[#B1EAC2] dark:text-black",
      "[&>.toast-content-wrapper]:before:bg-white dark:[&>.toast-content-wrapper]:before:bg-black"
    ]
  end

  defp color_variant("gradient", "warning") do
    [
      "bg-gradient-to-br from-[#976A01] to-[#FDC034] text-white",
      "dark:from-[#FDC034] dark:to-[#FEDF99] dark:text-black",
      "[&>.toast-content-wrapper]:before:bg-white dark:[&>.toast-content-wrapper]:before:bg-black"
    ]
  end

  defp color_variant("gradient", "danger") do
    [
      "bg-gradient-to-br from-[#BB032A] to-[#FC7F79] text-white",
      "dark:from-[#FC7F79] dark:to-[#FFD2CD] dark:text-black",
      "[&>.toast-content-wrapper]:before:bg-white dark:[&>.toast-content-wrapper]:before:bg-black"
    ]
  end

  defp color_variant("gradient", "info") do
    [
      "bg-gradient-to-br from-[#08638C] to-[#3EB7ED] text-white",
      "dark:from-[#3EB7ED] dark:to-[#9FDBF6] dark:text-black",
      "[&>.toast-content-wrapper]:before:bg-white dark:[&>.toast-content-wrapper]:before:bg-black"
    ]
  end

  defp color_variant("gradient", "misc") do
    [
      "bg-gradient-to-br from-[#653C94] to-[#BA83F9] text-white",
      "dark:from-[#BA83F9] dark:to-[#DDC1FC] dark:text-black",
      "[&>.toast-content-wrapper]:before:bg-white dark:[&>.toast-content-wrapper]:before:bg-black"
    ]
  end

  defp color_variant("gradient", "dawn") do
    [
      "bg-gradient-to-br from-[#7E4B2A] to-[#DB976B] text-white",
      "dark:from-[#DB976B] dark:to-[#EDCBB5] dark:text-black",
      "[&>.toast-content-wrapper]:before:bg-white dark:[&>.toast-content-wrapper]:before:bg-black"
    ]
  end

  defp color_variant("gradient", "silver") do
    [
      "bg-gradient-to-br from-[#5E5E5E] to-[#A6A6A6] text-white",
      "dark:from-[#868686] dark:to-[#BBBBBB] dark:text-black",
      "[&>.toast-content-wrapper]:before:bg-white dark:[&>.toast-content-wrapper]:before:bg-black"
    ]
  end

  defp color_variant(params, _) when is_binary(params), do: params

  ## JS Commands

  @doc """
  Displays a toast notification.

  This function shows a toast notification by applying a specified transition effect to the
  element identified by the provided `selector`. It utilizes the `JS.show/2` function to handle
  the showing animation with a duration of 300 milliseconds.

  ## Parameters

  - `js` (optional): A `JS` struct that can be used to chain further JavaScript actions.
  - `selector`: A string representing the CSS selector for the toast element to be displayed.

  ## Example

  ```elixir
  show_toast(js, "#my-toast")
  ```

  This documentation provides a clear explanation of what the function does,
  its parameters, and an example usage.
  """
  def show_toast(js \\ %JS{}, selector) do
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
  Hides a toast notification.

  This function hides a toast notification by applying a specified transition effect to the
  element identified by the provided `selector`. It utilizes the `JS.hide/2` function to handle
  the hiding animation with a duration of 200 milliseconds.

  ## Parameters

  - `js` (optional): A `JS` struct that can be used to chain further JavaScript actions.
  - `selector`: A string representing the CSS selector for the toast element to be hidden.

  ## Example

  ```elixir
  hide_toast(js, "#my-toast")
  ```

  This documentation clearly outlines the purpose of the function, its parameters,
  and an example of how to use it.
  """
  def hide_toast(js \\ %JS{}, selector) do
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
