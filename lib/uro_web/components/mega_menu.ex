defmodule UroWeb.Components.MegaMenu do
  @moduledoc """
  The `UroWeb.Components.MegaMenu` module provides a customizable and interactive mega menu component
  for building sophisticated navigation systems in Phoenix LiveView applications.

  This component can be used to create multi-level navigation menus with various styling and
  layout options, making it ideal for sites with complex information architectures.

  ### Features

  - **Multiple Styling Options:** Choose from several variants, including `default` and `shadow`,
  to match your design needs.
  - **Color Customization:** Supports a wide range of color themes to integrate seamlessly with
  your application's style.
  - **Interactive Elements:** Allows for click or hover-based activation of the menu, giving users
  flexibility in interaction.
  - **Customizable Slots:** Utilize the `trigger` and `inner_block` slots to define custom content
  and layout within the mega menu.
  """

  use Phoenix.Component
  alias Phoenix.LiveView.JS

  @doc """
  Renders a customizable `mega_menu` component that can display various sections of content.
  It includes slots for defining a trigger element, such as a button, and inner content blocks.

  ## Examples

  ```elixir
  <.mega_menu id="mega" space="small" rounded="large" padding="extra_small" top_gap="large" clickable>
    <:trigger>
      <button class="text-start w-full block">MegaMenu</button>
    </:trigger>

    <div>
      <div class="grid md:grid-cols-2 lg:grid-cols-3">
        <ul class="space-y-4 sm:mb-4 md:mb-0" aria-labelledby="mega-menu-full-cta-button">
          <li>
            <a href="#" class="hover:underline hover:text-blue-600">
              Online Stores
            </a>
          </li>
          <li>
            <a href="#" class="hover:underline hover:text-blue-600">
              Segmentation
            </a>
          </li>
          <li>
            <a href="#" class="hover:underline hover:text-blue-600">
              Marketing CRM
            </a>
          </li>
          <li>
            <a href="#" class="hover:underline hover:text-blue-600">
              Online Stores
            </a>
          </li>
        </ul>
        <ul class="hidden mb-4 space-y-4 md:mb-0 sm:block">
          <li>
            <a href="#" class="hover:underline hover:text-blue-600">
              Our Blog
            </a>
          </li>
          <li>
            <a href="#" class="hover:underline hover:text-blue-600">
              Terms & Conditions
            </a>
          </li>
          <li>
            <a href="#" class="hover:underline hover:text-blue-600">
              License
            </a>
          </li>
          <li>
            <a href="#" class="hover:underline hover:text-blue-600">
              Resources
            </a>
          </li>
        </ul>
        <div class="mt-4 md:mt-0">
          <h2 class="mb-2 font-semibold text-gray-900">Our brands</h2>
          <p class="mb-2 text-gray-500">
            At Flowbite, we have a portfolio of brands that cater to a variety of preferences.
          </p>
          <a
            href="#"
            class="inline-flex items-center text-sm font-medium text-blue-600 hover:underline hover:text-blue-600"
          >
            Explore our brands <span class="sr-only">Explore our brands </span>
            <svg
              class="w-3 h-3 ms-2 rtl:rotate-180"
              aria-hidden="true"
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 14 10"
            >
              <path
                stroke="currentColor"
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M1 5h12m0 0L9 1m4 4L9 9"
              />
            </svg>
          </a>
        </div>
      </div>
    </div>
  </.mega_menu>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :clickable, :boolean,
    default: false,
    doc: "Determines if the element can be activated on click"

  attr :variant, :string, default: "base", doc: "Determines the style"
  attr :color, :string, default: "natural", doc: "Determines color theme"
  attr :rounded, :string, default: "", doc: "Determines the border radius"

  attr :size, :string,
    default: "",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :space, :string, default: "", doc: "Space between items"
  attr :width, :string, default: "full", doc: "Determines the element width"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :padding, :string, default: "", doc: "Determines padding for items"
  attr :icon, :string, default: nil, doc: "Icon displayed alongside of an item"
  attr :icon_class, :string, default: nil, doc: "Determines custom class for the icon"
  attr :title, :string, default: nil, doc: "Specifies the title of the element"
  attr :title_class, :string, default: nil, doc: "Determines custom class for the title"
  attr :border, :string, default: "extra_small", doc: "Determines border style"
  attr :top_gap, :string, default: "extra_small", doc: "Determines top gap of the element"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  slot :trigger, required: false do
    attr :class, :string, doc: "Custom CSS class for additional styling"
  end

  def mega_menu(assigns) do
    ~H"""
    <div
      id={@id}
      phx-open-mega={
        JS.toggle_class("show-mega-menu",
          to: "##{@id}-mega-menu-content",
          transition: "duration-100"
        )
      }
      class={[
        "[&>.mega-menu-content]:invisible [&>.mega-menu-content]:opacity-0",
        "[&>.mega-menu-content.show-mega-menu]:visible [&>.mega-menu-content.show-mega-menu]:opacity-100",
        !@clickable && tirgger_mega_menu(),
        color_variant(@variant, @color),
        padding_size(@padding),
        rounded_size(@rounded),
        width_size(@width),
        border_class(@border, @variant),
        top_gap(@top_gap),
        space_class(@space),
        size_class(@size),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <button
        :if={!is_nil(@title)}
        phx-click={@id && JS.exec("phx-open-mega", to: "##{@id}")}
        class={["flex items-center", @title_class]}
      >
        <.icon :if={!is_nil(@icon)} name={@icon} class={["aler-icon", @icon_class]} />
        <span>{@title}</span>
      </button>

      <div
        :if={@trigger}
        phx-click={@id && JS.exec("phx-open-mega", to: "##{@id}")}
        class={["cursor-pointer mega-menu-trigger", @trigger[:class]]}
      >
        {render_slot(@trigger)}
      </div>

      <div
        id={@id && "#{@id}-mega-menu-content"}
        phx-click-away={
          @id &&
            JS.remove_class("show-mega-menu",
              to: "##{@id}-mega-menu-content",
              transition: "duration-300"
            )
        }
        class={[
          "mega-menu-content inset-x-0 top-full absolute z-20 transition-all ease-in-out delay-100 duratio-500 w-full",
          "invisible opacity-0"
        ]}
      >
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  defp tirgger_mega_menu(),
    do: "[&>.mega-menu-content]:hover:visible [&>.mega-menu-content]:hover:opacity-100"

  defp top_gap("none"), do: "[&>.mega-menu-content]:mt-0"
  defp top_gap("extra_small"), do: "[&>.mega-menu-content]:mt-1"
  defp top_gap("small"), do: "[&>.mega-menu-content]:mt-2"
  defp top_gap("medium"), do: "[&>.mega-menu-content]:mt-3"
  defp top_gap("large"), do: "[&>.mega-menu-content]:mt-4"
  defp top_gap("extra_large"), do: "[&>.mega-menu-content]:mt-5"
  defp top_gap(params) when is_binary(params), do: params

  defp width_size("full"), do: "[&>.mega-menu-content]:w-ful"

  defp width_size("half"),
    do:
      "[&>.mega-menu-content]:w-full md:[&>.mega-menu-content]:w-1/2 md:[&>.mega-menu-content]:mx-auto"

  defp width_size(params) when is_binary(params), do: params

  defp border_class(_, variant) when variant in ["default", "shadow", "gradient"],
    do: nil

  defp border_class("none", _), do: "[&>.mega-menu-content]:border-0"
  defp border_class("extra_small", _), do: "[&>.mega-menu-content]:border"
  defp border_class("small", _), do: "[&>.mega-menu-content]:border-2"
  defp border_class("medium", _), do: "[&>.mega-menu-content]:[&>.mega-menu-content]:border-[3px]"
  defp border_class("large", _), do: "[&>.mega-menu-content]:border-4"

  defp border_class("extra_large", _),
    do: "[&>.mega-menu-content]:[&>.mega-menu-content]:border-[5px]"

  defp border_class(params, _) when is_binary(params), do: params

  defp rounded_size("extra_small"), do: "[&>.mega-menu-content]:rounded-sm"

  defp rounded_size("small"), do: "[&>.mega-menu-content]:rounded"

  defp rounded_size("medium"), do: "[&>.mega-menu-content]:rounded-md"

  defp rounded_size("large"), do: "[&>.mega-menu-content]:rounded-lg"

  defp rounded_size("extra_large"), do: "[&>.mega-menu-content]:rounded-xl"

  defp rounded_size(params) when is_binary(params), do: params

  defp size_class("extra_small"), do: "text-xs"

  defp size_class("small"), do: "text-sm"

  defp size_class("medium"), do: "text-base"

  defp size_class("large"), do: "text-lg"

  defp size_class("extra_large"), do: "text-xl"

  defp size_class(params) when is_binary(params), do: params

  defp padding_size("extra_small"), do: "[&>.mega-menu-content]:p-2"

  defp padding_size("small"), do: "[&>.mega-menu-content]:p-3"

  defp padding_size("medium"), do: "[&>.mega-menu-content]:p-4"

  defp padding_size("large"), do: "[&>.mega-menu-content]:p-5"

  defp padding_size("extra_large"), do: "[&>.mega-menu-content]:p-6"

  defp padding_size(params) when is_binary(params), do: params

  defp space_class("extra_small"), do: "[&>.mega-menu-content]:space-y-2"

  defp space_class("small"), do: "[&>.mega-menu-content]:space-y-3"

  defp space_class("medium"), do: "[&>.mega-menu-content]:space-y-4"

  defp space_class("large"), do: "[&>.mega-menu-content]:space-y-5"

  defp space_class("extra_large"), do: "[&>.mega-menu-content]:space-y-6"

  defp space_class(params) when is_binary(params), do: params

  defp color_variant("base", _) do
    [
      "[&>.mega-menu-content]:bg-white text-[#09090b] [&>.mega-menu-content]:border-[#e4e4e7] [&>.mega-menu-content]:shadow-sm",
      "dark:[&>.mega-menu-content]:bg-[#18181B] dark:text-[#FAFAFA] dark:[&>.mega-menu-content]:border-[#27272a]"
    ]
  end

  defp color_variant("default", "white") do
    [
      "[&>.mega-menu-content]:bg-white text-black"
    ]
  end

  defp color_variant("default", "dark") do
    [
      "[&>.mega-menu-content]:bg-[#282828] text-white"
    ]
  end

  defp color_variant("default", "natural") do
    [
      "[&>.mega-menu-content]:bg-[#4B4B4B] text-white dark:[&>.mega-menu-content]:bg-[#DDDDDD] dark:text-black"
    ]
  end

  defp color_variant("default", "primary") do
    [
      "[&>.mega-menu-content]:bg-[#007F8C] text-white dark:[&>.mega-menu-content]:bg-[#01B8CA] dark:text-black"
    ]
  end

  defp color_variant("default", "secondary") do
    [
      "[&>.mega-menu-content]:bg-[#266EF1] text-white dark:[&>.mega-menu-content]:bg-[#6DAAFB] dark:text-black"
    ]
  end

  defp color_variant("default", "success") do
    [
      "[&>.mega-menu-content]:bg-[#0E8345] text-white dark:[&>.mega-menu-content]:bg-[#06C167] dark:text-black"
    ]
  end

  defp color_variant("default", "warning") do
    [
      "[&>.mega-menu-content]:bg-[#CA8D01] text-white dark:[&>.mega-menu-content]:bg-[#FDC034] dark:text-black"
    ]
  end

  defp color_variant("default", "danger") do
    [
      "[&>.mega-menu-content]:bg-[#DE1135] text-white dark:[&>.mega-menu-content]:bg-[#FC7F79] dark:text-black"
    ]
  end

  defp color_variant("default", "info") do
    [
      "[&>.mega-menu-content]:bg-[#0B84BA] text-white dark:[&>.mega-menu-content]:bg-[#3EB7ED] dark:text-black"
    ]
  end

  defp color_variant("default", "misc") do
    [
      "[&>.mega-menu-content]:bg-[#8750C5] text-white dark:[&>.mega-menu-content]:bg-[#BA83F9] dark:text-black"
    ]
  end

  defp color_variant("default", "dawn") do
    [
      "[&>.mega-menu-content]:bg-[#A86438] text-white dark:[&>.mega-menu-content]:bg-[#DB976B] dark:text-black"
    ]
  end

  defp color_variant("default", "silver") do
    [
      "[&>.mega-menu-content]:bg-[#868686] text-white dark:[&>.mega-menu-content]:bg-[#A6A6A6] dark:text-black"
    ]
  end

  defp color_variant("outline", "natural") do
    [
      "text-[#4B4B4B] [&>.mega-menu-content]:border-[#4B4B4B] dark:text-[#DDDDDD] dark:[&>.mega-menu-content]:border-[#DDDDDD]"
    ]
  end

  defp color_variant("outline", "primary") do
    [
      "text-[#007F8C] [&>.mega-menu-content]:border-[#007F8C]  dark:text-[#01B8CA] dark:[&>.mega-menu-content]:border-[#01B8CA]"
    ]
  end

  defp color_variant("outline", "secondary") do
    [
      "text-[#266EF1] [&>.mega-menu-content]:border-[#266EF1] dark:text-[#6DAAFB] dark:[&>.mega-menu-content]:border-[#6DAAFB]"
    ]
  end

  defp color_variant("outline", "success") do
    [
      "text-[#0E8345] [&>.mega-menu-content]:border-[#0E8345] dark:text-[#06C167] dark:[&>.mega-menu-content]:border-[#06C167]"
    ]
  end

  defp color_variant("outline", "warning") do
    [
      "text-[#CA8D01] [&>.mega-menu-content]:border-[#CA8D01] dark:text-[#FDC034] dark:[&>.mega-menu-content]:border-[#FDC034]"
    ]
  end

  defp color_variant("outline", "danger") do
    [
      "text-[#DE1135] [&>.mega-menu-content]:border-[#DE1135] dark:text-[#FC7F79] dark:[&>.mega-menu-content]:border-[#FC7F79]"
    ]
  end

  defp color_variant("outline", "info") do
    [
      "text-[#0B84BA] [&>.mega-menu-content]:border-[#0B84BA] dark:text-[#3EB7ED] dark:[&>.mega-menu-content]:border-[#3EB7ED]"
    ]
  end

  defp color_variant("outline", "misc") do
    [
      "text-[#8750C5] [&>.mega-menu-content]:border-[#8750C5] dark:text-[#BA83F9] dark:[&>.mega-menu-content]:border-[#BA83F9]"
    ]
  end

  defp color_variant("outline", "dawn") do
    [
      "text-[#A86438] [&>.mega-menu-content]:border-[#A86438] dark:text-[#DB976B] dark:[&>.mega-menu-content]:border-[#DB976B]"
    ]
  end

  defp color_variant("outline", "silver") do
    [
      "text-[#868686] [&>.mega-menu-content]:border-[#868686] dark:text-[#A6A6A6] dark:[&>.mega-menu-content]:border-[#A6A6A6]"
    ]
  end

  defp color_variant("shadow", "natural") do
    [
      "[&>.mega-menu-content]:bg-[#4B4B4B] text-white dark:[&>.mega-menu-content]:bg-[#DDDDDD] dark:text-black",
      "[&>.mega-menu-content]:shadow-[0px_4px_6px_-4px_rgba(134,134,134,0.5)] [&>.mega-menu-content]:shadow-[0px_10px_15px_-3px_rgba(134,134,134,0.5)] dark:[&>.mega-menu-content]:shadow-none"
    ]
  end

  defp color_variant("shadow", "primary") do
    [
      "[&>.mega-menu-content]:bg-[#007F8C] text-white dark:[&>.mega-menu-content]:bg-[#01B8CA] dark:text-black",
      "[&>.mega-menu-content]:shadow-[0px_4px_6px_-4px_rgba(0,149,164,0.5)] [&>.mega-menu-content]:shadow-[0px_10px_15px_-3px_rgba(0,149,164,0.5)] dark:[&>.mega-menu-content]:shadow-none"
    ]
  end

  defp color_variant("shadow", "secondary") do
    [
      "[&>.mega-menu-content]:bg-[#266EF1] text-white dark:[&>.mega-menu-content]:bg-[#6DAAFB] dark:text-black",
      "[&>.mega-menu-content]:shadow-[0px_4px_6px_-4px_rgba(6,139,238,0.5)] [&>.mega-menu-content]:shadow-[0px_10px_15px_-3px_rgba(6,139,238,0.5)] dark:[&>.mega-menu-content]:shadow-none"
    ]
  end

  defp color_variant("shadow", "success") do
    [
      "[&>.mega-menu-content]:bg-[#0E8345] text-white hover:[&>.mega-menu-content]:bg-[#166C3B] dark:[&>.mega-menu-content]:bg-[#06C167] dark:text-black",
      "[&>.mega-menu-content]:shadow-[0px_4px_6px_-4px_rgba(0,154,81,0.5)] [&>.mega-menu-content]:shadow-[0px_10px_15px_-3px_rgba(0,154,81,0.5)] dark:[&>.mega-menu-content]:shadow-none"
    ]
  end

  defp color_variant("shadow", "warning") do
    [
      "[&>.mega-menu-content]:bg-[#CA8D01] text-white dark:[&>.mega-menu-content]:bg-[#FDC034] dark:text-black",
      "[&>.mega-menu-content]:shadow-[0px_4px_6px_-4px_rgba(252,176,1,0.5)] [&>.mega-menu-content]:shadow-[0px_10px_15px_-3px_rgba(252,176,1,0.5)] dark:[&>.mega-menu-content]:shadow-none"
    ]
  end

  defp color_variant("shadow", "danger") do
    [
      "[&>.mega-menu-content]:bg-[#DE1135] text-white dark:[&>.mega-menu-content]:bg-[#FC7F79] dark:text-black",
      "[&>.mega-menu-content]:shadow-[0px_4px_6px_-4px_rgba(248,52,70,0.5)] [&>.mega-menu-content]:shadow-[0px_10px_15px_-3px_rgba(248,52,70,0.5)] dark:[&>.mega-menu-content]:shadow-none"
    ]
  end

  defp color_variant("shadow", "info") do
    [
      "[&>.mega-menu-content]:bg-[#0B84BA] text-white dark:[&>.mega-menu-content]:bg-[#3EB7ED] dark:text-black",
      "[&>.mega-menu-content]:shadow-[0px_4px_6px_-4px_rgba(14,165,233,0.5)] [&>.mega-menu-content]:shadow-[0px_10px_15px_-3px_rgba(14,165,233,0.5)] dark:[&>.mega-menu-content]:shadow-none"
    ]
  end

  defp color_variant("shadow", "misc") do
    [
      "[&>.mega-menu-content]:bg-[#8750C5] text-white dark:[&>.mega-menu-content]:bg-[#BA83F9] dark:text-black",
      "[&>.mega-menu-content]:shadow-[0px_4px_6px_-4px_rgba(169,100,247,0.5)] [&>.mega-menu-content]:shadow-[0px_10px_15px_-3px_rgba(169,100,247,0.5)] dark:[&>.mega-menu-content]:shadow-none"
    ]
  end

  defp color_variant("shadow", "dawn") do
    [
      "[&>.mega-menu-content]:bg-[#A86438] text-white dark:[&>.mega-menu-content]:bg-[#DB976B] dark:text-black",
      "[&>.mega-menu-content]:shadow-[0px_4px_6px_-4px_rgba(210,125,70,0.5)] [&>.mega-menu-content]:shadow-[0px_10px_15px_-3px_rgba(210,125,70,0.5)] dark:[&>.mega-menu-content]:shadow-none"
    ]
  end

  defp color_variant("shadow", "silver") do
    [
      "[&>.mega-menu-content]:bg-[#868686] text-white dark:[&>.mega-menu-content]:bg-[#A6A6A6] dark:text-black",
      "[&>.mega-menu-content]:shadow-[0px_4px_6px_-4px_rgba(134,134,134,0.5)] [&>.mega-menu-content]:shadow-[0px_10px_15px_-3px_rgba(134,134,134,0.5)] dark:[&>.mega-menu-content]:shadow-none"
    ]
  end

  defp color_variant("bordered", "white") do
    [
      "[&>.mega-menu-content]:bg-white text-black [&>.mega-menu-content]:border-[#DDDDDD]"
    ]
  end

  defp color_variant("bordered", "dark") do
    [
      "[&>.mega-menu-content]:bg-[#282828] text-white [&>.mega-menu-content]:border-[#727272]"
    ]
  end

  defp color_variant("bordered", "natural") do
    [
      "text-[#282828] [&>.mega-menu-content]:border-[#282828] [&>.mega-menu-content]:bg-[#F3F3F3]",
      "dark:text-[#E8E8E8] dark:[&>.mega-menu-content]:border-[#E8E8E8] dark:[&>.mega-menu-content]:bg-[#4B4B4B]"
    ]
  end

  defp color_variant("bordered", "primary") do
    [
      "text-[#016974] [&>.mega-menu-content]:border-[#016974] [&>.mega-menu-content]:bg-[#E2F8FB]",
      "dark:text-[#77D5E3] dark:[&>.mega-menu-content]:border-[#77D5E3] dark:[&>.mega-menu-content]:bg-[#002D33]"
    ]
  end

  defp color_variant("bordered", "secondary") do
    [
      "text-[#175BCC] [&>.mega-menu-content]:border-[#175BCC] [&>.mega-menu-content]:bg-[#EFF4FE]",
      "dark:text-[#A9C9FF] dark:[&>.mega-menu-content]:border-[#A9C9FF] dark:[&>.mega-menu-content]:bg-[#002661]"
    ]
  end

  defp color_variant("bordered", "success") do
    [
      "text-[#166C3B] [&>.mega-menu-content]:border-[#166C3B] [&>.mega-menu-content]:bg-[#EAF6ED]",
      "dark:text-[#7FD99A] dark:[&>.mega-menu-content]:border-[#7FD99A] dark:[&>.mega-menu-content]:bg-[#002F14]"
    ]
  end

  defp color_variant("bordered", "warning") do
    [
      "text-[#976A01] [&>.mega-menu-content]:border-[#976A01] [&>.mega-menu-content]:bg-[#FFF7E6]",
      "dark:text-[#FDD067] dark:[&>.mega-menu-content]:border-[#FDD067] dark:[&>.mega-menu-content]:bg-[#322300]"
    ]
  end

  defp color_variant("bordered", "danger") do
    [
      "text-[#BB032A] [&>.mega-menu-content]:border-[#BB032A] [&>.mega-menu-content]:bg-[#FFF0EE]",
      "dark:text-[#FFB2AB] dark:[&>.mega-menu-content]:border-[#FFB2AB] dark:[&>.mega-menu-content]:bg-[#520810]"
    ]
  end

  defp color_variant("bordered", "info") do
    [
      "text-[#0B84BA] [&>.mega-menu-content]:border-[#0B84BA] [&>.mega-menu-content]:bg-[#E7F6FD]",
      "dark:text-[#6EC9F2] dark:[&>.mega-menu-content]:border-[#6EC9F2] dark:[&>.mega-menu-content]:bg-[#03212F]"
    ]
  end

  defp color_variant("bordered", "misc") do
    [
      "text-[#653C94] [&>.mega-menu-content]:border-[#653C94] [&>.mega-menu-content]:bg-[#F6F0FE]",
      "dark:text-[#CBA2FA] dark:[&>.mega-menu-content]:border-[#CBA2FA] dark:[&>.mega-menu-content]:bg-[#221431]"
    ]
  end

  defp color_variant("bordered", "dawn") do
    [
      "text-[#7E4B2A] [&>.mega-menu-content]:border-[#7E4B2A] [&>.mega-menu-content]:bg-[#FBF2ED]",
      "dark:text-[#E4B190] dark:[&>.mega-menu-content]:border-[#E4B190] dark:[&>.mega-menu-content]:bg-[#2A190E]"
    ]
  end

  defp color_variant("bordered", "silver") do
    [
      "text-[#727272] [&>.mega-menu-content]:border-[#727272] [&>.mega-menu-content]:bg-[#F3F3F3]",
      "dark:text-[#BBBBBB] dark:[&>.mega-menu-content]:border-[#BBBBBB] dark:[&>.mega-menu-content]:bg-[#4B4B4B]"
    ]
  end

  defp color_variant("gradient", "natural") do
    [
      "[&>.mega-menu-content]:bg-gradient-to-br from-[#282828] to-[#727272] text-white",
      "dark:from-[#A6A6A6] dark:to-[#FFFFFF] dark:text-black"
    ]
  end

  defp color_variant("gradient", "primary") do
    [
      "[&>.mega-menu-content]:bg-gradient-to-br from-[#016974] to-[#01B8CA] text-white",
      "dark:from-[#01B8CA] dark:to-[#B0E7EF] dark:text-black"
    ]
  end

  defp color_variant("gradient", "secondary") do
    [
      "[&>.mega-menu-content]:bg-gradient-to-br from-[#175BCC] to-[#6DAAFB] text-white",
      "dark:from-[#6DAAFB] dark:to-[#CDDEFF] dark:text-black"
    ]
  end

  defp color_variant("gradient", "success") do
    [
      "[&>.mega-menu-content]:bg-gradient-to-br from-[#166C3B] to-[#06C167] text-white",
      "dark:from-[#06C167] dark:to-[#B1EAC2] dark:text-black"
    ]
  end

  defp color_variant("gradient", "warning") do
    [
      "[&>.mega-menu-content]:bg-gradient-to-br from-[#976A01] to-[#FDC034] text-white",
      "dark:from-[#FDC034] dark:to-[#FEDF99] dark:text-black"
    ]
  end

  defp color_variant("gradient", "danger") do
    [
      "[&>.mega-menu-content]:bg-gradient-to-br from-[#BB032A] to-[#FC7F79] text-white",
      "dark:from-[#FC7F79] dark:to-[#FFD2CD] dark:text-black"
    ]
  end

  defp color_variant("gradient", "info") do
    [
      "[&>.mega-menu-content]:bg-gradient-to-br from-[#08638C] to-[#3EB7ED] text-white",
      "dark:from-[#3EB7ED] dark:to-[#9FDBF6] dark:text-black"
    ]
  end

  defp color_variant("gradient", "misc") do
    [
      "[&>.mega-menu-content]:bg-gradient-to-br from-[#653C94] to-[#BA83F9] text-white",
      "dark:from-[#BA83F9] dark:to-[#DDC1FC] dark:text-black"
    ]
  end

  defp color_variant("gradient", "dawn") do
    [
      "[&>.mega-menu-content]:bg-gradient-to-br from-[#7E4B2A] to-[#DB976B] text-white",
      "dark:from-[#DB976B] dark:to-[#EDCBB5] dark:text-black"
    ]
  end

  defp color_variant("gradient", "silver") do
    [
      "[&>.mega-menu-content]:bg-gradient-to-br from-[#5E5E5E] to-[#A6A6A6] text-white",
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
