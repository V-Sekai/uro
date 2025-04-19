defmodule UroWeb.Components.Sidebar do
  @moduledoc """
  The `UroWeb.Components.Sidebar` module provides a versatile and customizable sidebar
  component for Phoenix LiveView applications. This component is designed to create a
  navigation or information panel that can be toggled in and out of view, enhancing the user
  experience by offering easy access to additional content or navigation links.

  The component supports various configuration options, such as color themes, border styles,
  size, and positioning. It also allows developers to control the visibility and behavior of
  the sidebar through custom JavaScript actions. The sidebar can be positioned on either side of
  the screen, and it includes options for different visual variants, such as shadowed or transparent styles.

  The `Sidebar` component is ideal for building dynamic user interfaces that require collapsible
  navigation or content panels, and it integrates seamlessly with other Phoenix LiveView components
  for a cohesive and interactive application experience.
  """
  use Phoenix.Component
  use Gettext, backend: UroWeb.Gettext
  alias Phoenix.LiveView.JS

  @doc """
  Renders a `sidebar` component that can be shown or hidden based on user interactions.

  The sidebar supports various customizations such as size, color theme, and border style.

  ## Examples

  ```elixir
  <.sidebar id="left" size="extra_small" color="dark" hide_position="left">
    <div class="px-4 py-2">
      <h2 class="text-white">Menu</h2>
      ...
    </div>
  </.sidebar>
  ```
  """
  @doc type: :component
  attr :id, :string,
    required: true,
    doc: "A unique identifier is used to manage state and interaction"

  attr :variant, :string, default: "base", doc: "Determines the style"
  attr :color, :string, default: "natural", doc: "Determines color theme"

  attr :size, :string,
    default: "large",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :border, :string, default: "extra_small", doc: "Determines border style"
  attr :position, :string, default: "start", doc: "Determines the element position"

  attr :hide_position, :string,
    values: ["left", "right"],
    doc: "Determines what position should be hidden"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :on_hide, JS, default: %JS{}, doc: "Custom JS module for on_hide action"
  attr :on_show, JS, default: %JS{}, doc: "Custom JS module for on_show action"
  attr :on_hide_away, JS, default: %JS{}, doc: "Custom JS module for on_hide_away action"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  @spec sidebar(map()) :: Phoenix.LiveView.Rendered.t()
  def sidebar(assigns) do
    ~H"""
    <aside
      id={@id}
      phx-click-away={hide_sidebar(@on_hide_away, @id, @hide_position)}
      phx-remove={hide_sidebar(@id, @hide_position)}
      class={[
        "fixed h-screen transition-transform z-10",
        border_class(@border, @position, @variant),
        hide_position(@hide_position),
        color_variant(@variant, @color),
        position_class(@position),
        size_class(@size),
        @class
      ]}
      aria-label="Sidebar"
      {@rest}
    >
      <div class="h-full overflow-y-auto">
        <div class="flex justify-end pt-2 px-2 mb-1 md:hidden dismiss-sidebar-wrapper">
          <button type="button" class="dismiss-sidebar-button" phx-click={JS.exec(@on_hide, "phx-remove", to: "##{@id}")}>
            <.icon name="hero-x-mark" />
            <span class="sr-only">{gettext("Close menu")}</span>
          </button>
        </div>
        {render_slot(@inner_block)}
      </div>
    </aside>
    """
  end

  @doc """
  Shows the sidebar by applying specific CSS classes to animate it onto the screen.

  ## Parameters

    - `js`: A `Phoenix.LiveView.JS` struct used for managing client-side JavaScript interactions. Defaults to an empty `%JS{}`.
    - `id`: A unique identifier (string) for the sidebar element to be shown. This should correspond to the `id` attribute of the sidebar HTML element.
    - `position`: A string representing the initial position of the sidebar when hidden. Valid values include `"left"` or `"right"`, indicating whether the sidebar is off-screen to the left or right.

  ## Returns

    - Returns an updated `Phoenix.LiveView.JS` struct with the appropriate class changes applied to show the sidebar.

  ## Example

    ```elixir
    show_sidebar(%JS{}, "sidebar-id", "right")
    ```
  This will show the sidebar with the ID "sidebar-id" by sliding it onto the screen from the right.
  """

  def show_sidebar(js \\ %JS{}, id, position) when is_binary(id) do
    JS.remove_class(js, hide_position(position), to: "##{id}")
    |> JS.add_class("transform-none", to: "##{id}")
  end

  @doc """
  Hides the sidebar by applying specific CSS classes to animate it off-screen.

  ## Parameters

    - `js`: A `Phoenix.LiveView.JS` struct used for managing client-side JavaScript interactions. Defaults to an empty `%JS{}`.
    - `id`: A unique identifier (string) for the sidebar element to be hidden. The ID should correspond to the `id` attribute of the sidebar HTML element.
    - `position`: A string representing the direction in which the sidebar should be hidden. Valid values include `"left"` or `"right"`, indicating whether the sidebar will slide off the screen to the left or right, respectively.

  ## Returns

    - Returns an updated `Phoenix.LiveView.JS` struct with the appropriate class changes applied to hide the sidebar.

  ## Example

    ```elixir
    hide_sidebar(%JS{}, "sidebar-id", "left")
    ```

  This will hide the sidebar with the ID "sidebar-id" by sliding it off-screen to the left.
  """

  def hide_sidebar(js \\ %JS{}, id, position) do
    JS.remove_class(js, "transform-none", to: "##{id}")
    |> JS.add_class(hide_position(position), to: "##{id}")
  end

  defp hide_position("left"), do: "-translate-x-full md:translate-x-0"
  defp hide_position("right"), do: "translate-x-full md:translate-x-0"
  defp hide_position(_), do: nil

  defp position_class("start"), do: "top-0 start-0"
  defp position_class("end"), do: "top-0 end-0"
  defp position_class(params) when is_binary(params), do: params

  defp border_class(_, _, variant)
       when variant in ["default", "shadow", "transparent", "gradient"],
       do: nil

  defp border_class("none", _, _), do: "border-0"
  defp border_class("extra_small", "start", _), do: "border-e"
  defp border_class("small", "start", _), do: "border-e-2"
  defp border_class("medium", "start", _), do: "border-e-[3px]"
  defp border_class("large", "start", _), do: "border-e-4"
  defp border_class("extra_large", "start", _), do: "border-e-[5px]"

  defp border_class("extra_small", "end", _), do: "border-s"
  defp border_class("small", "end", _), do: "border-s-2"
  defp border_class("medium", "end", _), do: "border-s-[3px]"
  defp border_class("large", "end", _), do: "border-s-4"
  defp border_class("extra_large", "end", _), do: "border-s-[5px]"

  defp border_class(params, _, _) when is_binary(params), do: params

  defp size_class("extra_small"), do: "w-60"

  defp size_class("small"), do: "w-64"

  defp size_class("medium"), do: "w-72"

  defp size_class("large"), do: "w-80"

  defp size_class("extra_large"), do: "w-96"

  defp size_class(params) when is_binary(params), do: params

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
