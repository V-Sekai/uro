defmodule UroWeb.Components.CheckboxField do
  @moduledoc """
  UroWeb.Components.CheckboxField Module Provides a customizable checkbox component for use in Phoenix LiveView forms.

  This module includes individual checkbox fields as well as grouped
  checkbox fields, each with configurable options such as colors, borders,
  sizes, and more. It allows for easy integration and styling of checkboxes,
  with support for form validation and error handling.

  ### Features:
  - Individual and grouped checkbox fields with flexible styling options.
  - Support for form integration using `Phoenix.HTML.FormField`.
  - Customizable properties like color themes, border styles, sizes, and layout variations.
  - Error handling with customizable icons and messages.
  """

  use Phoenix.Component
  alias Phoenix.LiveView.Utils
  alias Phoenix.HTML.Form

  @doc """
  The `checkbox_field` component is used to create customizable checkbox input elements with various
  attributes such as `color`, `size`, and `label`.

  It supports form field structures and displays error messages when present, making it suitable
  for form validation.

  ## Examples

  ```elixir
  <.checkbox_field name="home" value="Home" space="small" label="This is label"/>
  <.checkbox_field name="home" value="Home" space="small" label="This is label"/>
  <.checkbox_field name="home" value="Home" space="small" color="misc" label="This is label"/>
  <.checkbox_field name="home" value="Home" space="small" color="dawn" label="This is label"/>
  <.checkbox_field name="home" value="Home" space="large" color="success" label="This is label"/>
  <.checkbox_field name="home" value="Home" space="small" color="info" label="This is label"/>
  <.checkbox_field name="home" value="Home" space="small" color="light" label="This is label"/>
  <.checkbox_field name="home" value="Home" space="small" color="danger" label="This is label"/>
  <.checkbox_field name="home" value="Home" space="small" color="warning" label="This is label"/>
  ```
  """
  @doc type: :component
  attr :id, :any,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :color, :string, default: "primary", doc: "Determines color theme"
  attr :border, :string, default: "extra_small", doc: "Determines border style"
  attr :rounded, :string, default: "small", doc: "Determines the border radius"
  attr :space, :string, default: "medium", doc: "Space between items"
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
  attr :checked, :boolean, default: false, doc: "Specifies if the element is checked by default"
  attr :error_icon, :string, default: nil, doc: "Icon to be displayed alongside error messages"
  attr :label, :string, default: nil, doc: "Specifies text for the label"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"
  attr :errors, :list, default: [], doc: "List of error messages to be displayed"
  attr :name, :any, doc: "Name of input"
  attr :value, :any, doc: "Value of input"

  attr :field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form"

  attr :rest, :global,
    include: ~w(autocomplete disabled form checked readonly required title autofocus),
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  @spec checkbox_field(map()) :: Phoenix.LiveView.Rendered.t()
  def checkbox_field(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    new_id = assigns.id || field.id
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil)
    |> assign(id: if(assigns.multiple, do: new_id <> "_#{Utils.random_id()}", else: new_id))
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:name, fn ->
      if assigns.multiple, do: field.name <> "[]", else: field.name
    end)
    |> assign_new(:value, fn -> field.value end)
    |> assign_new(:checked, fn ->
      Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
    end)
    |> checkbox_field()
  end

  def checkbox_field(assigns) do
    ~H"""
    <div class={[
      color_class(@color),
      rounded_size(@rounded),
      border_class(@border),
      size_class(@size),
      space_class(@space),
      @ring && "[&_.checkbox-field-wrapper_input]:focus-within:ring-1",
      @reverse && "[&_.checkbox-field-wrapper]:flex-row-reverse",
      @class
    ]}>
      <.label class={["checkbox-field-wrapper flex items-center w-fit", @label_class]} for={@id}>
        <%= if @value in ["true", "false"] do %>
          <input type="hidden" name={@name} value="false" disabled={@rest[:disabled]} />
        <% else %>
          <input type="hidden" name={@name} value="" disabled={@rest[:disabled]} />
        <% end %>

        <input
          type="checkbox"
          name={@name}
          value={@value}
          id={@id}
          checked={@checked}
          class={["bg-white checkbox-input"]}
          {@rest}
        />
        <span :if={@label} class="block">{@label}</span>
      </.label>

      <.error :for={msg <- @errors} icon={@error_icon}>{msg}</.error>
    </div>
    """
  end

  @doc """
  The `group_checkbox` component is used to create a group of checkboxes with customizable attributes
  such as `color`, `size`, and `variation`.

  It supports both horizontal and vertical layouts, and allows for individual styling of each
  checkbox within the group.

  ## Examples

  ```elixir
  <.group_checkbox id="items-2" variation="horizontal" name="items2" space="large" color="danger">
    <:checkbox value="10">Label of item 1 in group</:checkbox>
    <:checkbox value="30">Label of item 2 in group</:checkbox>
    <:checkbox value="50">Label of item 3 in group</:checkbox>
    <:checkbox value="60" checked={true}>Label of item 4 in group</:checkbox>
  </.group_checkbox>
  ```
  """
  @doc type: :component
  attr :id, :any,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :color, :string, default: "primary", doc: "Determines color theme"
  attr :border, :string, default: "extra_small", doc: "Determines border style"
  attr :rounded, :string, default: "small", doc: "Determines the border radius"
  attr :space, :string, default: "medium", doc: "Space between items"

  attr :variation, :string,
    default: "vertical",
    doc: "Defines the layout orientation of the component"

  attr :size, :string,
    default: "extra_large",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :label_class, :string, default: nil, doc: "Custom CSS class for the label styling"

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
    include: ~w(autocomplete disabled form indeterminate readonly required title autofocus),
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :checkbox, required: true do
    attr :value, :string, required: true
    attr :checked, :boolean, required: false
    attr :space, :string, required: false, doc: "Space between items"
  end

  attr :field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form"
  slot :inner_block

  @spec group_checkbox(map()) :: Phoenix.LiveView.Rendered.t()
  def group_checkbox(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil)
    |> assign(id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:name, fn -> field.name <> "[]" end)
    |> assign_new(:value, fn -> field.value end)
    |> assign(:multiple, true)
    |> group_checkbox()
  end

  def group_checkbox(assigns) do
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
        :for={{checkbox, index} <- Enum.with_index(@checkbox, 1)}
        class={[
          color_class(@color),
          rounded_size(@rounded),
          border_class(@border),
          size_class(@size),
          space_class(checkbox[:space] || "small"),
          @ring && "[&_.checkbox-field-wrapper_input]:focus-within:ring-1",
          @reverse && "[&_.checkbox-field-wrapper]:flex-row-reverse"
        ]}
      >
        <.label
          class={["checkbox-field-wrapper flex items-center w-fit", @label_class]}
          for={"#{@id}-#{index}"}
        >
          <input
            type="checkbox"
            name={@name}
            id={"#{@id}-#{index}"}
            value={checkbox[:value]}
            checked={checkbox[:checked]}
            class={["bg-white checkbox-input"]}
            {@rest}
          />
          <span class="block">{render_slot(checkbox)}</span>
        </.label>
      </div>
    </div>
    <.error :for={msg <- @errors} icon={@error_icon}>{msg}</.error>
    """
  end

  def checkbox_check(:list, {field, value}, %{params: params, data: data} = _form) do
    if params[Atom.to_string(field)] do
      new_value = if is_atom(value), do: Atom.to_string(value), else: value
      new_value in params[Atom.to_string(field)]
    else
      Map.get(data, field) == value
    end
  end

  def checkbox_check(:boolean, field, %{params: params, data: data} = _form) do
    if params[Atom.to_string(field)] do
      Form.normalize_value("checkbox", params[Atom.to_string(field)])
    else
      Map.get(data, field, false)
    end
  end

  @doc type: :component
  attr :class, :any, default: nil, doc: "Custom CSS class for additional styling"
  attr :for, :string, default: nil, doc: "Specifies the form which is associated with"
  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

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

  defp size_class("extra_small"), do: "[&_.checkbox-field-wrapper_input]:size-2.5"

  defp size_class("small"), do: "[&_.checkbox-field-wrapper_input]:size-3"

  defp size_class("medium"), do: "[&_.checkbox-field-wrapper_input]:size-3.5"

  defp size_class("large"), do: "[&_.checkbox-field-wrapper_input]:size-4"

  defp size_class("extra_large"), do: "[&_.checkbox-field-wrapper_input]:size-5"

  defp size_class(params) when is_binary(params), do: params

  defp rounded_size("extra_small"), do: "[&_.checkbox-field-wrapper_.checkbox-input]:rounded-sm"

  defp rounded_size("small"), do: "[&_.checkbox-field-wrapper_.checkbox-input]:rounded"

  defp rounded_size("medium"), do: "[&_.checkbox-field-wrapper_.checkbox-input]:rounded-md"

  defp rounded_size("large"), do: "[&_.checkbox-field-wrapper_.checkbox-input]:rounded-lg"

  defp rounded_size("extra_large"), do: "[&_.checkbox-field-wrapper_.checkbox-input]:rounded-xl"

  defp rounded_size("full"), do: "[&_.checkbox-field-wrapper_.checkbox-input]:rounded-full"

  defp rounded_size("none"), do: "[&_.checkbox-field-wrapper_.checkbox-input]:rounded-none"

  defp rounded_size(params) when is_binary(params), do: params

  defp border_class("none"), do: "[&_.checkbox-field-wrapper_.checkbox-input]:border-0"
  defp border_class("extra_small"), do: "[&_.checkbox-field-wrapper_.checkbox-input]:border"
  defp border_class("small"), do: "[&_.checkbox-field-wrapper_.checkbox-input]:border-2"
  defp border_class("medium"), do: "[&_.checkbox-field-wrapper_.checkbox-input]:border-[3px]"
  defp border_class("large"), do: "[&_.checkbox-field-wrapper_.checkbox-input]:border-4"
  defp border_class("extra_large"), do: "[&_.checkbox-field-wrapper_.checkbox-input]:border-[5px]"
  defp border_class(params) when is_binary(params), do: params

  defp space_class("none"), do: nil

  defp space_class("extra_small"), do: "[&_.checkbox-field-wrapper]:gap-1"

  defp space_class("small"), do: "[&_.checkbox-field-wrapper]:gap-1.5"

  defp space_class("medium"), do: "[&_.checkbox-field-wrapper]:gap-2"

  defp space_class("large"), do: "[&_.checkbox-field-wrapper]:gap-2.5"

  defp space_class("extra_large"), do: "[&_.checkbox-field-wrapper]:gap-3"

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
      "checked:[&_.checkbox-field-wrapper_.checkbox-input]:text-[#8B8B8D]",
      "dark:checked:[&_.checkbox-field-wrapper_.checkbox-input]:text-[#818182]",
      "[&_.checkbox-field-wrapper_.checkbox-input]:border-[#8B8B8D]",
      "dark:[&_.checkbox-field-wrapper_.checkbox-input]:border-[#818182]",
      "focus-within:[&_.checkbox-field-wrapper_.checkbox-input]:ring-[#F8F9FA] dark:focus-within:[&_.checkbox-field-wrapper_.checkbox-input]:ring-[#696969]"
    ]
  end

  defp color_class("white") do
    [
      "[&_.checkbox-field-wrapper_.checkbox-input]:text-white text-[#DDDDDD]",
      "[&_.checkbox-field-wrapper_.checkbox-input]:border-[#DDDDDD]",
      "focus-within:[&_.checkbox-field-wrapper_.checkbox-input_.radio-input]:ring-[#DDDDDD]"
    ]
  end

  defp color_class("natural") do
    [
      "text-[#282828] dark:text-[#E8E8E8]",
      "checked:[&_.checkbox-field-wrapper_.checkbox-input]:text-[#282828]",
      "dark:checked:[&_.checkbox-field-wrapper_.checkbox-input]:text-[#E8E8E8]",
      "[&_.checkbox-field-wrapper_.checkbox-input]:border-[#282828]",
      "dark:[&_.checkbox-field-wrapper_.checkbox-input]:border-[#868686]",
      "focus-within:[&_.checkbox-field-wrapper_.checkbox-input]:ring-[#4B4B4B] dark:focus-within:[&_.checkbox-field-wrapper_.checkbox-input]:ring-[#DDDDDD]"
    ]
  end

  defp color_class("primary") do
    [
      "text-[#016974] dark:text-[#77D5E3]",
      "checked:[&_.checkbox-field-wrapper_.checkbox-input]:text-[#016974]",
      "dark:checked:[&_.checkbox-field-wrapper_.checkbox-input]:text-[#77D5E3]",
      "[&_.checkbox-field-wrapper_.checkbox-input]:border-[#016974]",
      "dark:[&_.checkbox-field-wrapper_.checkbox-input]:border-[#77D5E3]",
      "focus-within:[&_.checkbox-field-wrapper_.checkbox-input]:ring-[#007F8C] dark:focus-within:[&_.checkbox-field-wrapper_.checkbox-input]:ring-[#01B8CA]"
    ]
  end

  defp color_class("secondary") do
    [
      "text-[#175BCC] dark:text-[#A9C9FF]",
      "checked:[&_.checkbox-field-wrapper_.checkbox-input]:text-[#175BCC]",
      "dark:checked:[&_.checkbox-field-wrapper_.checkbox-input]:text-[#A9C9FF]",
      "[&_.checkbox-field-wrapper_.checkbox-input]:border-[#175BCC]",
      "dark:[&_.checkbox-field-wrapper_.checkbox-input]:border-[#A9C9FF]",
      "focus-within:[&_.checkbox-field-wrapper_.checkbox-input]:ring-[#266EF1] dark:focus-within:[&_.checkbox-field-wrapper_.checkbox-input]:ring-[#6DAAFB]"
    ]
  end

  defp color_class("success") do
    [
      "text-[#166C3B] dark:text-[#7FD99A]",
      "checked:[&_.checkbox-field-wrapper_.checkbox-input]:text-[#166C3B]",
      "dark:checked:[&_.checkbox-field-wrapper_.checkbox-input]:text-[#7FD99A]",
      "[&_.checkbox-field-wrapper_.checkbox-input]:border-[#166C3B]",
      "dark:[&_.checkbox-field-wrapper_.checkbox-input]:border-[#7FD99A]",
      "focus-within:[&_.checkbox-field-wrapper_.checkbox-input]:ring-[#0E8345] dark:focus-within:[&_.checkbox-field-wrapper_.checkbox-input]:ring-[#06C167]"
    ]
  end

  defp color_class("warning") do
    [
      "text-[#976A01] dark:text-[#FDD067]",
      "checked:[&_.checkbox-field-wrapper_.checkbox-input]:text-[#976A01]",
      "dark:checked:[&_.checkbox-field-wrapper_.checkbox-input]:text-[#FDD067]",
      "[&_.checkbox-field-wrapper_.checkbox-input]:border-[#976A01]",
      "dark:[&_.checkbox-field-wrapper_.checkbox-input]:border-[#FDD067]",
      "focus-within:[&_.checkbox-field-wrapper_.checkbox-input]:ring-[#CA8D01] dark:focus-within:[&_.checkbox-field-wrapper_.checkbox-input]:ring-[#FDC034]"
    ]
  end

  defp color_class("danger") do
    [
      "text-[#BB032A] dark:text-[#FFB2AB]",
      "checked:[&_.checkbox-field-wrapper_.checkbox-input]:text-[#BB032A]",
      "dark:checked:[&_.checkbox-field-wrapper_.checkbox-input]:text-[#FFB2AB]",
      "[&_.checkbox-field-wrapper_.checkbox-input]:border-[#BB032A]",
      "dark:[&_.checkbox-field-wrapper_.checkbox-input]:border-[#FFB2AB]",
      "focus-within:[&_.checkbox-field-wrapper_.checkbox-input]:ring-[#DE1135] dark:focus-within:[&_.checkbox-field-wrapper_.checkbox-input]:ring-[#FC7F79]"
    ]
  end

  defp color_class("info") do
    [
      "text-[#0B84BA] dark:text-[#6EC9F2]",
      "checked:[&_.checkbox-field-wrapper_.checkbox-input]:text-[#0B84BA]",
      "dark:checked:[&_.checkbox-field-wrapper_.checkbox-input]:text-[#6EC9F2]",
      "[&_.checkbox-field-wrapper_.checkbox-input]:border-[#0B84BA]",
      "dark:[&_.checkbox-field-wrapper_.checkbox-input]:border-[#6EC9F2]",
      "focus-within:[&_.checkbox-field-wrapper_.checkbox-input]:ring-[#0B84BA] dark:focus-within:[&_.checkbox-field-wrapper_.checkbox-input]:ring-[#3EB7ED]"
    ]
  end

  defp color_class("misc") do
    [
      "text-[#653C94] dark:text-[#CBA2FA]",
      "checked:[&_.checkbox-field-wrapper_.checkbox-input]:text-[#653C94]",
      "dark:checked:[&_.checkbox-field-wrapper_.checkbox-input]:text-[#CBA2FA]",
      "[&_.checkbox-field-wrapper_.checkbox-input]:border-[#653C94]",
      "dark:[&_.checkbox-field-wrapper_.checkbox-input]:border-[#CBA2FA]",
      "focus-within:[&_.checkbox-field-wrapper_.checkbox-input]:ring-[#8750C5] dark:focus-within:[&_.checkbox-field-wrapper_.checkbox-input]:ring-[#BA83F9]"
    ]
  end

  defp color_class("dawn") do
    [
      "text-[#7E4B2A] dark:text-[#E4B190]",
      "checked:[&_.checkbox-field-wrapper_.checkbox-input]:text-[#7E4B2A]",
      "dark:checked:[&_.checkbox-field-wrapper_.checkbox-input]:text-[#E4B190]",
      "[&_.checkbox-field-wrapper_.checkbox-input]:border-[#7E4B2A]",
      "dark:[&_.checkbox-field-wrapper_.checkbox-input]:border-[#E4B190]",
      "focus-within:[&_.checkbox-field-wrapper_.checkbox-input]:ring-[#A86438] dark:focus-within:[&_.checkbox-field-wrapper_.checkbox-input]:ring-[#DB976B]"
    ]
  end

  defp color_class("silver") do
    [
      "text-[#727272] dark:text-[#BBBBBB]",
      "checked:[&_.checkbox-field-wrapper_.checkbox-input]:text-[#727272]",
      "dark:checked:[&_.checkbox-field-wrapper_.checkbox-input]:text-[#BBBBBB]",
      "[&_.checkbox-field-wrapper_.checkbox-input]:border-[#727272]",
      "dark:[&_.checkbox-field-wrapper_.checkbox-input]:border-[#BBBBBB]",
      "focus-within:[&_.checkbox-field-wrapper_.checkbox-input]:ring-[#868686] dark:focus-within:[&_.checkbox-field-wrapper_.checkbox-input]:ring-[#A6A6A6]"
    ]
  end

  defp color_class("dark") do
    [
      "[&_.checkbox-field-wrapper_.checkbox-input]:text-[#282828] text-[#282828]",
      "[&_.checkbox-field-wrapper_.checkbox-input]:border-[#727272]",
      "focus-within:[&_.checkbox-field-wrapper_.checkbox-input]:ring-[#282828]"
    ]
  end

  defp color_class(params) when is_binary(params), do: params

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
end
