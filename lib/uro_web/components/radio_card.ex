defmodule UroWeb.Components.RadioCard do
  @moduledoc """
  The `UroWeb.Components.RadioCard` module provides a customizable radio card component for Phoenix LiveView
  applications. This component extends beyond basic radio buttons by offering a card-based interface
  with rich styling options.

  ## Key Features
  - Multiple visual variants: base, default, outline, shadow, and bordered
  - Comprehensive color themes including natural, primary, secondary, etc.
  - Customizable borders, padding, and spacing
  - Support for icons and descriptions within cards
  - Grid layout options for organizing multiple cards
  - Built-in dark mode support
  - Accessible form integration

  ## Example Usage
  ```heex
  <.radio_card name="plan" class="w-full" icon="hero-home">
    <:radio value="basic" title="Basic Plan" description="For small teams">
    </:radio>
    <:radio value="pro" title="Pro Plan" description="For growing businesses">
    </:radio>
    <:radio value="pro">
      <p>$25/month</p>
    </:radio>
  </.radio_card>
  ```

  The component handles form integration automatically when used with Phoenix.HTML.Form fields
  and includes built-in error handling and validation display.
  """
  use Phoenix.Component
  alias Phoenix.HTML.Form

  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :color, :string, default: "natural", doc: "Determines color theme"
  attr :variant, :string, default: "base", doc: "Determines variant theme"
  attr :border, :string, default: "extra_small", doc: "Determines border style"
  attr :rounded, :string, default: "medium", doc: "Radius size"
  attr :padding, :string, default: "small", doc: "Padding size"
  attr :space, :string, default: "small", doc: "Determines space between elements"
  attr :cols, :string, default: "one", doc: "Determines cols of elements"
  attr :cols_gap, :string, default: "small", doc: "Determines gap between elements"
  attr :label_class, :string, default: nil, doc: "Custom CSS class for the label styling"
  attr :reverse, :boolean, default: false, doc: "Switches the order of the element and label"
  attr :show_radio, :boolean, default: false, doc: "Boolean to show and hide radio"
  attr :label, :string, default: nil, doc: "Specifies text for the label"
  attr :description, :string, default: nil, doc: "Determines a short description"

  attr :size, :string,
    default: "small",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

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
    attr :icon, :string, doc: "Icon displayed alongside of a radio"
    attr :icon_class, :string, doc: "Determines custom class for the icon"
    attr :content_class, :string, doc: "Determines custom class for the content"
    attr :title, :string, required: false
    attr :description, :string, required: false
  end

  slot :inner_block

  @spec radio_card(map()) :: Phoenix.LiveView.Rendered.t()
  def radio_card(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> radio_card()
  end

  def radio_card(assigns) do
    ~H"""
    <div class={["leading-5", space_class(@space)]}>
      <input type="hidden" name={@name} value="" disabled={@rest[:disabled]} />

      <div :if={@label || @description} class="radio-card-label-wrapper">
        <.label :if={@label} for={@id}>{@label}</.label>
        <div :if={@description} class="text-[12px]">
          {@description}
        </div>
      </div>

      <div class={["grid", grid_cols(@cols), grid_gap(@cols_gap), @class]}>
        <label
          :for={{radio, index} <- Enum.with_index(@radio, 1)}
          for={"#{@id}-#{index}"}
          class={[
            "radio-card-wrapper flex items-start cursor-pointer",
            "has-[:disabled]:pointer-events-none has-[:disabled]:opacity-50",
            "has-[:focus-visible]:outline has-[:focus-visible]:outline-2 has-[:focus-visible]:outline-blue-400",
            "has-[:focus-visible]:outline-offset-[-2px] transition-all",
            @reverse && "flex-row-reverse",
            border_class(@border, @variant),
            color_variant(@variant, @color),
            rounded_size(@rounded),
            padding_size(@padding),
            size_class(@size),
            @label_class
          ]}
          {@rest}
        >
          <input
            type="radio"
            name={@name}
            id={"#{@id}-#{index}"}
            value={radio[:value]}
            checked={radio[:checked]}
            class={[
              "radio-card-input shrink-0 focus:ring-0 focus:ring-offset-0 appearance-none",
              "disabled:opacity-50",
              !@show_radio && "opacity-0 absolute"
            ]}
          />
          <div data-part="label" class="radio-card-content-wrapper flex-1">
            <div
              :if={!is_nil(radio[:icon]) || radio[:title] || radio[:description]}
              class="radio-slot-content flex flex-col"
            >
              <.icon
                :if={!is_nil(radio[:icon])}
                name={radio[:icon]}
                class={["block mx-auto", radio[:icon_class]]}
              />
              <div :if={radio[:title]} class="block radio-card-title leading-[16px] font-semibold">
                {radio[:title]}
              </div>

              <p :if={radio[:description]} class="radio-card-description">
                {radio[:description]}
              </p>
            </div>
            <div class="radio-card-content leading-[17px]">
              {render_slot(radio)}
            </div>
          </div>
        </label>
      </div>
    </div>

    <.error :for={msg <- @errors} icon={@error_icon}>{msg}</.error>
    """
  end

  def radio_card_check(:list, {field, value}, %{params: params, data: data} = _form) do
    if params[Atom.to_string(field)] do
      new_value = if is_atom(value), do: Atom.to_string(value), else: value
      new_value == params[Atom.to_string(field)]
    else
      Map.get(data, field) == value
    end
  end

  def radio_card_check(:boolean, field, %{params: params, data: data} = _form) do
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
    <label for={@for} class={["leading-4 font-semibold", @class]}>
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

  defp border_class(_, variant) when variant in ["default", "shadow"],
    do: nil

  defp border_class("none", _), do: nil
  defp border_class("extra_small", _), do: "border"
  defp border_class("small", _), do: "border-2"
  defp border_class("medium", _), do: "border-[3px]"
  defp border_class("large", _), do: "border-4"
  defp border_class("extra_large", _), do: "border-[5px]"
  defp border_class(params, _) when is_binary(params), do: params

  defp rounded_size("extra_small"), do: "rounded-sm"

  defp rounded_size("small"), do: "rounded"

  defp rounded_size("medium"), do: "rounded-md"

  defp rounded_size("large"), do: "rounded-lg"

  defp rounded_size("extra_large"), do: "rounded-xl"

  defp rounded_size("none"), do: nil

  defp rounded_size(params) when is_binary(params), do: params

  defp padding_size("extra_small"), do: "py-1 px-2"

  defp padding_size("small"), do: "py-2 px-3"

  defp padding_size("medium"), do: "py-3 px-4"

  defp padding_size("large"), do: "py-4 px-5"

  defp padding_size("extra_large"), do: "py-5 px-6"

  defp padding_size(params) when is_binary(params), do: params

  defp grid_cols("one"), do: "grid-cols-1"
  defp grid_cols("two"), do: "grid-cols-2"
  defp grid_cols("three"), do: "grid-cols-2 md:grid-cols-3"
  defp grid_cols("four"), do: "grid-cols-2 md:grid-cols-4"
  defp grid_cols("five"), do: "grid-cols-2 md:grid-cols-5"
  defp grid_cols("six"), do: "grid-cols-2 md:grid-cols-6"
  defp grid_cols("seven"), do: "grid-cols-2 md:grid-cols-7"
  defp grid_cols("eight"), do: "grid-cols-2 md:grid-cols-8"
  defp grid_cols("nine"), do: "grid-cols-2 md:grid-cols-9"
  defp grid_cols("ten"), do: "grid-cols-2 md:grid-cols-10"
  defp grid_cols("eleven"), do: "grid-cols-2 md:grid-cols-11"
  defp grid_cols("twelve"), do: "grid-cols-2 md:grid-cols-12"
  defp grid_cols(params) when is_binary(params), do: params

  defp grid_gap("extra_small"), do: "gap-1"
  defp grid_gap("small"), do: "gap-2"
  defp grid_gap("medium"), do: "gap-3"
  defp grid_gap("large"), do: "gap-4"
  defp grid_gap("extra_large"), do: "gap-5"
  defp grid_gap(params) when is_binary(params), do: params

  defp size_class("extra_small") do
    [
      "text-[13px]",
      "[&_.radio-card-icon]:size-5",
      "[&_.radio-card-description]:text-[11px]"
    ]
  end

  defp size_class("small") do
    [
      "text-[14px]",
      "[&_.radio-card-icon]:size-6",
      "[&_.radio-card-description]:text-[12px]"
    ]
  end

  defp size_class("medium") do
    [
      "text-[15px]",
      "[&_.radio-card-icon]:size-7",
      "[&_.radio-card-description]:text-[13px]"
    ]
  end

  defp size_class("large") do
    [
      "text-[16px]",
      "[&_.radio-card-icon]:size-8",
      "[&_.radio-card-description]:text-[14px]"
    ]
  end

  defp size_class("extra_large") do
    [
      "text-[17px]",
      "[&_.radio-card-icon]:size-9",
      "[&_.radio-card-description]:text-[15px]"
    ]
  end

  defp size_class(params) when is_binary(params), do: params

  defp space_class("extra_small") do
    [
      "[&_.radio-card-label-wrapper]:space-y-1",
      "[&_.radio-card-label-wrapper]:mb-1",
      "[&_.radio-card-wrapper]:gap-1 [&_.radio-slot-content]:gap-1"
    ]
  end

  defp space_class("small") do
    [
      "[&_.radio-card-label-wrapper]:space-y-1.5",
      "[&_.radio-card-label-wrapper]:mb-2",
      "[&_.radio-card-wrapper]:gap-2 [&_.radio-slot-content]:gap-2"
    ]
  end

  defp space_class("medium") do
    [
      "[&_.radio-card-label-wrapper]:space-y-2",
      "[&_.radio-card-label-wrapper]:mb-3",
      "[&_.radio-card-wrapper]:gap-3 [&_.radio-slot-content]:gap-3"
    ]
  end

  defp space_class("large") do
    [
      "[&_.radio-card-label-wrapper]:space-y-2.5",
      "[&_.radio-card-label-wrapper]:mb-4",
      "[&_.radio-card-wrapper]:gap-4 [&_.radio-slot-content]:gap-4"
    ]
  end

  defp space_class("extra_large") do
    [
      "[&_.radio-card-label-wrapper]:space-y-3",
      "[&_.radio-card-label-wrapper]:mb-5",
      "[&_.radio-card-wrapper]:gap-5 [&_.radio-slot-content]:gap-5"
    ]
  end

  defp space_class("none"), do: nil

  defp space_class(params) when is_binary(params), do: params

  defp color_variant("base", _) do
    [
      "bg-white text-[#09090b] border-[#e4e4e7] shadow-sm",
      "dark:bg-[#18181B] dark:text-[#FAFAFA] dark:border-[#27272a]",
      "checked:[&_.radio-card-input]:text-[#09090b]",
      "dark:checked:[&_.radio-card-input]:text-[#757373]",
      "[&_.radio-card-input]:border-[#e4e4e7] dark:[&_.radio-card-input]:border-[#27272a]",
      "[&_.radio-card-input:checked]:border-[#09090b] dark:[&_.radio-card-input:checked]:border-[#27272a]",
      "has-[:checked]:bg-[#F8F9FA] dark:has-[:checked]:bg-[#242424]",
      "has-[:checked]:border-[#09090b] dark:has-[:checked]:border-[#757373]",
      "[&_.radio-card-input:not(:checked)]:bg-white dark:[&_.radio-card-input:not(:checked)]:bg-[#333]"
    ]
  end

  defp color_variant("default", "white") do
    [
      "bg-white text-black",
      "checked:[&_.radio-card-input]:text-black",
      "[&_.radio-card-input]:border-black",
      "has-[:checked]:bg-[#ede8e8]"
    ]
  end

  defp color_variant("default", "dark") do
    [
      "bg-[#282828] text-white",
      "checked:[&_.radio-card-input]:text-white",
      "[&_.radio-card-input]:border-white",
      "has-[:checked]:bg-[#616060]"
    ]
  end

  defp color_variant("default", "natural") do
    [
      "bg-[#4B4B4B] text-white dark:bg-[#DDDDDD] dark:text-black",
      "checked:[&_.radio-card-input]:text-[#5E5E5E]",
      "dark:checked:[&_.radio-card-input]:text-[#BBBBBB]",
      "[&_.radio-card-input]:border-[#e4e4e7] dark:[&_.radio-card-input]:border-[#27272a]",
      "has-[:checked]:bg-[#282828] dark:has-[:checked]:bg-[#E8E8E8]"
    ]
  end

  defp color_variant("default", "primary") do
    [
      "bg-[#007F8C] text-white dark:bg-[#01B8CA] dark:text-black",
      "checked:[&_.radio-card-input]:text-[#0095A4]",
      "[&_.radio-card-input]:border-[#0095A4]",
      "has-[:checked]:bg-[#77D5E3] dark:has-[:checked]:bg-[#016974]"
    ]
  end

  defp color_variant("default", "secondary") do
    [
      "bg-[#266EF1] text-white dark:bg-[#6DAAFB] dark:text-black",
      "checked:[&_.radio-card-input]:text-[#068BEE]",
      "[&_.radio-card-input]:border-[#068BEE]",
      "has-[:checked]:bg-[#175BCC] dark:has-[:checked]:bg-[#016974]"
    ]
  end

  defp color_variant("default", "success") do
    [
      "bg-[#0E8345] text-white dark:bg-[#06C167] dark:text-black",
      "checked:[&_.radio-card-input]:text-[#009A51]",
      "[&_.radio-card-input]:border-[#009A51]",
      "has-[:checked]:bg-[#166C3B] dark:has-[:checked]:bg-[#7FD99A]"
    ]
  end

  defp color_variant("default", "warning") do
    [
      "bg-[#CA8D01] text-white dark:bg-[#FDC034] dark:text-black",
      "checked:[&_.radio-card-input]:text-[#FCB001]",
      "[&_.radio-card-input]:border-[#FCB001]",
      "has-[:checked]:bg-[#976A01] dark:has-[:checked]:bg-[#FDD067]"
    ]
  end

  defp color_variant("default", "danger") do
    [
      "bg-[#DE1135] text-white dark:bg-[#FC7F79] dark:text-black",
      "checked:[&_.radio-card-input]:text-[#F83446]",
      "[&_.radio-card-input]:border-[#F83446]",
      "has-[:checked]:bg-[#BB032A] dark:has-[:checked]:bg-[#FFB2AB]"
    ]
  end

  defp color_variant("default", "info") do
    [
      "bg-[#0B84BA] text-white dark:bg-[#3EB7ED] dark:text-black",
      "checked:[&_.radio-card-input]:text-[#0EA5E9]",
      "[&_.radio-card-input]:border-[#0EA5E9]",
      "has-[:checked]:bg-[#08638C] dark:has-[:checked]:bg-[#6EC9F2]"
    ]
  end

  defp color_variant("default", "misc") do
    [
      "bg-[#8750C5] text-white dark:bg-[#BA83F9] dark:text-black",
      "checked:[&_.radio-card-input]:text-[#A964F7]",
      "[&_.radio-card-input]:border-[#A964F7]",
      "has-[:checked]:bg-[#653C94] dark:has-[:checked]:bg-[#CBA2FA]"
    ]
  end

  defp color_variant("default", "dawn") do
    [
      "bg-[#A86438] text-white dark:bg-[#DB976B] dark:text-black",
      "checked:[&_.radio-card-input]:text-[#D27D46]",
      "[&_.radio-card-input]:border-[#D27D46]",
      "has-[:checked]:bg-[#7E4B2A] dark:has-[:checked]:bg-[#E4B190]"
    ]
  end

  defp color_variant("default", "silver") do
    [
      "bg-[#868686] text-white dark:bg-[#A6A6A6] dark:text-black",
      "checked:[&_.radio-card-input]:text-[#A6A6A6]",
      "[&_.radio-card-input]:border-[#A6A6A6]",
      "has-[:checked]:bg-[#727272] dark:has-[:checked]:bg-[#BBBBBB]"
    ]
  end

  defp color_variant("outline", "natural") do
    [
      "text-[#4B4B4B] border-[#4B4B4B] dark:text-[#DDDDDD] dark:border-[#DDDDDD]",
      "checked:[&_.radio-card-input]:text-[#DDDDDD]",
      "[&_.radio-card-input]:border-[#DDDDDD]",
      "dark:checked:[&_.radio-card-input]:text-[#4B4B4B]",
      "dark:[&_.radio-card-input]:border-[#4B4B4B]",
      "has-[:checked]:border-black dark:has-[:checked]:border-white"
    ]
  end

  defp color_variant("outline", "primary") do
    [
      "text-[#007F8C] border-[#007F8C]  dark:text-[#01B8CA] dark:border-[#01B8CA]",
      "checked:[&_.radio-card-input]:text-[#007F8C]",
      "[&_.radio-card-input]:border-[#007F8C]",
      "dark:checked:[&_.radio-card-input]:text-[#01B8CA]",
      "dark:[&_.radio-card-input]:border-[#01B8CA]",
      "has-[:checked]:border-[#1A535A] dark:has-[:checked]:border-[#B0E7EF]"
    ]
  end

  defp color_variant("outline", "secondary") do
    [
      "text-[#266EF1] border-[#266EF1] dark:text-[#6DAAFB] dark:border-[#6DAAFB]",
      "checked:[&_.radio-card-input]:text-[#266EF1]",
      "[&_.radio-card-input]:border-[#266EF1]",
      "dark:checked:[&_.radio-card-input]:text-[#6DAAFB]",
      "dark:[&_.radio-card-input]:border-[#6DAAFB]",
      "has-[:checked]:border-[#1948A3] dark:has-[:checked]:border-[#CDDEFF]"
    ]
  end

  defp color_variant("outline", "success") do
    [
      "text-[#0E8345] border-[#0E8345] dark:text-[#06C167] dark:border-[#06C167]",
      "checked:[&_.radio-card-input]:text-[#0E8345]",
      "[&_.radio-card-input]:border-[#0E8345]",
      "dark:checked:[&_.radio-card-input]:text-[#06C167]",
      "dark:[&_.radio-card-input]:border-[#06C167]",
      "has-[:checked]:border-[#0D572D] dark:has-[:checked]:border-[#B1EAC2]"
    ]
  end

  defp color_variant("outline", "warning") do
    [
      "text-[#CA8D01] border-[#CA8D01] dark:text-[#FDC034] dark:border-[#FDC034]",
      "checked:[&_.radio-card-input]:text-[#CA8D01]",
      "[&_.radio-card-input]:border-[#CA8D01]",
      "dark:checked:[&_.radio-card-input]:text-[#FDC034]",
      "dark:[&_.radio-card-input]:border-[#FDC034]",
      "has-[:checked]:border-[#654600] dark:has-[:checked]:border-[#FEDF99]"
    ]
  end

  defp color_variant("outline", "danger") do
    [
      "text-[#DE1135] border-[#DE1135] dark:text-[#FC7F79] dark:border-[#FC7F79]",
      "checked:[&_.radio-card-input]:text-[#DE1135]",
      "[&_.radio-card-input]:border-[#DE1135]",
      "dark:checked:[&_.radio-card-input]:text-[#FC7F79]",
      "dark:[&_.radio-card-input]:border-[#FC7F79]",
      "has-[:checked]:border-[#950F22] dark:has-[:checked]:border-[#FFD2CD]"
    ]
  end

  defp color_variant("outline", "info") do
    [
      "text-[#0B84BA] border-[#0B84BA] dark:text-[#3EB7ED] dark:border-[#3EB7ED]",
      "checked:[&_.radio-card-input]:text-[#0B84BA]",
      "[&_.radio-card-input]:border-[#0B84BA]",
      "dark:checked:[&_.radio-card-input]:text-[#3EB7ED]",
      "dark:[&_.radio-card-input]:border-[#3EB7ED]",
      "has-[:checked]:border-[#06425D] dark:has-[:checked]:border-[#9FDBF6]"
    ]
  end

  defp color_variant("outline", "misc") do
    [
      "text-[#8750C5] border-[#8750C5] dark:text-[#BA83F9] dark:border-[#BA83F9]",
      "checked:[&_.radio-card-input]:text-[#8750C5]",
      "[&_.radio-card-input]:border-[#8750C5]",
      "dark:checked:[&_.radio-card-input]:text-[#BA83F9]",
      "dark:[&_.radio-card-input]:border-[#BA83F9]",
      "has-[:checked]:border-[#442863] dark:has-[:checked]:border-[#DDC1FC]"
    ]
  end

  defp color_variant("outline", "dawn") do
    [
      "text-[#A86438] border-[#A86438] dark:text-[#DB976B] dark:border-[#DB976B]",
      "checked:[&_.radio-card-input]:text-[#A86438]",
      "[&_.radio-card-input]:border-[#A86438]",
      "dark:checked:[&_.radio-card-input]:text-[#BA83F9]",
      "dark:[&_.radio-card-input]:border-[#BA83F9]",
      "has-[:checked]:border-[#54321C] dark:has-[:checked]:border-[#EDCBB5]"
    ]
  end

  defp color_variant("outline", "silver") do
    [
      "text-[#868686] border-[#868686] dark:text-[#A6A6A6] dark:border-[#A6A6A6]",
      "checked:[&_.radio-card-input]:text-[#868686]",
      "[&_.radio-card-input]:border-[#868686]",
      "dark:checked:[&_.radio-card-input]:text-[#A6A6A6]",
      "dark:[&_.radio-card-input]:border-[#A6A6A6]",
      "has-[:checked]:border-[#5E5E5E] dark:has-[:checked]:border-[#DDDDDD]"
    ]
  end

  defp color_variant("shadow", "natural") do
    [
      "bg-[#4B4B4B] text-white dark:bg-[#DDDDDD] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(134,134,134,0.5)] shadow-[0px_10px_15px_-3px_rgba(134,134,134,0.5)] dark:shadow-none",
      "checked:[&_.radio-card-input]:text-[#5E5E5E]",
      "dark:checked:[&_.radio-card-input]:text-[#BBBBBB]",
      "[&_.radio-card-input]:border-[#e4e4e7] dark:[&_.radio-card-input]:border-[#27272a]",
      "has-[:checked]:bg-[#282828] dark:has-[:checked]:bg-[#E8E8E8]"
    ]
  end

  defp color_variant("shadow", "primary") do
    [
      "bg-[#007F8C] text-white dark:bg-[#01B8CA] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(0,149,164,0.5)] shadow-[0px_10px_15px_-3px_rgba(0,149,164,0.5)] dark:shadow-none",
      "checked:[&_.radio-card-input]:text-[#0095A4]",
      "[&_.radio-card-input]:border-[#0095A4]",
      "has-[:checked]:bg-[#77D5E3] dark:has-[:checked]:bg-[#016974]"
    ]
  end

  defp color_variant("shadow", "secondary") do
    [
      "bg-[#266EF1] text-white dark:bg-[#6DAAFB] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(6,139,238,0.5)] shadow-[0px_10px_15px_-3px_rgba(6,139,238,0.5)] dark:shadow-none",
      "checked:[&_.radio-card-input]:text-[#068BEE]",
      "[&_.radio-card-input]:border-[#068BEE]",
      "has-[:checked]:bg-[#175BCC] dark:has-[:checked]:bg-[#016974]"
    ]
  end

  defp color_variant("shadow", "success") do
    [
      "bg-[#0E8345] text-white hover:bg-[#166C3B] dark:bg-[#06C167] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(0,154,81,0.5)] shadow-[0px_10px_15px_-3px_rgba(0,154,81,0.5)] dark:shadow-none",
      "checked:[&_.radio-card-input]:text-[#009A51]",
      "[&_.radio-card-input]:border-[#009A51]",
      "has-[:checked]:bg-[#166C3B] dark:has-[:checked]:bg-[#7FD99A]"
    ]
  end

  defp color_variant("shadow", "warning") do
    [
      "bg-[#CA8D01] text-white dark:bg-[#FDC034] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(252,176,1,0.5)] shadow-[0px_10px_15px_-3px_rgba(252,176,1,0.5)] dark:shadow-none",
      "checked:[&_.radio-card-input]:text-[#FCB001]",
      "[&_.radio-card-input]:border-[#FCB001]",
      "has-[:checked]:bg-[#976A01] dark:has-[:checked]:bg-[#FDD067]"
    ]
  end

  defp color_variant("shadow", "danger") do
    [
      "bg-[#DE1135] text-white dark:bg-[#FC7F79] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(248,52,70,0.5)] shadow-[0px_10px_15px_-3px_rgba(248,52,70,0.5)] dark:shadow-none",
      "checked:[&_.radio-card-input]:text-[#F83446]",
      "[&_.radio-card-input]:border-[#F83446]",
      "has-[:checked]:bg-[#BB032A] dark:has-[:checked]:bg-[#FFB2AB]"
    ]
  end

  defp color_variant("shadow", "info") do
    [
      "bg-[#0B84BA] text-white dark:bg-[#3EB7ED] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(14,165,233,0.5)] shadow-[0px_10px_15px_-3px_rgba(14,165,233,0.5)] dark:shadow-none",
      "checked:[&_.radio-card-input]:text-[#0EA5E9]",
      "[&_.radio-card-input]:border-[#0EA5E9]",
      "has-[:checked]:bg-[#08638C] dark:has-[:checked]:bg-[#6EC9F2]"
    ]
  end

  defp color_variant("shadow", "misc") do
    [
      "bg-[#BA83F9] text-white dark:bg-[#BA83F9] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(169,100,247,0.5)] shadow-[0px_10px_15px_-3px_rgba(169,100,247,0.5)] dark:shadow-none",
      "checked:[&_.radio-card-input]:text-[#A964F7]",
      "[&_.radio-card-input]:border-[#A964F7]",
      "has-[:checked]:bg-[#653C94] dark:has-[:checked]:bg-[#CBA2FA]"
    ]
  end

  defp color_variant("shadow", "dawn") do
    [
      "bg-[#A86438] text-white dark:bg-[#DB976B] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(210,125,70,0.5)] shadow-[0px_10px_15px_-3px_rgba(210,125,70,0.5)] dark:shadow-none",
      "checked:[&_.radio-card-input]:text-[#D27D46]",
      "[&_.radio-card-input]:border-[#D27D46]",
      "has-[:checked]:bg-[#7E4B2A] dark:has-[:checked]:bg-[#E4B190]"
    ]
  end

  defp color_variant("shadow", "silver") do
    [
      "bg-[#868686] text-white dark:bg-[#A6A6A6] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(134,134,134,0.5)] shadow-[0px_10px_15px_-3px_rgba(134,134,134,0.5)] dark:shadow-none",
      "checked:[&_.radio-card-input]:text-[#A6A6A6]",
      "[&_.radio-card-input]:border-[#A6A6A6]",
      "has-[:checked]:bg-[#727272] dark:has-[:checked]:bg-[#BBBBBB]"
    ]
  end

  defp color_variant("bordered", "white") do
    [
      "bg-white text-black border-[#DDDDDD]",
      "checked:[&_.radio-card-input]:text-black",
      "[&_.radio-card-input]:border-black",
      "has-[:checked]:bg-[#ede8e8]"
    ]
  end

  defp color_variant("bordered", "dark") do
    [
      "bg-[#282828] text-white border-[#727272]",
      "checked:[&_.radio-card-input]:text-white",
      "[&_.radio-card-input]:border-white",
      "has-[:checked]:bg-[#616060]"
    ]
  end

  defp color_variant("bordered", "natural") do
    [
      "text-[#282828] border-[#282828] bg-[#F3F3F3]",
      "dark:text-[#E8E8E8] dark:border-[#E8E8E8] dark:bg-[#4B4B4B]",
      "checked:[&_.radio-card-input]:text-black",
      "dark:checked:[&_.radio-card-input]:text-white",
      "[&_.radio-card-input]:border-[#282828] dark:[&_.radio-card-input]:border-[#E8E8E8]",
      "has-[:checked]:border-black dark:has-[:checked]:border-white",
      "has-[:checked]:bg-[#E8E8E8] dark:has-[:checked]:bg-[#5E5E5E]"
    ]
  end

  defp color_variant("bordered", "primary") do
    [
      "text-[#016974] border-[#016974] bg-[#E2F8FB]",
      "dark:text-[#77D5E3] dark:border-[#77D5E3] dark:bg-[#002D33]",
      "checked:[&_.radio-card-input]:text-[#016974]",
      "dark:checked:[&_.radio-card-input]:text-[#77D5E3]",
      "[&_.radio-card-input]:border-[#016974] dark:[&_.radio-card-input]:border-[#77D5E3]",
      "has-[:checked]:border-[#1A535A] dark:has-[:checked]:border-[#B0E7EF]",
      "has-[:checked]:bg-[#CDEEF3] dark:has-[:checked]:bg-[#1A535A]"
    ]
  end

  defp color_variant("bordered", "secondary") do
    [
      "text-[#175BCC] border-[#175BCC] bg-[#EFF4FE]",
      "dark:text-[#A9C9FF] dark:border-[#A9C9FF] dark:bg-[#002661]",
      "checked:[&_.radio-card-input]:text-[#175BCC]",
      "dark:checked:[&_.radio-card-input]:text-[#A9C9FF]",
      "[&_.radio-card-input]:border-[#175BCC] dark:[&_.radio-card-input]:border-[#A9C9FF]",
      "has-[:checked]:border-[#1948A3] dark:has-[:checked]:border-[#CDDEFF]",
      "has-[:checked]:bg-[#DEE9FE] dark:has-[:checked]:bg-[#1948A3]"
    ]
  end

  defp color_variant("bordered", "success") do
    [
      "text-[#166C3B] border-[#166C3B] bg-[#EAF6ED]",
      "dark:text-[#7FD99A] dark:border-[#7FD99A] dark:bg-[#002F14]",
      "checked:[&_.radio-card-input]:text-[#166C3B]",
      "dark:checked:[&_.radio-card-input]:text-[#7FD99A]",
      "[&_.radio-card-input]:border-[#166C3B] dark:[&_.radio-card-input]:border-[#7FD99A]",
      "has-[:checked]:border-[#0D572D] dark:has-[:checked]:border-[#B1EAC2]",
      "has-[:checked]:bg-[#D3EFDA] dark:has-[:checked]:bg-[#0D572D]"
    ]
  end

  defp color_variant("bordered", "warning") do
    [
      "text-[#976A01] border-[#976A01] bg-[#FFF7E6]",
      "dark:text-[#FDD067] dark:border-[#FDD067] dark:bg-[#322300]",
      "checked:[&_.radio-card-input]:text-[#976A01]",
      "dark:checked:[&_.radio-card-input]:text-[#FDD067]",
      "[&_.radio-card-input]:border-[#976A01] dark:[&_.radio-card-input]:border-[#FDD067]",
      "has-[:checked]:border-[#654600] dark:has-[:checked]:border-[#FEDF99]",
      "has-[:checked]:bg-[#FEEFCC] dark:has-[:checked]:bg-[#654600]"
    ]
  end

  defp color_variant("bordered", "danger") do
    [
      "text-[#BB032A] border-[#BB032A] bg-[#FFF0EE]",
      "dark:text-[#FFB2AB] dark:border-[#FFB2AB] dark:bg-[#520810]",
      "checked:[&_.radio-card-input]:text-[#BB032A]",
      "dark:checked:[&_.radio-card-input]:text-[#FFB2AB]",
      "[&_.radio-card-input]:border-[#BB032A] dark:[&_.radio-card-input]:border-[#FFB2AB]",
      "has-[:checked]:border-[#950F22] dark:has-[:checked]:border-[#FFD2CD]",
      "has-[:checked]:bg-[#FFE1DE] dark:has-[:checked]:bg-[#950F22]"
    ]
  end

  defp color_variant("bordered", "info") do
    [
      "text-[#0B84BA] border-[#0B84BA] bg-[#E7F6FD]",
      "dark:text-[#6EC9F2] dark:border-[#6EC9F2] dark:bg-[#03212F]",
      "checked:[&_.radio-card-input]:text-[#0B84BA]",
      "dark:checked:[&_.radio-card-input]:text-[#6EC9F2]",
      "[&_.radio-card-input]:border-[#0B84BA] dark:[&_.radio-card-input]:border-[#6EC9F2]",
      "has-[:checked]:border-[#06425D] dark:has-[:checked]:border-[#9FDBF6]",
      "has-[:checked]:bg-[#CFEDFB] dark:has-[:checked]:bg-[#06425D]"
    ]
  end

  defp color_variant("bordered", "misc") do
    [
      "text-[#653C94] border-[#653C94] bg-[#F6F0FE]",
      "dark:text-[#CBA2FA] dark:border-[#CBA2FA] dark:bg-[#221431]",
      "checked:[&_.radio-card-input]:text-[#653C94]",
      "dark:checked:[&_.radio-card-input]:text-[#CBA2FA]",
      "[&_.radio-card-input]:border-[#653C94] dark:[&_.radio-card-input]:border-[#CBA2FA]",
      "has-[:checked]:border-[#442863] dark:has-[:checked]:border-[#DDC1FC]",
      "has-[:checked]:bg-[#EEE0FD] dark:has-[:checked]:bg-[#442863]"
    ]
  end

  defp color_variant("bordered", "dawn") do
    [
      "text-[#7E4B2A] border-[#7E4B2A] bg-[#FBF2ED]",
      "dark:text-[#E4B190] dark:border-[#E4B190] dark:bg-[#2A190E]",
      "checked:[&_.radio-card-input]:text-[#7E4B2A]",
      "dark:checked:[&_.radio-card-input]:text-[#E4B190]",
      "[&_.radio-card-input]:border-[#7E4B2A] dark:[&_.radio-card-input]:border-[#E4B190]",
      "has-[:checked]:border-[#54321C] dark:has-[:checked]:border-[#EDCBB5]",
      "has-[:checked]:bg-[#F6E5DA] dark:has-[:checked]:bg-[#54321C]"
    ]
  end

  defp color_variant("bordered", "silver") do
    [
      "text-[#727272] border-[#727272] bg-[#F3F3F3]",
      "dark:text-[#BBBBBB] dark:border-[#BBBBBB] dark:bg-[#4B4B4B]",
      "checked:[&_.radio-card-input]:text-[#727272]",
      "dark:checked:[&_.radio-card-input]:text-[#BBBBBB]",
      "[&_.radio-card-input]:border-[#727272] dark:[&_.radio-card-input]:border-[#BBBBBB]",
      "has-[:checked]:border-[#5E5E5E] dark:has-[:checked]:border-[#DDDDDD]",
      "has-[:checked]:bg-[#E8E8E8] dark:has-[:checked]:bg-[#5E5E5E]"
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
