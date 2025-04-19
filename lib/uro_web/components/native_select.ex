defmodule UroWeb.Components.NativeSelect do
  @moduledoc """
  The `UroWeb.Components.NativeSelect` module provides a customizable native select component
  for forms in Phoenix LiveView. It supports a variety of styles, colors, and sizes, making
  it adaptable to different design requirements. The module allows for flexible configuration
  of the select element, including options for multi-selection, custom labels, and error handling.

  This component is highly versatile, with extensive theming options such as border styles,
  color variants, and rounded corners. It also provides a convenient way to render select
  options through slots, enabling dynamic rendering of form elements based on the passed data.

  With built-in error handling and custom error messages, `UroWeb.Components.NativeSelect`
  enhances the user experience by providing clear feedback and interaction states,
  ensuring a polished and user-friendly interface for form-based applications.
  """

  use Phoenix.Component

  @doc """
  Renders a customizable `native_select` input component with options for single or multiple selections.
  Supports validation and various styling options.

  ## Examples

  ```elixir
  <.native_select name="name" description="This is description" label="This is outline label">
    <:option value="usa">USA</:option>
    <:option value="uae" selected>UAE</:option>
  </.native_select>

  <.native_select
    name="name"
    space="small"
    color="danger"
    variant="default"
    multiple
    min_height="min-h-36"
    size="extra_small"
    description="This is multiple option group"
    label="This is outline label"
  >
    <.select_option_group label="group 1">
      <:option value="usa">USA</:option>
      <:option value="uae" selected>UAE</:option>
    </.select_option_group>

    <.select_option_group label="group 2">
      <:option value="usa">USA</:option>
      <:option value="uae">UAE</:option>
      <:option value="br" selected>Great Britain</:option>
    </.select_option_group>
  </.native_select>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :color, :string, default: "natural", doc: "Determines color theme"
  attr :border, :string, default: "extra_small", doc: "Determines border style"
  attr :rounded, :string, default: "small", doc: "Determines the border radius"
  attr :variant, :string, default: "base", doc: "Determines the style"
  attr :description, :string, default: nil, doc: "Determines a short description"
  attr :space, :string, default: "medium", doc: "Space between items"
  attr :min_height, :string, default: nil, doc: "Determines min height style"

  attr :size, :string,
    default: "extra_large",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :ring, :boolean,
    default: true,
    doc:
      "Determines a ring border on focused input, utilities for creating outline rings with box-shadows."

  attr :error_icon, :string, default: nil, doc: "Icon to be displayed alongside error messages"
  attr :label, :string, default: nil, doc: "Specifies text for the label"

  attr :multiple, :boolean,
    default: false,
    doc: "Specifies if the select input allows multiple selections"

  attr :errors, :list, default: [], doc: "List of error messages to be displayed"
  attr :name, :any, doc: "Name of input"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  slot :option, required: false do
    attr :value, :string, doc: "Value of each select option"
    attr :selected, :boolean, required: false, doc: "Specifies this option is seleted"
    attr :disabled, :string, required: false, doc: "Specifies this option is disabled"
  end

  attr :field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form"

  attr :rest, :global,
    include: ~w(autocomplete disabled form readonly multiple required title autofocus tabindex),
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  @spec native_select(map()) :: Phoenix.LiveView.Rendered.t()
  def native_select(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:name, fn ->
      if assigns.rest[:multiple], do: field.name <> "[]", else: field.name
    end)
    |> assign_new(:value, fn -> field.value end)
    |> native_select()
  end

  def native_select(assigns) do
    ~H"""
    <div class={[
      @variant != "native" && color_variant(@variant, @color),
      rounded_size(@rounded),
      border_class(@border, @variant),
      size_class(@size),
      space_class(@space),
      @ring && "[&_.select-field]:focus-within:ring-[0.03rem]"
    ]}>
      <div>
        <.label for={@id}>{@label}</.label>

        <div :if={!is_nil(@description)} class="text-xs">
          {@description}
        </div>
      </div>

      <select
        name={@name}
        id={@id}
        multiple={@multiple}
        class={[
          "select-field appearance-none block w-full text-[16px] sm:font-inherit",
          @multiple && "select-multiple-option",
          @errors != [] && "select-field-error",
          @min_height,
          @class
        ]}
        {@rest}
      >
        <option
          :for={{option, index} <- Enum.with_index(@option, 1)}
          id={"#{@id}-option-#{index}"}
          value={option[:value]}
          selected={option[:selected]}
          disabled={option[:disabled]}
        >
          {render_slot(option)}
        </option>
      </select>

      <.error :for={msg <- @errors} icon={@error_icon}>{msg}</.error>
    </div>
    """
  end

  @doc """
  Renders a group (`select_option_group`) of selectable options within a native select input.
  The group can have a label and multiple options, with support for selected and disabled states.

  ## Examples

  ```elixir
  <.select_option_group label="group 2">
    <:option value="usa">USA</:option>
    <:option value="uae">UAE</:option>
    <:option value="br" selected>Great Britain</:option>
  </.select_option_group>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :label, :string, default: nil, doc: "Specifies text for the label"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  slot :option, required: false, doc: "Option slot for select" do
    attr :value, :string, doc: "Value of each select option"
    attr :selected, :boolean, required: false, doc: "Specifies this option is seleted"
    attr :disabled, :string, required: false, doc: "Specifies this option is disabled"
  end

  def select_option_group(assigns) do
    ~H"""
    <optgroup label={@label} class={@class}>
      <option
        :for={{option, index} <- Enum.with_index(@option, 1)}
        id={"#{@id}-option-#{index}"}
        value={option[:value]}
        selected={option[:selected]}
        disabled={option[:disabled]}
      >
        {render_slot(option)}
      </option>
    </optgroup>
    <hr />
    """
  end

  @doc type: :component
  attr :for, :string, default: nil, doc: "Specifies the form which is associated with"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

  defp label(assigns) do
    ~H"""
    <label for={@for} class={["block text-sm font-semibold leading-6", @class]}>
      {render_slot(@inner_block)}
    </label>
    """
  end

  @doc type: :component
  attr :icon, :string, default: nil, doc: "Icon displayed alongside of an item"
  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

  defp error(assigns) do
    ~H"""
    <p class="mt-3 flex items-center gap-3 text-sm leading-6 text-rose-700">
      <.icon :if={!is_nil(@icon)} name={@icon} class="shrink-0" />
      {render_slot(@inner_block)}
    </p>
    """
  end

  defp size_class("extra_small") do
    [
      "text-xs [&_.select-field]:text-xs [&_.select-field:not(.select-multiple-option)]:h-9"
    ]
  end

  defp size_class("small") do
    [
      "text-sm [&_.select-field]:text-sm [&_.select-field:not(.select-multiple-option)]:h-10"
    ]
  end

  defp size_class("medium") do
    [
      "text-base [&_.select-field]:text-base [&_.select-field:not(.select-multiple-option)]:h-11"
    ]
  end

  defp size_class("large") do
    [
      "text-lg [&_.select-field]:text-lg [&_.select-field:not(.select-multiple-option)]:h-12"
    ]
  end

  defp size_class("extra_large") do
    [
      "text-xl [&_.select-field]:text-xl [&_.select-field:not(.select-multiple-option)]:h-14"
    ]
  end

  defp size_class(params) when is_binary(params), do: params

  defp rounded_size("extra_small"), do: "[&_.select-field]:rounded-sm"

  defp rounded_size("small"), do: "[&_.select-field]:rounded"

  defp rounded_size("medium"), do: "[&_.select-field]:rounded-md"

  defp rounded_size("large"), do: "[&_.select-field]:rounded-lg"

  defp rounded_size("extra_large"), do: "[&_.select-field]:rounded-xl"

  defp rounded_size("full"), do: "[&_.select-field]:rounded-full"

  defp rounded_size("none"), do: nil

  defp rounded_size(params) when is_binary(params), do: params

  defp border_class(_, variant)
       when variant in [
              "default",
              "shadow",
              "native"
            ],
       do: nil

  defp border_class("none", _), do: "[&_.select-field]:border-0"
  defp border_class("extra_small", _), do: "[&_.select-field]:border"
  defp border_class("small", _), do: "[&_.select-field]:border-2"
  defp border_class("medium", _), do: "[&_.select-field]:border-[3px]"
  defp border_class("large", _), do: "[&_.select-field]:border-4"
  defp border_class("extra_large", _), do: "[&_.select-field]:border-[5px]"
  defp border_class(params, _) when is_binary(params), do: params

  defp space_class("none"), do: nil

  defp space_class("extra_small"), do: "space-y-1"

  defp space_class("small"), do: "space-y-1.5"

  defp space_class("medium"), do: "space-y-2"

  defp space_class("large"), do: "space-y-2.5"

  defp space_class("extra_large"), do: "space-y-3"

  defp space_class(params) when is_binary(params), do: params

  defp color_variant("base", _) do
    [
      "text-[#09090b] dark:text-[#FAFAFA] [&_.select-field:not(:has(.select-field-error))]:border-[#e4e4e7] [&_.select-field]:shadow-sm",
      "[&_.select-field:not(:has(.select-field-error))]:bg-white",
      "dark:[&_.select-field:not(:has(.select-field-error))]:bg-[#18181B]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:border-[#27272a]",
      "[&_.select-field.select-field-error]:bg-rose-700 [&_.select-field.select-field-error]:border-rose-700",
      "focus-within:[&_.select-field]:ring-[#F8F9FA] dark:focus-within:[&_.select-field]:ring-[#242424]"
    ]
  end

  defp color_variant("default", "white") do
    [
      "[&_..select-field]:bg-white text-[#3E3E3E]",
      "[&_.select-field.select-field-error]:border-rose-700",
      "focus-within:[&_.select-field]:ring-[#DADADA]"
    ]
  end

  defp color_variant("default", "natural") do
    [
      "text-black dark:text-white [&_.select-field:not(:has(.select-field-error))]:bg-[#4B4B4B]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:bg-[#DDDDDD]",
      "[&_.select-field.select-field-error]:bg-rose-700",
      "[&_.select-field]:text-white dark:[&_.select-field]:text-black",
      "focus-within:[&_.select-field]:ring-[#4B4B4B] dark:focus-within:[&_.select-field]:ring-[#DDDDDD]"
    ]
  end

  defp color_variant("default", "primary") do
    [
      "text-black dark:text-white [&_.select-field:not(:has(.select-field-error))]:bg-[#007F8C]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:bg-[#01B8CA]",
      "[&_.select-field.select-field-error]:bg-rose-700",
      "[&_.select-field]:text-white dark:[&_.select-field]:text-black",
      "focus-within:[&_.select-field]:ring-[#007F8C] dark:focus-within:[&_.select-field]:ring-[#01B8CA]"
    ]
  end

  defp color_variant("default", "secondary") do
    [
      "text-black dark:text-white [&_.select-field:not(:has(.select-field-error))]:bg-[#266EF1]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:bg-[#6DAAFB]",
      "[&_.select-field.select-field-error]:bg-rose-700",
      "[&_.select-field]:text-white dark:[&_.select-field]:text-black",
      "focus-within:[&_.select-field]:ring-[#266EF1] dark:focus-within:[&_.select-field]:ring-[#6DAAFB]"
    ]
  end

  defp color_variant("default", "success") do
    [
      "text-black dark:text-white [&_.select-field:not(:has(.select-field-error))]:bg-[#0E8345]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:bg-[#06C167]",
      "[&_.select-field.select-field-error]:bg-rose-700",
      "[&_.select-field]:text-white dark:[&_.select-field]:text-black",
      "focus-within:[&_.select-field]:ring-[#0E8345] dark:focus-within:[&_.select-field]:ring-[#06C167]"
    ]
  end

  defp color_variant("default", "warning") do
    [
      "text-black dark:text-white [&_.select-field:not(:has(.select-field-error))]:bg-[#CA8D01]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:bg-[#FDC034]",
      "[&_.select-field.select-field-error]:bg-rose-700",
      "[&_.select-field]:text-white dark:[&_.select-field]:text-black",
      "focus-within:[&_.select-field]:ring-[#CA8D01] dark:focus-within:[&_.select-field]:ring-[#FDC034]"
    ]
  end

  defp color_variant("default", "danger") do
    [
      "text-black dark:text-white [&_.select-field:not(:has(.select-field-error))]:bg-[#DE1135]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:bg-[#FC7F79]",
      "[&_.select-field.select-field-error]:bg-rose-700",
      "[&_.select-field]:text-white dark:[&_.select-field]:text-black",
      "focus-within:[&_.select-field]:ring-[#DE1135] dark:focus-within:[&_.select-field]:ring-[#FC7F79]"
    ]
  end

  defp color_variant("default", "info") do
    [
      "text-black dark:text-white [&_.select-field:not(:has(.select-field-error))]:bg-[#0B84BA]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:bg-[#3EB7ED]",
      "[&_.select-field.select-field-error]:bg-rose-700",
      "[&_.select-field]:text-white dark:[&_.select-field]:text-black",
      "focus-within:[&_.select-field]:ring-[#0B84BA] dark:focus-within:[&_.select-field]:ring-[#3EB7ED]"
    ]
  end

  defp color_variant("default", "misc") do
    [
      "text-black dark:text-white [&_.select-field:not(:has(.select-field-error))]:bg-[#8750C5]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:bg-[#BA83F9]",
      "[&_.select-field.select-field-error]:bg-rose-700",
      "[&_.select-field]:text-white dark:[&_.select-field]:text-black",
      "focus-within:[&_.select-field]:ring-[#8750C5] dark:focus-within:[&_.select-field]:ring-[#BA83F9]"
    ]
  end

  defp color_variant("default", "dawn") do
    [
      "text-black dark:text-white [&_.select-field:not(:has(.select-field-error))]:bg-[#A86438]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:bg-[#DB976B]",
      "[&_.select-field.select-field-error]:bg-rose-700",
      "[&_.select-field]:text-white dark:[&_.select-field]:text-black",
      "focus-within:[&_.select-field]:ring-[#A86438] dark:focus-within:[&_.select-field]:ring-[#DB976B]"
    ]
  end

  defp color_variant("default", "silver") do
    [
      "text-black dark:text-white [&_.select-field:not(:has(.select-field-error))]:bg-[#868686]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:bg-[#A6A6A6]",
      "[&_.select-field.select-field-error]:bg-rose-700",
      "[&_.select-field]:text-white dark:[&_.select-field]:text-black",
      "focus-within:[&_.select-field]:ring-[#868686] dark:focus-within:[&_.select-field]:ring-[#A6A6A6]"
    ]
  end

  defp color_variant("default", "dark") do
    [
      "[&_.select-field]:bg-[#282828] text-[#282828] [&_.select-field]:text-white",
      "[&_.select-field.select-field-error]:bg-rose-700",
      "focus-within:[&_.select-field]:ring-[#727272]"
    ]
  end

  defp color_variant("bordered", "white") do
    [
      "[&_.select-field]:bg-white [&_.select-field]:border-transparent text-[#3E3E3E]",
      "[&_.select-field>input]:placeholder:text-[#3E3E3E]"
    ]
  end

  defp color_variant("bordered", "natural") do
    [
      "text-[#282828] dark:text-[#E8E8E8] [&_.select-field:not(:has(.select-field-error))]:border-[#282828]",
      "[&_.select-field:not(:has(.select-field-error))]:bg-[#F3F3F3]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:bg-[#4B4B4B]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:border-[#868686]",
      "[&_.select-field.select-field-error]:bg-rose-700 [&_.select-field.select-field-error]:border-rose-700",
      "focus-within:[&_.select-field]:ring-[#4B4B4B] dark:focus-within:[&_.select-field]:ring-[#DDDDDD]"
    ]
  end

  defp color_variant("bordered", "primary") do
    [
      "text-[#016974] dark:text-[#77D5E3] [&_.select-field:not(:has(.select-field-error))]:border-[#016974]",
      "[&_.select-field:not(:has(.select-field-error))]:bg-[#E2F8FB]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:bg-[#4B4B4B]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:border-[#77D5E3]",
      "[&_.select-field.select-field-error]:bg-rose-700 [&_.select-field.select-field-error]:border-rose-700",
      "focus-within:[&_.select-field]:ring-[#007F8C] dark:focus-within:[&_.select-field]:ring-[#01B8CA]"
    ]
  end

  defp color_variant("bordered", "secondary") do
    [
      "text-[#175BCC] dark:text-[#A9C9FF] [&_.select-field:not(:has(.select-field-error))]:border-[#175BCC]",
      "[&_.select-field:not(:has(.select-field-error))]:bg-[#EFF4FE]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:bg-[#002661]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:border-[#A9C9FF]",
      "[&_.select-field.select-field-error]:bg-rose-700 [&_.select-field.select-field-error]:border-rose-700",
      "focus-within:[&_.select-field]:ring-[#266EF1] dark:focus-within:[&_.select-field]:ring-[#6DAAFB]"
    ]
  end

  defp color_variant("bordered", "success") do
    [
      "text-[#166C3B] dark:text-[#7FD99A] [&_.select-field:not(:has(.select-field-error))]:border-[#166C3B]",
      "[&_.select-field:not(:has(.select-field-error))]:bg-[#EAF6ED]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:bg-[#002F14]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:border-[#7FD99A]",
      "[&_.select-field.select-field-error]:bg-rose-700 [&_.select-field.select-field-error]:border-rose-700",
      "focus-within:[&_.select-field]:ring-[#0E8345] dark:focus-within:[&_.select-field]:ring-[#06C167]"
    ]
  end

  defp color_variant("bordered", "warning") do
    [
      "text-[#976A01] dark:text-[#FDD067] [&_.select-field:not(:has(.select-field-error))]:border-[#976A01]",
      "[&_.select-field:not(:has(.select-field-error))]:bg-[#FFF7E6]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:bg-[#322300]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:border-[#FDD067]",
      "[&_.select-field.select-field-error]:bg-rose-700 [&_.select-field.select-field-error]:border-rose-700",
      "focus-within:[&_.select-field]:ring-[#CA8D01] dark:focus-within:[&_.select-field]:ring-[#FDC034]"
    ]
  end

  defp color_variant("bordered", "danger") do
    [
      "text-[#BB032A] dark:text-[#FFB2AB] [&_.select-field:not(:has(.select-field-error))]:border-[#BB032A]",
      "[&_.select-field:not(:has(.select-field-error))]:bg-[#FFF0EE]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:bg-[#221431]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:border-[#FFB2AB]",
      "[&_.select-field.select-field-error]:bg-rose-700 [&_.select-field.select-field-error]:border-rose-700",
      "focus-within:[&_.select-field]:ring-[#DE1135] dark:focus-within:[&_.select-field]:ring-[#FC7F79]"
    ]
  end

  defp color_variant("bordered", "info") do
    [
      "text-[#0B84BA] dark:text-[#6EC9F2] [&_.select-field:not(:has(.select-field-error))]:border-[#0B84BA]",
      "[&_.select-field:not(:has(.select-field-error))]:bg-[#E7F6FD]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:bg-[#03212F]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:border-[#6EC9F2]",
      "[&_.select-field.select-field-error]:bg-rose-700 [&_.select-field.select-field-error]:border-rose-700",
      "focus-within:[&_.select-field]:ring-[#0B84BA] dark:focus-within:[&_.select-field]:ring-[#3EB7ED]"
    ]
  end

  defp color_variant("bordered", "misc") do
    [
      "text-[#653C94] dark:text-[#CBA2FA] [&_.select-field:not(:has(.select-field-error))]:border-[#653C94]",
      "[&_.select-field:not(:has(.select-field-error))]:bg-[#F6F0FE]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:bg-[#221431]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:border-[#CBA2FA]",
      "[&_.select-field.select-field-error]:bg-rose-700 [&_.select-field.select-field-error]:border-rose-700",
      "focus-within:[&_.select-field]:ring-[#8750C5] dark:focus-within:[&_.select-field]:ring-[#BA83F9]"
    ]
  end

  defp color_variant("bordered", "dawn") do
    [
      "text-[#7E4B2A] dark:text-[#E4B190] [&_.select-field:not(:has(.select-field-error))]:border-[#7E4B2A]",
      "[&_.select-field:not(:has(.select-field-error))]:bg-[#FBF2ED]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:bg-[#2A190E]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:border-[#E4B190]",
      "[&_.select-field.select-field-error]:bg-rose-700 [&_.select-field.select-field-error]:border-rose-700",
      "focus-within:[&_.select-field]:ring-[#A86438] dark:focus-within:[&_.select-field]:ring-[#DB976B]"
    ]
  end

  defp color_variant("bordered", "silver") do
    [
      "text-[#727272] dark:text-[#BBBBBB] [&_.select-field:not(:has(.select-field-error))]:border-[#727272]",
      "[&_.select-field:not(:has(.select-field-error))]:bg-[#F3F3F3]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:bg-[#4B4B4B]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:border-[#BBBBBB]",
      "[&_.select-field.select-field-error]:bg-rose-700 [&_.select-field.select-field-error]:border-rose-700",
      "focus-within:[&_.select-field]:ring-[#868686] dark:focus-within:[&_.select-field]:ring-[#A6A6A6]"
    ]
  end

  defp color_variant("bordered", "dark") do
    [
      "[&_.select-field]:bg-[#282828] text-[#282828] [&_.select-field]:border-[#727272] text-white",
      "focus-within:[&_.select-field]:ring-[#050404]"
    ]
  end

  defp color_variant("shadow", "natural") do
    [
      "text-black dark:text-white [&_.select-field:not(:has(.select-field-error))]:bg-[#4B4B4B]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:bg-[#DDDDDD]",
      "[&_.select-field.select-field-error]:bg-rose-700",
      "[&_.select-field]:text-white dark:[&_.select-field]:text-black",
      "focus-within:[&_.select-field]:ring-[#4B4B4B] dark:focus-within:[&_.select-field]:ring-[#DDDDDD]",
      "[&_.select-field]:shadow-[0px_4px_6px_-4px_rgba(134,134,134,0.5)] [&_.select-field]:shadow-[0px_10px_15px_-3px_rgba(134,134,134,0.5)]",
      "dark:[&_.select-field]:shadow-none"
    ]
  end

  defp color_variant("shadow", "primary") do
    [
      "text-black dark:text-white [&_.select-field:not(:has(.select-field-error))]:bg-[#007F8C]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:bg-[#01B8CA]",
      "[&_.select-field.select-field-error]:bg-rose-700",
      "[&_.select-field]:text-white dark:[&_.select-field]:text-black",
      "focus-within:[&_.select-field]:ring-[#007F8C] dark:focus-within:[&_.select-field]:ring-[#01B8CA]",
      "[&_.select-field]:shadow-[0px_4px_6px_-4px_rgba(0,149,164,0.5)] [&_.select-field]:shadow-[0px_10px_15px_-3px_rgba(0,149,164,0.5)]",
      "dark:[&_.select-field]:shadow-none"
    ]
  end

  defp color_variant("shadow", "secondary") do
    [
      "text-black dark:text-white [&_.select-field:not(:has(.select-field-error))]:bg-[#266EF1]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:bg-[#6DAAFB]",
      "[&_.select-field.select-field-error]:bg-rose-700",
      "[&_.select-field]:text-white dark:[&_.select-field]:text-black",
      "focus-within:[&_.select-field]:ring-[#266EF1] dark:focus-within:[&_.select-field]:ring-[#6DAAFB]",
      "[&_.select-field]:shadow-[0px_4px_6px_-4px_rgba(6,139,238,0.5)] [&_.select-field]:shadow-[0px_10px_15px_-3px_rgba(6,139,238,0.5)]",
      "dark:[&_.select-field]:shadow-none"
    ]
  end

  defp color_variant("shadow", "success") do
    [
      "text-black dark:text-white [&_.select-field:not(:has(.select-field-error))]:bg-[#0E8345]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:bg-[#06C167]",
      "[&_.select-field.select-field-error]:bg-rose-700",
      "[&_.select-field]:text-white dark:[&_.select-field]:text-black",
      "focus-within:[&_.select-field]:ring-[#0E8345] dark:focus-within:[&_.select-field]:ring-[#06C167]",
      "[&_.select-field]:shadow-[0px_4px_6px_-4px_rgba(0,154,81,0.5)] [&_.select-field]:shadow-[0px_10px_15px_-3px_rgba(0,154,81,0.5)]",
      "dark:[&_.select-field]:shadow-none"
    ]
  end

  defp color_variant("shadow", "warning") do
    [
      "text-black dark:text-white [&_.select-field:not(:has(.select-field-error))]:bg-[#CA8D01]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:bg-[#FDC034]",
      "[&_.select-field.select-field-error]:bg-rose-700",
      "[&_.select-field]:text-white dark:[&_.select-field]:text-black",
      "focus-within:[&_.select-field]:ring-[#CA8D01] dark:focus-within:[&_.select-field]:ring-[#FDC034]",
      "[&_.select-field]:shadow-[0px_4px_6px_-4px_rgba(252,176,1,0.5)] [&_.select-field]:shadow-[0px_10px_15px_-3px_rgba(252,176,1,0.5)]",
      "dark:[&_.select-field]:shadow-none"
    ]
  end

  defp color_variant("shadow", "danger") do
    [
      "text-black dark:text-white [&_.select-field:not(:has(.select-field-error))]:bg-[#DE1135]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:bg-[#FC7F79]",
      "[&_.select-field.select-field-error]:bg-rose-700",
      "[&_.select-field]:text-white dark:[&_.select-field]:text-black",
      "focus-within:[&_.select-field]:ring-[#DE1135] dark:focus-within:[&_.select-field]:ring-[#FC7F79]",
      "[&_.select-field]:shadow-[0px_4px_6px_-4px_rgba(248,52,70,0.5)] [&_.select-field]:shadow-[0px_10px_15px_-3px_rgba(248,52,70,0.5)]",
      "dark:[&_.select-field]:shadow-none"
    ]
  end

  defp color_variant("shadow", "info") do
    [
      "text-black dark:text-white [&_.select-field:not(:has(.select-field-error))]:bg-[#0B84BA]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:bg-[#3EB7ED]",
      "[&_.select-field.select-field-error]:bg-rose-700",
      "[&_.select-field]:text-white dark:[&_.select-field]:text-black",
      "focus-within:[&_.select-field]:ring-[#0B84BA] dark:focus-within:[&_.select-field]:ring-[#3EB7ED]",
      "[&_.select-field]:shadow-[0px_4px_6px_-4px_rgba(14,165,233,0.5)] [&_.select-field]:shadow-[0px_10px_15px_-3px_rgba(14,165,233,0.5)]",
      "dark:[&_.select-field]:shadow-none"
    ]
  end

  defp color_variant("shadow", "misc") do
    [
      "text-black dark:text-white [&_.select-field:not(:has(.select-field-error))]:bg-[#8750C5]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:bg-[#BA83F9]",
      "[&_.select-field.select-field-error]:bg-rose-700",
      "[&_.select-field]:text-white dark:[&_.select-field]:text-black",
      "focus-within:[&_.select-field]:ring-[#8750C5] dark:focus-within:[&_.select-field]:ring-[#BA83F9]",
      "[&_.select-field]:shadow-[0px_4px_6px_-4px_rgba(169,100,247,0.5)] [&_.select-field]:shadow-[0px_10px_15px_-3px_rgba(169,100,247,0.5)]",
      "dark:[&_.select-field]:shadow-none"
    ]
  end

  defp color_variant("shadow", "dawn") do
    [
      "text-black dark:text-white [&_.select-field:not(:has(.select-field-error))]:bg-[#A86438]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:bg-[#DB976B]",
      "[&_.select-field.select-field-error]:bg-rose-700",
      "[&_.select-field]:text-white dark:[&_.select-field]:text-black",
      "focus-within:[&_.select-field]:ring-[#A86438] dark:focus-within:[&_.select-field]:ring-[#DB976B]",
      "[&_.select-field]:shadow-[0px_4px_6px_-4px_rgba(210,125,70,0.5)] [&_.select-field]:shadow-[0px_10px_15px_-3px_rgba(210,125,70,0.5)]",
      "dark:[&_.select-field]:shadow-none"
    ]
  end

  defp color_variant("shadow", "silver") do
    [
      "text-black dark:text-white [&_.select-field:not(:has(.select-field-error))]:bg-[#868686]",
      "dark:[&_.select-field:not(:has(.select-field-error))]:bg-[#A6A6A6]",
      "[&_.select-field.select-field-error]:bg-rose-700",
      "[&_.select-field]:text-white dark:[&_.select-field]:text-black",
      "focus-within:[&_.select-field]:ring-[#868686] dark:focus-within:[&_.select-field]:ring-[#A6A6A6]",
      "[&_.select-field]:shadow-[0px_4px_6px_-4px_rgba(134,134,134,0.5)] [&_.select-field]:shadow-[0px_10px_15px_-3px_rgba(134,134,134,0.5)]",
      "dark:[&_.select-field]:shadow-none"
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
    <span class={[@name] ++ @class} />
    """
  end

  defp icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end
end
