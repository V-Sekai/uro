defmodule UroWeb.Components.Tabs do
  @moduledoc """
  `UroWeb.Components.Tabs` is a Phoenix component module that provides a highly customizable tab
  interface for organizing and displaying content.

  It allows the creation of both horizontal and vertical tabs with different styles, colors, and sizes.

  The component supports various features such as icon placement, active state management,
  and different border and padding options.

  ## Features

  - **Vertical and Horizontal Layouts:** Choose between a vertical or horizontal arrangement for the tabs.
  - **Customizable Styles:** Supports multiple `variant` styles such as `default`, and `pills`.
  - **Flexible Size Options:** Adjust the overall size of elements, including padding and font size.
  - **Color Themes:** Offers a range of color themes such as `primary`, `secondary`, `success`, and more.
  - **Active State Management:** Automatically manages active states and interactions with tabs.
  - **Dynamic Content Slots:** Define tab and panel content using dynamic slots for easy customization.

  ### Functionality:

  The component uses Phoenix.LiveView.JS to manage the visibility and active state of the tabs dynamically.
  It provides utility functions like show_tab/3 and hide_tab/3 for controlling the visibility of specific
  tabs and panels programmatically.
  """

  use Phoenix.Component
  alias Phoenix.LiveView.JS
  import UroWeb.Components.Badge, only: [badge: 1]

  @doc """
  The `tabs` component provides a set of clickable tabs for organizing content.

  Each tab can have an icon and supports various styles and configurations like vertical
  or horizontal alignment.

  ## Examples

  ```elixir
  <.tabs id="tab-1" color="warning" padding="large" gap="small" variant="pills" vertical>
    <:tab icon="hero-home">1</:tab>
    <:tab icon="hero-home">2</:tab>
    <:tab icon="hero-home" active>3</:tab>

    <:panel>
      <p>
        Tab1 Lorem ipsum dolor sit amet consectetur adipisicing elit. Nostrum quis sapiente id?
      </p>
    </:panel>
    <:panel>
      <p>
        Tab2 Lorem ipsum dolor sit amet consectetur adipisicing elit. Nostrum quis sapiente id?
      </p>
    </:panel>
    <:panel>
      <p>
        Tab3 Lorem ipsum dolor sit amet consectetur adipisicing elit. Nostrum quis sapiente id?
      </p>
    </:panel>
  </.tabs>
  ```
  """
  @doc type: :component
  attr :id, :string,
    required: true,
    doc: "A unique identifier is used to manage state and interaction"

  attr :variant, :string, default: "base", doc: "Determines the style"
  attr :color, :string, default: "base", doc: "Determines color theme"
  attr :border, :string, default: "none", doc: "Determines border style"
  attr :tab_border_size, :string, default: "small", doc: "Determines border style for tab"
  attr :full_width_tab, :boolean, default: false, doc: "Determines border style for tab"
  attr :hide_list_border, :boolean, default: false, doc: "Determines border style for tab"

  attr :size, :string,
    default: "small",
    doc: "",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :gap, :string, default: "", doc: "Determines gap for tabs"
  attr :rounded, :string, default: "none", doc: "Determines the border radius"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :padding, :string, default: "extra_small", doc: "Determines padding for items"
  attr :content_padding, :string, default: "extra_small", doc: "Determines padding for items"
  attr :triggers_position, :string, default: "extra_small", doc: ""
  attr :vertical, :boolean, default: false, doc: "Determines whether element is vertical"
  attr :placement, :string, default: "start", doc: ""
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  slot :tab, required: true do
    attr :icon, :string, doc: "Icon displayed alongside of an item"
    attr :class, :string, doc: "Custom CSS class for additional styling"
    attr :padding, :string, doc: "Determines padding for items"
    attr :icon_class, :string, doc: "Determines custom class for the icon"
    attr :icon_position, :string, doc: "Determines icon position"
    attr :active, :boolean, doc: "Indicates whether the element is currently active and visible"
    attr :badge, :string, doc: "Add badge to tab"
    attr :badge_color, :string, doc: "badge color"
    attr :badge_position, :string, doc: "badge position"
    attr :badge_size, :string, doc: "badge size"
    attr :badge_variant, :string, doc: "badge color varinat"
    attr :on_select, :any, doc: "Custom JS module for on_select action"
  end

  slot :panel, required: false do
    attr :class, :string, doc: "Custom CSS class for additional styling"
  end

  def tabs(%{vertical: true} = assigns) do
    assigns =
      assign_new(assigns, :mounted_active_tab, fn ->
        Enum.find(assigns.tab, &Map.get(&1, :active))
      end)

    ~H"""
    <div
      id={@id}
      phx-mounted={is_nil(@mounted_active_tab) && hide_tab(@id, length(@tab)) |> show_tab(@id, 1)}
      class={[
        "vertical-tab flex dark:text-gray-200",
        @placement == "end" && "flex-row-reverse",
        content_position(@triggers_position),
        @variant == "default" || (@variant == "base" && tab_border(@tab_border_size, @vertical)),
        color_variant(@variant, @color),
        rounded_size(@rounded, @variant),
        padding_size(@padding),
        content_padding(@content_padding),
        border_class(@border),
        size_class(@size),
        gap_size(@gap),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <div
        role="tablist"
        tabindex="0"
        class={[
          "tab-trigger-list flex flex-col shrink-0 text-[#4B4B4B] dark:text-[#DDDDDD]",
          @variant == "default" &&
            "border-[#e8e8e8] dark:border-[#5e5e5e] [&:not(.active-tab)_.tab-trigger]:border-[#e8e8e8] dark:[&:not(.active-tab)_.tab-trigger]:border-[#5e5e5e]",
          @variant == "base" &&
            "border-[#e4e4e7] dark:border-[#27272A] [&:not(.active-tab)_.tab-trigger]:border-[#e4e4e7] dark:[&:not(.active-tab)_.tab-trigger]:border-[#27272a]"
        ]}
      >
        <button
          :for={{tab, index} <- Enum.with_index(@tab, 1)}
          id={"#{@id}-tab-header-#{index}"}
          phx-show-tab={hide_tab(@id, length(@tab)) |> show_tab(@id, index)}
          phx-click={
            if is_nil(tab[:on_select]) do
              JS.exec("phx-show-tab", to: "##{@id}-tab-header-#{index}")
            else
              JS.exec(tab[:on_select] || %JS{}, "phx-show-tab", to: "##{@id}-tab-header-#{index}")
            end
          }
          phx-mounted={tab[:active] && JS.exec("phx-show-tab", to: "##{@id}-tab-header-#{index}")}
          role="tab"
          class={[
            "tab-trigger flex flex-row flex-nowrap items-center gap-1.5 leading-5",
            "transition-all duration-400 delay-100 disabled:opacity-80",
            tab[:icon_position] == "end" && tab[:badge_position] == "end" && "flex-row-reverse",
            tab[:class]
          ]}
        >
          <.icon :if={tab[:icon]} name={tab[:icon]} class="tab-icon" />
          <.badge
            :if={tab[:badge]}
            variant={tab[:badge_variant] || "default"}
            color={tab[:badge_color] || "natural"}
            size={tab[:badge_size] || "extra_small"}
            rounded="full"
            circle
          >
            {tab[:badge]}
          </.badge>
          <span class="block tab-button_contnet">
            {render_slot(tab)}
          </span>
        </button>
      </div>

      <div class="ms-2 flex-1">
        <div
          :for={{panel, index} <- Enum.with_index(@panel, 1)}
          id={"#{@id}-tab-panel-#{index}"}
          role="tabpanel"
          class={[
            "tab-content",
            "[&:not(.active-tab-panel)]:hidden [&:not(.active-tab-panel)]:opacity-0 [&:not(.active-tab-panel)]:invisible",
            "[&.active-tab-panel]:block [&.active-tab-panel]:opacity-100 [&.active-tab-panel]:visible",
            panel[:class]
          ]}
        >
          {render_slot(panel)}
        </div>
      </div>
    </div>
    """
  end

  def tabs(assigns) do
    assigns =
      assign_new(assigns, :mounted_active_tab, fn ->
        Enum.find(assigns.tab, &Map.get(&1, :active))
      end)

    ~H"""
    <div
      id={@id}
      phx-mounted={is_nil(@mounted_active_tab) && hide_tab(@id, length(@tab)) |> show_tab(@id, 1)}
      class={[
        "horizontal-tab dark:text-gray-200",
        content_position(@triggers_position),
        @variant == "default" || (@variant == "base" && tab_border(@tab_border_size, @vertical)),
        @hide_list_border && "no-border-tabs-list [&_.tab-trigger]:flex-1",
        @full_width_tab && "[&_.tab-trigger]:flex-1",
        color_variant(@variant, @color),
        rounded_size(@rounded, @variant),
        padding_size(@padding),
        content_padding(@content_padding),
        border_class(@border),
        size_class(@size),
        gap_size(@gap),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      <div
        role="tablist"
        tabindex="0"
        class={[
          "tab-trigger-list flex flex-wrap flex-wrap",
          @variant == "nav_pills" && "tab-nav-pills bg-[#F4F4F5] dark:bg-[#27272A]",
          @variant == "nav_pills" && !@full_width_tab && "w-fit"
        ]}
      >
        <button
          :for={{tab, index} <- Enum.with_index(@tab, 1)}
          id={"#{@id}-tab-header-#{index}"}
          phx-click={
            if is_nil(tab[:on_select]) do
              hide_tab(@id, length(@tab)) |> show_tab(@id, index)
            else
              tab[:on_select] |> hide_tab(@id, length(@tab)) |> show_tab(@id, index)
            end
          }
          role="tab"
          class={[
            "tab-trigger flex flex-row flex-nowrap justify-center items-center gap-1.5 leading-5",
            "transition-all duration-400 delay-100 disabled:opacity-80",
            tab[:icon_position] == "end" && tab[:badge_position] == "end" && "flex-row-reverse",
            tab[:class]
          ]}
        >
          <.icon :if={tab[:icon]} name={tab[:icon]} class="tab-icon" />
          <.badge
            :if={tab[:badge]}
            variant={tab[:badge_variant] || "default"}
            color={tab[:badge_color] || "natural"}
            size={tab[:badge_size] || "extra_small"}
            rounded="full"
            circle
          >
            {tab[:badge]}
          </.badge>
          <span class="block tab-button_contnet">
            {render_slot(tab)}
          </span>
        </button>
      </div>

      <div class="mt-2">
        <div
          :for={{panel, index} <- Enum.with_index(@panel, 1)}
          id={"#{@id}-tab-panel-#{index}"}
          role="tabpanel"
          class={[
            "tab-content w-full",
            "[&:not(.active-tab-panel)]:hidden [&:not(.active-tab-panel)]:opacity-0 [&:not(.active-tab-panel)]:invisible",
            "[&.active-tab-panel]:block [&.active-tab-panel]:opacity-100 [&.active-tab-panel]:visible",
            panel[:class]
          ]}
        >
          {render_slot(panel)}
        </div>
      </div>
    </div>
    """
  end

  defp content_position("start") do
    [
      "[&_.horizontal-tab_.tab-trigger-list]:justify-start",
      "[&_.vertical-tab_.tab-trigger-list]:justify-start"
    ]
  end

  defp content_position("end") do
    [
      "[&_.horizontal-tab_.tab-trigger-list]:justify-end",
      "[&_.vertical-tab_.tab-trigger-list]:justify-end"
    ]
  end

  defp content_position("center") do
    [
      "[&_.horizontal-tab_.tab-trigger-list]:justify-center",
      "[&_.vertical-tab_.tab-trigger-list]:justify-center"
    ]
  end

  defp content_position("between") do
    [
      "[&_.horizontal-tab_.tab-trigger-list]:justify-between",
      "[&_.vertical-tab_.tab-trigger-list]:justify-between"
    ]
  end

  defp content_position("around") do
    [
      "[&_.horizontal-tab_.tab-trigger-list]:justify-around",
      "[&_.vertical-tab_.tab-trigger-list]:justify-around"
    ]
  end

  defp content_position(params) when is_binary(params), do: params

  defp padding_size("none"), do: nil

  defp padding_size("extra_small") do
    [
      "[&_.tab-trigger]:py-1 [&_.tab-trigger]:px-2",
      "[&_.tab-nav-pills]:py-1 [&_.tab-nav-pills]:px-2"
    ]
  end

  defp padding_size("small") do
    [
      "[&_.tab-trigger]:py-1.5 [&_.tab-trigger]:px-3",
      "[&_.tab-nav-pills]:py-1.5 [&_.tab-nav-pills]:px-3"
    ]
  end

  defp padding_size("medium") do
    [
      "[&_.tab-trigger]:py-2 [&_.tab-trigger]:px-4",
      "[&_.tab-nav-pills]:py-2 [&_.tab-nav-pills]:px-4"
    ]
  end

  defp padding_size("large") do
    [
      "[&_.tab-trigger]:py-2.5 [&_.tab-trigger]:px-5",
      "[&_.tab-nav-pills]:py-2.5 [&_.tab-nav-pills]:px-5"
    ]
  end

  defp padding_size("extra_large") do
    [
      "[&_.tab-trigger]:py-3 [&_.tab-trigger]:px-5",
      "[&_.tab-nav-pills]:py-3 [&_.tab-nav-pills]:px-5"
    ]
  end

  defp padding_size(params) when is_binary(params), do: params

  defp content_padding("none"), do: nil
  defp content_padding("extra_small"), do: "[&_.tab-content]:p-2"
  defp content_padding("small"), do: "[&_.tab-content]:p-3"
  defp content_padding("medium"), do: "[&_.tab-content]:p-4"
  defp content_padding("large"), do: "[&_.tab-content]:p-5"
  defp content_padding("extra_large"), do: "[&_.tab-content]:p-6"
  defp content_padding(params) when is_binary(params), do: params

  defp size_class("extra_small"), do: "text-xs [&_.tab-icon]:size-4"

  defp size_class("small"), do: "text-sm [&_.tab-icon]:size-5"

  defp size_class("medium"), do: "text-base [&_.tab-icon]:size-6"

  defp size_class("large"), do: "text-lg [&_.tab-icon]:size-7"

  defp size_class("extra_large"), do: "text-xl [&_.tab-icon]:size-8"

  defp size_class(params) when is_binary(params), do: params

  defp gap_size("extra_small"), do: "[&_.tab-trigger-list]:gap-1"
  defp gap_size("small"), do: "[&_.tab-trigger-list]:gap-2"
  defp gap_size("medium"), do: "[&_.tab-trigger-list]:gap-3"
  defp gap_size("large"), do: "[&_.tab-trigger-list]:gap-4"
  defp gap_size("extra_large"), do: "[&_.tab-trigger-list]:gap-5"
  defp gap_size("none"), do: nil
  defp gap_size(params) when is_binary(params), do: params

  defp border_class("none"), do: nil
  defp border_class("extra_small"), do: "border"
  defp border_class("small"), do: "border-2"
  defp border_class("medium"), do: "border-[3px]"
  defp border_class("large"), do: "border-4"
  defp border_class("extra_large"), do: "border-[5px]"
  defp border_class(params) when is_binary(params), do: [params]
  defp border_class(nil), do: border_class("none")

  defp tab_border("none", true), do: nil
  defp tab_border("extra_small", true), do: "[&_.tab-trigger]:border-e"
  defp tab_border("small", true), do: "[&_.tab-trigger]:border-e-2"
  defp tab_border("medium", true), do: "[&_.tab-trigger]:border-e-[3px]"
  defp tab_border("large", true), do: "[&_.tab-trigger]:border-e-4"
  defp tab_border("extra_large", true), do: "[&_.tab-trigger]:border-e-[5px]"
  defp tab_border(params, true) when is_binary(params), do: [params]

  defp tab_border("none", false), do: nil

  defp tab_border("extra_small", false) do
    [
      "[&_.tab-trigger]:border-b [&_.tab-trigger]:-mb-px",
      "[&:not(.no-border-tabs-list)_.tab-trigger-list]:border-b"
    ]
  end

  defp tab_border("small", false) do
    [
      "[&_.tab-trigger]:border-b-2 [&_.tab-trigger]:-mb-0.5",
      "[&:not(.no-border-tabs-list)_.tab-trigger-list]:border-b-2"
    ]
  end

  defp tab_border("medium", false) do
    [
      "[&_.tab-trigger]:border-b-[3px]  [&_.tab-trigger]:-mb-1",
      "[&:not(.no-border-tabs-list)_.tab-trigger-list]:border-b-[3px]"
    ]
  end

  defp tab_border("large", false) do
    [
      "[&_.tab-trigger]:border-b-4 [&_.tab-trigger]:-mb-1.5",
      "[&:not(.no-border-tabs-list)_.tab-trigger-list]:border-b-4"
    ]
  end

  defp tab_border("extra_large", false) do
    [
      "[&_.tab-trigger]:border-b-[5px] [&_.tab-trigger]:-mb-2",
      "[&:not(.no-border-tabs-list)_.tab-trigger-list]:border-b-[5px]"
    ]
  end

  defp tab_border(params, false) when is_binary(params), do: [params]

  defp rounded_size("none", "default"), do: nil

  defp rounded_size("extra_small", "default"), do: "[&_.tab-trigger]:rounded-t-sm"

  defp rounded_size("small", "default"), do: "[&_.tab-trigger]:rounded-t"

  defp rounded_size("medium", "default"), do: "[&_.tab-trigger]:rounded-t-md"

  defp rounded_size("large", "default"), do: "[&_.tab-trigger]:rounded-t-lg"

  defp rounded_size("extra_large", "default"), do: "[&_.tab-trigger]:rounded-t-xl"

  defp rounded_size("none", "pills"), do: "[&_.tab-trigger]:rounded-none"

  defp rounded_size("extra_small", "pills"), do: "[&_.tab-trigger]:rounded-sm"

  defp rounded_size("small", "pills"), do: "[&_.tab-trigger]:rounded"

  defp rounded_size("medium", "pills"), do: "[&_.tab-trigger]:rounded-md"

  defp rounded_size("large", "pills"), do: "[&_.tab-trigger]:rounded-lg"

  defp rounded_size("extra_large", "pills"), do: "[&_.tab-trigger]:rounded-xl"

  defp rounded_size("full", "pills"), do: "[&_.tab-trigger]:rounded-full"

  defp rounded_size("none", "nav_pills"),
    do: "[&_.tab-trigger]:rounded-none [&_.tab-nav-pills]:rounded-none"

  defp rounded_size("extra_small", "nav_pills"),
    do: "[&_.tab-trigger]:rounded-sm [&_.tab-nav-pills]:rounded-sm"

  defp rounded_size("small", "nav_pills"),
    do: "[&_.tab-trigger]:rounded [&_.tab-nav-pills]:rounded"

  defp rounded_size("medium", "nav_pills"),
    do: "[&_.tab-trigger]:rounded-md [&_.tab-nav-pills]:rounded-md"

  defp rounded_size("large", "nav_pills"),
    do: "[&_.tab-trigger]:rounded-lg [&_.tab-nav-pills]:rounded-lg"

  defp rounded_size("extra_large", "nav_pills"),
    do: "[&_.tab-trigger]:rounded-xl [&_.tab-nav-pills]:rounded-xl"

  defp rounded_size("full", "nav_pills"),
    do: "[&_.tab-trigger]:rounded-full [&_.tab-nav-pills]:rounded-full"

  defp rounded_size(params, _) when is_binary(params), do: [params]

  defp color_variant("base", _) do
    [
      "[&_.tab-trigger.active-tab]:bg-[#e4e4e7] [&_.tab-trigger.active-tab]:text-[#09090b]",
      "[&_.tab-trigger.active-tab]:border-[#e4e4e7]",
      "hover:[&_.tab-trigger]:text-[#09090b] hover:[&_.tab-trigger]:border-[#e4e4e7]",
      "[&_.tab-trigger]:border-[#e4e4e7] dark:[&_.tab-trigger]:border-[#27272a]",
      "dark:[&_.tab-trigger.active-tab]:bg-[#27272a] dark:[&_.tab-trigger.active-tab]:text-[#FAFAFA]",
      "dark:[&_.tab-trigger.active-tab]:border-[#27272a] ",
      "dark:hover:[&_.tab-trigger]:text-[#FAFAFA] dark:hover:[&_.tab-trigger]:border-[#27272a]",
      "hover:[&_.tab-trigger]:bg-[#e4e4e7] dark:hover:[&_.tab-trigger]:bg-[#27272a]",
      "dark:[&_.tab-trigger-list]:border-[#27272A] [&_.tab-trigger-list]:border-[#e4e4e7]"
    ]
  end

  defp color_variant("default", "natural") do
    [
      "[&_.tab-trigger.active-tab]:text-[#282828] [&_.tab-trigger.active-tab]:border-[#282828]",
      "hover:[&_.tab-trigger]:text-[#282828] hover:[&_.tab-trigger]:border-[#282828]",
      "dark:[&_.tab-trigger.active-tab]:text-white dark:[&_.tab-trigger.active-tab]:border-white ",
      "dark:hover:[&_.tab-trigger]:text-white dark:hover:[&_.tab-trigger]:border-white"
    ]
  end

  defp color_variant("default", "primary") do
    [
      "[&_.tab-trigger.active-tab]:text-[#016974] [&_.tab-trigger.active-tab]:border-[#016974]",
      "hover:[&_.tab-trigger]:text-[#016974] hover:[&_.tab-trigger]:border-[#016974]",
      "dark:[&_.tab-trigger.active-tab]:text-[#77D5E3] dark:[&_.tab-trigger.active-tab]:border-[#77D5E3]",
      "dark:hover:[&_.tab-trigger]:text-[#77D5E3] dark:hover:[&_.tab-trigger]:border-[#77D5E3]"
    ]
  end

  defp color_variant("default", "secondary") do
    [
      "[&_.tab-trigger.active-tab]:text-[#175BCC] [&_.tab-trigger.active-tab]:border-[#175BCC]",
      "hover:[&_.tab-trigger]:text-[#175BCC] hover:[&_.tab-trigger]:border-[#175BCC]",
      "dark:[&_.tab-trigger.active-tab]:text-[#A9C9FF] dark:[&_.tab-trigger.active-tab]:border-[#A9C9FF]",
      "dark:hover:[&_.tab-trigger]:text-[#A9C9FF] dark:hover:[&_.tab-trigger]:border-[#A9C9FF]"
    ]
  end

  defp color_variant("default", "success") do
    [
      "[&_.tab-trigger.active-tab]:text-[#166C3B] [&_.tab-trigger.active-tab]:border-[#166C3B]",
      "hover:[&_.tab-trigger]:text-[#166C3B] hover:[&_.tab-trigger]:border-[#166C3B]",
      "dark:[&_.tab-trigger.active-tab]:text-[#7FD99A] dark:[&_.tab-trigger.active-tab]:border-[#7FD99A]",
      "dark:hover:[&_.tab-trigger]:text-[#7FD99A] dark:hover:[&_.tab-trigger]:border-[#7FD99A]"
    ]
  end

  defp color_variant("default", "warning") do
    [
      "[&_.tab-trigger.active-tab]:text-[#976A01] [&_.tab-trigger.active-tab]:border-[#976A01]",
      "hover:[&_.tab-trigger]:text-[#976A01] hover:[&_.tab-trigger]:border-[#976A01]",
      "dark:[&_.tab-trigger.active-tab]:text-[#FDD067] dark:[&_.tab-trigger.active-tab]:border-[#FDD067]",
      "dark:hover:[&_.tab-trigger]:text-[#FDD067] dark:hover:[&_.tab-trigger]:border-[#FDD067]"
    ]
  end

  defp color_variant("default", "danger") do
    [
      "[&_.tab-trigger.active-tab]:text-[#BB032A] [&_.tab-trigger.active-tab]:border-[#BB032A]",
      "hover:[&_.tab-trigger]:text-[#BB032A] hover:[&_.tab-trigger]:border-[#BB032A]",
      "dark:[&_.tab-trigger.active-tab]:text-[#FFB2AB] dark:[&_.tab-trigger.active-tab]:border-[#FFB2AB]",
      "dark:hover:[&_.tab-trigger]:text-[#FFB2AB] dark:hover:[&_.tab-trigger]:border-[#FFB2AB]"
    ]
  end

  defp color_variant("default", "info") do
    [
      "[&_.tab-trigger.active-tab]:text-[#08638C] [&_.tab-trigger.active-tab]:border-[#08638C]",
      "hover:[&_.tab-trigger]:text-[#08638C] hover:[&_.tab-trigger]:border-[#08638C]",
      "dark:[&_.tab-trigger.active-tab]:text-[#6EC9F2] dark:[&_.tab-trigger.active-tab]:border-[#6EC9F2]",
      "dark:hover:[&_.tab-trigger]:text-[#6EC9F2] dark:hover:[&_.tab-trigger]:border-[#6EC9F2]"
    ]
  end

  defp color_variant("default", "misc") do
    [
      "[&_.tab-trigger.active-tab]:text-[#653C94] [&_.tab-trigger.active-tab]:border-[#653C94]",
      "hover:[&_.tab-trigger]:text-[#653C94] hover:[&_.tab-trigger]:border-[#653C94]",
      "dark:[&_.tab-trigger.active-tab]:text-[#CBA2FA] dark:[&_.tab-trigger.active-tab]:border-[#CBA2FA]",
      "dark:hover:[&_.tab-trigger]:text-[#CBA2FA] dark:hover:[&_.tab-trigger]:border-[#CBA2FA]"
    ]
  end

  defp color_variant("default", "dawn") do
    [
      "[&_.tab-trigger.active-tab]:text-[#7E4B2A] [&_.tab-trigger.active-tab]:border-[#7E4B2A]",
      "hover:[&_.tab-trigger]:text-[#7E4B2A] hover:[&_.tab-trigger]:border-[#7E4B2A]",
      "dark:[&_.tab-trigger.active-tab]:text-[#E4B190] dark:[&_.tab-trigger.active-tab]:border-[#E4B190]",
      "dark:hover:[&_.tab-trigger]:text-[#E4B190] dark:hover:[&_.tab-trigger]:border-[#E4B190]"
    ]
  end

  defp color_variant("default", "silver") do
    [
      "[&_.tab-trigger.active-tab]:text-[#727272] [&_.tab-trigger.active-tab]:border-[#727272]",
      "hover:[&_.tab-trigger]:text-[#727272] hover:[&_.tab-trigger]:border-[#727272]",
      "dark:[&_.tab-trigger.active-tab]:text-[#BBBBBB] dark:[&_.tab-trigger.active-tab]:border-[#BBBBBB]",
      "dark:hover:[&_.tab-trigger]:text-[#BBBBBB] dark:hover:[&_.tab-trigger]:border-[#BBBBBB]"
    ]
  end

  defp color_variant("pills", "natural") do
    [
      "hover:[&_.tab-trigger]:text-white hover:[&_.tab-trigger]:bg-[#282828]",
      "[&_.tab-trigger.active-tab]:text-white [&_.tab-trigger.active-tab]:bg-[#4B4B4B]",
      "dark:hover:[&_.tab-trigger]:text-black dark:hover:[&_.tab-trigger]:bg-[#E8E8E8]",
      "dark:[&_.tab-trigger.active-tab]:text-black dark:[&_.tab-trigger.active-tab]:bg-[#DDDDDD]"
    ]
  end

  defp color_variant("pills", "primary") do
    [
      "hover:[&_.tab-trigger]:text-white hover:[&_.tab-trigger]:bg-[#016974]",
      "[&_.tab-trigger.active-tab]:text-white [&_.tab-trigger.active-tab]:bg-[#007F8C]",
      "dark:hover:[&_.tab-trigger]:text-black dark:hover:[&_.tab-trigger]:bg-[#77D5E3]",
      "dark:[&_.tab-trigger.active-tab]:text-black dark:[&_.tab-trigger.active-tab]:bg-[#01B8CA]"
    ]
  end

  defp color_variant("pills", "secondary") do
    [
      "hover:[&_.tab-trigger]:text-white hover:[&_.tab-trigger]:bg-[#175BCC]",
      "[&_.tab-trigger.active-tab]:text-white [&_.tab-trigger.active-tab]:bg-[#266EF1]",
      "dark:hover:[&_.tab-trigger]:text-black dark:hover:[&_.tab-trigger]:bg-[#A9C9FF]",
      "dark:[&_.tab-trigger.active-tab]:text-black dark:[&_.tab-trigger.active-tab]:bg-[#6DAAFB]"
    ]
  end

  defp color_variant("pills", "success") do
    [
      "hover:[&_.tab-trigger]:text-white hover:[&_.tab-trigger]:bg-[#166C3B]",
      "[&_.tab-trigger.active-tab]:text-white [&_.tab-trigger.active-tab]:bg-[#0E8345]",
      "dark:hover:[&_.tab-trigger]:text-black dark:hover:[&_.tab-trigger]:bg-[#7FD99A]",
      "dark:[&_.tab-trigger.active-tab]:text-black dark:[&_.tab-trigger.active-tab]:bg-[#06C167]"
    ]
  end

  defp color_variant("pills", "warning") do
    [
      "hover:[&_.tab-trigger]:text-white hover:[&_.tab-trigger]:bg-[#976A01]",
      "[&_.tab-trigger.active-tab]:text-white [&_.tab-trigger.active-tab]:bg-[#CA8D01]",
      "dark:hover:[&_.tab-trigger]:text-black dark:hover:[&_.tab-trigger]:bg-[#FDD067]",
      "dark:[&_.tab-trigger.active-tab]:text-black dark:[&_.tab-trigger.active-tab]:bg-[#FDC034]"
    ]
  end

  defp color_variant("pills", "danger") do
    [
      "hover:[&_.tab-trigger]:text-white hover:[&_.tab-trigger]:bg-[#BB032A]",
      "[&_.tab-trigger.active-tab]:text-white [&_.tab-trigger.active-tab]:bg-[#DE1135]",
      "dark:hover:[&_.tab-trigger]:text-black dark:hover:[&_.tab-trigger]:bg-[#FFB2AB]",
      "dark:[&_.tab-trigger.active-tab]:text-black dark:[&_.tab-trigger.active-tab]:bg-[#FC7F79]"
    ]
  end

  defp color_variant("pills", "info") do
    [
      "hover:[&_.tab-trigger]:text-white hover:[&_.tab-trigger]:bg-[#08638C]",
      "[&_.tab-trigger.active-tab]:text-white [&_.tab-trigger.active-tab]:bg-[#0B84BA]",
      "dark:hover:[&_.tab-trigger]:text-black dark:hover:[&_.tab-trigger]:bg-[#6EC9F2]",
      "dark:[&_.tab-trigger.active-tab]:text-black dark:[&_.tab-trigger.active-tab]:bg-[#3EB7ED]"
    ]
  end

  defp color_variant("pills", "misc") do
    [
      "hover:[&_.tab-trigger]:text-white hover:[&_.tab-trigger]:bg-[#653C94]",
      "[&_.tab-trigger.active-tab]:text-white [&_.tab-trigger.active-tab]:bg-[#8750C5]",
      "dark:hover:[&_.tab-trigger]:text-black dark:hover:[&_.tab-trigger]:bg-[#CBA2FA]",
      "dark:[&_.tab-trigger.active-tab]:text-black dark:[&_.tab-trigger.active-tab]:bg-[#BA83F9]"
    ]
  end

  defp color_variant("pills", "dawn") do
    [
      "hover:[&_.tab-trigger]:text-white hover:[&_.tab-trigger]:bg-[#7E4B2A]",
      "[&_.tab-trigger.active-tab]:text-white [&_.tab-trigger.active-tab]:bg-[#A86438]",
      "dark:hover:[&_.tab-trigger]:text-black dark:hover:[&_.tab-trigger]:bg-[#E4B190]",
      "dark:[&_.tab-trigger.active-tab]:text-black dark:[&_.tab-trigger.active-tab]:bg-[#DB976B]"
    ]
  end

  defp color_variant("pills", "silver") do
    [
      "hover:[&_.tab-trigger]:text-white hover:[&_.tab-trigger]:bg-[#727272]",
      "[&_.tab-trigger.active-tab]:text-white [&_.tab-trigger.active-tab]:bg-[#868686]",
      "dark:hover:[&_.tab-trigger]:text-black dark:hover:[&_.tab-trigger]:bg-[#BBBBBB]",
      "dark:[&_.tab-trigger.active-tab]:text-black dark:[&_.tab-trigger.active-tab]:bg-[#A6A6A6]"
    ]
  end

  defp color_variant("nav_pills", "base") do
    [
      "hover:[&_.tab-trigger]:text-[#09090b] hover:[&_.tab-trigger]:bg-[#e4e4e7]",
      "[&_.tab-trigger.active-tab]:text-[#09090b] [&_.tab-trigger.active-tab]:bg-white",
      "dark:hover:[&_.tab-trigger]:text-[#FAFAFA] dark:hover:[&_.tab-trigger]:bg-[#18181B]",
      "dark:[&_.tab-trigger.active-tab]:text-[#FAFAFA] dark:[&_.tab-trigger.active-tab]:bg-[#18181B]"
    ]
  end

  defp color_variant("nav_pills", "natural") do
    [
      "hover:[&_.tab-trigger]:text-white hover:[&_.tab-trigger]:bg-[#282828]",
      "[&_.tab-trigger.active-tab]:text-white [&_.tab-trigger.active-tab]:bg-[#4B4B4B]",
      "dark:hover:[&_.tab-trigger]:text-black dark:hover:[&_.tab-trigger]:bg-[#E8E8E8]",
      "dark:[&_.tab-trigger.active-tab]:text-black dark:[&_.tab-trigger.active-tab]:bg-[#DDDDDD]"
    ]
  end

  defp color_variant("nav_pills", "primary") do
    [
      "hover:[&_.tab-trigger]:text-white hover:[&_.tab-trigger]:bg-[#016974]",
      "[&_.tab-trigger.active-tab]:text-white [&_.tab-trigger.active-tab]:bg-[#007F8C]",
      "dark:hover:[&_.tab-trigger]:text-black dark:hover:[&_.tab-trigger]:bg-[#77D5E3]",
      "dark:[&_.tab-trigger.active-tab]:text-black dark:[&_.tab-trigger.active-tab]:bg-[#01B8CA]"
    ]
  end

  defp color_variant("nav_pills", "secondary") do
    [
      "hover:[&_.tab-trigger]:text-white hover:[&_.tab-trigger]:bg-[#175BCC]",
      "[&_.tab-trigger.active-tab]:text-white [&_.tab-trigger.active-tab]:bg-[#266EF1]",
      "dark:hover:[&_.tab-trigger]:text-black dark:hover:[&_.tab-trigger]:bg-[#A9C9FF]",
      "dark:[&_.tab-trigger.active-tab]:text-black dark:[&_.tab-trigger.active-tab]:bg-[#6DAAFB]"
    ]
  end

  defp color_variant("nav_pills", "success") do
    [
      "hover:[&_.tab-trigger]:text-white hover:[&_.tab-trigger]:bg-[#166C3B]",
      "[&_.tab-trigger.active-tab]:text-white [&_.tab-trigger.active-tab]:bg-[#0E8345]",
      "dark:hover:[&_.tab-trigger]:text-black dark:hover:[&_.tab-trigger]:bg-[#7FD99A]",
      "dark:[&_.tab-trigger.active-tab]:text-black dark:[&_.tab-trigger.active-tab]:bg-[#06C167]"
    ]
  end

  defp color_variant("nav_pills", "warning") do
    [
      "hover:[&_.tab-trigger]:text-white hover:[&_.tab-trigger]:bg-[#976A01]",
      "[&_.tab-trigger.active-tab]:text-white [&_.tab-trigger.active-tab]:bg-[#CA8D01]",
      "dark:hover:[&_.tab-trigger]:text-black dark:hover:[&_.tab-trigger]:bg-[#FDD067]",
      "dark:[&_.tab-trigger.active-tab]:text-black dark:[&_.tab-trigger.active-tab]:bg-[#FDC034]"
    ]
  end

  defp color_variant("nav_pills", "danger") do
    [
      "hover:[&_.tab-trigger]:text-white hover:[&_.tab-trigger]:bg-[#BB032A]",
      "[&_.tab-trigger.active-tab]:text-white [&_.tab-trigger.active-tab]:bg-[#DE1135]",
      "dark:hover:[&_.tab-trigger]:text-black dark:hover:[&_.tab-trigger]:bg-[#FFB2AB]",
      "dark:[&_.tab-trigger.active-tab]:text-black dark:[&_.tab-trigger.active-tab]:bg-[#FC7F79]"
    ]
  end

  defp color_variant("nav_pills", "info") do
    [
      "hover:[&_.tab-trigger]:text-white hover:[&_.tab-trigger]:bg-[#08638C]",
      "[&_.tab-trigger.active-tab]:text-white [&_.tab-trigger.active-tab]:bg-[#0B84BA]",
      "dark:hover:[&_.tab-trigger]:text-black dark:hover:[&_.tab-trigger]:bg-[#6EC9F2]",
      "dark:[&_.tab-trigger.active-tab]:text-black dark:[&_.tab-trigger.active-tab]:bg-[#3EB7ED]"
    ]
  end

  defp color_variant("nav_pills", "misc") do
    [
      "hover:[&_.tab-trigger]:text-white hover:[&_.tab-trigger]:bg-[#653C94]",
      "[&_.tab-trigger.active-tab]:text-white [&_.tab-trigger.active-tab]:bg-[#8750C5]",
      "dark:hover:[&_.tab-trigger]:text-black dark:hover:[&_.tab-trigger]:bg-[#CBA2FA]",
      "dark:[&_.tab-trigger.active-tab]:text-black dark:[&_.tab-trigger.active-tab]:bg-[#BA83F9]"
    ]
  end

  defp color_variant("nav_pills", "dawn") do
    [
      "hover:[&_.tab-trigger]:text-white hover:[&_.tab-trigger]:bg-[#7E4B2A]",
      "[&_.tab-trigger.active-tab]:text-white [&_.tab-trigger.active-tab]:bg-[#A86438]",
      "dark:hover:[&_.tab-trigger]:text-black dark:hover:[&_.tab-trigger]:bg-[#E4B190]",
      "dark:[&_.tab-trigger.active-tab]:text-black dark:[&_.tab-trigger.active-tab]:bg-[#DB976B]"
    ]
  end

  defp color_variant("nav_pills", "silver") do
    [
      "hover:[&_.tab-trigger]:text-white hover:[&_.tab-trigger]:bg-[#727272]",
      "[&_.tab-trigger.active-tab]:text-white [&_.tab-trigger.active-tab]:bg-[#868686]",
      "dark:hover:[&_.tab-trigger]:text-black dark:hover:[&_.tab-trigger]:bg-[#BBBBBB]",
      "dark:[&_.tab-trigger.active-tab]:text-black dark:[&_.tab-trigger.active-tab]:bg-[#A6A6A6]"
    ]
  end

  defp color_variant(params, _) when is_binary(params), do: params

  @doc """
  Sets a specific tab as active by adding `active-tab` and `active-tab-panel` CSS classes to the
  selected tab and its corresponding panel.

  ## Parameters

    - `js` (optional): A `%Phoenix.LiveView.JS{}` struct that allows chaining multiple JS commands.
    Defaults to an empty `%JS{}`.
    - `id`: A `string` representing the unique identifier for the tab group.
    - `count`: An `integer` indicating the tab number to be activated.

  ## Usage

  ```elixir
  show_tab(%JS{}, "example-tabs", 2)
  ```
  This will activate the second tab and its corresponding panel in the tab group with the ID `example-tabs`.
  """

  def show_tab(js \\ %JS{}, id, count) when is_binary(id) do
    JS.add_class(js, "active-tab", to: "##{id}-tab-header-#{count}")
    |> JS.add_class("active-tab-panel", to: "##{id}-tab-panel-#{count}")
  end

  @doc """
  Hides all tabs in a given tab group by removing the `active-tab` and `active-tab-panel` CSS
  classes from each tab and its corresponding panel.

  ## Parameters

    - `js` (optional): A `%Phoenix.LiveView.JS{}` struct used to chain multiple JS commands.
    Defaults to an empty `%JS{}`.
    - `id`: A `string` representing the unique identifier for the tab group.
    - `count`: An `integer` indicating the total number of tabs in the group.

  ## Usage

  ```elixir
  hide_tab(%JS{}, "example-tabs", 3)
  ```

  This will deactivate all three tabs and their corresponding panels in the tab group
  with the ID `example-tabs`.
  """
  def hide_tab(js \\ %JS{}, id, count) do
    Enum.reduce(1..count, js, fn item, acc ->
      acc
      |> JS.remove_class("active-tab", to: "##{id}-tab-header-#{item}")
      |> JS.remove_class("active-tab-panel", to: "##{id}-tab-panel-#{item}")
    end)
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
