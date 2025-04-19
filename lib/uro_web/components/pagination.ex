defmodule UroWeb.Components.Pagination do
  @moduledoc """
  The `UroWeb.Components.Pagination` module provides a comprehensive and highly customizable
  pagination component for Phoenix LiveView applications.

  It is designed to handle complex pagination scenarios, supporting various styles,
  sizes, colors, and interaction patterns.

  This module offers several options to tailor the pagination component's appearance and behavior,
  such as custom icons, separators, and control buttons.

  It allows for fine-tuning of the pagination layout, including sibling and boundary
  controls, as well as different visual variants like outlined, shadowed, and inverted styles.

  These features enable developers to integrate pagination seamlessly into their UI,
  enhancing user experience and interaction.
  """

  use Phoenix.Component
  alias Phoenix.LiveView.JS

  @doc """
  Renders a `pagination` component that allows users to navigate through pages.

  The component supports various configurations such as setting the total number of pages,
  current active page, and the number of sibling and boundary pages to display.

  Custom icons or labels can be used for navigation controls, and slots are available
  for additional start and end items.

  ## Examples

  ```elixir
  <.pagination
    total={200}
    active={@posts.active}
    siblings={3}
    show_edges
    grouped
    next_label="next"
    previous_label="prev"
    first_label="first"
    last_label="last"
  />

  <.pagination total={@posts.total} active={@posts.active} siblings={3} variant="outline" show_edges grouped/>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :total, :integer, required: true, doc: ""
  attr :active, :integer, default: 1, doc: ""
  attr :siblings, :integer, default: 1, doc: ""
  attr :boundaries, :integer, default: 1, doc: ""
  attr :on_select, JS, default: %JS{}, doc: "Custom JS module for on_select action"
  attr :on_first, JS, default: %JS{}, doc: "Custom JS module for on_first action"
  attr :on_last, JS, default: %JS{}, doc: "Custom JS module for on_last action"
  attr :on_next, JS, default: %JS{}, doc: "Custom JS module for on_next action"
  attr :on_previous, JS, default: %JS{}, doc: "Custom JS module for on_previous action"

  attr :size, :string,
    default: "medium",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :space, :string, default: "small", doc: "Space between items"
  attr :color, :string, default: "base", doc: "Determines color theme"
  attr :rounded, :string, default: "small", doc: "Determines the border radius"
  attr :border, :string, default: "extra_small", doc: "Determines the border radius"

  attr :variant, :string, default: "base", doc: "Determines the style"

  attr :separator, :string,
    default: "hero-ellipsis-horizontal",
    doc: "Determines a separator for items of an element"

  attr :next_label, :string,
    default: "hero-chevron-right",
    doc: "Determines the next icon or label"

  attr :previous_label, :string,
    default: "hero-chevron-left",
    doc: "Determines the previous icon or label"

  attr :first_label, :string,
    default: "hero-chevron-double-left",
    doc: "Determines the first icon or label"

  attr :last_label, :string,
    default: "hero-chevron-double-right",
    doc: "Determines the last icon or label"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :params, :map,
    default: %{},
    doc: "A map of additional parameters used for element configuration"

  slot :start_items, required: false, doc: "Determines the start items which accept heex"
  slot :end_items, required: false, doc: "Determines the end items which accept heex"

  attr :rest, :global,
    include: ~w(disabled hide_one_page show_edges hide_controls grouped),
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  def pagination(
        %{siblings: siblings, boundaries: boundaries, total: total, active: active} = assigns
      ) do
    assigns = assign(assigns, %{siblings: build_pagination(total, active, siblings, boundaries)})

    ~H"""
    <div
      :if={show_pagination?(@rest[:hide_one_page], @total)}
      id={@id}
      class={
        default_classes() ++
          [
            color_variant(@variant, @color),
            border_size(@border, @variant),
            rounded_size(@rounded),
            size_class(@size),
            border_class(@color),
            (!is_nil(@rest[:grouped]) && "gap-0 grouped-pagination") || space_class(@space),
            @class
          ]
      }
    >
      {render_slot(@start_items)}

      <.item_button
        :if={@rest[:show_edges]}
        on_action={{"first", @on_next}}
        page={{nil, @active}}
        params={@params}
        icon={@first_label}
        disabled={@active <= 1}
      />

      <.item_button
        :if={is_nil(@rest[:hide_controls])}
        on_action={{"previous", @on_previous}}
        page={{nil, @active}}
        params={@params}
        icon={@previous_label}
        disabled={@active <= 1}
      />

      <div :for={range <- @siblings.range}>
        <%= if is_integer(range) do %>
          <.item_button on_action={{"select", @on_select}} page={{range, @active}} params={@params} />
        <% else %>
          <div class="pagination-seperator flex justify-center items-center">
            <.icon_or_text name={@separator} />
          </div>
        <% end %>
      </div>

      <.item_button
        :if={is_nil(@rest[:hide_controls])}
        on_action={{"next", @on_next}}
        page={{nil, @active}}
        params={@params}
        icon={@next_label}
        disabled={@active >= @total}
      />

      <.item_button
        :if={@rest[:show_edges]}
        on_action={{"last", @on_last}}
        page={{nil, @active}}
        params={@params}
        icon={@last_label}
        disabled={@active >= @total}
      />

      {render_slot(@end_items)}
    </div>
    """
  end

  @doc type: :component
  attr :name, :string, doc: "Specifies the name of the element"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  defp icon_or_text(%{name: "hero-" <> _icon_name} = assigns) do
    ~H"""
    <.icon name={@name} class={@class || "pagination-icon"} />
    """
  end

  defp icon_or_text(assigns) do
    ~H"""
    <span class={@class || "pagination-text"}>{@name}</span>
    """
  end

  @doc type: :component
  attr :params, :map,
    default: %{},
    doc: "A map of additional parameters used for element configuration"

  attr :page, :list, required: true, doc: "Specifies pagination pages"
  attr :on_action, JS, default: %JS{}, doc: "Custom JS module for on_action action"
  attr :icon, :string, required: false, doc: "Icon displayed alongside of an item"
  attr :disabled, :boolean, required: false, doc: "Specifies whether the element is disabled"

  defp item_button(%{on_action: {"select", _on_action}} = assigns) do
    ~H"""
    <button
      class={[
        "pagination-button",
        elem(@page, 1) == elem(@page, 0) && "active-pagination-button"
      ]}
      phx-click={
        elem(@on_action, 1)
        |> JS.push("pagination", value: Map.merge(%{action: "select", page: elem(@page, 0)}, @params))
      }
      disabled={elem(@page, 0) == elem(@page, 1)}
    >
      {elem(@page, 0)}
    </button>
    """
  end

  defp item_button(assigns) do
    ~H"""
    <button
      class="pagination-control flex items-center justify-center"
      phx-click={
        elem(@on_action, 1)
        |> JS.push("pagination", value: Map.merge(%{action: elem(@on_action, 0)}, @params))
      }
      disabled={@disabled}
    >
      <.icon_or_text name={@icon} />
    </button>
    """
  end

  # We got the original code from mantine.dev pagination hook and changed some numbers
  defp build_pagination(total, current_page, siblings, boundaries) do
    total_pages = max(total, 0)

    total_page_numbers = siblings * 2 + 3 + boundaries * 2

    pagination_range =
      if total_page_numbers >= total_pages do
        range(1, total_pages)
      else
        left_sibling_index = max(current_page - siblings, boundaries + 1)
        right_sibling_index = min(current_page + siblings, total_pages - boundaries)

        should_show_left_dots = left_sibling_index > boundaries + 2
        should_show_right_dots = right_sibling_index < total_pages - boundaries - 1

        dots = :dots

        cond do
          !should_show_left_dots and should_show_right_dots ->
            left_item_count = siblings * 2 + boundaries + 2

            range(1, left_item_count) ++
              [dots] ++ range(total_pages - boundaries + 1, total_pages)

          should_show_left_dots and not should_show_right_dots ->
            right_item_count = boundaries + 1 + 2 * siblings

            range(1, boundaries) ++
              [dots] ++ range(total_pages - right_item_count + 1, total_pages)

          true ->
            range(1, boundaries) ++
              [dots] ++
              range(left_sibling_index, right_sibling_index) ++
              [dots] ++ range(total_pages - boundaries + 1, total_pages)
        end
      end

    %{range: pagination_range(current_page, pagination_range), active: current_page}
  end

  defp pagination_range(active, range) do
    if active != 1 and (active - 1) not in range do
      index = Enum.find_index(range, &(&1 == active))
      List.insert_at(range, index, active - 1)
    else
      range
    end
  end

  defp range(start, stop) when start > stop, do: []
  defp range(start, stop), do: Enum.to_list(start..stop)

  defp space_class("extra_small"), do: "gap-2"
  defp space_class("small"), do: "gap-3"
  defp space_class("medium"), do: "gap-4"
  defp space_class("large"), do: "gap-5"
  defp space_class("extra_large"), do: "gap-6"
  defp space_class("none"), do: nil
  defp space_class(params) when is_binary(params), do: params

  defp border_size(_, variant)
       when variant in [
              "default",
              "shadow",
              "transparent",
              "subtle",
              "gradient"
            ],
       do: nil

  defp border_size("none", _), do: "[&:not(.grouped-pagination)_.pagination-button]:border-0"

  defp border_size("extra_small", _), do: "[&:not(.grouped-pagination)_.pagination-button]:border"

  defp border_size("small", _), do: "[&:not(.grouped-pagination)_.pagination-button]:border-2"

  defp border_size("medium", _),
    do: "[&:not(.grouped-pagination)_.pagination-button]:border-[3px]"

  defp border_size("large", _), do: "[&:not(.grouped-pagination)_.pagination-button]:border-4"

  defp border_size("extra_large", _),
    do: "[&:not(.grouped-pagination)_.pagination-button]:border-[5px]"

  defp border_size(params, _) when is_binary(params), do: params

  defp border_class("transparent") do
    ["[&.grouped-pagination]:border border-transparent"]
  end

  defp border_class("base") do
    [
      "[&.grouped-pagination]:border [&.grouped-pagination_.pagination-button]:border-r",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-r",
      "[&.grouped-pagination_.pagination-seperator]:border-r",
      "border-[#e4e4e7] [&.grouped-pagination_.pagination-button]:border-[#e4e4e7]",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-[#e4e4e7]",
      "[&.grouped-pagination_.pagination-seperator]:border-[#e4e4e7]",
      "dark:border-[#27272a] dark:[&.grouped-pagination_.pagination-button]:border-[#27272a]",
      "dark:[&.grouped-pagination_.pagination-control:not(:last-child)]:border-[#27272a]",
      "dark:[&.grouped-pagination_.pagination-seperator]:border-[#27272a]"
    ]
  end

  defp border_class("natural") do
    [
      "[&.grouped-pagination]:border [&.grouped-pagination_.pagination-button]:border-r",
      "border-[#DADADA] [&.grouped-pagination_.pagination-button]:border-[#DADADA]",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-r",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-[#DADADA]",
      "[&.grouped-pagination_.pagination-seperator]:border-r",
      "[&.grouped-pagination_.pagination-seperator]:border-[#DADADA]"
    ]
  end

  defp border_class("primary") do
    [
      "[&.grouped-pagination]:border [&.grouped-pagination_.pagination-button]:border-r",
      "border-[#4363EC] [&.grouped-pagination_.pagination-button]:border-[#2441de]",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-r",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-[#2441de]",
      "[&.grouped-pagination_.pagination-seperator]:border-r",
      "[&.grouped-pagination_.pagination-seperator]:border-[#2441de]"
    ]
  end

  defp border_class("secondary") do
    [
      "[&.grouped-pagination]:border [&.grouped-pagination_.pagination-button]:border-r",
      "border-[#6B6E7C] [&.grouped-pagination_.pagination-button]:border-[#3d3f49]",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-r",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-[#3d3f49]",
      "[&.grouped-pagination_.pagination-seperator]:border-r",
      "[&.grouped-pagination_.pagination-seperator]:border-[#3d3f49]"
    ]
  end

  defp border_class("success") do
    [
      "[&.grouped-pagination]:border [&.grouped-pagination_.pagination-button]:border-r",
      "border-[#227A52] [&.grouped-pagination_.pagination-button]:border-[#227A52]",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-r",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-[#227A52]",
      "[&.grouped-pagination_.pagination-seperator]:border-r",
      "[&.grouped-pagination_.pagination-seperator]:border-[#227A52]"
    ]
  end

  defp border_class("warning") do
    [
      "[&.grouped-pagination]:border [&.grouped-pagination_.pagination-button]:border-r",
      "border-[#FF8B08] [&.grouped-pagination_.pagination-button]:border-[#FF8B08]",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-r",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-[#FF8B08]",
      "[&.grouped-pagination_.pagination-seperator]:border-r",
      "[&.grouped-pagination_.pagination-seperator]:border-[#FF8B08]"
    ]
  end

  defp border_class("danger") do
    [
      "[&.grouped-pagination]:border [&.grouped-pagination_.pagination-button]:border-r",
      "border-[#E73B3B] [&.grouped-pagination_.pagination-button]:border-[#E73B3B]",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-r",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-[#E73B3B]",
      "[&.grouped-pagination_.pagination-seperator]:border-r",
      "[&.grouped-pagination_.pagination-seperator]:border-[#E73B3B]"
    ]
  end

  defp border_class("info") do
    [
      "[&.grouped-pagination]:border [&.grouped-pagination_.pagination-button]:border-r",
      "border-[#004FC4] [&.grouped-pagination_.pagination-button]:border-[#004FC4]",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-r",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-[#004FC4]",
      "[&.grouped-pagination_.pagination-seperator]:border-r",
      "[&.grouped-pagination_.pagination-seperator]:border-[#004FC4]"
    ]
  end

  defp border_class("misc") do
    [
      "[&.grouped-pagination]:border [&.grouped-pagination_.pagination-button]:border-r",
      "border-[#52059C] [&.grouped-pagination_.pagination-button]:border-[#52059C]",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-r",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-[#52059C]",
      "[&.grouped-pagination_.pagination-seperator]:border-r",
      "[&.grouped-pagination_.pagination-seperator]:border-[#52059C]"
    ]
  end

  defp border_class("dawn") do
    [
      "[&.grouped-pagination]:border [&.grouped-pagination_.pagination-button]:border-r",
      "border-[#4D4137] [&.grouped-pagination_.pagination-button]:border-[#4D4137]",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-r",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-[#4D4137]",
      "[&.grouped-pagination_.pagination-seperator]:border-r",
      "[&.grouped-pagination_.pagination-seperator]:border-[#4D4137]"
    ]
  end

  defp border_class("silver") do
    [
      "[&.grouped-pagination]:border [&.grouped-pagination_.pagination-button]:border-r",
      "border-[#707483] [&.grouped-pagination_.pagination-button]:border-[#707483]",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-r",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-[#707483]",
      "[&.grouped-pagination_.pagination-seperator]:border-r",
      "[&.grouped-pagination_.pagination-seperator]:border-[#707483]"
    ]
  end

  defp border_class("dark") do
    [
      "[&.grouped-pagination]:bg-[#282828] [&.grouped-pagination]:text-white",
      "[&.grouped-pagination]:border [&.grouped-pagination_.pagination-button]:border-r",
      "border-[#1E1E1E] [&.grouped-pagination_.pagination-button]:border-[#727272]",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-r",
      "[&.grouped-pagination_.pagination-control:not(:last-child)]:border-[#727272]",
      "[&.grouped-pagination_.pagination-seperator]:border-r",
      "[&.grouped-pagination_.pagination-seperator]:border-[#727272]"
    ]
  end

  defp border_class(params) when is_binary(params), do: params

  defp rounded_size("extra_small"),
    do:
      "[&.grouped-pagination]:rounded-sm [&:not(.grouped-pagination)_.pagination-button]:rounded-sm"

  defp rounded_size("small"),
    do: "[&.grouped-pagination]:rounded [&:not(.grouped-pagination)_.pagination-button]:rounded"

  defp rounded_size("medium"),
    do:
      "[&.grouped-pagination]:rounded-md [&:not(.grouped-pagination)_.pagination-button]:rounded-md"

  defp rounded_size("large"),
    do:
      "[&.grouped-pagination]:rounded-lg [&:not(.grouped-pagination)_.pagination-button]:rounded-lg"

  defp rounded_size("extra_large"),
    do:
      "[&.grouped-pagination]:rounded-xl [&:not(.grouped-pagination)_.pagination-button]:rounded-xl"

  defp rounded_size("full"),
    do:
      "[&.grouped-pagination]:rounded-full [&:not(.grouped-pagination)_.pagination-button]:rounded-full"

  defp rounded_size("none"),
    do:
      "[&.grouped-pagination]:rounded-none [&:not(.grouped-pagination)_.pagination-button]:rounded-none"

  defp size_class("extra_small") do
    [
      "[&.grouped-pagination_.pagination-button]:w-full [&.grouped-pagination_.pagination-button]:px-3",
      "[&:not(.grouped-pagination)_.pagination-button]:w-6",
      "[&.grouped-pagination_.pagination-button]:min-w-6 [&.grouped-pagination_.pagination-control]:min-w-6",
      "[&_.pagination-button]:h-6 [&_.pagination-control>.pagination-icon]:h-6",
      "[&_.pagination-control]:px-2",
      "[&_.pagination-seperator]:h-6 text-xs",
      "[&_:not(.pagination-seperator)>.pagination-icon]:size-3.5"
    ]
  end

  defp size_class("small") do
    [
      "[&.grouped-pagination_.pagination-button]:w-full [&.grouped-pagination_.pagination-button]:px-3",
      "[&:not(.grouped-pagination)_.pagination-button]:w-7",
      "[&.grouped-pagination_.pagination-button]:min-w-7 [&.grouped-pagination_.pagination-control]:min-w-7",
      "[&_.pagination-button]:h-7 [&_.pagination-control>.pagination-icon]:h-7",
      "[&_.pagination-control]:px-2",
      "[&_.pagination-seperator]:w-full [&_.pagination-seperator]:h-7 text-sm",
      "[&_:not(.pagination-seperator)>.pagination-icon]:size-4"
    ]
  end

  defp size_class("medium") do
    [
      "[&.grouped-pagination_.pagination-button]:w-full [&.grouped-pagination_.pagination-button]:px-3",
      "[&:not(.grouped-pagination)_.pagination-button]:w-8",
      "[&.grouped-pagination_.pagination-button]:min-w-8 [&.grouped-pagination_.pagination-control]:min-w-8",
      "[&_.pagination-control]:px-2",
      "[&_.pagination-button]:h-8 [&_.pagination-control>.pagination-icon]:h-8",
      "[&_.pagination-seperator]:w-full [&_.pagination-seperator]:h-8 text-base",
      "[&_:not(.pagination-seperator)>.pagination-icon]:size-5"
    ]
  end

  defp size_class("large") do
    [
      "[&.grouped-pagination_.pagination-button]:w-full [&.grouped-pagination_.pagination-button]:px-3",
      "[&:not(.grouped-pagination)_.pagination-button]:w-9",
      "[&.grouped-pagination_.pagination-button]:min-w-9 [&.grouped-pagination_.pagination-control]:min-w-9",
      "[&_.pagination-control]:px-2",
      "[&_.pagination-button]:h-9 [&_.pagination-control>.pagination-icon]:h-9",
      "[&_.pagination-seperator]:w-full [&_.pagination-seperator]:h-9 text-lg",
      "[&_:not(.pagination-seperator)>.pagination-icon]:size-6"
    ]
  end

  defp size_class("extra_large") do
    [
      "[&.grouped-pagination_.pagination-button]:w-full [&.grouped-pagination_.pagination-button]:px-3",
      "[&:not(.grouped-pagination)_.pagination-button]:w-10",
      "[&.grouped-pagination_.pagination-button]:min-w-10 [&.grouped-pagination_.pagination-control]:min-w-10",
      "[&_.pagination-control]:px-2",
      "[&_.pagination-button]:h-10 [&_.pagination-control>.pagination-icon]:h-10",
      "[&_.pagination-seperator]:w-full [&_.pagination-seperator]:h-10 text-xl",
      "[&_:not(.pagination-seperator)>.pagination-icon]:size-7"
    ]
  end

  defp size_class(params) when is_binary(params), do: params

  defp color_variant("base", _) do
    [
      "bg-white dark:bg-[#18181B] [&_.pagination-button]:border-[#e4e4e7] [&_.pagination-button]:text-[#09090b]",
      "dark:[&_.pagination-button]:border-[#27272a] dark:[&_.pagination-button]:text-[#FAFAFA]",
      "hover:[&_.pagination-button]:bg-[#F8F9FA] dark:hover:[&_.pagination-button]:bg-[#242424]",
      "[&_.pagination-button.active-pagination-button]:bg-[#F8F9FA] dark:[&_.pagination-button.active-pagination-button]:bg-[#242424]"
    ]
  end

  defp color_variant("default", "white") do
    [
      "[&_.pagination-button]:bg-white [&_.pagination-button]:text-[#3E3E3E]",
      "hover:[&_.pagination-button]:bg-[#E8E8E8]",
      "[&_.pagination-button.active-pagination-button]:bg-[#E8E8E8]"
    ]
  end

  defp color_variant("default", "dark") do
    [
      "[&_.pagination-button]:bg-[#282828] [&_.pagination-button]:text-white",
      "hover:[&_.pagination-button]:bg-[#727272]",
      "[&_.pagination-button.active-pagination-button]:bg-[#727272]"
    ]
  end

  defp color_variant("default", "natural") do
    [
      "[&_.pagination-button]:bg-[#4B4B4B] [&_.pagination-button]:text-white",
      "hover:[&_.pagination-button]:bg-[#282828]",
      "[&_.pagination-button.active-pagination-button]:bg-[#282828]",
      "dark:[&_.pagination-button]:bg-[#DDDDDD] dark:[&_.pagination-button]:text-black",
      "dark:hover:[&_.pagination-button]:bg-[#E8E8E8]",
      "dark:[&_.pagination-button.active-pagination-button]:bg-[#E8E8E8]"
    ]
  end

  defp color_variant("default", "primary") do
    [
      "[&_.pagination-button]:bg-[#007F8C] [&_.pagination-button]:text-white",
      "hover:[&_.pagination-button]:bg-[#016974]",
      "[&_.pagination-button.active-pagination-button]:bg-[#016974]",
      "dark:[&_.pagination-button]:bg-[#01B8CA] dark:[&_.pagination-button]:text-black",
      "dark:hover:[&_.pagination-button]:bg-[#77D5E3]",
      "dark:[&_.pagination-button.active-pagination-button]:bg-[#77D5E3]"
    ]
  end

  defp color_variant("default", "secondary") do
    [
      "[&_.pagination-button]:bg-[#266EF1] [&_.pagination-button]:text-white",
      "hover:[&_.pagination-button]:bg-[#175BCC]",
      "[&_.pagination-button.active-pagination-button]:bg-[#175BCC]",
      "dark:[&_.pagination-button]:bg-[#6DAAFB] dark:[&_.pagination-button]:text-black",
      "dark:hover:[&_.pagination-button]:bg-[#A9C9FF]",
      "dark:[&_.pagination-button.active-pagination-button]:bg-[#A9C9FF]"
    ]
  end

  defp color_variant("default", "success") do
    [
      "[&_.pagination-button]:bg-[#0E8345] [&_.pagination-button]:text-white",
      "hover:[&_.pagination-button]:bg-[#166C3B]",
      "[&_.pagination-button.active-pagination-button]:bg-[#166C3B]",
      "dark:[&_.pagination-button]:bg-[#06C167] dark:[&_.pagination-button]:text-black",
      "dark:hover:[&_.pagination-button]:bg-[#7FD99A]",
      "dark:[&_.pagination-button.active-pagination-button]:bg-[#7FD99A]"
    ]
  end

  defp color_variant("default", "warning") do
    [
      "[&_.pagination-button]:bg-[#CA8D01] [&_.pagination-button]:text-white",
      "hover:[&_.pagination-button]:bg-[#976A01]",
      "[&_.pagination-button.active-pagination-button]:bg-[#976A01]",
      "dark:[&_.pagination-button]:bg-[#FDC034] dark:[&_.pagination-button]:text-black",
      "dark:hover:[&_.pagination-button]:bg-[#FDD067]",
      "dark:[&_.pagination-button.active-pagination-button]:bg-[#FDD067]"
    ]
  end

  defp color_variant("default", "danger") do
    [
      "[&_.pagination-button]:bg-[#DE1135] [&_.pagination-button]:text-white",
      "hover:[&_.pagination-button]:bg-[#BB032A]",
      "[&_.pagination-button.active-pagination-button]:bg-[#BB032A]",
      "dark:[&_.pagination-button]:bg-[#FC7F79] dark:[&_.pagination-button]:text-black",
      "dark:hover:[&_.pagination-button]:bg-[#FFB2AB]",
      "dark:[&_.pagination-button.active-pagination-button]:bg-[#FFB2AB]"
    ]
  end

  defp color_variant("default", "info") do
    [
      "[&_.pagination-button]:bg-[#0B84BA] [&_.pagination-button]:text-white",
      "hover:[&_.pagination-button]:bg-[#08638C]",
      "[&_.pagination-button.active-pagination-button]:bg-[#08638C]",
      "dark:[&_.pagination-button]:bg-[#3EB7ED] dark:[&_.pagination-button]:text-black",
      "dark:hover:[&_.pagination-button]:bg-[#6EC9F2]",
      "dark:[&_.pagination-button.active-pagination-button]:bg-[#6EC9F2]"
    ]
  end

  defp color_variant("default", "misc") do
    [
      "[&_.pagination-button]:bg-[#8750C5] [&_.pagination-button]:text-white",
      "hover:[&_.pagination-button]:bg-[#653C94]",
      "[&_.pagination-button.active-pagination-button]:bg-[#653C94]",
      "dark:[&_.pagination-button]:bg-[#BA83F9] dark:[&_.pagination-button]:text-black",
      "dark:hover:[&_.pagination-button]:bg-[#CBA2FA]",
      "dark:[&_.pagination-button.active-pagination-button]:bg-[#CBA2FA]"
    ]
  end

  defp color_variant("default", "dawn") do
    [
      "[&_.pagination-button]:bg-[#A86438] [&_.pagination-button]:text-white",
      "hover:[&_.pagination-button]:bg-[#7E4B2A]",
      "[&_.pagination-button.active-pagination-button]:bg-[#7E4B2A]",
      "dark:[&_.pagination-button]:bg-[#DB976B] dark:[&_.pagination-button]:text-black",
      "dark:hover:[&_.pagination-button]:bg-[#E4B190]",
      "dark:[&_.pagination-button.active-pagination-button]:bg-[#E4B190]"
    ]
  end

  defp color_variant("default", "silver") do
    [
      "[&_.pagination-button]:bg-[#868686] [&_.pagination-button]:text-white",
      "hover:[&_.pagination-button]:bg-[#727272]",
      "[&_.pagination-button.active-pagination-button]:bg-[#727272]",
      "dark:[&_.pagination-button]:bg-[#A6A6A6] dark:[&_.pagination-button]:text-black",
      "dark:hover:[&_.pagination-button]:bg-[#BBBBBB]",
      "dark:[&_.pagination-button.active-pagination-button]:bg-[#BBBBBB]"
    ]
  end

  defp color_variant("outline", "natural") do
    [
      "[&_.pagination-button]:border-[#4B4B4B] [&_.pagination-button]:text-[#4B4B4B]",
      "hover:[&_.pagination-button]:border-[#282828] hover:[&_.pagination-button]:text-[#282828]",
      "dark:[&_.pagination-button]:border-[#DDDDDD] dark:[&_.pagination-button]:text-[#DDDDDD]",
      "dark:hover:[&_.pagination-button]:border-[#E8E8E8] dark:hover:[&_.pagination-button]:text-[#E8E8E8]",
      "[&_.pagination-button.active-pagination-button]:border-[#282828] [&_.pagination-button.active-pagination-button]:text-[#282828]",
      "dark:[&_.pagination-button.active-pagination-button]:border-[#E8E8E8] dark:[&_.pagination-button.active-pagination-button]:text-[#E8E8E8]"
    ]
  end

  defp color_variant("outline", "primary") do
    [
      "[&_.pagination-button]:border-[#007F8C] [&_.pagination-button]:text-[#007F8C]",
      "hover:[&_.pagination-button]:border-[#016974] hover:[&_.pagination-button]:text-[#016974]",
      "[&_.pagination-button.active-pagination-button]:border-[#016974] [&_.pagination-button.active-pagination-button]:text-[#016974]",
      "dark:[&_.pagination-button]:border-[#01B8CA] dark:[&_.pagination-button]:text-[#01B8CA]",
      "dark:hover:[&_.pagination-button]:border-[#77D5E3] dark:hover:[&_.pagination-button]:text-[#77D5E3]",
      "dark:[&_.pagination-button.active-pagination-button]:border-[#77D5E3] dark:[&_.pagination-button.active-pagination-button]:text-[#77D5E3]"
    ]
  end

  defp color_variant("outline", "secondary") do
    [
      "[&_.pagination-button]:border-[#266EF1] [&_.pagination-button]:text-[#266EF1]",
      "hover:[&_.pagination-button]:border-[#175BCC] hover:[&_.pagination-button]:text-[#175BCC]",
      "[&_.pagination-button.active-pagination-button]:border-[#175BCC] [&_.pagination-button.active-pagination-button]:text-[#175BCC]",
      "dark:[&_.pagination-button]:border-[#6DAAFB] dark:[&_.pagination-button]:text-[#6DAAFB]",
      "dark:hover:[&_.pagination-button]:border-[#A9C9FF] dark:hover:[&_.pagination-button]:text-[#A9C9FF]",
      "dark:[&_.pagination-button.active-pagination-button]:border-[#A9C9FF] dark:[&_.pagination-button.active-pagination-button]:text-[#A9C9FF]"
    ]
  end

  defp color_variant("outline", "success") do
    [
      "[&_.pagination-button]:border-[#0E8345] [&_.pagination-button]:text-[#0E8345]",
      "hover:[&_.pagination-button]:border-[#166C3B] hover:[&_.pagination-button]:text-[#166C3B]",
      "[&_.pagination-button.active-pagination-button]:border-[#166C3B] [&_.pagination-button.active-pagination-button]:text-[#166C3B]",
      "dark:[&_.pagination-button]:border-[#06C167] dark:[&_.pagination-button]:text-[#06C167]",
      "dark:hover:[&_.pagination-button]:border-[#7FD99A] dark:hover:[&_.pagination-button]:text-[#7FD99A]",
      "dark:[&_.pagination-button.active-pagination-button]:border-[#7FD99A] dark:[&_.pagination-button.active-pagination-button]:text-[#7FD99A]"
    ]
  end

  defp color_variant("outline", "warning") do
    [
      "[&_.pagination-button]:border-[#CA8D01] [&_.pagination-button]:text-[#CA8D01]",
      "hover:[&_.pagination-button]:border-[#976A01] hover:[&_.pagination-button]:text-[#976A01]",
      "[&_.pagination-button.active-pagination-button]:border-[#976A01] [&_.pagination-button.active-pagination-button]:text-[#976A01]",
      "dark:[&_.pagination-button]:border-[#FDC034] dark:[&_.pagination-button]:text-[#FDC034]",
      "dark:hover:[&_.pagination-button]:border-[#FDD067] dark:hover:[&_.pagination-button]:text-[#FDD067]",
      "dark:[&_.pagination-button.active-pagination-button]:border-[#FDD067] dark:[&_.pagination-button.active-pagination-button]:text-[#FDD067]"
    ]
  end

  defp color_variant("outline", "danger") do
    [
      "[&_.pagination-button]:border-[#DE1135] [&_.pagination-button]:text-[#DE1135]",
      "hover:[&_.pagination-button]:border-[#BB032A] hover:[&_.pagination-button]:text-[#BB032A]",
      "[&_.pagination-button.active-pagination-button]:border-[#BB032A] [&_.pagination-button.active-pagination-button]:text-[#BB032A]",
      "dark:[&_.pagination-button]:border-[#FC7F79] dark:[&_.pagination-button]:text-[#FC7F79]",
      "dark:hover:[&_.pagination-button]:border-[#FFB2AB] dark:hover:[&_.pagination-button]:text-[#FFB2AB]",
      "dark:[&_.pagination-button.active-pagination-button]:border-[#FFB2AB] dark:[&_.pagination-button.active-pagination-button]:text-[#FFB2AB]"
    ]
  end

  defp color_variant("outline", "info") do
    [
      "[&_.pagination-button]:border-[#0B84BA] [&_.pagination-button]:text-[#0B84BA]",
      "hover:[&_.pagination-button]:border-[#BB032A] hover:[&_.pagination-button]:text-[#BB032A]",
      "[&_.pagination-button.active-pagination-button]:border-[#BB032A] [&_.pagination-button.active-pagination-button]:text-[#BB032A]",
      "dark:[&_.pagination-button]:border-[#FC7F79] dark:[&_.pagination-button]:text-[#FC7F79]",
      "dark:hover:[&_.pagination-button]:border-[#FFB2AB] dark:hover:[&_.pagination-button]:text-[#FFB2AB]",
      "dark:[&_.pagination-button.active-pagination-button]:border-[#FFB2AB] dark:[&_.pagination-button.active-pagination-button]:text-[#FFB2AB]"
    ]
  end

  defp color_variant("outline", "misc") do
    [
      "[&_.pagination-button]:border-[#8750C5] [&_.pagination-button]:text-[#8750C5]",
      "hover:[&_.pagination-button]:border-[#653C94] hover:[&_.pagination-button]:text-[#653C94]",
      "[&_.pagination-button.active-pagination-button]:border-[#653C94] [&_.pagination-button.active-pagination-button]:text-[#653C94]",
      "dark:[&_.pagination-button]:border-[#BA83F9] dark:[&_.pagination-button]:text-[#BA83F9]",
      "dark:hover:[&_.pagination-button]:border-[#CBA2FA] dark:hover:[&_.pagination-button]:text-[#CBA2FA]",
      "dark:[&_.pagination-button.active-pagination-button]:border-[#CBA2FA] dark:[&_.pagination-button.active-pagination-button]:text-[#CBA2FA]"
    ]
  end

  defp color_variant("outline", "dawn") do
    [
      "[&_.pagination-button]:border-[#A86438] [&_.pagination-button]:text-[#A86438]",
      "hover:[&_.pagination-button]:border-[#7E4B2A] hover:[&_.pagination-button]:text-[#7E4B2A]",
      "[&_.pagination-button.active-pagination-button]:border-[#7E4B2A] [&_.pagination-button.active-pagination-button]:text-[#7E4B2A]",
      "dark:[&_.pagination-button]:border-[#DB976B] dark:[&_.pagination-button]:text-[#DB976B]",
      "dark:hover:[&_.pagination-button]:border-[#E4B190] dark:hover:[&_.pagination-button]:text-[#E4B190]",
      "dark:[&_.pagination-button.active-pagination-button]:border-[#E4B190] dark:[&_.pagination-button.active-pagination-button]:text-[#E4B190]"
    ]
  end

  defp color_variant("outline", "silver") do
    [
      "[&_.pagination-button]:border-[#868686] [&_.pagination-button]:text-[#868686]",
      "hover:[&_.pagination-button]:border-[#727272] hover:[&_.pagination-button]:text-[#727272]",
      "[&_.pagination-button.active-pagination-button]:border-[#727272] [&_.pagination-button.active-pagination-button]:text-[#727272]",
      "dark:[&_.pagination-button]:border-[#A6A6A6] dark:[&_.pagination-button]:text-[#A6A6A6]",
      "dark:hover:[&_.pagination-button]:border-[#BBBBBB] dark:hover:[&_.pagination-button]:text-[#BBBBBB]",
      "dark:[&_.pagination-button.active-pagination-button]:border-[#BBBBBB] dark:[&_.pagination-button.active-pagination-button]:text-[#BBBBBB]"
    ]
  end

  defp color_variant("bordered", "natural") do
    [
      "bg-white dark:bg-[#282828] [&_.pagination-button]:border-[#4B4B4B] [&_.pagination-button]:text-[#4B4B4B]",
      "hover:[&_.pagination-button]:border-[#282828] hover:[&_.pagination-button]:text-[#282828]",
      "dark:[&_.pagination-button]:border-[#DDDDDD] dark:[&_.pagination-button]:text-[#DDDDDD]",
      "dark:hover:[&_.pagination-button]:border-[#E8E8E8] dark:hover:[&_.pagination-button]:text-[#E8E8E8]",
      "[&_.pagination-button.active-pagination-button]:border-[#282828] [&_.pagination-button.active-pagination-button]:text-[#282828]",
      "dark:[&_.pagination-button.active-pagination-button]:border-[#E8E8E8] dark:[&_.pagination-button.active-pagination-button]:text-[#E8E8E8]"
    ]
  end

  defp color_variant("bordered", "primary") do
    [
      "bg-white dark:bg-[#282828] [&_.pagination-button]:border-[#007F8C] [&_.pagination-button]:text-[#007F8C]",
      "hover:[&_.pagination-button]:border-[#016974] hover:[&_.pagination-button]:text-[#016974]",
      "[&_.pagination-button.active-pagination-button]:border-[#016974] [&_.pagination-button.active-pagination-button]:text-[#016974]",
      "dark:[&_.pagination-button]:border-[#01B8CA] dark:[&_.pagination-button]:text-[#01B8CA]",
      "dark:hover:[&_.pagination-button]:border-[#77D5E3] dark:hover:[&_.pagination-button]:text-[#77D5E3]",
      "dark:[&_.pagination-button.active-pagination-button]:border-[#77D5E3] dark:[&_.pagination-button.active-pagination-button]:text-[#77D5E3]"
    ]
  end

  defp color_variant("bordered", "secondary") do
    [
      "bg-white dark:bg-[#282828] [&_.pagination-button]:border-[#266EF1] [&_.pagination-button]:text-[#266EF1]",
      "hover:[&_.pagination-button]:border-[#175BCC] hover:[&_.pagination-button]:text-[#175BCC]",
      "[&_.pagination-button.active-pagination-button]:border-[#175BCC] [&_.pagination-button.active-pagination-button]:text-[#175BCC]",
      "dark:[&_.pagination-button]:border-[#6DAAFB] dark:[&_.pagination-button]:text-[#6DAAFB]",
      "dark:hover:[&_.pagination-button]:border-[#A9C9FF] dark:hover:[&_.pagination-button]:text-[#A9C9FF]",
      "dark:[&_.pagination-button.active-pagination-button]:border-[#A9C9FF] dark:[&_.pagination-button.active-pagination-button]:text-[#A9C9FF]"
    ]
  end

  defp color_variant("bordered", "success") do
    [
      "bg-white dark:bg-[#282828] [&_.pagination-button]:border-[#0E8345] [&_.pagination-button]:text-[#0E8345]",
      "hover:[&_.pagination-button]:border-[#166C3B] hover:[&_.pagination-button]:text-[#166C3B]",
      "[&_.pagination-button.active-pagination-button]:border-[#166C3B] [&_.pagination-button.active-pagination-button]:text-[#166C3B]",
      "dark:[&_.pagination-button]:border-[#06C167] dark:[&_.pagination-button]:text-[#06C167]",
      "dark:hover:[&_.pagination-button]:border-[#7FD99A] dark:hover:[&_.pagination-button]:text-[#7FD99A]",
      "dark:[&_.pagination-button.active-pagination-button]:border-[#7FD99A] dark:[&_.pagination-button.active-pagination-button]:text-[#7FD99A]"
    ]
  end

  defp color_variant("bordered", "warning") do
    [
      "bg-white dark:bg-[#282828] [&_.pagination-button]:border-[#CA8D01] [&_.pagination-button]:text-[#CA8D01]",
      "hover:[&_.pagination-button]:border-[#976A01] hover:[&_.pagination-button]:text-[#976A01]",
      "[&_.pagination-button.active-pagination-button]:border-[#976A01] [&_.pagination-button.active-pagination-button]:text-[#976A01]",
      "dark:[&_.pagination-button]:border-[#FDC034] dark:[&_.pagination-button]:text-[#FDC034]",
      "dark:hover:[&_.pagination-button]:border-[#FDD067] dark:hover:[&_.pagination-button]:text-[#FDD067]",
      "dark:[&_.pagination-button.active-pagination-button]:border-[#FDD067] dark:[&_.pagination-button.active-pagination-button]:text-[#FDD067]"
    ]
  end

  defp color_variant("bordered", "danger") do
    [
      "bg-white dark:bg-[#282828] [&_.pagination-button]:border-[#DE1135] [&_.pagination-button]:text-[#DE1135]",
      "hover:[&_.pagination-button]:border-[#BB032A] hover:[&_.pagination-button]:text-[#BB032A]",
      "[&_.pagination-button.active-pagination-button]:border-[#BB032A] [&_.pagination-button.active-pagination-button]:text-[#BB032A]",
      "dark:[&_.pagination-button]:border-[#FC7F79] dark:[&_.pagination-button]:text-[#FC7F79]",
      "dark:hover:[&_.pagination-button]:border-[#FFB2AB] dark:hover:[&_.pagination-button]:text-[#FFB2AB]",
      "dark:[&_.pagination-button.active-pagination-button]:border-[#FFB2AB] dark:[&_.pagination-button.active-pagination-button]:text-[#FFB2AB]"
    ]
  end

  defp color_variant("bordered", "info") do
    [
      "bg-white dark:bg-[#282828] [&_.pagination-button]:border-[#0B84BA] [&_.pagination-button]:text-[#0B84BA]",
      "hover:[&_.pagination-button]:border-[#BB032A] hover:[&_.pagination-button]:text-[#BB032A]",
      "[&_.pagination-button.active-pagination-button]:border-[#BB032A] [&_.pagination-button.active-pagination-button]:text-[#BB032A]",
      "dark:[&_.pagination-button]:border-[#FC7F79] dark:[&_.pagination-button]:text-[#FC7F79]",
      "dark:hover:[&_.pagination-button]:border-[#FFB2AB] dark:hover:[&_.pagination-button]:text-[#FFB2AB]",
      "dark:[&_.pagination-button.active-pagination-button]:border-[#FFB2AB] dark:[&_.pagination-button.active-pagination-button]:text-[#FFB2AB]"
    ]
  end

  defp color_variant("bordered", "misc") do
    [
      "bg-white dark:bg-[#282828] [&_.pagination-button]:border-[#8750C5] [&_.pagination-button]:text-[#8750C5]",
      "hover:[&_.pagination-button]:border-[#653C94] hover:[&_.pagination-button]:text-[#653C94]",
      "[&_.pagination-button.active-pagination-button]:border-[#653C94] [&_.pagination-button.active-pagination-button]:text-[#653C94]",
      "dark:[&_.pagination-button]:border-[#BA83F9] dark:[&_.pagination-button]:text-[#BA83F9]",
      "dark:hover:[&_.pagination-button]:border-[#CBA2FA] dark:hover:[&_.pagination-button]:text-[#CBA2FA]",
      "dark:[&_.pagination-button.active-pagination-button]:border-[#CBA2FA] dark:[&_.pagination-button.active-pagination-button]:text-[#CBA2FA]"
    ]
  end

  defp color_variant("bordered", "dawn") do
    [
      "bg-white dark:bg-[#282828] [&_.pagination-button]:border-[#A86438] [&_.pagination-button]:text-[#A86438]",
      "hover:[&_.pagination-button]:border-[#7E4B2A] hover:[&_.pagination-button]:text-[#7E4B2A]",
      "[&_.pagination-button.active-pagination-button]:border-[#7E4B2A] [&_.pagination-button.active-pagination-button]:text-[#7E4B2A]",
      "dark:[&_.pagination-button]:border-[#DB976B] dark:[&_.pagination-button]:text-[#DB976B]",
      "dark:hover:[&_.pagination-button]:border-[#E4B190] dark:hover:[&_.pagination-button]:text-[#E4B190]",
      "dark:[&_.pagination-button.active-pagination-button]:border-[#E4B190] dark:[&_.pagination-button.active-pagination-button]:text-[#E4B190]"
    ]
  end

  defp color_variant("bordered", "silver") do
    [
      "bg-white dark:bg-[#282828] [&_.pagination-button]:border-[#868686] [&_.pagination-button]:text-[#868686]",
      "hover:[&_.pagination-button]:border-[#727272] hover:[&_.pagination-button]:text-[#727272]",
      "[&_.pagination-button.active-pagination-button]:border-[#727272] [&_.pagination-button.active-pagination-button]:text-[#727272]",
      "dark:[&_.pagination-button]:border-[#A6A6A6] dark:[&_.pagination-button]:text-[#A6A6A6]",
      "dark:hover:[&_.pagination-button]:border-[#BBBBBB] dark:hover:[&_.pagination-button]:text-[#BBBBBB]",
      "dark:[&_.pagination-button.active-pagination-button]:border-[#BBBBBB] dark:[&_.pagination-button.active-pagination-button]:text-[#BBBBBB]"
    ]
  end

  defp color_variant("transparent", "natural") do
    [
      "[&_.pagination-button]:text-[#4B4B4B] hover:[&_.pagination-button]:text-[#282828]",
      "dark:[&_.pagination-button]:text-[#DDDDDD] dark:hover:[&_.pagination-button]:text-[#E8E8E8]",
      "[&_.pagination-button.active-pagination-button]:text-[#282828]",
      "dark:[&_.pagination-button.active-pagination-button]:text-[#E8E8E8]"
    ]
  end

  defp color_variant("transparent", "primary") do
    [
      "[&_.pagination-button]:text-[#007F8C] hover:[&_.pagination-button]:text-[#016974]",
      "dark:[&_.pagination-button]:text-[#01B8CA] dark:hover:[&_.pagination-button]:text-[#77D5E3]",
      "[&_.pagination-button.active-pagination-button]:text-[#016974]",
      "dark:[&_.pagination-button.active-pagination-button]:text-[#77D5E3]"
    ]
  end

  defp color_variant("transparent", "secondary") do
    [
      "[&_.pagination-button]:text-[#266EF1] hover:[&_.pagination-button]:text-[#175BCC]",
      "dark:[&_.pagination-button]:text-[#6DAAFB] dark:hover:[&_.pagination-button]:text-[#A9C9FF]",
      "[&_.pagination-button.active-pagination-button]:text-[#175BCC]",
      "dark:[&_.pagination-button.active-pagination-button]:text-[#A9C9FF]"
    ]
  end

  defp color_variant("transparent", "success") do
    [
      "[&_.pagination-button]:text-[#0E8345] hover:[&_.pagination-button]:text-[#166C3B]",
      "dark:[&_.pagination-button]:text-[#06C167] dark:hover:[&_.pagination-button]:text-[#7FD99A]",
      "[&_.pagination-button.active-pagination-button]:text-[#175BCC]",
      "dark:[&_.pagination-button.active-pagination-button]:text-[#A9C9FF]"
    ]
  end

  defp color_variant("transparent", "warning") do
    [
      "[&_.pagination-button]:text-[#CA8D01] hover:[&_.pagination-button]:text-[#CA8D01]",
      "dark:[&_.pagination-button]:text-[#FDC034] dark:hover:[&_.pagination-button]:text-[#FDD067]",
      "[&_.pagination-button.active-pagination-button]:text-[#CA8D01]",
      "dark:[&_.pagination-button.active-pagination-button]:text-[#FDD067]"
    ]
  end

  defp color_variant("transparent", "danger") do
    [
      "[&_.pagination-button]:text-[#DE1135] hover:[&_.pagination-button]:text-[#BB032A]",
      "dark:[&_.pagination-button]:text-[#FC7F79] dark:hover:[&_.pagination-button]:text-[#FFB2AB]",
      "[&_.pagination-button.active-pagination-button]:text-[#BB032A]",
      "dark:[&_.pagination-button.active-pagination-button]:text-[#FFB2AB]"
    ]
  end

  defp color_variant("transparent", "info") do
    [
      "[&_.pagination-button]:text-[#0B84BA] hover:[&_.pagination-button]:text-[#08638C]",
      "dark:[&_.pagination-button]:text-[#3EB7ED] dark:hover:[&_.pagination-button]:text-[#6EC9F2]",
      "[&_.pagination-button.active-pagination-button]:text-[#08638C]",
      "dark:[&_.pagination-button.active-pagination-button]:text-[#6EC9F2]"
    ]
  end

  defp color_variant("transparent", "misc") do
    [
      "[&_.pagination-button]:text-[#8750C5] hover:[&_.pagination-button]:text-[#653C94]",
      "dark:[&_.pagination-button]:text-[#BA83F9] dark:hover:[&_.pagination-button]:text-[#CBA2FA]",
      "[&_.pagination-button.active-pagination-button]:text-[#653C94]",
      "dark:[&_.pagination-button.active-pagination-button]:text-[#CBA2FA]"
    ]
  end

  defp color_variant("transparent", "dawn") do
    [
      "[&_.pagination-button]:text-[#A86438] hover:[&_.pagination-button]:text-[#7E4B2A]",
      "dark:[&_.pagination-button]:text-[#DB976B] dark:hover:[&_.pagination-button]:text-[#E4B190]",
      "[&_.pagination-button.active-pagination-button]:text-[#7E4B2A]",
      "dark:[&_.pagination-button.active-pagination-button]:text-[#E4B190]"
    ]
  end

  defp color_variant("transparent", "silver") do
    [
      "[&_.pagination-button]:text-[#868686] hover:[&_.pagination-button]:text-[#727272]",
      "dark:[&_.pagination-button]:text-[#A6A6A6] dark:hover:[&_.pagination-button]:text-[#BBBBBB]",
      "[&_.pagination-button.active-pagination-button]:text-[#727272]",
      "dark:[&_.pagination-button.active-pagination-button]:text-[#BBBBBB]"
    ]
  end

  defp color_variant("subtle", "natural") do
    [
      "[&_.pagination-button]:text-[#4B4B4B] hover:[&_.pagination-button]:text-[#282828]",
      "dark:[&_.pagination-button]:text-[#DDDDDD] dark:hover:[&_.pagination-button]:text-[#E8E8E8]",
      "[&_.pagination-button.active-pagination-button]:text-[#282828]",
      "dark:[&_.pagination-button.active-pagination-button]:text-[#E8E8E8]",
      "hover:[&_.pagination-button]:bg-[#F3F3F3] dark:hover:[&_.pagination-button]:bg-[#4B4B4B]",
      "[&_.pagination-button.active-pagination-button]:bg-[#F3F3F3]",
      "dark:[&_.pagination-button.active-pagination-button]:bg-[#4B4B4B]"
    ]
  end

  defp color_variant("subtle", "primary") do
    [
      "[&_.pagination-button]:text-[#007F8C] hover:[&_.pagination-button]:text-[#016974]",
      "dark:[&_.pagination-button]:text-[#01B8CA] dark:hover:[&_.pagination-button]:text-[#77D5E3]",
      "[&_.pagination-button.active-pagination-button]:text-[#016974]",
      "dark:[&_.pagination-button.active-pagination-button]:text-[#77D5E3]",
      "hover:[&_.pagination-button]:bg-[#E2F8FB] dark:hover:[&_.pagination-button]:bg-[#002D33]",
      "[&_.pagination-button.active-pagination-button]:bg-[#E2F8FB]",
      "dark:[&_.pagination-button.active-pagination-button]:bg-[#002D33]"
    ]
  end

  defp color_variant("subtle", "secondary") do
    [
      "[&_.pagination-button]:text-[#266EF1] hover:[&_.pagination-button]:text-[#175BCC]",
      "dark:[&_.pagination-button]:text-[#6DAAFB] dark:hover:[&_.pagination-button]:text-[#A9C9FF]",
      "[&_.pagination-button.active-pagination-button]:text-[#175BCC]",
      "dark:[&_.pagination-button.active-pagination-button]:text-[#A9C9FF]",
      "hover:[&_.pagination-button]:bg-[#EFF4FE] dark:hover:[&_.pagination-button]:bg-[#002661]",
      "[&_.pagination-button.active-pagination-button]:bg-[#EFF4FE]",
      "dark:[&_.pagination-button.active-pagination-button]:bg-[#002661]"
    ]
  end

  defp color_variant("subtle", "success") do
    [
      "[&_.pagination-button]:text-[#0E8345] hover:[&_.pagination-button]:text-[#166C3B]",
      "dark:[&_.pagination-button]:text-[#06C167] dark:hover:[&_.pagination-button]:text-[#7FD99A]",
      "[&_.pagination-button.active-pagination-button]:text-[#175BCC]",
      "dark:[&_.pagination-button.active-pagination-button]:text-[#A9C9FF]",
      "hover:[&_.pagination-button]:bg-[#EAF6ED] dark:hover:[&_.pagination-button]:bg-[#002F14]",
      "[&_.pagination-button.active-pagination-button]:bg-[#EAF6ED]",
      "dark:[&_.pagination-button.active-pagination-button]:bg-[#002F14]"
    ]
  end

  defp color_variant("subtle", "warning") do
    [
      "[&_.pagination-button]:text-[#CA8D01] hover:[&_.pagination-button]:text-[#CA8D01]",
      "dark:[&_.pagination-button]:text-[#FDC034] dark:hover:[&_.pagination-button]:text-[#FDD067]",
      "[&_.pagination-button.active-pagination-button]:text-[#CA8D01]",
      "dark:[&_.pagination-button.active-pagination-button]:text-[#FDD067]",
      "hover:[&_.pagination-button]:bg-[#FFF7E6] dark:hover:[&_.pagination-button]:bg-[#322300]",
      "[&_.pagination-button.active-pagination-button]:bg-[#FFF7E6]",
      "dark:[&_.pagination-button.active-pagination-button]:bg-[#322300]"
    ]
  end

  defp color_variant("subtle", "danger") do
    [
      "[&_.pagination-button]:text-[#DE1135] hover:[&_.pagination-button]:text-[#BB032A]",
      "dark:[&_.pagination-button]:text-[#FC7F79] dark:hover:[&_.pagination-button]:text-[#FFB2AB]",
      "[&_.pagination-button.active-pagination-button]:text-[#BB032A]",
      "dark:[&_.pagination-button.active-pagination-button]:text-[#FFB2AB]",
      "hover:[&_.pagination-button]:bg-[#FFF0EE] dark:hover:[&_.pagination-button]:bg-[#520810]",
      "[&_.pagination-button.active-pagination-button]:bg-[#FFF0EE]",
      "dark:[&_.pagination-button.active-pagination-button]:bg-[#520810]"
    ]
  end

  defp color_variant("subtle", "info") do
    [
      "[&_.pagination-button]:text-[#0B84BA] hover:[&_.pagination-button]:text-[#08638C]",
      "dark:[&_.pagination-button]:text-[#3EB7ED] dark:hover:[&_.pagination-button]:text-[#6EC9F2]",
      "[&_.pagination-button.active-pagination-button]:text-[#08638C]",
      "dark:[&_.pagination-button.active-pagination-button]:text-[#6EC9F2]",
      "hover:[&_.pagination-button]:bg-[#E7F6FD] dark:hover:[&_.pagination-button]:bg-[#03212F]",
      "[&_.pagination-button.active-pagination-button]:bg-[#E7F6FD]",
      "dark:[&_.pagination-button.active-pagination-button]:bg-[#03212F]"
    ]
  end

  defp color_variant("subtle", "misc") do
    [
      "[&_.pagination-button]:text-[#8750C5] hover:[&_.pagination-button]:text-[#653C94]",
      "dark:[&_.pagination-button]:text-[#BA83F9] dark:hover:[&_.pagination-button]:text-[#CBA2FA]",
      "[&_.pagination-button.active-pagination-button]:text-[#653C94]",
      "dark:[&_.pagination-button.active-pagination-button]:text-[#CBA2FA]",
      "hover:[&_.pagination-button]:bg-[#F6F0FE] dark:hover:[&_.pagination-button]:bg-[#221431]",
      "[&_.pagination-button.active-pagination-button]:bg-[#F6F0FE]",
      "dark:[&_.pagination-button.active-pagination-button]:bg-[#221431]"
    ]
  end

  defp color_variant("subtle", "dawn") do
    [
      "[&_.pagination-button]:text-[#A86438] hover:[&_.pagination-button]:text-[#7E4B2A]",
      "dark:[&_.pagination-button]:text-[#DB976B] dark:hover:[&_.pagination-button]:text-[#E4B190]",
      "[&_.pagination-button.active-pagination-button]:text-[#7E4B2A]",
      "dark:[&_.pagination-button.active-pagination-button]:text-[#E4B190]",
      "hover:[&_.pagination-button]:bg-[#FBF2ED] dark:hover:[&_.pagination-button]:bg-[#2A190E]",
      "[&_.pagination-button.active-pagination-button]:bg-[#FBF2ED]",
      "dark:[&_.pagination-button.active-pagination-button]:bg-[#2A190E]"
    ]
  end

  defp color_variant("subtle", "silver") do
    [
      "[&_.pagination-button]:text-[#868686] hover:[&_.pagination-button]:text-[#727272]",
      "dark:[&_.pagination-button]:text-[#A6A6A6] dark:hover:[&_.pagination-button]:text-[#BBBBBB]",
      "[&_.pagination-button.active-pagination-button]:text-[#727272]",
      "dark:[&_.pagination-button.active-pagination-button]:text-[#BBBBBB]",
      "hover:[&_.pagination-button]:bg-[#F3F3F3] dark:hover:[&_.pagination-button]:bg-[#4B4B4B]",
      "[&_.pagination-button.active-pagination-button]:bg-[#F3F3F3]",
      "dark:[&_.pagination-button.active-pagination-button]:bg-[#4B4B4B]"
    ]
  end

  defp color_variant("shadow", "natural") do
    [
      "[&_.pagination-button]:bg-[#4B4B4B] [&_.pagination-button]:text-white",
      "hover:[&_.pagination-button]:bg-[#282828]",
      "[&_.pagination-button.active-pagination-button]:bg-[#282828]",
      "dark:[&_.pagination-button]:bg-[#DDDDDD] dark:[&_.pagination-button]:text-black",
      "dark:hover:[&_.pagination-button]:bg-[#E8E8E8]",
      "dark:[&_.pagination-button.active-pagination-button]:bg-[#E8E8E8]",
      "[&_.pagination-button]:shadow-[0px_4px_6px_-4px_rgba(134,134,134,0.5)] [&_.pagination-button]:shadow-[0px_10px_15px_-3px_rgba(134,134,134,0.5)]",
      "dark:[&_.pagination-button]:shadow-none"
    ]
  end

  defp color_variant("shadow", "primary") do
    [
      "[&_.pagination-button]:bg-[#007F8C] [&_.pagination-button]:text-white",
      "hover:[&_.pagination-button]:bg-[#016974]",
      "[&_.pagination-button.active-pagination-button]:bg-[#016974]",
      "dark:[&_.pagination-button]:bg-[#01B8CA] dark:[&_.pagination-button]:text-black",
      "dark:hover:[&_.pagination-button]:bg-[#77D5E3]",
      "dark:[&_.pagination-button.active-pagination-button]:bg-[#77D5E3]",
      "[&_.pagination-button]:shadow-[0px_4px_6px_-4px_rgba(0,149,164,0.5)] [&_.pagination-button]:shadow-[0px_10px_15px_-3px_rgba(0,149,164,0.5)]",
      "dark:[&_.pagination-button]:shadow-none"
    ]
  end

  defp color_variant("shadow", "secondary") do
    [
      "[&_.pagination-button]:bg-[#266EF1] [&_.pagination-button]:text-white",
      "hover:[&_.pagination-button]:bg-[#175BCC]",
      "[&_.pagination-button.active-pagination-button]:bg-[#175BCC]",
      "dark:[&_.pagination-button]:bg-[#6DAAFB] dark:[&_.pagination-button]:text-black",
      "dark:hover:[&_.pagination-button]:bg-[#A9C9FF]",
      "dark:[&_.pagination-button.active-pagination-button]:bg-[#A9C9FF]",
      "[&_.pagination-button]:shadow-[0px_4px_6px_-4px_rgba(6,139,238,0.5)] [&_.pagination-button]:shadow-[0px_10px_15px_-3px_rgba(6,139,238,0.5)]",
      "dark:[&_.pagination-button]:shadow-none"
    ]
  end

  defp color_variant("shadow", "success") do
    [
      "[&_.pagination-button]:bg-[#0E8345] [&_.pagination-button]:text-white",
      "hover:[&_.pagination-button]:bg-[#166C3B]",
      "[&_.pagination-button.active-pagination-button]:bg-[#166C3B]",
      "dark:[&_.pagination-button]:bg-[#06C167] dark:[&_.pagination-button]:text-black",
      "dark:hover:[&_.pagination-button]:bg-[#7FD99A]",
      "dark:[&_.pagination-button.active-pagination-button]:bg-[#7FD99A]",
      "[&_.pagination-button]:shadow-[0px_4px_6px_-4px_rgba(0,154,81,0.5)] [&_.pagination-button]:shadow-[0px_10px_15px_-3px_rgba(0,154,81,0.5)]",
      "dark:[&_.pagination-button]:shadow-none"
    ]
  end

  defp color_variant("shadow", "warning") do
    [
      "[&_.pagination-button]:bg-[#CA8D01] [&_.pagination-button]:text-white",
      "hover:[&_.pagination-button]:bg-[#976A01]",
      "[&_.pagination-button.active-pagination-button]:bg-[#976A01]",
      "dark:[&_.pagination-button]:bg-[#FDC034] dark:[&_.pagination-button]:text-black",
      "dark:hover:[&_.pagination-button]:bg-[#FDD067]",
      "dark:[&_.pagination-button.active-pagination-button]:bg-[#FDD067]",
      "[&_.pagination-button]:shadow-[0px_4px_6px_-4px_rgba(252,176,1,0.5)] [&_.pagination-button]:shadow-[0px_10px_15px_-3px_rgba(252,176,1,0.5)]",
      "dark:[&_.pagination-button]:shadow-none"
    ]
  end

  defp color_variant("shadow", "danger") do
    [
      "[&_.pagination-button]:bg-[#DE1135] [&_.pagination-button]:text-white",
      "hover:[&_.pagination-button]:bg-[#BB032A]",
      "[&_.pagination-button.active-pagination-button]:bg-[#BB032A]",
      "dark:[&_.pagination-button]:bg-[#FC7F79] dark:[&_.pagination-button]:text-black",
      "dark:hover:[&_.pagination-button]:bg-[#FFB2AB]",
      "dark:[&_.pagination-button.active-pagination-button]:bg-[#FFB2AB]",
      "[&_.pagination-button]:shadow-[0px_4px_6px_-4px_rgba(248,52,70,0.5)] [&_.pagination-button]:shadow-[0px_10px_15px_-3px_rgba(248,52,70,0.5)]",
      "dark:[&_.pagination-button]:shadow-none"
    ]
  end

  defp color_variant("shadow", "info") do
    [
      "[&_.pagination-button]:bg-[#0B84BA] [&_.pagination-button]:text-white",
      "hover:[&_.pagination-button]:bg-[#08638C]",
      "[&_.pagination-button.active-pagination-button]:bg-[#08638C]",
      "dark:[&_.pagination-button]:bg-[#3EB7ED] dark:[&_.pagination-button]:text-black",
      "dark:hover:[&_.pagination-button]:bg-[#6EC9F2]",
      "dark:[&_.pagination-button.active-pagination-button]:bg-[#6EC9F2]",
      "[&_.pagination-button]:shadow-[0px_4px_6px_-4px_rgba(14,165,233,0.5)] [&_.pagination-button]:shadow-[0px_10px_15px_-3px_rgba(14,165,233,0.5)]",
      "dark:[&_.pagination-button]:shadow-none"
    ]
  end

  defp color_variant("shadow", "misc") do
    [
      "[&_.pagination-button]:bg-[#8750C5] [&_.pagination-button]:text-white",
      "hover:[&_.pagination-button]:bg-[#653C94]",
      "[&_.pagination-button.active-pagination-button]:bg-[#653C94]",
      "dark:[&_.pagination-button]:bg-[#BA83F9] dark:[&_.pagination-button]:text-black",
      "dark:hover:[&_.pagination-button]:bg-[#CBA2FA]",
      "dark:[&_.pagination-button.active-pagination-button]:bg-[#CBA2FA]",
      "[&_.pagination-button]:shadow-[0px_4px_6px_-4px_rgba(169,100,247,0.5)] [&_.pagination-button]:shadow-[0px_10px_15px_-3px_rgba(169,100,247,0.5)]",
      "dark:[&_.pagination-button]:shadow-none"
    ]
  end

  defp color_variant("shadow", "dawn") do
    [
      "[&_.pagination-button]:bg-[#A86438] [&_.pagination-button]:text-white",
      "hover:[&_.pagination-button]:bg-[#7E4B2A]",
      "[&_.pagination-button.active-pagination-button]:bg-[#7E4B2A]",
      "dark:[&_.pagination-button]:bg-[#DB976B] dark:[&_.pagination-button]:text-black",
      "dark:hover:[&_.pagination-button]:bg-[#E4B190]",
      "dark:[&_.pagination-button.active-pagination-button]:bg-[#E4B190]",
      "[&_.pagination-button]:shadow-[0px_4px_6px_-4px_rgba(210,125,70,0.5)] [&_.pagination-button]:shadow-[0px_10px_15px_-3px_rgba(210,125,70,0.5)]",
      "dark:[&_.pagination-button]:shadow-none"
    ]
  end

  defp color_variant("shadow", "silver") do
    [
      "[&_.pagination-button]:bg-[#868686] [&_.pagination-button]:text-white",
      "hover:[&_.pagination-button]:bg-[#727272]",
      "[&_.pagination-button.active-pagination-button]:bg-[#727272]",
      "dark:[&_.pagination-button]:bg-[#A6A6A6] dark:[&_.pagination-button]:text-black",
      "dark:hover:[&_.pagination-button]:bg-[#BBBBBB]",
      "dark:[&_.pagination-button.active-pagination-button]:bg-[#BBBBBB]",
      "[&_.pagination-button]:shadow-[0px_4px_6px_-4px_rgba(134,134,134,0.5)] [&_.pagination-button]:shadow-[0px_10px_15px_-3px_rgba(134,134,134,0.5)]",
      "dark:[&_.pagination-button]:shadow-none"
    ]
  end

  defp color_variant("inverted", "natural") do
    [
      "[&_.pagination-button]:border-[#4B4B4B] [&_.pagination-button]:text-[#4B4B4B]",
      "hover:[&_.pagination-button]:border-[#282828] hover:[&_.pagination-button]:text-[#282828]",
      "dark:[&_.pagination-button]:border-[#DDDDDD] dark:[&_.pagination-button]:text-[#DDDDDD]",
      "dark:hover:[&_.pagination-button]:border-[#E8E8E8] dark:hover:[&_.pagination-button]:text-[#E8E8E8]",
      "[&_.pagination-button.active-pagination-button]:border-[#282828] [&_.pagination-button.active-pagination-button]:text-[#282828]",
      "dark:[&_.pagination-button.active-pagination-button]:border-[#E8E8E8] dark:[&_.pagination-button.active-pagination-button]:text-[#E8E8E8]",
      "hover:[&_.pagination-button]:bg-[#F3F3F3] dark:hover:[&_.pagination-button]:bg-[#4B4B4B]",
      "[&_.pagination-button.active-pagination-button]:bg-[#F3F3F3] dark:[&_.pagination-button.active-pagination-button]:bg-[#4B4B4B]"
    ]
  end

  defp color_variant("inverted", "primary") do
    [
      "[&_.pagination-button]:border-[#007F8C] [&_.pagination-button]:text-[#007F8C]",
      "hover:[&_.pagination-button]:border-[#016974] hover:[&_.pagination-button]:text-[#016974]",
      "[&_.pagination-button.active-pagination-button]:border-[#016974] [&_.pagination-button.active-pagination-button]:text-[#016974]",
      "dark:[&_.pagination-button]:border-[#01B8CA] dark:[&_.pagination-button]:text-[#01B8CA]",
      "dark:hover:[&_.pagination-button]:border-[#77D5E3] dark:hover:[&_.pagination-button]:text-[#77D5E3]",
      "dark:[&_.pagination-button.active-pagination-button]:border-[#77D5E3] dark:[&_.pagination-button.active-pagination-button]:text-[#77D5E3]",
      "hover:[&_.pagination-button]:bg-[#E2F8FB] dark:hover:[&_.pagination-button]:bg-[#002D33]",
      "[&_.pagination-button.active-pagination-button]:bg-[#E2F8FB] dark:[&_.pagination-button.active-pagination-button]:bg-[#002D33]"
    ]
  end

  defp color_variant("inverted", "secondary") do
    [
      "[&_.pagination-button]:border-[#266EF1] [&_.pagination-button]:text-[#266EF1]",
      "hover:[&_.pagination-button]:border-[#175BCC] hover:[&_.pagination-button]:text-[#175BCC]",
      "[&_.pagination-button.active-pagination-button]:border-[#175BCC] [&_.pagination-button.active-pagination-button]:text-[#175BCC]",
      "dark:[&_.pagination-button]:border-[#6DAAFB] dark:[&_.pagination-button]:text-[#6DAAFB]",
      "dark:hover:[&_.pagination-button]:border-[#A9C9FF] dark:hover:[&_.pagination-button]:text-[#A9C9FF]",
      "dark:[&_.pagination-button.active-pagination-button]:border-[#A9C9FF] dark:[&_.pagination-button.active-pagination-button]:text-[#A9C9FF]",
      "hover:[&_.pagination-button]:bg-[#EFF4FE] dark:hover:[&_.pagination-button]:bg-[#002661]",
      "[&_.pagination-button.active-pagination-button]:bg-[#EFF4FE] dark:[&_.pagination-button.active-pagination-button]:bg-[#002661]"
    ]
  end

  defp color_variant("inverted", "success") do
    [
      "[&_.pagination-button]:border-[#0E8345] [&_.pagination-button]:text-[#0E8345]",
      "hover:[&_.pagination-button]:border-[#166C3B] hover:[&_.pagination-button]:text-[#166C3B]",
      "[&_.pagination-button.active-pagination-button]:border-[#166C3B] [&_.pagination-button.active-pagination-button]:text-[#166C3B]",
      "dark:[&_.pagination-button]:border-[#06C167] dark:[&_.pagination-button]:text-[#06C167]",
      "dark:hover:[&_.pagination-button]:border-[#7FD99A] dark:hover:[&_.pagination-button]:text-[#7FD99A]",
      "dark:[&_.pagination-button.active-pagination-button]:border-[#7FD99A] dark:[&_.pagination-button.active-pagination-button]:text-[#7FD99A]",
      "hover:[&_.pagination-button]:bg-[#EAF6ED] dark:hover:[&_.pagination-button]:bg-[#002F14]",
      "[&_.pagination-button.active-pagination-button]:bg-[#EAF6ED] dark:[&_.pagination-button.active-pagination-button]:bg-[#002F14]"
    ]
  end

  defp color_variant("inverted", "warning") do
    [
      "[&_.pagination-button]:border-[#CA8D01] [&_.pagination-button]:text-[#CA8D01]",
      "hover:[&_.pagination-button]:border-[#976A01] hover:[&_.pagination-button]:text-[#976A01]",
      "[&_.pagination-button.active-pagination-button]:border-[#976A01] [&_.pagination-button.active-pagination-button]:text-[#976A01]",
      "dark:[&_.pagination-button]:border-[#FDC034] dark:[&_.pagination-button]:text-[#FDC034]",
      "dark:hover:[&_.pagination-button]:border-[#FDD067] dark:hover:[&_.pagination-button]:text-[#FDD067]",
      "dark:[&_.pagination-button.active-pagination-button]:border-[#FDD067] dark:[&_.pagination-button.active-pagination-button]:text-[#FDD067]",
      "hover:[&_.pagination-button]:bg-[#FFF7E6] dark:hover:[&_.pagination-button]:bg-[#322300]",
      "[&_.pagination-button.active-pagination-button]:bg-[#FFF7E6] dark:[&_.pagination-button.active-pagination-button]:bg-[#322300]"
    ]
  end

  defp color_variant("inverted", "danger") do
    [
      "[&_.pagination-button]:border-[#DE1135] [&_.pagination-button]:text-[#DE1135]",
      "hover:[&_.pagination-button]:border-[#BB032A] hover:[&_.pagination-button]:text-[#BB032A]",
      "[&_.pagination-button.active-pagination-button]:border-[#BB032A] [&_.pagination-button.active-pagination-button]:text-[#BB032A]",
      "dark:[&_.pagination-button]:border-[#FC7F79] dark:[&_.pagination-button]:text-[#FC7F79]",
      "dark:hover:[&_.pagination-button]:border-[#FFB2AB] dark:hover:[&_.pagination-button]:text-[#FFB2AB]",
      "dark:[&_.pagination-button.active-pagination-button]:border-[#FFB2AB] dark:[&_.pagination-button.active-pagination-button]:text-[#FFB2AB]",
      "hover:[&_.pagination-button]:bg-[#FFF0EE] dark:hover:[&_.pagination-button]:bg-[#520810]",
      "[&_.pagination-button.active-pagination-button]:bg-[#FFF0EE] dark:[&_.pagination-button.active-pagination-button]:bg-[#520810]"
    ]
  end

  defp color_variant("inverted", "info") do
    [
      "[&_.pagination-button]:border-[#0B84BA] [&_.pagination-button]:text-[#0B84BA]",
      "hover:[&_.pagination-button]:border-[#08638C] hover:[&_.pagination-button]:text-[#08638C]",
      "[&_.pagination-button.active-pagination-button]:border-[#08638C] [&_.pagination-button.active-pagination-button]:text-[#08638C]",
      "dark:[&_.pagination-button]:border-[#3EB7ED] dark:[&_.pagination-button]:text-[#3EB7ED]",
      "dark:hover:[&_.pagination-button]:border-[#6EC9F2] dark:hover:[&_.pagination-button]:text-[#6EC9F2]",
      "dark:[&_.pagination-button.active-pagination-button]:border-[#6EC9F2] dark:[&_.pagination-button.active-pagination-button]:text-[#6EC9F2]",
      "hover:[&_.pagination-button]:bg-[#E7F6FD] dark:hover:[&_.pagination-button]:bg-[#03212F]",
      "[&_.pagination-button.active-pagination-button]:bg-[#E7F6FD] dark:[&_.pagination-button.active-pagination-button]:bg-[#03212F]"
    ]
  end

  defp color_variant("inverted", "misc") do
    [
      "[&_.pagination-button]:border-[#8750C5] [&_.pagination-button]:text-[#8750C5]",
      "hover:[&_.pagination-button]:border-[#653C94] hover:[&_.pagination-button]:text-[#653C94]",
      "[&_.pagination-button.active-pagination-button]:border-[#653C94] [&_.pagination-button.active-pagination-button]:text-[#653C94]",
      "dark:[&_.pagination-button]:border-[#BA83F9] dark:[&_.pagination-button]:text-[#BA83F9]",
      "dark:hover:[&_.pagination-button]:border-[#CBA2FA] dark:hover:[&_.pagination-button]:text-[#CBA2FA]",
      "dark:[&_.pagination-button.active-pagination-button]:border-[#CBA2FA] dark:[&_.pagination-button.active-pagination-button]:text-[#CBA2FA]",
      "hover:[&_.pagination-button]:bg-[#F6F0FE] dark:hover:[&_.pagination-button]:bg-[#221431]",
      "[&_.pagination-button.active-pagination-button]:bg-[#F6F0FE] dark:[&_.pagination-button.active-pagination-button]:bg-[#221431]"
    ]
  end

  defp color_variant("inverted", "dawn") do
    [
      "[&_.pagination-button]:border-[#A86438] [&_.pagination-button]:text-[#A86438]",
      "hover:[&_.pagination-button]:border-[#7E4B2A] hover:[&_.pagination-button]:text-[#7E4B2A]",
      "[&_.pagination-button.active-pagination-button]:border-[#7E4B2A] [&_.pagination-button.active-pagination-button]:text-[#7E4B2A]",
      "dark:[&_.pagination-button]:border-[#DB976B] dark:[&_.pagination-button]:text-[#DB976B]",
      "dark:hover:[&_.pagination-button]:border-[#E4B190] dark:hover:[&_.pagination-button]:text-[#E4B190]",
      "dark:[&_.pagination-button.active-pagination-button]:border-[#E4B190] dark:[&_.pagination-button.active-pagination-button]:text-[#E4B190]",
      "hover:[&_.pagination-button]:bg-[#FBF2ED] dark:hover:[&_.pagination-button]:bg-[#2A190E]",
      "[&_.pagination-button.active-pagination-button]:bg-[#FBF2ED] dark:[&_.pagination-button.active-pagination-button]:bg-[#2A190E]"
    ]
  end

  defp color_variant("inverted", "silver") do
    [
      "[&_.pagination-button]:border-[#868686] [&_.pagination-button]:text-[#868686]",
      "hover:[&_.pagination-button]:border-[#727272] hover:[&_.pagination-button]:text-[#727272]",
      "[&_.pagination-button.active-pagination-button]:border-[#727272] [&_.pagination-button.active-pagination-button]:text-[#727272]",
      "dark:[&_.pagination-button]:border-[#A6A6A6] dark:[&_.pagination-button]:text-[#A6A6A6]",
      "dark:hover:[&_.pagination-button]:border-[#BBBBBB] dark:hover:[&_.pagination-button]:text-[#BBBBBB]",
      "dark:[&_.pagination-button.active-pagination-button]:border-[#BBBBBB] dark:[&_.pagination-button.active-pagination-button]:text-[#BBBBBB]",
      "hover:[&_.pagination-button]:bg-[#F3F3F3] dark:hover:[&_.pagination-button]:bg-[#4B4B4B]",
      "[&_.pagination-button.active-pagination-button]:bg-[#F3F3F3] dark:[&_.pagination-button.active-pagination-button]:bg-[#4B4B4B]"
    ]
  end

  defp color_variant("gradient", "natural") do
    [
      "[&_.pagination-button]:bg-gradient-to-br hover:[&_.pagination-button]:bg-gradient-to-bl",
      "from-[#282828] to-[#727272] [&_.pagination-button]:text-white",
      "dark:from-[#A6A6A6] dark:to-[#FFFFFF] dark:[&_.pagination-button]:text-black",
      "[&_.pagination-button.active-pagination-button]:bg-gradient-to-bl"
    ]
  end

  defp color_variant("gradient", "primary") do
    [
      "[&_.pagination-button]:bg-gradient-to-br hover:[&_.pagination-button]:bg-gradient-to-bl",
      "from-[#016974] to-[#01B8CA] [&_.pagination-button]:text-white",
      "dark:from-[#01B8CA] dark:to-[#B0E7EF] dark:[&_.pagination-button]:text-black",
      "[&_.pagination-button.active-pagination-button]:bg-gradient-to-bl"
    ]
  end

  defp color_variant("gradient", "secondary") do
    [
      "[&_.pagination-button]:bg-gradient-to-br hover:[&_.pagination-button]:bg-gradient-to-bl",
      "from-[#175BCC] to-[#6DAAFB] [&_.pagination-button]:text-white",
      "dark:from-[#6DAAFB] dark:to-[#CDDEFF] dark:[&_.pagination-button]:text-black",
      "[&_.pagination-button.active-pagination-button]:bg-gradient-to-bl"
    ]
  end

  defp color_variant("gradient", "success") do
    [
      "[&_.pagination-button]:bg-gradient-to-br hover:[&_.pagination-button]:bg-gradient-to-bl",
      "from-[#166C3B] to-[#06C167] [&_.pagination-button]:text-white",
      "dark:from-[#06C167] dark:to-[#B1EAC2] dark:[&_.pagination-button]:text-black",
      "[&_.pagination-button.active-pagination-button]:bg-gradient-to-bl"
    ]
  end

  defp color_variant("gradient", "warning") do
    [
      "[&_.pagination-button]:bg-gradient-to-br hover:[&_.pagination-button]:bg-gradient-to-bl",
      "from-[#976A01] to-[#FDC034] [&_.pagination-button]:text-white",
      "dark:from-[#FDC034] dark:to-[#FEDF99] dark:[&_.pagination-button]:text-black",
      "[&_.pagination-button.active-pagination-button]:bg-gradient-to-bl"
    ]
  end

  defp color_variant("gradient", "danger") do
    [
      "[&_.pagination-button]:bg-gradient-to-br hover:[&_.pagination-button]:bg-gradient-to-bl",
      "from-[#BB032A] to-[#FC7F79] [&_.pagination-button]:text-white",
      "dark:from-[#FC7F79] dark:to-[#FFD2CD] dark:[&_.pagination-button]:text-black",
      "[&_.pagination-button.active-pagination-button]:bg-gradient-to-bl"
    ]
  end

  defp color_variant("gradient", "info") do
    [
      "[&_.pagination-button]:bg-gradient-to-br hover:[&_.pagination-button]:bg-gradient-to-bl",
      "from-[#08638C] to-[#3EB7ED] [&_.pagination-button]:text-white",
      "dark:from-[#3EB7ED] dark:to-[#9FDBF6] dark:[&_.pagination-button]:text-black",
      "[&_.pagination-button.active-pagination-button]:bg-gradient-to-bl"
    ]
  end

  defp color_variant("gradient", "misc") do
    [
      "[&_.pagination-button]:bg-gradient-to-br hover:[&_.pagination-button]:bg-gradient-to-bl",
      "from-[#653C94] to-[#BA83F9] [&_.pagination-button]:text-white",
      "dark:from-[#BA83F9] dark:to-[#DDC1FC] dark:[&_.pagination-button]:text-black",
      "[&_.pagination-button.active-pagination-button]:bg-gradient-to-bl"
    ]
  end

  defp color_variant("gradient", "dawn") do
    [
      "[&_.pagination-button]:bg-gradient-to-br hover:[&_.pagination-button]:bg-gradient-to-bl",
      "from-[#7E4B2A] to-[#DB976B] [&_.pagination-button]:text-white",
      "dark:from-[#DB976B] dark:to-[#EDCBB5] dark:[&_.pagination-button]:text-black",
      "[&_.pagination-button.active-pagination-button]:bg-gradient-to-bl"
    ]
  end

  defp color_variant("gradient", "silver") do
    [
      "[&_.pagination-button]:bg-gradient-to-br hover:[&_.pagination-button]:bg-gradient-to-bl",
      "from-[#5E5E5E] to-[#A6A6A6] [&_.pagination-button]:text-white",
      "dark:from-[#868686] dark:to-[#BBBBBB] dark:[&_.pagination-button]:text-black",
      "[&_.pagination-button.active-pagination-button]:bg-gradient-to-bl"
    ]
  end

  defp color_variant(params, _) when is_binary(params), do: params

  defp default_classes() do
    [
      "w-fit flex [&.grouped-pagination>*]::flex-1 [&:not(.grouped-pagination)]:justify-start [&:not(.grouped-pagination)]:items-center [&:not(.grouped-pagination)]:flex-wrap  [&_.pagination-button.active-pagination-button]:font-medium [&.grouped-pagination]:overflow-hidden"
    ]
  end

  defp show_pagination?(nil, _total), do: true
  defp show_pagination?(true, total) when total <= 1, do: false
  defp show_pagination?(_, total) when total > 1, do: true
  defp show_pagination?(_, _), do: false

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
