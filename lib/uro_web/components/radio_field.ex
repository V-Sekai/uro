defmodule UroWeb.Components.RadioField do
  @moduledoc """
  The `UroWeb.Components.RadioField` module provides a highly customizable radio button
  component for Phoenix LiveView applications. This module supports various styling options,
  including different colors, sizes, and border styles, allowing developers to
  integrate radio buttons seamlessly into their design system.

  The component offers attributes and slots to control layout, appearance, and behavior,
  making it versatile for use cases ranging from simple forms to complex UI elements.
  With features such as error handling and custom labels, it enhances the usability and
  accessibility of forms, ensuring a cohesive user experience across the application.

  In addition, the module includes support for grouped radio buttons with the `group_radio`
  component, enabling the creation of sets of related radio inputs. This facilitates the
  development of dynamic and interactive form elements in a clean and organized manner.
  """
  use Phoenix.Component
  alias Phoenix.HTML.Form

  @doc """
  Renders a `radio_field` component. This component allows users to select a single option from
  a list of options, and provides various customization options for appearance and behavior.

  ## Examples

  ```elixir
  <.radio_field name="option" value="Option 1" space="small" label="Option 1 Label"/>

  <.radio_field
    name="option"
    value="Option 2"
    space="medium"
    color="secondary"
    label="Option 2 Label"
    checked
  />

  <.radio_field name="option" value="Option 3" color="dawn" label="Option 3 Label" reverse/>

  <.radio_field
    name="option"
    value="Option 4"
    space="medium"
    color="danger"
    label="Option 4 Label"
    errors={["Error message for Option 4"]}
  />

  <.radio_field name="option" value="Option 5" space="small" color="info" label="Option 5 Label"/>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :any, default: nil, doc: "Custom CSS class for additional styling"
  attr :label_class, :string, default: nil, doc: "Custom CSS class for the label styling"
  attr :color, :string, default: "primary", doc: "Determines color theme"
  attr :border, :string, default: "extra_small", doc: "Determines border style"
  attr :space, :string, default: "medium", doc: "Space between items"

  attr :size, :string,
    default: "extra_large",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

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
    include: ~w(autocomplete disabled form checked readonly required title autofocus),
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  @spec radio_field(map()) :: Phoenix.LiveView.Rendered.t()
  def radio_field(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> radio_field()
  end

  def radio_field(assigns) do
    ~H"""
    <div class={[
      color_class(@color),
      border_class(@border),
      size_class(@size),
      space_class(@space),
      @ring && "[&_.radio-field-wrapper_input]:focus-within:ring-1",
      @reverse && "[&_.radio-field-wrapper]:flex-row-reverse",
      @class
    ]}>
      <.label class={["radio-field-wrapper flex items-center w-fit", @label_class]} for={@id}>
        <input
          type="radio"
          name={@name}
          id={@id}
          value={@value}
          checked={@checked}
          class={[
            "bg-white radio-input rounded-full"
          ]}
          {@rest}
        />
        <span :if={@label} class="block">{@label}</span>
      </.label>

      <.error :for={msg <- @errors} icon={@error_icon}>{msg}</.error>
    </div>
    """
  end

  @doc """
  Renders a `group_radio` component, allowing users to select a single option from a list of
  grouped options. This component provides flexibility in layout, appearance, and behavior.

  ## Examples

  ```elixir
  <.group_radio name="items_group_1" space="small">
    <:radio value="option1">Option 1</:radio>
    <:radio value="option2">Option 2</:radio>
    <:radio value="option3">Option 3</:radio>
    <:radio value="option4" checked>Option 4</:radio>
  </.group_radio>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :color, :string, default: "primary", doc: "Determines color theme"
  attr :border, :string, default: "extra_small", doc: "Determines border style"
  attr :space, :string, default: "medium", doc: "Space between items"

  attr :variation, :string,
    default: "vertical",
    doc: "Defines the layout orientation of the component"

  attr :label_class, :string, default: nil, doc: "Custom CSS class for the label styling"

  attr :size, :string,
    default: "extra_large",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :ring, :boolean,
    default: true,
    doc:
      "Determines a ring border on focused input, utilities for creating outline rings with box-shadows."

  attr :reverse, :boolean, default: false, doc: "Switches the order of the element and label"
  attr :error_icon, :string, default: nil, doc: "Icon to be displayed alongside error messages"
  attr :errors, :list, default: [], doc: "List of error messages to be displayed"
  attr :name, :any, doc: "Name of input"
  attr :value, :any, doc: "Value of input"

  attr :rest, :global,
    include:
      ~w(autocomplete disabled form indeterminate multiple readonly required title autofocus),
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  attr :field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form"

  slot :radio, required: true do
    attr :value, :string, required: true
    attr :checked, :boolean, required: false
    attr :space, :any, required: false, doc: "Space between items"
  end

  slot :inner_block

  @spec group_radio(map()) :: Phoenix.LiveView.Rendered.t()
  def group_radio(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> group_radio()
  end

  def group_radio(assigns) do
    ~H"""
    <div class={[
      @variation == "horizontal" && "flex flex-wrap items-center",
      @variation == "vertical" && "flex flex-col",
      variation_gap(@space),
      @class
    ]}>
      {render_slot(@inner_block)}
      <input type="hidden" name={@name} value="" disabled={@rest[:disabled]} />
      <div
        :for={{radio, index} <- Enum.with_index(@radio, 1)}
        class={[
          color_class(@color),
          border_class(@border),
          size_class(@size),
          space_class(radio[:space] || "small"),
          @ring && "[&_.radio-field-wrapper_input]:focus-within:ring-1",
          @reverse && "[&_.radio-field-wrapper]:flex-row-reverse"
        ]}
      >
        <.label
          class={["radio-field-wrapper flex items-center w-fit", @label_class]}
          for={"#{@id}-#{index}"}
        >
          <input
            type="radio"
            name={@name}
            id={"#{@id}-#{index}"}
            value={radio[:value]}
            checked={radio[:checked]}
            class={["bg-white radio-input rounded-full"]}
            {@rest}
          />
          <span class="block">{render_slot(radio)}</span>
        </.label>
      </div>
    </div>
    <.error :for={msg <- @errors} icon={@error_icon}>{msg}</.error>
    """
  end

  def radio_check(:list, {field, value}, %{params: params, data: data} = _form) do
    if params[Atom.to_string(field)] do
      new_value = if is_atom(value), do: Atom.to_string(value), else: value
      new_value == params[Atom.to_string(field)]
    else
      Map.get(data, field) == value
    end
  end

  def radio_check(:boolean, field, %{params: params, data: data} = _form) do
    if params[Atom.to_string(field)] do
      Form.normalize_value("radio", params[Atom.to_string(field)])
    else
      Map.get(data, field, false)
    end
  end

  @doc type: :component
  attr :for, :string, default: nil, doc: "Specifies the form which is associated with"
  attr :class, :any, default: nil, doc: "Custom CSS class for additional styling"
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

  defp size_class("extra_small"), do: "[&_.radio-field-wrapper_input]:size-2.5"

  defp size_class("small"), do: "[&_.radio-field-wrapper_input]:size-3"

  defp size_class("medium"), do: "[&_.radio-field-wrapper_input]:size-3.5"

  defp size_class("large"), do: "[&_.radio-field-wrapper_input]:size-4"

  defp size_class("extra_large"), do: "[&_.radio-field-wrapper_input]:size-5"

  defp size_class(params) when is_binary(params), do: params

  defp border_class("none"), do: "[&_.radio-field-wrapper_.radio-input]:border-0"
  defp border_class("extra_small"), do: "[&_.radio-field-wrapper_.radio-input]:border"
  defp border_class("small"), do: "[&_.radio-field-wrapper_.radio-input]:border-2"
  defp border_class("medium"), do: "[&_.radio-field-wrapper_.radio-input]:border-[3px]"
  defp border_class("large"), do: "[&_.radio-field-wrapper_.radio-input]:border-4"
  defp border_class("extra_large"), do: "[&_.radio-field-wrapper_.radio-input]:border-[5px]"
  defp border_class(params) when is_binary(params), do: params

  defp space_class("extra_small"), do: "[&_.radio-field-wrapper]:gap-1"

  defp space_class("small"), do: "[&_.radio-field-wrapper]:gap-1.5"

  defp space_class("medium"), do: "[&_.radio-field-wrapper]:gap-2"

  defp space_class("large"), do: "[&_.radio-field-wrapper]:gap-2.5"

  defp space_class("extra_large"), do: "[&_.radio-field-wrapper]:gap-3"

  defp space_class("none"), do: nil

  defp space_class(params) when is_binary(params), do: params

  defp variation_gap("extra_small"), do: "gap-1"
  defp variation_gap("small"), do: "gap-2"
  defp variation_gap("medium"), do: "gap-3"
  defp variation_gap("large"), do: "gap-4"
  defp variation_gap("extra_large"), do: "gap-5"

  defp variation_gap(params) when is_binary(params), do: params

  defp color_class("base") do
    [
      "text-[#09090b] dark:text-[#FAFAFA]",
      "checked:[&_.radio-field-wrapper_.radio-input]:text-[#8B8B8D]",
      "dark:checked:[&_.radio-field-wrapper_.radio-input]:text-[#818182]",
      "[&_.radio-field-wrapper_.radio-input]:border-[#8B8B8D]",
      "dark:[&_.radio-field-wrapper_.radio-input]:border-[#818182]",
      "focus-within:[&_.radio-field-wrapper_.radio-input]:ring-[#F8F9FA] dark:focus-within:[&_.radio-field-wrapper_.radio-input]:ring-[#242424]"
    ]
  end

  defp color_class("white") do
    [
      "[&_.radio-field-wrapper_.radio-input]:text-white text-[#DDDDDD]",
      "[&_.radio-field-wrapper_.radio-input]:border-[#DDDDDD]",
      "focus-within:[&_.radio-field-wrapper_.radio-input_.radio-input]:ring-[#DDDDDD]"
    ]
  end

  defp color_class("natural") do
    [
      "text-[#282828] dark:text-[#E8E8E8]",
      "checked:[&_.radio-field-wrapper_.radio-input]:text-[#282828]",
      "dark:checked:[&_.radio-field-wrapper_.radio-input]:text-[#E8E8E8]",
      "[&_.radio-field-wrapper_.radio-input]:border-[#282828]",
      "dark:[&_.radio-field-wrapper_.radio-input]:border-[#868686]",
      "focus-within:[&_.radio-field-wrapper_.radio-input]:ring-[#4B4B4B] dark:focus-within:[&_.radio-field-wrapper_.radio-input]:ring-[#DDDDDD]"
    ]
  end

  defp color_class("primary") do
    [
      "text-[#016974] dark:text-[#77D5E3]",
      "checked:[&_.radio-field-wrapper_.radio-input]:text-[#016974]",
      "dark:checked:[&_.radio-field-wrapper_.radio-input]:text-[#77D5E3]",
      "[&_.radio-field-wrapper_.radio-input]:border-[#016974]",
      "dark:[&_.radio-field-wrapper_.radio-input]:border-[#77D5E3]",
      "focus-within:[&_.radio-field-wrapper_.radio-input]:ring-[#007F8C] dark:focus-within:[&_.radio-field-wrapper_.radio-input]:ring-[#01B8CA]"
    ]
  end

  defp color_class("secondary") do
    [
      "text-[#175BCC] dark:text-[#A9C9FF]",
      "checked:[&_.radio-field-wrapper_.radio-input]:text-[#175BCC]",
      "dark:checked:[&_.radio-field-wrapper_.radio-input]:text-[#A9C9FF]",
      "[&_.radio-field-wrapper_.radio-input]:border-[#175BCC]",
      "dark:[&_.radio-field-wrapper_.radio-input]:border-[#A9C9FF]",
      "focus-within:[&_.radio-field-wrapper_.radio-input]:ring-[#266EF1] dark:focus-within:[&_.radio-field-wrapper_.radio-input]:ring-[#6DAAFB]"
    ]
  end

  defp color_class("success") do
    [
      "text-[#166C3B] dark:text-[#7FD99A]",
      "checked:[&_.radio-field-wrapper_.radio-input]:text-[#166C3B]",
      "dark:checked:[&_.radio-field-wrapper_.radio-input]:text-[#7FD99A]",
      "[&_.radio-field-wrapper_.radio-input]:border-[#166C3B]",
      "dark:[&_.radio-field-wrapper_.radio-input]:border-[#7FD99A]",
      "focus-within:[&_.radio-field-wrapper_.radio-input]:ring-[#0E8345] dark:focus-within:[&_.radio-field-wrapper_.radio-input]:ring-[#06C167]"
    ]
  end

  defp color_class("warning") do
    [
      "text-[#976A01] dark:text-[#FDD067]",
      "checked:[&_.radio-field-wrapper_.radio-input]:text-[#976A01]",
      "dark:checked:[&_.radio-field-wrapper_.radio-input]:text-[#FDD067]",
      "[&_.radio-field-wrapper_.radio-input]:border-[#976A01]",
      "dark:[&_.radio-field-wrapper_.radio-input]:border-[#FDD067]",
      "focus-within:[&_.radio-field-wrapper_.radio-input]:ring-[#CA8D01] dark:focus-within:[&_.radio-field-wrapper_.radio-input]:ring-[#FDC034]"
    ]
  end

  defp color_class("danger") do
    [
      "text-[#BB032A] dark:text-[#FFB2AB]",
      "checked:[&_.radio-field-wrapper_.radio-input]:text-[#BB032A]",
      "dark:checked:[&_.radio-field-wrapper_.radio-input]:text-[#FFB2AB]",
      "[&_.radio-field-wrapper_.radio-input]:border-[#BB032A]",
      "dark:[&_.radio-field-wrapper_.radio-input]:border-[#FFB2AB]",
      "focus-within:[&_.radio-field-wrapper_.radio-input]:ring-[#DE1135] dark:focus-within:[&_.radio-field-wrapper_.radio-input]:ring-[#FC7F79]"
    ]
  end

  defp color_class("info") do
    [
      "text-[#0B84BA] dark:text-[#6EC9F2]",
      "checked:[&_.radio-field-wrapper_.radio-input]:text-[#0B84BA]",
      "dark:checked:[&_.radio-field-wrapper_.radio-input]:text-[#6EC9F2]",
      "[&_.radio-field-wrapper_.radio-input]:border-[#0B84BA]",
      "dark:[&_.radio-field-wrapper_.radio-input]:border-[#6EC9F2]",
      "focus-within:[&_.radio-field-wrapper_.radio-input]:ring-[#0B84BA] dark:focus-within:[&_.radio-field-wrapper_.radio-input]:ring-[#3EB7ED]"
    ]
  end

  defp color_class("misc") do
    [
      "text-[#653C94] dark:text-[#CBA2FA]",
      "checked:[&_.radio-field-wrapper_.radio-input]:text-[#653C94]",
      "dark:checked:[&_.radio-field-wrapper_.radio-input]:text-[#CBA2FA]",
      "[&_.radio-field-wrapper_.radio-input]:border-[#653C94]",
      "dark:[&_.radio-field-wrapper_.radio-input]:border-[#CBA2FA]",
      "focus-within:[&_.radio-field-wrapper_.radio-input]:ring-[#8750C5] dark:focus-within:[&_.radio-field-wrapper_.radio-input]:ring-[#BA83F9]"
    ]
  end

  defp color_class("dawn") do
    [
      "text-[#7E4B2A] dark:text-[#E4B190]",
      "checked:[&_.radio-field-wrapper_.radio-input]:text-[#7E4B2A]",
      "dark:checked:[&_.radio-field-wrapper_.radio-input]:text-[#E4B190]",
      "[&_.radio-field-wrapper_.radio-input]:border-[#7E4B2A]",
      "dark:[&_.radio-field-wrapper_.radio-input]:border-[#E4B190]",
      "focus-within:[&_.radio-field-wrapper_.radio-input]:ring-[#A86438] dark:focus-within:[&_.radio-field-wrapper_.radio-input]:ring-[#DB976B]"
    ]
  end

  defp color_class("silver") do
    [
      "text-[#727272] dark:text-[#BBBBBB]",
      "checked:[&_.radio-field-wrapper_.radio-input]:text-[#727272]",
      "dark:checked:[&_.radio-field-wrapper_.radio-input]:text-[#BBBBBB]",
      "[&_.radio-field-wrapper_.radio-input]:border-[#727272]",
      "dark:[&_.radio-field-wrapper_.radio-input]:border-[#BBBBBB]",
      "focus-within:[&_.radio-field-wrapper_.radio-input]:ring-[#868686] dark:focus-within:[&_.radio-field-wrapper_.radio-input]:ring-[#A6A6A6]"
    ]
  end

  defp color_class("dark") do
    [
      "[&_.radio-field-wrapper_.radio-input]:text-[#282828] text-[#282828]",
      "[&_.radio-field-wrapper_.radio-input]:border-[#727272]",
      "focus-within:[&_.radio-field-wrapper_.radio-input]:ring-[#282828]"
    ]
  end

  defp color_class(params) when is_binary(params), do: params

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
