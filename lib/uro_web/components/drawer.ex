defmodule UroWeb.Components.Drawer do
  @moduledoc """
  The `UroWeb.Components.Drawer` module provides a flexible and customizable drawer component
  for use in Phoenix LiveView applications.

  ## Features:
  - **Positioning:** Drawers can be positioned on the left, right, top, or bottom of the screen.
  - **Styling Variants:** Offers several styling options like `default`, `outline`,
  `transparent`, `shadow`, and `unbordered`.
  - **Color Themes:** Supports a variety of predefined color themes, including `primary`,
  `secondary`, `success`, `danger`, `info`, and more.
  - **Customizable:** Allows customization of border style, size, border radius,
  and padding to fit various design needs.
  - **Interactive:** Integrated with `Phoenix.LiveView.JS` for show/hide functionality and
  nteraction management.
  - **Slots Support:** Includes slots for adding a custom header and inner content,
  with full HEEx support for dynamic rendering.
  """
  use Phoenix.Component
  alias Phoenix.LiveView.JS
  use Gettext, backend: UroWeb.Gettext

  @doc """
  A `drawer` component for displaying content in a sliding panel. It can be positioned on the left or
  right side of the viewport and controlled using custom JavaScript actions.

  ## Examples

  ```elixir
  <.drawer id="acc-left" show={true}>
    Lorem ipsum dolor sit amet consectetur adipisicing elit. Commodi ea atque soluta
    praesentium quidem dicta sapiente accusamus nihil.
  </.drawer>

  <.drawer id="acc-right" title_class="text-2xl font-light" position="right">
    <:header><p>Right Drawer</p></:header>
    Lorem ipsum dolor sit amet consectetur adipisicing elit. Commodi ea atque soluta praesentium
    quidem dicta sapiente accusamus nihil.
  </.drawer>
  ```
  """
  @doc type: :component
  attr :id, :string,
    required: true,
    doc: "A unique identifier is used to manage state and interaction"

  attr :title, :string, default: nil, doc: "Specifies the title of the element"
  attr :title_class, :string, default: nil, doc: "Determines custom class for the title"
  attr :variant, :string, default: "base", doc: "Determines the style"
  attr :color, :string, default: "natural", doc: "Determines color theme"

  attr :size, :string,
    default: "large",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :border, :string, default: "extra_small", doc: "Determines border style"
  attr :position, :string, default: "left", doc: "Determines the element position"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :on_hide, JS, default: %JS{}, doc: "Custom JS module for on_hide action"
  attr :on_show, JS, default: %JS{}, doc: "Custom JS module for on_show action"
  attr :on_hide_away, JS, default: %JS{}, doc: "Custom JS module for on_hide_away action"
  attr :show, :boolean, default: false, doc: "Show element"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :header, required: false, doc: "Specifies element's header that accepts heex"
  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def drawer(assigns) do
    ~H"""
    <div
      id={@id}
      phx-mounted={@show && show_drawer(@on_show, @id, @position)}
      phx-remove={hide_drawer(@id, @position)}
      class={[
        "fixed z-50 transition-transform",
        "[&:not(.drawer-showed)_.drawer-overlay]:opacity-0 [&.drawer-showed_.drawer-overlay]:opacity-100",
        translate_position(@position),
        position_class(@position)
      ]}
      tabindex="-1"
      aria-labelledby={"#{@id}-#{@position}-label"}
      {@rest}
    >
    <div class="fixed bg-black/60 inset-0 -z-10 transition-all duration-[0.4s] delay-[0.1s] ease-in-out drawer-overlay"></div>
      <div
        phx-click-away={hide_drawer(@on_hide_away, @id, @position)}
        class={[
          "p-2 overflow-y-auto",
          (@position == "left" || "right") && "h-full",
          size_class(@size, @position),
          border_class(@border, @position, @variant),
          color_variant(@variant, @color),
          @class
        ]}
      >
        <div class="flex flex-row-reverse justify-between items-center gap-5 mb-2">
          <button type="button" phx-click={JS.exec(@on_hide, "phx-remove", to: "##{@id}")}>
            <.icon name="hero-x-mark" />
            <span class="sr-only">{gettext("Close menu")}</span>
          </button>
          <h5
            :if={title = @title || render_slot(@header)}
            id={"#{@id}-#{@position}-title"}
            class={[@title_class || "text-lg font-semibold"]}
          >
            {title}
          </h5>
        </div>

        <div>
          {render_slot(@inner_block)}
        </div>
      </div>
    </div>
    """
  end

  defp translate_position("left"), do: "-translate-x-full"
  defp translate_position("right"), do: "translate-x-full"
  defp translate_position("bottom"), do: "translate-y-full"
  defp translate_position("top"), do: "-translate-y-full"
  defp translate_position(params) when is_binary(params), do: params

  defp position_class("left"), do: "top-0 left-0 h-screen"
  defp position_class("right"), do: "top-0 right-0 h-screen"
  defp position_class("top"), do: "top-0 inset-x-0 w-full"
  defp position_class("bottom"), do: "bottom-0 inset-x-0 w-full"
  defp position_class(params) when is_binary(params), do: params

  defp border_class(_, _, variant)
       when variant in [
              "default",
              "shadow",
              "transparent",
              "gradient"
            ],
       do: nil

  defp border_class("extra_small", "left", _), do: "border-r"
  defp border_class("small", "left", _), do: "border-r-2"
  defp border_class("medium", "left", _), do: "border-r-[3px]"
  defp border_class("large", "left", _), do: "border-r-4"
  defp border_class("extra_large", "left", _), do: "border-r-[5px]"

  defp border_class("extra_small", "right", _), do: "border-l"
  defp border_class("small", "right", _), do: "border-l-2"
  defp border_class("medium", "right", _), do: "border-l-[3px]"
  defp border_class("large", "right", _), do: "border-l-4"
  defp border_class("extra_large", "right", _), do: "border-l-[5px]"

  defp border_class("extra_small", "top", _), do: "border-b"
  defp border_class("small", "top", _), do: "border-b-2"
  defp border_class("medium", "top", _), do: "border-b-[3px]"
  defp border_class("large", "top", _), do: "border-b-4"
  defp border_class("extra_large", "top", _), do: "border-b-[5px]"

  defp border_class("extra_small", "bottom", _), do: "border-t"
  defp border_class("small", "bottom", _), do: "border-t-2"
  defp border_class("medium", "bottom", _), do: "border-t-[3px]"
  defp border_class("large", "bottom", _), do: "border-t-4"
  defp border_class("extra_large", "bottom", _), do: "border-t-[5px]"

  defp border_class(params, _, _) when is_binary(params), do: params

  defp size_class("extra_small", "left"), do: "w-60"

  defp size_class("small", "left"), do: "w-64"

  defp size_class("medium", "left"), do: "w-72"

  defp size_class("large", "left"), do: "w-80"

  defp size_class("extra_large", "left"), do: "w-96"

  defp size_class("extra_small", "right"), do: "w-60"

  defp size_class("small", "right"), do: "w-64"

  defp size_class("medium", "right"), do: "w-72"

  defp size_class("large", "right"), do: "w-80"

  defp size_class("extra_large", "right"), do: "w-96"

  defp size_class("extra_small", "top"), do: "min-h-32"

  defp size_class("small", "top"), do: "min-h-36"

  defp size_class("medium", "top"), do: "min-h-40"

  defp size_class("large", "top"), do: "min-h-44"

  defp size_class("extra_large", "top"), do: "min-h-48"

  defp size_class("extra_small", "bottom"), do: "min-h-32"

  defp size_class("small", "bottom"), do: "min-h-36"

  defp size_class("medium", "bottom"), do: "min-h-40"

  defp size_class("large", "bottom"), do: "min-h-44"

  defp size_class("extra_large", "bottom"), do: "min-h-48"

  defp size_class(params, _) when is_binary(params), do: params

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

  @doc """
  Shows the drawer component by modifying its CSS classes to transition it into view.

  ## Parameters:
    - `js` (optional, `Phoenix.LiveView.JS`): The JS struct used to chain JavaScript commands.
    Defaults to an empty `%JS{}`.
    - `id` (string): The unique identifier of the drawer element to show.
    - `position` (string): The position of the drawer, such as "left", "right", "top", or "bottom".

  ## Behavior:
  Removes the CSS class that keeps the drawer off-screen and adds the class `"transform-none"`
  to bring the drawer into view.

  ## Examples:

  ```elixir
  show_drawer(%JS{}, "drawer-id", "left")
  ```

  This will show the drawer with ID `drawer-id` positioned on the left side of the screen.
  """
  def show_drawer(js \\ %JS{}, id, position) when is_binary(id) do
    JS.remove_class(js, translate_position(position), to: "##{id}")
    |> JS.add_class("transform-none", to: "##{id}")
    |> JS.add_class("drawer-showed", to: "##{id}")
  end

  @doc """
  Hides the drawer component by modifying its CSS classes to transition it out of view.

  ## Parameters:
    - `js` (optional, `Phoenix.LiveView.JS`): The JS struct used to chain JavaScript commands. Defaults to an empty `%JS{}`.
    - `id` (string): The unique identifier of the drawer element to hide.
    - `position` (string): The position of the drawer, such as "left", "right", "top", or "bottom".

  ## Behavior:
  Removes the `"transform-none"` CSS class that keeps the drawer visible and adds the class based on the drawer's position (e.g., `"-translate-x-full"` for a left-positioned drawer) to move the drawer off-screen.

  ## Examples:

  ```elixir
  hide_drawer(%JS{}, "drawer-id", "left")
  ```

  This will hide the drawer with ID "drawer-id" positioned on the left side of the screen.
  """
  def hide_drawer(js \\ %JS{}, id, position) do
    js
    |> JS.remove_class("drawer-showed", to: "##{id}")
    |> JS.remove_class("transform-none", to: "##{id}")
    |> JS.add_class(translate_position(position), to: "##{id}")
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
