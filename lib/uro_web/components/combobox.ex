defmodule UroWeb.Components.Combobox do
  @moduledoc """
  The `UroWeb.Components.Combobox` is a Phoenix LiveView component module for creating customizable combobox elements.

  This module provides components to display combobox/select inputs with various styles, colors,
  sizes, and configurations. The main component, `combobox/1`, acts as a container for select options,
  and allows users to search, filter and select items from a dropdown list.

  The combobox component supports features like:
  - Search filtering of options
  - Single and multiple selection modes
  - Custom option rendering
  - Keyboard navigation
  - Accessibility support
  """

  use Phoenix.Component
  use Gettext, backend: UroWeb.Gettext
  import UroWeb.Components.ScrollArea, only: [scroll_area: 1]
  import Phoenix.LiveView.Utils, only: [random_id: 0]

  @doc """
  The `combobox` component is a customizable select/dropdown element with advanced features
  such as searchable options, multiple selection, and grouped items.

  It supports various customization options including:
  - Searchable options with filter functionality
  - Single or multiple selection modes
  - Option grouping with labels
  - Custom styling with color themes and variants
  - Accessibility features with ARIA attributes
  - Responsive dropdown with scrollable area
  - Form field integration
  - Custom placeholders and descriptions
  - Start section slots for icons or additional content


   ## Example usage:
    <.combobox
      options={@options}
      placeholder="Select an option"
      on_change="handle_selection"
    />
    # Single selection with options
    <.combobox placeholder="Select an item">
      <:option value="Item 1">First Item</:option>
      <:option value="Item 2">Second Item</:option>
      <:option value="Item 3">Third Item</:option>
    </.combobox>

    # With grouped options
    <.combobox placeholder="Select a fruit">
      <:option group="Citrus" value="orange">Orange</:option>
      <:option group="Citrus" value="lemon">Lemon</:option>
      <:option group="Berries" value="strawberry">Strawberry</:option>
      <:option group="Berries" value="blueberry">Blueberry</:option>
    </.combobox>

    # With disabled options
    <.combobox placeholder="Select an option">
      <:option value="available">Available Option</:option>
      <:option value="disabled" disabled>Disabled Option</:option>
      <:option value="another">Another Option</:option>
    </.combobox>

    # Multiple selection with custom rendering
    <.combobox multiple searchable placeholder="Select fruits">
      <:option value="apple">
        <div class="flex items-center gap-2">
          <span>🍎</span>
          <span>Apple</span>
        </div>
      </:option>
      <:option value="banana">
        <div class="flex items-center gap-2">
          <span>🍌</span>
          <span>Banana</span>
        </div>
      </:option>
    </.combobox>
  ```
  """

  @doc type: :component
  attr :id, :any, default: nil, doc: "A unique identifier is used to manage state and interaction"
  attr :name, :any, doc: "Name of input"
  attr :label, :string, default: nil
  attr :value, :any, doc: "Value of input"
  attr :field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form"

  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :errors, :list, default: [], doc: "List of error messages to be displayed"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :placeholder, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :search_placeholder, :string,
    default: "Search..",
    doc: "Custom CSS class for additional styling"

  attr :color, :string, default: "natural", doc: "Determines color theme"
  attr :variant, :string, default: "base", doc: "Determines variant theme"
  attr :border, :string, default: "extra_small", doc: "Determines border style"
  attr :rounded, :string, default: "medium", doc: "Radius size"
  attr :space, :string, default: "extra_small", doc: "Radius size"
  attr :padding, :string, default: "small", doc: "Padding size"
  attr :height, :string, default: "h-fit max-h-40", doc: "Dropdown height"
  attr :description, :string, default: nil, doc: "Determines a short description"
  attr :searchable, :boolean, default: false, doc: "Determines a short description"
  attr :multiple, :boolean, default: false, doc: "Multiple selections in the combobox"

  slot :start_section, required: false, doc: "Renders heex content in start of an element" do
    attr :class, :string, doc: "Custom CSS class for additional styling"
    attr :icon, :string, doc: "Icon displayed alongside of an item"
  end

  attr :size, :string,
    default: "small",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  slot :option, required: false do
    attr :value, :string, required: true, doc: "Value of the select option"
    attr :group, :string, required: false, doc: "Group name for the option"
    attr :disabled, :boolean, required: false, doc: "Specifies if this option is disabled"
  end

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step),
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  def combobox(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> combobox()
  end

  def combobox(%{multiple: true} = assigns) do
    assigns =
      assigns
      |> assign_new(:id, fn -> "combo-#{random_id()}" end)
      |> assign_new(:options, fn -> [] end)
      |> assign_new(:option, fn -> [] end)
      |> assign_new(:value, fn -> Map.get(assigns, :value, []) end)

    ~H"""
    <div class={[
      "leading-5",
      border_class(@border, @variant),
      color_variant(@variant, @color),
      rounded_size(@rounded),
      padding_size(@padding),
      size_class(@size),
      space_class(@space)
    ]}>
      <div :if={@label || @description} class="combobox-label-wrapper">
        <.label :if={@label} for={@id}>{@label}</.label>

        <div :if={@description} class="text-[12px]">
          {@description}
        </div>
      </div>

      <div phx-hook="Combobox" data-multiple={@multiple} id={"#{@id}-combo"}>
        <input type="hidden" name={@name} />
        <select id={@id} name={@name} multiple class="combo-select hidden" {@rest}>
          <option value=""></option>

          <%= if Enum.empty?(@option) do %>
            {Phoenix.HTML.Form.options_for_select(@options, @value)}
          <% else %>
            <optgroup
              :for={{group_label, grouped_options} <- Enum.group_by(@option, & &1[:group])}
              :if={!is_nil(group_label)}
              label={group_label}
            >
              {Phoenix.HTML.Form.options_for_select(
                Enum.map(grouped_options, fn option -> {option[:value], option[:value]} end),
                @value
              )}
            </optgroup>

            {!Enum.any?(@option, &Map.has_key?(&1, :group)) &&
              Phoenix.HTML.Form.options_for_select(
                Enum.map(@option, fn %{value: v} -> {v, v} end),
                @value
              )}
          <% end %>
        </select>

        <div phx-update="ignore" id={"#{@id}-combo-wrapper"} class="relative">
          <button class="combobox-trigger w-full text-start py-1 flex items-center justify-between focus:outline-none border">
            <div class="flex-1 flex items-center gap-2">
              <div
                :if={@start_section != []}
                class={[
                  "shrink-0",
                  @start_section[:class]
                ]}
              >
                {render_slot(@start_section)}
              </div>

              <div :if={@placeholder} class="combobox-placeholder select-none">
                {@placeholder}
              </div>

              <div
                data-part="select-toggle-label"
                class={[
                  "selected-value flex flex-wrap items-center gap-2 [&_.combobox-pill]:py-0.5",
                  "[&_.combobox-pill]:px-1 [&_.combobox-pill]:leading-4"
                ]}
              >
              </div>
            </div>

            <div class="flex items-center gap-1">
              <div class="shrink-0" data-part="clear-combobox-button" role="button" hidden>
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  width="24"
                  height="24"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  stroke-width="2"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  class="size-3.5 opacity-60"
                >
                  <path d="M18 6 6 18" /><path d="m6 6 12 12" />
                </svg>
              </div>

              <svg
                xmlns="http://www.w3.org/2000/svg"
                width="24"
                height="24"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
                stroke-linecap="round"
                stroke-linejoin="round"
                class="shrink-0 combobox-icon"
              >
                <path d="m7 15 5 5 5-5" /><path d="m7 9 5-5 5 5" />
              </svg>
            </div>
          </button>

          <div
            role="listbox"
            data-part="listbox"
            class="combobox-dropdown z-50 absolute w-full px-[3px] py-2 transition-all ease-out duration-[250ms] top-full mt-2"
            hidden
          >
            <div :if={@searchable} class="mt-1 mb-2 mx-1.5">
              <input
                type="text"
                class="combobox-search-input appearance-none bg-transparent px-2 py-1 w-full focus:outline-none"
                data-part="search"
                placeholder={@search_placeholder}
              />
            </div>

            <.scroll_area
              id={"combobox-wrapper-#{@id}"}
              padding="none"
              height={@height}
              scrollbar_width="w-[4px]"
            >
              <div class="px-1.5">
                <.option :for={{label, value} <- @options} :if={@options} value={value}>
                  {label}
                </.option>

                <div
                  :for={{group_label, grouped_options} <- Enum.group_by(@option, & &1[:group])}
                  :if={!is_nil(group_label)}
                  class="option-group"
                >
                  <div class="group-label font-semibold my-2">{group_label}</div>

                  <div>
                    <.option
                      :for={option <- grouped_options}
                      value={option[:value]}
                      disabled={option[:disabled]}
                    >
                      {render_slot(option)}
                    </.option>
                  </div>
                </div>

                <.option
                  :for={option <- Enum.filter(@option, &is_nil(&1[:group]))}
                  value={option[:value]}
                  disabled={option[:disabled]}
                >
                  {render_slot(option)}
                </.option>

                <div :if={@searchable} class="no-results text-center hidden">
                  {gettext("Nothing found!")}
                </div>
              </div>
            </.scroll_area>
          </div>
        </div>
      </div>

      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def combobox(assigns) do
    assigns =
      assigns
      |> assign_new(:id, fn -> "combo-#{random_id()}" end)
      |> assign_new(:options, fn -> [] end)
      |> assign_new(:option, fn -> [] end)
      |> assign_new(:value, fn -> Map.get(assigns, :value) end)

    ~H"""
    <div class={[
      "leading-5",
      border_class(@border, @variant),
      color_variant(@variant, @color),
      rounded_size(@rounded),
      padding_size(@padding),
      size_class(@size),
      space_class(@space)
    ]}>
      <div :if={@label || @description} class="combobox-label-wrapper">
        <.label :if={@label} for={@id}>{@label}</.label>

        <div :if={@description} class="text-[12px]">
          {@description}
        </div>
      </div>

      <div phx-hook="Combobox" id={"#{@id}-combo"}>
        <select id={@id} name={@name} class="combo-select hidden" {@rest}>
          <option value=""></option>

          <%= if Enum.empty?(@option) do %>
            {Phoenix.HTML.Form.options_for_select(@options, @value)}
          <% else %>
            <optgroup
              :for={{group_label, grouped_options} <- Enum.group_by(@option, & &1[:group])}
              :if={!is_nil(group_label)}
              label={group_label}
            >
              {Phoenix.HTML.Form.options_for_select(
                Enum.map(grouped_options, fn option -> {option[:value], option[:value]} end),
                @value
              )}
            </optgroup>

            {!Enum.any?(@option, &Map.has_key?(&1, :group)) &&
              Phoenix.HTML.Form.options_for_select(
                Enum.map(@option, fn %{value: v} -> {v, v} end),
                @value
              )}
          <% end %>
        </select>

        <div id={"#{@id}-combo-wrapper"} class="relative" phx-update="ignore">
          <button class="combobox-trigger w-full text-start py-1 flex items-center justify-between focus:outline-none border">
            <div id={"#{@id}-select-toggle-label"} class="flex-1 flex items-center gap-2">
              <div
                :if={@start_section != []}
                class={[
                  "shrink-0",
                  @start_section[:class]
                ]}
              >
                {render_slot(@start_section)}
              </div>

              <div :if={@placeholder} class="combobox-placeholder select-none">
                {@placeholder}
              </div>

              <div data-part="select-toggle-label" class="selected-value"></div>
            </div>

            <div class="flex items-center gap-1">
              <div class="shrink-0" data-part="clear-combobox-button" role="button" hidden>
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  width="24"
                  height="24"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  stroke-width="2"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  class="size-3.5 opacity-60"
                >
                  <path d="M18 6 6 18" /><path d="m6 6 12 12" />
                </svg>
              </div>

              <svg
                xmlns="http://www.w3.org/2000/svg"
                width="24"
                height="24"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
                stroke-linecap="round"
                stroke-linejoin="round"
                class="shrink-0 combobox-icon"
              >
                <path d="m7 15 5 5 5-5" /><path d="m7 9 5-5 5 5" />
              </svg>
            </div>
          </button>

          <div
            role="listbox"
            data-part="listbox"
            class="combobox-dropdown z-50 absolute w-full px-[3px] py-2 transition-all ease-out duration-[250ms] top-full mt-2"
            hidden
          >
            <div :if={@searchable} class="mt-1 mb-2 mx-1.5">
              <input
                type="text"
                class="combobox-search-input appearance-none bg-transparent px-2 py-1 w-full focus:outline-none"
                data-part="search"
                placeholder={@search_placeholder}
              />
            </div>

            <.scroll_area
              id={"combobox-wrapper-#{@id}"}
              padding="none"
              height={@height}
              scrollbar_width="w-[4px]"
            >
              <div class="px-1.5">
                <.option :for={{label, value} <- @options} :if={@options} value={value}>
                  {label}
                </.option>

                <div
                  :for={{group_label, grouped_options} <- Enum.group_by(@option, & &1[:group])}
                  :if={!is_nil(group_label)}
                  class="option-group"
                >
                  <div class="group-label font-semibold my-2">{group_label}</div>

                  <div>
                    <.option
                      :for={option <- grouped_options}
                      value={option[:value]}
                      disabled={option[:disabled]}
                    >
                      {render_slot(option)}
                    </.option>
                  </div>
                </div>

                <.option
                  :for={option <- Enum.filter(@option, &is_nil(&1[:group]))}
                  value={option[:value]}
                  disabled={option[:disabled]}
                >
                  {render_slot(option)}
                </.option>

                <div :if={@searchable} class="no-results text-center hidden">
                  {gettext("Nothing found!")}
                </div>
              </div>
            </.scroll_area>
          </div>
        </div>
      </div>

      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  @doc type: :component
  attr :value, :string, required: true, doc: "Specifies the form which is associated with"
  attr :disabled, :boolean, default: false, doc: "Inner block that renders HEEx content"
  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  defp option(assigns) do
    ~H"""
    <div
      role="option"
      class={[
        "combobox-option cursor-pointer rounded flex justify-between items-center",
        "[&[data-combobox-navigate]]:bg-blue-500 [&[data-combobox-navigate]]:text-white"
      ]}
      data-combobox-value={@value}
    >
      {render_slot(@inner_block)}
      <svg
        class="hidden [[data-combobox-selected]_&]:block shrink-0 w-3.5 h-3.5 combobox-icon"
        fill="none"
        viewBox="0 0 24 24"
      >
        <path
          stroke="currentColor"
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M20 6 9 17l-5-5"
        >
        </path>
      </svg>
    </div>
    """
  end

  @doc type: :component
  attr :for, :string, default: nil, doc: "Specifies the form which is associated with"
  attr :class, :any, default: nil, doc: "Custom CSS class for additional styling"
  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

  defp label(assigns) do
    ~H"""
    <label for={@for} class={["leading-5 font-semibold", @class]}>
      {render_slot(@inner_block)}
    </label>
    """
  end

  @doc type: :component
  attr :icon, :string, default: nil, doc: "Icon displayed alongside of an item"
  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

  defp error(assigns) do
    ~H"""
    <p class="mt-3 flex items-center gap-3 text-[14px] text-rose-700">
      <.icon :if={!is_nil(@icon)} name={@icon} class="shrink-0" /> {render_slot(@inner_block)}
    </p>
    """
  end

  defp size_class("extra_small") do
    [
      "[&_.combobox-trigger]:min-h-7 [&_.combobox-icon]:size-3 text-[12px]",
      "[&_.combobox-search-input]:h-6 [&_.combobox-search-input]:text-[12px]"
    ]
  end

  defp size_class("small") do
    [
      "[&_.combobox-trigger]:min-h-8 [&_.combobox-icon]:size-3.5 text-[13px]",
      "[&_.combobox-search-input]:h-7 [&_.combobox-search-input]:text-[13px]"
    ]
  end

  defp size_class("medium") do
    [
      "[&_.combobox-trigger]:min-h-9 [&_.combobox-icon]:size-4 text-[14px]",
      "[&_.combobox-search-input]:h-8 [&_.combobox-search-input]:text-[14px]"
    ]
  end

  defp size_class("large") do
    [
      "[&_.combobox-trigger]:min-h-10 [&_.combobox-icon]:size-[18px] text-[15px]",
      "[&_.combobox-search-input]:h-9 [&_.combobox-search-input]:text-[15px]"
    ]
  end

  defp size_class("extra_large") do
    [
      "[&_.combobox-trigger]:min-h-11 [&_.combobox-icon]:size-5 text-[16px]",
      "[&_.combobox-search-input]:h-10 [&_.combobox-search-input]:text-[16px]"
    ]
  end

  defp size_class(params) when is_binary(params), do: params

  defp rounded_size("extra_small") do
    [
      "[&_.combobox-trigger]:rounded-sm [&_.combobox-dropdown]:rounded-sm",
      "[&_.combobox-pill]:rounded-[0.0625rem] [&_.combobox-search-input]:rounded-sm"
    ]
  end

  defp rounded_size("small") do
    [
      "[&_.combobox-trigger]:rounded [&_.combobox-dropdown]:rounded",
      "[&_.combobox-pill]:rounded-[0.13rem] [&_.combobox-search-input]:rounded"
    ]
  end

  defp rounded_size("medium") do
    [
      "[&_.combobox-trigger]:rounded-md [&_.combobox-dropdown]:rounded-md",
      "[&_.combobox-pill]:rounded-[0.19rem] [&_.combobox-search-input]:rounded-md"
    ]
  end

  defp rounded_size("large") do
    [
      "[&_.combobox-trigger]:rounded-lg [&_.combobox-dropdown]:rounded-lg",
      "[&_.combobox-pill]:rounded-[0.3rem] [&_.combobox-search-input]:rounded-lg"
    ]
  end

  defp rounded_size("extra_large") do
    [
      "[&_.combobox-trigger]:rounded-xl [&_.combobox-dropdown]:rounded-xl",
      "[&_.combobox-pill]:rounded-[0.313rem] [&_.combobox-search-input]:rounded-xl"
    ]
  end

  defp rounded_size("full") do
    [
      "[&_.combobox-trigger]:rounded-full [&_.combobox-dropdown]:rounded-full",
      "[&_.combobox-pill]:rounded-full [&_.combobox-search-input]:rounded-full"
    ]
  end

  defp rounded_size("none"), do: nil

  defp rounded_size(params) when is_binary(params), do: params

  defp border_class(_, variant) when variant in ["default"],
    do: nil

  defp border_class("none", _), do: nil

  defp border_class("extra_small", _),
    do: "[&_.combobox-trigger]:border [&_.combobox-dropdown]:border"

  defp border_class("small", _),
    do: "[&_.combobox-trigger]:border-2 [&_.combobox-dropdown]:border-2"

  defp border_class("medium", _),
    do: "[&_.combobox-trigger]:border-[3px] [&_.combobox-dropdown]:border-[3px]"

  defp border_class("large", _),
    do: "[&_.combobox-trigger]:border-4 [&_.combobox-dropdown]:border-4"

  defp border_class("extra_large", _),
    do: "[&_.combobox-trigger]:border-[5px] [&_.combobox-dropdown]:border-[5px]"

  defp border_class(params, _) when is_binary(params), do: params

  defp padding_size("extra_small") do
    ["[&_.combobox-trigger]:px-2 [&_.combobox-option]:px-2", "[&_.combobox-option]:py-0.5"]
  end

  defp padding_size("small") do
    ["[&_.combobox-trigger]:px-3 [&_.combobox-option]:px-3", "[&_.combobox-option]:py-1"]
  end

  defp padding_size("medium") do
    ["[&_.combobox-trigger]:px-4 [&_.combobox-option]:px-4", "[&_.combobox-option]:py-1.5"]
  end

  defp padding_size("large") do
    ["[&_.combobox-trigger]:px-5 [&_.combobox-option]:px-5", "[&_.combobox-option]:py-2"]
  end

  defp padding_size("extra_large") do
    ["[&_.combobox-trigger]:px-6 [&_.combobox-option]:px-6", "[&_.combobox-option]:py-2.5"]
  end

  defp padding_size(params) when is_binary(params), do: params

  defp space_class("extra_small"), do: "space-y-2 [&_.combobox-label-wrapper]:space-y-1"
  defp space_class("small"), do: "space-y-3 [&_.combobox-label-wrapper]:space-y-2"
  defp space_class("medium"), do: "space-y-4 [&_.combobox-label-wrapper]:space-y-3"
  defp space_class("large"), do: "space-y-5 [&_.combobox-label-wrapper]:space-y-4"
  defp space_class("extra_large"), do: "space-y-6 [&_.combobox-label-wrapper]:space-y-5"
  defp space_class("none"), do: nil
  defp space_class(params) when is_binary(params), do: params

  defp color_variant("base", _) do
    [
      "[&_.combobox-trigger]:bg-white text-[#09090b] [&_.combobox-trigger]:border-[#e4e4e7] [&_.combobox-trigger]:shadow-sm",
      "dark:[&_.combobox-trigger]:bg-[#18181B] dark:text-[#FAFAFA] dark:[&_.combobox-trigger]:border-[#27272a]",
      "[&_.combobox-dropdown]:bg-white [&_.combobox-dropdown]:border-[#e4e4e7]",
      "dark:[&_.combobox-dropdown]:bg-[#18181B] dark:[&_.combobox-dropdown]:border-[#27272a]",
      "hover:[&_.combobox-option:not([data-combobox-navigate])]:bg-[#e4e4e7] hover:[&_.combobox-option:not([data-combobox-navigate])]:text-[#09090b]",
      "dark:hover:[&_.combobox-option:not([data-combobox-navigate])]:bg-[#27272a] dark:hover:[&_.combobox-option:not([data-combobox-navigate])]:text-[#FAFAFA]",
      "[&_.combobox-search-input]:border-[#e4e4e7] dark:[&_.combobox-search-input]:border-[#27272a]",
      "[&_.combobox-pill]:text-[#09090b] [&_.combobox-pill]:bg-[#e4e4e7]",
      "[&_.combobox-dropdown]:shadow"
    ]
  end

  defp color_variant("default", "natural") do
    [
      "[&_.combobox-trigger]:bg-[#4B4B4B] text-white dark:[&_.combobox-trigger]:bg-[#DDDDDD] dark:text-black",
      "[&_.combobox-dropdown]:bg-[#4B4B4B] dark:[&_.combobox-dropdown]:bg-[#E8E8E8]",
      "hover:[&_.combobox-option]:bg-[#282828] dark:hover:[&_.combobox-option]:bg-[#E8E8E8]",
      "[&_.combobox-search-input]:border-white dark:[&_.combobox-search-input]:border-black",
      "[&_.combobox-search-input]:text-white dark:[&_.combobox-search-input]:text-black",
      "[&_.combobox-search-input]:placeholder-white dark:[&_.combobox-search-input]:placeholder-black",
      "[&_.combobox-pill]:bg-[#282828] dark:[&_.combobox-pill]:bg-[#E8E8E8]"
    ]
  end

  defp color_variant("default", "primary") do
    [
      "[&_.combobox-trigger]:bg-[#007F8C] text-white dark:[&_.combobox-trigger]:bg-[#01B8CA] dark:text-black",
      "[&_.combobox-dropdown]:bg-[#007F8C] dark:[&_.combobox-dropdown]:bg-[#01B8CA]",
      "hover:[&_.combobox-option]:bg-[#016974] dark:hover:[&_.combobox-option]:bg-[#77D5E3]",
      "[&_.combobox-search-input]:border-white dark:[&_.combobox-search-input]:border-black",
      "[&_.combobox-search-input]:text-white dark:[&_.combobox-search-input]:text-black",
      "[&_.combobox-search-input]:placeholder-white dark:[&_.combobox-search-input]:placeholder-black",
      "[&_.combobox-pill]:bg-[#016974] dark:[&_.combobox-pill]:bg-[#77D5E3]"
    ]
  end

  defp color_variant("default", "secondary") do
    [
      "[&_.combobox-trigger]:bg-[#266EF1] text-white dark:[&_.combobox-trigger]:bg-[#6DAAFB] dark:text-black",
      "[&_.combobox-dropdown]:bg-[#266EF1] dark:[&_.combobox-dropdown]:bg-[#6DAAFB]",
      "hover:[&_.combobox-option]:bg-[#175BCC] dark:hover:[&_.combobox-option]:bg-[#A9C9FF]",
      "[&_.combobox-search-input]:border-white dark:[&_.combobox-search-input]:border-black",
      "[&_.combobox-search-input]:text-white dark:[&_.combobox-search-input]:text-black",
      "[&_.combobox-search-input]:placeholder-white dark:[&_.combobox-search-input]:placeholder-black",
      "[&_.combobox-pill]:bg-[#175BCC] dark:[&_.combobox-pill]:bg-[#A9C9FF]"
    ]
  end

  defp color_variant("default", "success") do
    [
      "[&_.combobox-trigger]:bg-[#0E8345] text-white dark:[&_.combobox-trigger]:bg-[#06C167] dark:text-black",
      "[&_.combobox-dropdown]:bg-[#0E8345] dark:[&_.combobox-dropdown]:bg-[#06C167]",
      "hover:[&_.combobox-option]:bg-[#166C3B] dark:hover:[&_.combobox-option]:bg-[#7FD99A]",
      "[&_.combobox-search-input]:border-white dark:[&_.combobox-search-input]:border-black",
      "[&_.combobox-search-input]:text-white dark:[&_.combobox-search-input]:text-black",
      "[&_.combobox-search-input]:placeholder-white dark:[&_.combobox-search-input]:placeholder-black",
      "[&_.combobox-pill]:bg-[#166C3B] dark:[&_.combobox-pill]:bg-[#7FD99A]"
    ]
  end

  defp color_variant("default", "warning") do
    [
      "[&_.combobox-trigger]:bg-[#CA8D01] text-white dark:[&_.combobox-trigger]:bg-[#FDC034] dark:text-black",
      "[&_.combobox-dropdown]:bg-[#CA8D01] dark:[&_.combobox-dropdown]:bg-[#FDC034]",
      "hover:[&_.combobox-option]:bg-[#976A01] dark:hover:[&_.combobox-option]:bg-[#FDD067]",
      "[&_.combobox-search-input]:border-white dark:[&_.combobox-search-input]:border-black",
      "[&_.combobox-search-input]:text-white dark:[&_.combobox-search-input]:text-black",
      "[&_.combobox-search-input]:placeholder-white dark:[&_.combobox-search-input]:placeholder-black",
      "[&_.combobox-pill]:bg-[#976A01] dark:[&_.combobox-pill]:bg-[#FDD067]"
    ]
  end

  defp color_variant("default", "danger") do
    [
      "[&_.combobox-trigger]:bg-[#DE1135] text-white dark:[&_.combobox-trigger]:bg-[#FC7F79] dark:text-black",
      "[&_.combobox-dropdown]:bg-[#DE1135] dark:[&_.combobox-dropdown]:bg-[#FC7F79]",
      "hover:[&_.combobox-option]:bg-[#BB032A] dark:hover:[&_.combobox-option]:bg-[#FFB2AB]",
      "[&_.combobox-search-input]:border-white dark:[&_.combobox-search-input]:border-black",
      "[&_.combobox-search-input]:text-white dark:[&_.combobox-search-input]:text-black",
      "[&_.combobox-search-input]:placeholder-white dark:[&_.combobox-search-input]:placeholder-black",
      "[&_.combobox-pill]:bg-[#BB032A] dark:[&_.combobox-pill]:bg-[#FFB2AB]"
    ]
  end

  defp color_variant("default", "info") do
    [
      "[&_.combobox-trigger]:bg-[#0B84BA] text-white dark:[&_.combobox-trigger]:bg-[#3EB7ED] dark:text-black",
      "[&_.combobox-dropdown]:bg-[#0B84BA] dark:[&_.combobox-dropdown]:bg-[#3EB7ED]",
      "hover:[&_.combobox-option]:bg-[#08638C] dark:hover:[&_.combobox-option]:bg-[#6EC9F2]",
      "[&_.combobox-search-input]:border-white dark:[&_.combobox-search-input]:border-black",
      "[&_.combobox-search-input]:text-white dark:[&_.combobox-search-input]:text-black",
      "[&_.combobox-search-input]:placeholder-white dark:[&_.combobox-search-input]:placeholder-black",
      "[&_.combobox-pill]:bg-[#08638C] dark:[&_.combobox-pill]:bg-[#6EC9F2]"
    ]
  end

  defp color_variant("default", "misc") do
    [
      "[&_.combobox-trigger]:bg-[#8750C5] text-white dark:[&_.combobox-trigger]:bg-[#BA83F9] dark:text-black",
      "[&_.combobox-dropdown]:bg-[#8750C5] dark:[&_.combobox-dropdown]:bg-[#BA83F9]",
      "hover:[&_.combobox-option]:bg-[#653C94] dark:hover:[&_.combobox-option]:bg-[#CBA2FA]",
      "[&_.combobox-search-input]:border-white dark:[&_.combobox-search-input]:border-black",
      "[&_.combobox-search-input]:text-white dark:[&_.combobox-search-input]:text-black",
      "[&_.combobox-search-input]:placeholder-white dark:[&_.combobox-search-input]:placeholder-black",
      "[&_.combobox-pill]:bg-[#653C94] dark:[&_.combobox-pill]:bg-[#CBA2FA]"
    ]
  end

  defp color_variant("default", "dawn") do
    [
      "[&_.combobox-trigger]:bg-[#A86438] text-white dark:[&_.combobox-trigger]:bg-[#DB976B] dark:text-black",
      "[&_.combobox-dropdown]:bg-[#A86438] dark:[&_.combobox-dropdown]:bg-[#DB976B]",
      "hover:[&_.combobox-option]:bg-[#7E4B2A] dark:hover:[&_.combobox-option]:bg-[#E4B190]",
      "[&_.combobox-search-input]:border-white dark:[&_.combobox-search-input]:border-black",
      "[&_.combobox-search-input]:text-white dark:[&_.combobox-search-input]:text-black",
      "[&_.combobox-search-input]:placeholder-white dark:[&_.combobox-search-input]:placeholder-black",
      "[&_.combobox-pill]:bg-[#7E4B2A] dark:[&_.combobox-pill]:bg-[#E4B190]"
    ]
  end

  defp color_variant("default", "silver") do
    [
      "[&_.combobox-trigger]:bg-[#868686] text-white dark:[&_.combobox-trigger]:bg-[#A6A6A6] dark:text-black",
      "[&_.combobox-dropdown]:bg-[#868686] dark:[&_.combobox-dropdown]:bg-[#A6A6A6]",
      "hover:[&_.combobox-option]:bg-[#727272] dark:hover:[&_.combobox-option]:bg-[#BBBBBB]",
      "[&_.combobox-search-input]:border-white dark:[&_.combobox-search-input]:border-black",
      "[&_.combobox-search-input]:text-white dark:[&_.combobox-search-input]:text-black",
      "[&_.combobox-search-input]:placeholder-white dark:[&_.combobox-search-input]:placeholder-black",
      "[&_.combobox-pill]:bg-[#727272] dark:[&_.combobox-pill]:bg-[#BBBBBB]"
    ]
  end

  defp color_variant("bordered", "natural") do
    [
      "text-[#282828] [&_.combobox-trigger]:border-[#282828] [&_.combobox-trigger]:bg-[#F3F3F3]",
      "dark:text-[#E8E8E8] dark:[&_.combobox-trigger]:border-[#E8E8E8] dark:[&_.combobox-trigger]:bg-[#4B4B4B]",
      "[&_.combobox-dropdown]:bg-[#F3F3F3] [&_.combobox-dropdown]:border-[#282828]",
      "dark:[&_.combobox-dropdown]:bg-[#4B4B4B] dark:[&_.combobox-dropdown]:border-[#E8E8E8]",
      "hover:[&_.combobox-option]:bg-[#282828] hover:[&_.combobox-option]:text-white",
      "dark:hover:[&_.combobox-option]:bg-[#E8E8E8] dark:hover:[&_.combobox-option]:text-black",
      "[&_.combobox-search-input]:border-[#282828] dark:[&_.combobox-search-input]:border-[#E8E8E8]",
      "[&_.combobox-search-input]:text-[#282828] dark:[&_.combobox-search-input]:text-[#E8E8E8]",
      "[&_.combobox-search-input]:placeholder-[#282828] dark:[&_.combobox-search-input]:placeholder-[#E8E8E8]",
      "[&_.combobox-pill]:bg-[#282828] [&_.combobox-pill]:text-white",
      "dark:[&_.combobox-pill]:bg-[#E8E8E8] dark:[&_.combobox-pill]:text-black"
    ]
  end

  defp color_variant("bordered", "primary") do
    [
      "text-[#016974] [&_.combobox-trigger]:border-[#016974] [&_.combobox-trigger]:bg-[#E2F8FB]",
      "dark:text-[#77D5E3] dark:[&_.combobox-trigger]:border-[#77D5E3] dark:[&_.combobox-trigger]:bg-[#002D33]",
      "[&_.combobox-dropdown]:bg-[#E2F8FB] [&_.combobox-dropdown]:border-[#016974]",
      "dark:[&_.combobox-dropdown]:bg-[#002D33] dark:[&_.combobox-dropdown]:border-[#77D5E3]",
      "hover:[&_.combobox-option]:bg-[#016974] hover:[&_.combobox-option]:text-white",
      "dark:hover:[&_.combobox-option]:bg-[#77D5E3] dark:hover:[&_.combobox-option]:text-black",
      "[&_.combobox-search-input]:border-[#016974] dark:[&_.combobox-search-input]:border-[#77D5E3]",
      "[&_.combobox-search-input]:text-[#016974] dark:[&_.combobox-search-input]:text-[#77D5E3]",
      "[&_.combobox-search-input]:placeholder-[#016974] dark:[&_.combobox-search-input]:placeholder-[#77D5E3]",
      "[&_.combobox-pill]:bg-[#016974] [&_.combobox-pill]:text-white",
      "dark:[&_.combobox-pill]:bg-[#77D5E3] dark:[&_.combobox-pill]:text-black"
    ]
  end

  defp color_variant("bordered", "secondary") do
    [
      "text-[#175BCC] [&_.combobox-trigger]:border-[#175BCC] [&_.combobox-trigger]:bg-[#EFF4FE]",
      "dark:text-[#A9C9FF] dark:[&_.combobox-trigger]:border-[#A9C9FF] dark:[&_.combobox-trigger]:bg-[#002661]",
      "[&_.combobox-dropdown]:bg-[#EFF4FE] [&_.combobox-dropdown]:border-[#175BCC]",
      "dark:[&_.combobox-dropdown]:bg-[#002661] dark:[&_.combobox-dropdown]:border-[#A9C9FF]",
      "hover:[&_.combobox-option]:bg-[#175BCC] hover:[&_.combobox-option]:text-white",
      "dark:hover:[&_.combobox-option]:bg-[#A9C9FF] dark:hover:[&_.combobox-option]:text-black",
      "[&_.combobox-search-input]:border-[#175BCC] dark:[&_.combobox-search-input]:border-[#A9C9FF]",
      "[&_.combobox-search-input]:text-[#175BCC] dark:[&_.combobox-search-input]:text-[#A9C9FF]",
      "[&_.combobox-search-input]:placeholder-[#175BCC] dark:[&_.combobox-search-input]:placeholder-[#A9C9FF]",
      "[&_.combobox-pill]:bg-[#175BCC] [&_.combobox-pill]:text-white",
      "dark:[&_.combobox-pill]:bg-[#A9C9FF] dark:[&_.combobox-pill]:text-black"
    ]
  end

  defp color_variant("bordered", "success") do
    [
      "text-[#166C3B] [&_.combobox-trigger]:border-[#166C3B] [&_.combobox-trigger]:bg-[#EAF6ED]",
      "dark:text-[#7FD99A] dark:[&_.combobox-trigger]:border-[#7FD99A] dark:[&_.combobox-trigger]:bg-[#002F14]",
      "[&_.combobox-dropdown]:bg-[#EAF6ED] [&_.combobox-dropdown]:border-[#166C3B]",
      "dark:[&_.combobox-dropdown]:bg-[#002F14] dark:[&_.combobox-dropdown]:border-[#7FD99A]",
      "hover:[&_.combobox-option]:bg-[#175BCC] hover:[&_.combobox-option]:text-white",
      "dark:hover:[&_.combobox-option]:bg-[#A9C9FF] dark:hover:[&_.combobox-option]:text-black",
      "[&_.combobox-search-input]:border-[#166C3B] dark:[&_.combobox-search-input]:border-[#7FD99A]",
      "[&_.combobox-search-input]:text-[#166C3B] dark:[&_.combobox-search-input]:text-[#7FD99A]",
      "[&_.combobox-search-input]:placeholder-[#166C3B] dark:[&_.combobox-search-input]:placeholder-[#7FD99A]",
      "[&_.combobox-pill]:bg-[#175BCC] [&_.combobox-pill]:text-white",
      "dark:[&_.combobox-pill]:bg-[#A9C9FF] dark:[&_.combobox-pill]:text-black"
    ]
  end

  defp color_variant("bordered", "warning") do
    [
      "text-[#976A01] [&_.combobox-trigger]:border-[#976A01] [&_.combobox-trigger]:bg-[#FFF7E6]",
      "dark:text-[#FDD067] dark:[&_.combobox-trigger]:border-[#FDD067] dark:[&_.combobox-trigger]:bg-[#322300]",
      "[&_.combobox-dropdown]:bg-[#FFF7E6] [&_.combobox-dropdown]:border-[#976A01]",
      "dark:[&_.combobox-dropdown]:bg-[#322300] dark:[&_.combobox-dropdown]:border-[#FDD067]",
      "hover:[&_.combobox-option]:bg-[#976A01] hover:[&_.combobox-option]:text-white",
      "dark:hover:[&_.combobox-option]:bg-[#FDD067] dark:hover:[&_.combobox-option]:text-black",
      "[&_.combobox-search-input]:border-[#976A01] dark:[&_.combobox-search-input]:border-[#FDD067]",
      "[&_.combobox-search-input]:text-[#976A01] dark:[&_.combobox-search-input]:text-[#FDD067]",
      "[&_.combobox-search-input]:placeholder-[#976A01] dark:[&_.combobox-search-input]:placeholder-[#FDD067]",
      "[&_.combobox-pill]:bg-[#976A01] [&_.combobox-pill]:text-white",
      "dark:[&_.combobox-pill]:bg-[#FDD067] dark:[&_.combobox-pill]:text-black"
    ]
  end

  defp color_variant("bordered", "danger") do
    [
      "text-[#BB032A] [&_.combobox-trigger]:border-[#BB032A] [&_.combobox-trigger]:bg-[#FFF0EE]",
      "dark:text-[#FFB2AB] dark:[&_.combobox-trigger]:border-[#FFB2AB] dark:[&_.combobox-trigger]:bg-[#520810]",
      "[&_.combobox-dropdown]:bg-[#FFF0EE] [&_.combobox-dropdown]:border-[#BB032A]",
      "dark:[&_.combobox-dropdown]:bg-[#520810] dark:[&_.combobox-dropdown]:border-[#FFB2AB]",
      "hover:[&_.combobox-option]:bg-[#BB032A] hover:[&_.combobox-option]:text-white",
      "dark:hover:[&_.combobox-option]:bg-[#FFB2AB] dark:hover:[&_.combobox-option]:text-black",
      "[&_.combobox-search-input]:border-[#BB032A] dark:[&_.combobox-search-input]:border-[#FFB2AB]",
      "[&_.combobox-search-input]:text-[#BB032A] dark:[&_.combobox-search-input]:text-[#FFB2AB]",
      "[&_.combobox-search-input]:placeholder-[#BB032A] dark:[&_.combobox-search-input]:placeholder-[#FFB2AB]",
      "[&_.combobox-pill]:bg-[#BB032A] [&_.combobox-pill]:text-white",
      "dark:[&_.combobox-pill]:bg-[#FFB2AB] dark:[&_.combobox-pill]:text-black"
    ]
  end

  defp color_variant("bordered", "info") do
    [
      "text-[#0B84BA] [&_.combobox-trigger]:border-[#0B84BA] [&_.combobox-trigger]:bg-[#E7F6FD]",
      "dark:text-[#6EC9F2] dark:[&_.combobox-trigger]:border-[#6EC9F2] dark:[&_.combobox-trigger]:bg-[#03212F]",
      "[&_.combobox-dropdown]:bg-[#E7F6FD] [&_.combobox-dropdown]:border-[#0B84BA]",
      "dark:[&_.combobox-dropdown]:bg-[#03212F] dark:[&_.combobox-dropdown]:border-[#6EC9F2]",
      "hover:[&_.combobox-option]:bg-[#0B84BA] hover:[&_.combobox-option]:text-white",
      "dark:hover:[&_.combobox-option]:bg-[#6EC9F2] dark:hover:[&_.combobox-option]:text-black",
      "[&_.combobox-search-input]:border-[#0B84BA] dark:[&_.combobox-search-input]:border-[#6EC9F2]",
      "[&_.combobox-search-input]:text-[#0B84BA] dark:[&_.combobox-search-input]:text-[#6EC9F2]",
      "[&_.combobox-search-input]:placeholder-[#0B84BA] dark:[&_.combobox-search-input]:placeholder-[#6EC9F2]",
      "[&_.combobox-pill]:bg-[#0B84BA] [&_.combobox-pill]:text-white",
      "dark:[&_.combobox-pill]:bg-[#6EC9F2] dark:[&_.combobox-pill]:text-black"
    ]
  end

  defp color_variant("bordered", "misc") do
    [
      "text-[#653C94] [&_.combobox-trigger]:border-[#653C94] [&_.combobox-trigger]:bg-[#F6F0FE]",
      "dark:text-[#CBA2FA] dark:[&_.combobox-trigger]:border-[#CBA2FA] dark:[&_.combobox-trigger]:bg-[#221431]",
      "[&_.combobox-dropdown]:bg-[#F6F0FE] [&_.combobox-dropdown]:border-[#653C94]",
      "dark:[&_.combobox-dropdown]:bg-[#03212F] dark:[&_.combobox-dropdown]:border-[#CBA2FA]",
      "hover:[&_.combobox-option]:bg-[#221431] hover:[&_.combobox-option]:text-white",
      "dark:hover:[&_.combobox-option]:bg-[#CBA2FA] dark:hover:[&_.combobox-option]:text-black",
      "[&_.combobox-search-input]:border-[#653C94] dark:[&_.combobox-search-input]:border-[#CBA2FA]",
      "[&_.combobox-search-input]:text-[#653C94] dark:[&_.combobox-search-input]:text-[#CBA2FA]",
      "[&_.combobox-search-input]:placeholder-[#653C94] dark:[&_.combobox-search-input]:placeholder-[#CBA2FA]",
      "[&_.combobox-pill]:bg-[#221431] [&_.combobox-pill]:text-white",
      "dark:[&_.combobox-pill]:bg-[#CBA2FA] dark:[&_.combobox-pill]:text-black"
    ]
  end

  defp color_variant("bordered", "dawn") do
    [
      "text-[#7E4B2A] [&_.combobox-trigger]:border-[#7E4B2A] [&_.combobox-trigger]:bg-[#FBF2ED]",
      "dark:text-[#E4B190] dark:[&_.combobox-trigger]:border-[#E4B190] dark:[&_.combobox-trigger]:bg-[#2A190E]",
      "[&_.combobox-dropdown]:bg-[#FBF2ED] [&_.combobox-dropdown]:border-[#7E4B2A]",
      "dark:[&_.combobox-dropdown]:bg-[#2A190E] dark:[&_.combobox-dropdown]:border-[#E4B190]",
      "hover:[&_.combobox-option]:bg-[#7E4B2A] hover:[&_.combobox-option]:text-white",
      "dark:hover:[&_.combobox-option]:bg-[#E4B190] dark:hover:[&_.combobox-option]:text-black",
      "[&_.combobox-search-input]:border-[#7E4B2A] dark:[&_.combobox-search-input]:border-[#E4B190]",
      "[&_.combobox-search-input]:text-[#7E4B2A] dark:[&_.combobox-search-input]:text-[#E4B190]",
      "[&_.combobox-search-input]:placeholder-[#7E4B2A] dark:[&_.combobox-search-input]:placeholder-[#E4B190]",
      "[&_.combobox-pill]:bg-[#7E4B2A] [&_.combobox-pill]:text-white",
      "dark:[&_.combobox-pill]:bg-[#E4B190] dark:[&_.combobox-pill]:text-black"
    ]
  end

  defp color_variant("bordered", "silver") do
    [
      "text-[#727272] [&_.combobox-trigger]:border-[#727272] [&_.combobox-trigger]:bg-[#F3F3F3]",
      "dark:text-[#BBBBBB] dark:[&_.combobox-trigger]:border-[#BBBBBB] dark:[&_.combobox-trigger]:bg-[#4B4B4B]",
      "[&_.combobox-dropdown]:bg-[#F3F3F3] [&_.combobox-dropdown]:border-[#727272]",
      "dark:[&_.combobox-dropdown]:bg-[#4B4B4B] dark:[&_.combobox-dropdown]:border-[#BBBBBB]",
      "hover:[&_.combobox-option]:bg-[#727272] hover:[&_.combobox-option]:text-white",
      "dark:hover:[&_.combobox-option]:bg-[#BBBBBB] dark:hover:[&_.combobox-option]:text-black",
      "[&_.combobox-search-input]:border-[#727272] dark:[&_.combobox-search-input]:border-[#BBBBBB]",
      "[&_.combobox-search-input]:text-[#727272] dark:[&_.combobox-search-input]:text-[#BBBBBB]",
      "[&_.combobox-search-input]:placeholder-[#727272] dark:[&_.combobox-search-input]:placeholder-[#BBBBBB]",
      "[&_.combobox-pill]:bg-[#727272] [&_.combobox-pill]:text-white",
      "dark:[&_.combobox-pill]:bg-[#BBBBBB] dark:[&_.combobox-pill]:text-black"
    ]
  end

  defp color_variant(params, _) when is_binary(params), do: params

  defp translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # However the error messages in our forms and APIs are generated
    # dynamically, so we need to translate them by calling Gettext
    # with our gettext backend as first argument. Translations are
    # available in the errors.po file (as we use the "errors" domain).
    if count = opts[:count] do
      Gettext.dngettext(UroWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(UroWeb.Gettext, "errors", msg, opts)
    end
  end

  attr :name, :string, required: true, doc: "Specifies the name of the element"
  attr :class, :any, default: nil, doc: "Custom CSS class for additional styling"

  defp icon(%{name: "hero-" <> _, class: class} = assigns) when is_list(class) do
    ~H"""
    <span class={["radio-card-icon", @name, @class]} />
    """
  end

  defp icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={["radio-card-icon", @name, @class]} />
    """
  end
end
