defmodule UroWeb.Components.RangeField do
  @moduledoc """
  The `UroWeb.Components.RangeField` module provides a comprehensive range input field
  component for Phoenix LiveView applications. This component is designed with flexibility and
  customization in mind, allowing developers to configure various aspects such as size, color, and
  styling options.

  With attributes for managing state, interaction, and layout, the `RangeField` component can be
  easily adapted to different use cases, from simple form inputs to more complex data-driven interfaces.
  The module supports custom labels, error handling, and a range value slot for displaying dynamic
  content based on the input value.

  This component is particularly useful for scenarios that require user input in a defined range,
  such as sliders for adjusting numerical values or settings. It ensures a visually consistent
  and user-friendly experience across different parts of the application, while maintaining a
  high level of customization and control.
  """
  use Phoenix.Component

  @doc """
  Renders a customizable `range_field`, which allows users to select a numeric value from a defined range.
  The component can be styled in different ways and supports additional labels or values at specified positions.

  ## Examples

  ```elixir
  <.range_field
    appearance="custom"
    value="40"
    color="warning"
    size="small"
    min="10"
    id="custom-range-1"
    max="100"
    name="custom-range"
    step="5"
  >
    <:range_value position="start">Min ($100)</:range_value>
    <:range_value position="middle">$700</:range_value>
    <:range_value position="end">Max ($1500)</:range_value>
  </.range_field>

  <.range_field
    value="60"
    size="medium"
    color="primary"
    id="default-range-2"
    name="default-range-2"
    label="Primary Range"
  >
    <:range_value position="end">60%</:range_value>
  </.range_field>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :label_class, :string, default: nil, doc: "Custom CSS class for the label styling"
  attr :color, :string, default: "primary", doc: "Determines color theme"
  attr :border, :string, default: "extra_small", doc: "Determines border style"

  attr :size, :string,
    default: "extra_small",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :appearance, :string, default: "default", doc: "custom, default"
  attr :width, :string, default: "full", doc: "Determines the element width"

  attr :ring, :boolean,
    default: true,
    doc:
      "Determines a ring border on focused input, utilities for creating outline rings with box-shadows."

  attr :reverse, :boolean, default: false, doc: "Switches the order of the element and label"
  attr :checked, :boolean, default: false, doc: "Specifies if the element is checked by default"
  attr :error_icon, :string, default: nil, doc: "Icon to be displayed alongside error messages"
  attr :label, :string, default: nil, doc: "Specifies text for the label"
  attr :errors, :list, default: [], doc: "List of error messages to be displayed"
  attr :name, :any, doc: "Name of input"
  attr :value, :any, doc: "Value of input"

  attr :field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form"

  attr :rest, :global,
    include: ~w(autocomplete disabled form readonly min max step required title autofocus),
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :range_value, required: false do
    attr :class, :string, doc: "Custom CSS class for additional styling"
    attr :position, :any, required: false, doc: "Determines the element position"
  end

  @spec range_field(map()) :: Phoenix.LiveView.Rendered.t()
  def range_field(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> range_field()
  end

  def range_field(%{appearance: "default"} = assigns) do
    ~H"""
    <div class={[
      width_class(@width),
      @class
    ]}>
      <.label for={@id}>{@label}</.label>
      <div class="relative mb-8">
        <input type="range" value={@value} name={@name} id={@id} class={["w-full", color_class(@appearance, @color)]} {@rest} />
        <span
          :for={{range_value, index} <- Enum.with_index(@range_value, 1)}
          id={"#{@id}-value-#{index}"}
          class={[
            "absolute block -bottom-6 text-sm",
            value_position(range_value[:position]),
            range_value[:class]
          ]}
        >
          {render_slot(range_value)}
        </span>
      </div>
      <.error :for={msg <- @errors} icon={@error_icon}>{msg}</.error>
    </div>
    """
  end

  def range_field(assigns) do
    ~H"""
    <div class={[
      color_class(@appearance, @color),
      size_class(@size),
      width_class(@width),
      @class
    ]}>
      <.label for={@id}>{@label}</.label>
      <div class="relative mb-8">
        <input
          type="range"
          value={@value}
          name={@name}
          id={@id}
          class={[
            "range-field bg-transparent cursor-pointer appearance-none disabled:opacity-50",
            "disabled:pointer-events-none focus:outline-none",
            "[&::-webkit-slider-runnable-track]:w-full [&::-webkit-slider-thumb]:rounded-full",
            "[&::-webkit-slider-runnable-track]:bg-[#DDDDDD] dark:[&::-webkit-slider-runnable-track]:bg-[#4B4B4B]",
            "[&::-webkit-slider-thumb]:bg-[#DDDDDD] dark:[&::-webkit-slider-thumb]:bg-[#4B4B4B]",
            "[&::-webkit-slider-thumb]:-mt-0.5 [&::-webkit-slider-thumb]:appearance-none",
            "[&::-webkit-slider-thumb]:transition-all [&::-webkit-slider-thumb]:duration-200 [&::-webkit-slider-thumb]:ease-in-out",
            "[&::-moz-range-thumb]:appearance-none [&::-moz-range-thumb]:bg-white",
            "[&::-moz-range-thumb]:border-4 [&::-moz-range-thumb]:rounded-full",
            "[&::-moz-range-thumb]:transition-all [&::-moz-range-thumb]:duration-200 [&::-moz-range-thumb]:ease-in-out",
            "[&::-webkit-slider-runnable-track]:rounded-full [&::-moz-range-track]:w-full",
            "[&::-moz-range-track]:bg-[#e6e6e6] [&::-moz-range-track]:rounded-full"
          ]}
          {@rest}
        />
        <span
          :for={{range_value, index} <- Enum.with_index(@range_value, 1)}
          id={"#{@id}-value-#{index}"}
          class={[
            "absolute block -bottom-6 text-sm",
            value_position(range_value[:position]),
            range_value[:class]
          ]}
        >
          {render_slot(range_value)}
        </span>
      </div>
      <.error :for={msg <- @errors} icon={@error_icon}>{msg}</.error>
    </div>
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

  defp value_position("start"), do: "start-0"
  defp value_position("end"), do: "end-0"
  defp value_position("middle"), do: "start-1/2"
  defp value_position("quarter"), do: "start-1/4"
  defp value_position("three-quarters"), do: "start-3/4"
  defp value_position("two-thirds"), do: "start-2/3 -translate-x-1/2 rtl:translate-x-1/2"
  defp value_position("one-thirds"), do: "start-1/3 -translate-x-1/2 rtl:translate-x-1/2"
  defp value_position(params) when is_binary(params), do: params

  defp width_class("half"), do: "[&_.range-field]:w-1/2"
  defp width_class("full"), do: "[&_.range-field]:w-full"
  defp width_class(params) when is_binary(params), do: params

  defp size_class("extra_small") do
    [
      "[&_.range-field::-webkit-slider-runnable-track]:h-2 [&_.range-field::-webkit-slider-thumb]:size-2.5",
      "[&_.range-field::-moz-range-track]:h-2 [&_.range-field::-moz-range-thumb]:size-2.5"
    ]
  end

  defp size_class("small") do
    [
      "[&_.range-field::-webkit-slider-runnable-track]:h-2.5 [&_.range-field::-webkit-slider-thumb]:size-3",
      "[&_.range-field::-moz-range-track]:h-2.5 [&_.range-field::-moz-range-thumb]:size-3"
    ]
  end

  defp size_class("medium") do
    [
      "[&_.range-field::-webkit-slider-runnable-track]:h-3 [&_.range-field::-webkit-slider-thumb]:size-3.5",
      "[&_.range-field::-moz-range-track]:h-3 [&_.range-field::-moz-range-thumb]:size-3.5"
    ]
  end

  defp size_class("large") do
    [
      "[&_.range-field::-webkit-slider-runnable-track]:h-3.5 [&_.range-field::-webkit-slider-thumb]:size-4",
      "[&_.range-field::-moz-range-track]:h-3.5 [&_.range-field::-moz-range-thumb]:size-4"
    ]
  end

  defp size_class("extra_large") do
    [
      "[&_.range-field::-webkit-slider-runnable-track]:h-4 [&_.range-field::-webkit-slider-thumb]:size-5",
      "[&_.range-field::-moz-range-track]:h-4 [&_.range-field::-moz-range-thumb]:size-5"
    ]
  end

  defp size_class(params) when is_binary(params), do: params

  defp color_class("default", "base") do
    ["accent-[#27272a] dark:accent-[#e4e4e7]"]
  end

  defp color_class("default", "white") do
    ["accent-white"]
  end

  defp color_class("default", "natural") do
    ["accent-[#4B4B4B] dark:accent-[#DDDDDD]"]
  end

  defp color_class("default", "primary") do
    ["accent-[#007F8C] dark:accent-[#01B8CA]"]
  end

  defp color_class("default", "secondary") do
    ["accent-[#266EF1] dark:accent-[#6DAAFB]"]
  end

  defp color_class("default", "success") do
    ["accent-[#0E8345] dark:accent-[#06C167]"]
  end

  defp color_class("default", "warning") do
    ["accent-[#976A01] dark:accent-[#FDC034]"]
  end

  defp color_class("default", "danger") do
    ["accent-[#DE1135] dark:accent-[#FC7F79]"]
  end

  defp color_class("default", "info") do
    ["accent-[#0B84BA] dark:accent-[#3EB7ED]"]
  end

  defp color_class("default", "misc") do
    ["accent-[#8750C5] dark:accent-[#BA83F9]"]
  end

  defp color_class("default", "dawn") do
    ["accent-[#A86438] dark:accent-[#DB976B]"]
  end

  defp color_class("default", "silver") do
    ["accent-[#868686] dark:accent-[#A6A6A6]"]
  end

  defp color_class("default", "dark") do
    ["accent-[#282828]"]
  end

  defp color_class("custom", "white") do
    [
      "[&_.range-field::-moz-range-thumb]:border-white",
      "[&_.range-field::-webkit-slider-thumb]:shadow-[0_0_0_4px_rgba(255,255,255,1)]"
    ]
  end

  defp color_class("custom", "natural") do
    [
      "[&_.range-field::-moz-range-thumb]:border-[#4B4B4B]",
      "[&_.range-field::-webkit-slider-thumb]:shadow-[0_0_0_4px_rgba(75,75,75,1)]",
      "dark:[&_.range-field::-moz-range-thumb]:border-[#DDDDDD]",
      "dark:[&_.range-field::-webkit-slider-thumb]:shadow-[0_0_0_4px_rgba(221,221,221,1)]"
    ]
  end

  defp color_class("custom", "primary") do
    [
      "[&_.range-field::-moz-range-thumb]:border-[#007f8c]",
      "[&_.range-field::-webkit-slider-thumb]:shadow-[0_0_0_4px_rgba(0,65,127,140)]",
      "dark:[&_.range-field::-moz-range-thumb]:border-[#01B8CA]",
      "dark:[&_.range-field::-webkit-slider-thumb]:shadow-[0_0_0_4px_rgba(1,184,202,140)]"
    ]
  end

  defp color_class("custom", "secondary") do
    [
      "[&_.range-field::-moz-range-thumb]:border-[#266EF1]",
      "[&_.range-field::-webkit-slider-thumb]:shadow-[0_0_0_4px_rgba(38,110,241,1)]",
      "dark[&_.range-field::-moz-range-thumb]:border-[#6DAAFB]",
      "dark[&_.range-field::-webkit-slider-thumb]:shadow-[0_0_0_4px_rgba(109,170,251,1)]"
    ]
  end

  defp color_class("custom", "success") do
    [
      "[&_.range-field::-moz-range-thumb]:border-[#0E8345]",
      "[&_.range-field::-webkit-slider-thumb]:shadow-[0_0_0_4px_rgba(14,131,69,1)]",
      "dark:[&_.range-field::-moz-range-thumb]:border-[#06C167]",
      "dark:[&_.range-field::-webkit-slider-thumb]:shadow-[0_0_0_4px_rgba(6,193,103,1)]"
    ]
  end

  defp color_class("custom", "warning") do
    [
      "[&_.range-field::-moz-range-thumb]:border-[#CA8D01]",
      "[&_.range-field::-webkit-slider-thumb]:shadow-[0_0_0_4px_rgba(202,141,1,1)]",
      "dark:[&_.range-field::-moz-range-thumb]:border-[#FDC034]",
      "dark:[&_.range-field::-webkit-slider-thumb]:shadow-[0_0_0_4px_rgba(253,192,52,1)]"
    ]
  end

  defp color_class("custom", "danger") do
    [
      "[&_.range-field::-moz-range-thumb]:border-[#DE1135]",
      "[&_.range-field::-webkit-slider-thumb]:shadow-[0_0_0_4px_rgba(222,17,53,1)]",
      "dark:[&_.range-field::-moz-range-thumb]:border-[#FC7F79]",
      "dark:[&_.range-field::-webkit-slider-thumb]:shadow-[0_0_0_4px_rgba(252,127,121,1)]"
    ]
  end

  defp color_class("custom", "info") do
    [
      "[&_.range-field::-moz-range-thumb]:border-[#0B84BA]",
      "[&_.range-field::-webkit-slider-thumb]:shadow-[0_0_0_4px_rgba(11,132,186,1)]",
      "dark:[&_.range-field::-moz-range-thumb]:border-[#3EB7ED]",
      "dark:[&_.range-field::-webkit-slider-thumb]:shadow-[0_0_0_4px_rgba(62,183,237,1)]"
    ]
  end

  defp color_class("custom", "misc") do
    [
      "[&_.range-field::-moz-range-thumb]:border-[#8750C5]",
      "[&_.range-field::-webkit-slider-thumb]:shadow-[0_0_0_4px_rgba(135,80,197,1)]",
      "dark:[&_.range-field::-moz-range-thumb]:border-[#DB976B]",
      "dark:[&_.range-field::-webkit-slider-thumb]:shadow-[0_0_0_4px_rgba(186,131,249,1)]"
    ]
  end

  defp color_class("custom", "dawn") do
    [
      "[&_.range-field::-moz-range-thumb]:border-[#A86438]",
      "[&_.range-field::-webkit-slider-thumb]:shadow-[0_0_0_4px_rgba(168,100,56,1)]",
      "dark:[&_.range-field::-moz-range-thumb]:border-[#DB976B]",
      "dark:[&_.range-field::-webkit-slider-thumb]:shadow-[0_0_0_4px_rgba(219,151,107,1)]"
    ]
  end

  defp color_class("custom", "silver") do
    [
      "[&_.range-field::-moz-range-thumb]:border-[#868686]",
      "[&_.range-field::-webkit-slider-thumb]:shadow-[0_0_0_4px_rgba(134,134,134,1)]",
      "[&_.range-field::-moz-range-thumb]:border-[#A6A6A6]",
      "[&_.range-field::-webkit-slider-thumb]:shadow-[0_0_0_4px_rgba(166,166,166,1)]"
    ]
  end

  defp color_class("custom", "dark") do
    [
      "[&_.range-field::-moz-range-thumb]:border-[#282828]",
      "[&_.range-field::-webkit-slider-thumb]:shadow-[0_0_0_4px_rgba(40,40,40,1)]"
    ]
  end

  defp color_class(params, _) when is_binary(params), do: params

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
