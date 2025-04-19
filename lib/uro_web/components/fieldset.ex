defmodule UroWeb.Components.Fieldset do
  @moduledoc """
  The `UroWeb.Components.Fieldset` module provides a reusable and customizable
  component for creating styled fieldsets in Phoenix LiveView applications.

  It offers various options for styling, layout, and interaction, including:

  - Customizable color themes, border styles, and sizes.
  - Support for displaying error messages alongside form fields.
  - Flexible layout options using slots for adding controls and content inside the fieldset.
  - Global attributes support for enhanced configurability and integration.

  This component is designed to enhance the user interface of forms by providing consistent
  and visually appealing fieldsets that can be easily integrated into any LiveView application.
  """
  use Phoenix.Component

  @doc """
  Renders a `fieldset` component that groups related form elements visually and semantically.

  ## Examples

  ```elixir
  <.fieldset space="small" color="success" variant="outline">
    <:control>
      <.radio_field name="home" value="Home" space="small" color="success" label="This is label"/>
    </:control>

    <:control>
      <.radio_field
        name="home"
        value="Home"
        space="small"
        color="success"
        label="This is label of radio"
      />
    </:control>

    <:control>
      <.radio_field
        name="home"
        value="Home"
        space="small"
        color="success"
        label="This is label of radio"
      />
    </:control>
  </.fieldset>
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
  attr :padding, :string, default: "small", doc: "Determines padding for items"
  attr :variant, :string, default: "base", doc: "Determines the style"
  attr :space, :string, default: "medium", doc: "Space between items"

  attr :size, :string,
    default: "extra_large",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :error_icon, :string, default: nil, doc: "Icon to be displayed alongside error messages"
  attr :legend, :string, default: nil, doc: "Determines a caption for the content of its parent"

  attr :errors, :list, default: [], doc: "List of error messages to be displayed"
  attr :name, :any, doc: "Name of input"
  attr :value, :any, doc: "Value of input"

  attr :rest, :global,
    include: ~w(disabled form title),
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :control, required: false, doc: "Defines a collection of elements inside the fieldset"

  def fieldset(assigns) do
    ~H"""
    <div class={[
      color_variant(@variant, @color),
      rounded_size(@rounded),
      border_class(@border, @variant),
      padding_class(@padding),
      size_class(@size),
      space_class(@space),
      @class
    ]}>
      <fieldset class="fieldset-field">
        <legend :if={@legend} class="fieldset-legend py-0.5 px-1 leading-7" for={@id}>{@legend}</legend>

        <div :for={{control, index} <- Enum.with_index(@control, 1)} id={"#{@id}-control-#{index}"}>
          {render_slot(control)}
        </div>
      </fieldset>

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
      <.icon :if={!is_nil(@icon)} name={@icon} class="shrink-0" /> {render_slot(@inner_block)}
    </p>
    """
  end

  defp size_class("extra_small"), do: "text-xs"

  defp size_class("small"), do: "text-sm"

  defp size_class("medium"), do: "text-base"

  defp size_class("large"), do: "text-lg"

  defp size_class("extra_large"), do: "text-xl"

  defp size_class(params) when is_binary(params), do: params

  defp rounded_size("none"), do: nil

  defp rounded_size("extra_small") do
    "[&_.fieldset-field]:rounded-sm [&_.fieldset-legend]:rounded-t-sm"
  end

  defp rounded_size("small") do
    "[&_.fieldset-field]:rounded [&_.fieldset-legend]:rounded-t"
  end

  defp rounded_size("medium") do
    "[&_.fieldset-field]:rounded-md [&_.fieldset-legend]:rounded-t-md"
  end

  defp rounded_size("large") do
    "[&_.fieldset-field]:rounded-lg [&_.fieldset-legend]:rounded-t-lg"
  end

  defp rounded_size("extra_large") do
    "[&_.fieldset-field]:rounded-xl [&_.fieldset-legend]:rounded-t-xl"
  end

  defp rounded_size("full"), do: "[&_.fieldset-field]:rounded-full"

  defp rounded_size(params) when is_binary(params), do: params

  defp border_class(_, variant) when variant in ["default", "shadow", "transparent", "gradient"],
    do: nil

  defp border_class("none", _), do: nil
  defp border_class("extra_small", _), do: "[&_.fieldset-field]:border"
  defp border_class("small", _), do: "[&_.fieldset-field]:border-2"
  defp border_class("medium", _), do: "[&_.fieldset-field]:border-[3px]"
  defp border_class("large", _), do: "[&_.fieldset-field]:border-4"
  defp border_class("extra_large", _), do: "[&_.fieldset-field]:border-[5px]"
  defp border_class(params, _) when is_binary(params), do: params

  defp padding_class("extra_small"), do: "[&_.fieldset-field]:p-2"

  defp padding_class("small"), do: "[&_.fieldset-field]:p-3"

  defp padding_class("medium"), do: "[&_.fieldset-field]:p-4"

  defp padding_class("large"), do: "[&_.fieldset-field]:p-5"

  defp padding_class("extra_large"), do: "[&_.fieldset-field]:p-6"

  defp padding_class(params) when is_binary(params), do: params

  defp space_class("none"), do: nil

  defp space_class("extra_small"), do: "[&_fieldset]:space-y-1"

  defp space_class("small"), do: "[&_fieldset]:space-y-1.5"

  defp space_class("medium"), do: "[&_fieldset]:space-y-2"

  defp space_class("large"), do: "[&_fieldset]:space-y-2.5"

  defp space_class("extra_large"), do: "[&_fieldset]:space-y-3"

  defp space_class(params) when is_binary(params), do: params

  defp color_variant("base", _) do
    [
      "text-[#09090b] [&_.fieldset-field]:border-[#e4e4e7] [&_.fieldset-field]:bg-white [&_.fieldset-field]:shadow-sm",
      "dark:text-[#FAFAFA] dark:[&_.fieldset-field]:border-[#27272a] dark:[&_.fieldset-field]:bg-[#18181B]"
    ]
  end

  defp color_variant("default", "white") do
    [
      "[&_.fieldset-field]:bg-white text-black",
      "[&_.fieldset-legend]:bg-white"
    ]
  end

  defp color_variant("default", "dark") do
    [
      "[&_.fieldset-field]:bg-[#282828] text-white",
      "[&_.fieldset-legend]:bg-[#282828] dark:[&_.fieldset-legend]:bg-[#18181B]"
    ]
  end

  defp color_variant("default", "natural") do
    [
      "[&_.fieldset-field]:bg-[#4B4B4B] text-white dark:[&_.fieldset-field]:bg-[#DDDDDD] dark:text-black",
      "[&_.fieldset-legend]:bg-[#4B4B4B] dark:[&_.fieldset-legend]:bg-[#DDDDDD]"
    ]
  end

  defp color_variant("default", "primary") do
    [
      "[&_.fieldset-field]:bg-[#007F8C] text-white dark:[&_.fieldset-field]:bg-[#01B8CA] dark:text-black",
      "[&_.fieldset-legend]:bg-[#007F8C] dark:[&_.fieldset-legend]:bg-[#01B8CA]"
    ]
  end

  defp color_variant("default", "secondary") do
    [
      "[&_.fieldset-field]:bg-[#266EF1] text-white dark:[&_.fieldset-field]:bg-[#6DAAFB] dark:text-black",
      "[&_.fieldset-legend]:bg-[#266EF1] dark:[&_.fieldset-legend]:bg-[#6DAAFB]"
    ]
  end

  defp color_variant("default", "success") do
    [
      "[&_.fieldset-field]:bg-[#0E8345] text-white dark:[&_.fieldset-field]:bg-[#06C167] dark:text-black",
      "[&_.fieldset-legend]:bg-[#0E8345] dark:[&_.fieldset-legend]:bg-[#06C167]"
    ]
  end

  defp color_variant("default", "warning") do
    [
      "[&_.fieldset-field]:bg-[#CA8D01] text-white dark:[&_.fieldset-field]:bg-[#FDC034] dark:text-black",
      "[&_.fieldset-legend]:bg-[#CA8D01] dark:[&_.fieldset-legend]:bg-[#FDC034]"
    ]
  end

  defp color_variant("default", "danger") do
    [
      "[&_.fieldset-field]:bg-[#DE1135] text-white dark:[&_.fieldset-field]:bg-[#FC7F79] dark:text-black",
      "[&_.fieldset-legend]:bg-[#DE1135] dark:[&_.fieldset-legend]:bg-[#FC7F79]"
    ]
  end

  defp color_variant("default", "info") do
    [
      "[&_.fieldset-field]:bg-[#0B84BA] text-white dark:[&_.fieldset-field]:bg-[#3EB7ED] dark:text-black",
      "[&_.fieldset-legend]:bg-[#0B84BA] dark:[&_.fieldset-legend]:bg-[#3EB7ED]"
    ]
  end

  defp color_variant("default", "misc") do
    [
      "[&_.fieldset-field]:bg-[#8750C5] text-white dark:[&_.fieldset-field]:bg-[#BA83F9] dark:text-black",
      "[&_.fieldset-legend]:bg-[#8750C5] dark:[&_.fieldset-legend]:bg-[#BA83F9]"
    ]
  end

  defp color_variant("default", "dawn") do
    [
      "[&_.fieldset-field]:bg-[#A86438] text-white dark:[&_.fieldset-field]:bg-[#DB976B] dark:text-black",
      "[&_.fieldset-legend]:bg-[#A86438] dark:[&_.fieldset-legend]:bg-[#DB976B]"
    ]
  end

  defp color_variant("default", "silver") do
    [
      "[&_.fieldset-field]:bg-[#868686] text-white dark:[&_.fieldset-field]:bg-[#A6A6A6] dark:text-black",
      "[&_.fieldset-legend]:bg-[#868686] dark:[&_.fieldset-legend]:bg-[#A6A6A6]"
    ]
  end

  defp color_variant("outline", "natural") do
    [
      "text-[#4B4B4B] [&_.fieldset-field]:border-[#4B4B4B] dark:text-[#DDDDDD] dark:[&_.fieldset-field]:border-[#DDDDDD]"
    ]
  end

  defp color_variant("outline", "primary") do
    [
      "text-[#007F8C] [&_.fieldset-field]:border-[#007F8C]  dark:text-[#01B8CA] dark:[&_.fieldset-field]:border-[#01B8CA]"
    ]
  end

  defp color_variant("outline", "secondary") do
    [
      "text-[#266EF1] [&_.fieldset-field]:border-[#266EF1] dark:text-[#6DAAFB] dark:[&_.fieldset-field]:border-[#6DAAFB]"
    ]
  end

  defp color_variant("outline", "success") do
    [
      "text-[#0E8345] [&_.fieldset-field]:border-[#0E8345] dark:text-[#06C167] dark:[&_.fieldset-field]:border-[#06C167]"
    ]
  end

  defp color_variant("outline", "warning") do
    [
      "text-[#CA8D01] [&_.fieldset-field]:border-[#CA8D01] dark:text-[#FDC034] dark:[&_.fieldset-field]:border-[#FDC034]"
    ]
  end

  defp color_variant("outline", "danger") do
    [
      "text-[#DE1135] [&_.fieldset-field]:border-[#DE1135] dark:text-[#FC7F79] dark:[&_.fieldset-field]:border-[#FC7F79]"
    ]
  end

  defp color_variant("outline", "info") do
    [
      "text-[#0B84BA] [&_.fieldset-field]:border-[#0B84BA] dark:text-[#3EB7ED] dark:[&_.fieldset-field]:border-[#3EB7ED]"
    ]
  end

  defp color_variant("outline", "misc") do
    [
      "text-[#8750C5] [&_.fieldset-field]:border-[#8750C5] dark:text-[#BA83F9] dark:[&_.fieldset-field]:border-[#BA83F9]"
    ]
  end

  defp color_variant("outline", "dawn") do
    [
      "text-[#A86438] [&_.fieldset-field]:border-[#A86438] dark:text-[#DB976B] dark:[&_.fieldset-field]:border-[#DB976B]"
    ]
  end

  defp color_variant("outline", "silver") do
    [
      "text-[#868686] [&_.fieldset-field]:border-[#868686] dark:text-[#A6A6A6] dark:[&_.fieldset-field]:border-[#A6A6A6]"
    ]
  end

  defp color_variant("shadow", "natural") do
    [
      "[&_.fieldset-field]:bg-[#4B4B4B] text-white dark:[&_.fieldset-field]:bg-[#DDDDDD] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(134,134,134,0.5)] shadow-[0px_10px_15px_-3px_rgba(134,134,134,0.5)] dark:shadow-none",
      "[&_.fieldset-legend]:bg-[#4B4B4B] dark:[&_.fieldset-legend]:bg-[#DDDDDD]"
    ]
  end

  defp color_variant("shadow", "primary") do
    [
      "[&_.fieldset-field]:bg-[#007F8C] text-white dark:[&_.fieldset-field]:bg-[#01B8CA] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(0,149,164,0.5)] shadow-[0px_10px_15px_-3px_rgba(0,149,164,0.5)] dark:shadow-none",
      "[&_.fieldset-legend]:bg-[#007F8C] dark:[&_.fieldset-legend]:bg-[#01B8CA]"
    ]
  end

  defp color_variant("shadow", "secondary") do
    [
      "[&_.fieldset-field]:bg-[#266EF1] text-white dark:[&_.fieldset-field]:bg-[#6DAAFB] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(6,139,238,0.5)] shadow-[0px_10px_15px_-3px_rgba(6,139,238,0.5)] dark:shadow-none",
      "[&_.fieldset-legend]:bg-[#266EF1] dark:[&_.fieldset-legend]:bg-[#6DAAFB]"
    ]
  end

  defp color_variant("shadow", "success") do
    [
      "[&_.fieldset-field]:bg-[#0E8345] text-white dark:[&_.fieldset-field]:bg-[#06C167] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(0,154,81,0.5)] shadow-[0px_10px_15px_-3px_rgba(0,154,81,0.5)] dark:shadow-none",
      "[&_.fieldset-legend]:bg-[#0E8345] dark:[&_.fieldset-legend]:bg-[#06C167]"
    ]
  end

  defp color_variant("shadow", "warning") do
    [
      "[&_.fieldset-field]:bg-[#CA8D01] text-white dark:[&_.fieldset-field]:bg-[#FDC034] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(252,176,1,0.5)] shadow-[0px_10px_15px_-3px_rgba(252,176,1,0.5)] dark:shadow-none",
      "[&_.fieldset-legend]:bg-[#CA8D01] dark:[&_.fieldset-legend]:bg-[#FDC034]"
    ]
  end

  defp color_variant("shadow", "danger") do
    [
      "[&_.fieldset-field]:bg-[#DE1135] text-white dark:[&_.fieldset-field]:bg-[#FC7F79] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(248,52,70,0.5)] shadow-[0px_10px_15px_-3px_rgba(248,52,70,0.5)] dark:shadow-none",
      "[&_.fieldset-legend]:bg-[#DE1135] dark:[&_.fieldset-legend]:bg-[#FC7F79]"
    ]
  end

  defp color_variant("shadow", "info") do
    [
      "[&_.fieldset-field]:bg-[#0B84BA] text-white dark:[&_.fieldset-field]:bg-[#3EB7ED] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(14,165,233,0.5)] shadow-[0px_10px_15px_-3px_rgba(14,165,233,0.5)] dark:shadow-none",
      "[&_.fieldset-legend]:bg-[#0B84BA] dark:[&_.fieldset-legend]:bg-[#3EB7ED]"
    ]
  end

  defp color_variant("shadow", "misc") do
    [
      "[&_.fieldset-field]:bg-[#8750C5] text-white dark:[&_.fieldset-field]:bg-[#BA83F9] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(169,100,247,0.5)] shadow-[0px_10px_15px_-3px_rgba(169,100,247,0.5)] dark:shadow-none",
      "[&_.fieldset-legend]:bg-[#8750C5] dark:[&_.fieldset-legend]:bg-[#BA83F9]"
    ]
  end

  defp color_variant("shadow", "dawn") do
    [
      "[&_.fieldset-field]:bg-[#A86438] text-white dark:[&_.fieldset-field]:bg-[#DB976B] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(210,125,70,0.5)] shadow-[0px_10px_15px_-3px_rgba(210,125,70,0.5)] dark:shadow-none",
      "[&_.fieldset-legend]:bg-[#A86438] dark:[&_.fieldset-legend]:bg-[#DB976B]"
    ]
  end

  defp color_variant("shadow", "silver") do
    [
      "[&_.fieldset-field]:bg-[#868686] text-white dark:[&_.fieldset-field]:bg-[#A6A6A6] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(134,134,134,0.5)] shadow-[0px_10px_15px_-3px_rgba(134,134,134,0.5)] dark:shadow-none",
      "[&_.fieldset-legend]:bg-[#868686] dark:[&_.fieldset-legend]:bg-[#A6A6A6]"
    ]
  end

  defp color_variant("bordered", "white") do
    [
      "[&_.fieldset-field]:bg-white text-black [&_.fieldset-field]:border-[#DDDDDD]",
      "[&_.fieldset-legend]:bg-white"
    ]
  end

  defp color_variant("bordered", "dark") do
    [
      "[&_.fieldset-field]:bg-[#282828] text-white [&_.fieldset-field]:border-[#727272]",
      "[&_.fieldset-legend]:bg-[#282828]"
    ]
  end

  defp color_variant("bordered", "natural") do
    [
      "text-[#282828] [&_.fieldset-field]:border-[#282828] [&_.fieldset-field]:bg-[#F3F3F3]",
      "dark:text-[#E8E8E8] dark:[&_.fieldset-field]:border-[#E8E8E8] dark:[&_.fieldset-field]:bg-[#4B4B4B]",
      "[&_.fieldset-legend]:bg-[#F3F3F3] dark:[&_.fieldset-legend]:bg-[#4B4B4B]"
    ]
  end

  defp color_variant("bordered", "primary") do
    [
      "text-[#016974] [&_.fieldset-field]:border-[#016974] [&_.fieldset-field]:bg-[#E2F8FB]",
      "dark:text-[#77D5E3] dark:[&_.fieldset-field]:border-[#77D5E3] dark:[&_.fieldset-field]:bg-[#002D33]",
      "[&_.fieldset-legend]:bg-[#E2F8FB] dark:[&_.fieldset-legend]:bg-[#002D33]"
    ]
  end

  defp color_variant("bordered", "secondary") do
    [
      "text-[#175BCC] [&_.fieldset-field]:border-[#175BCC] [&_.fieldset-field]:bg-[#EFF4FE]",
      "dark:text-[#A9C9FF] dark:[&_.fieldset-field]:border-[#A9C9FF] dark:[&_.fieldset-field]:bg-[#002661]",
      "[&_.fieldset-legend]:bg-[#EFF4FE] dark:[&_.fieldset-legend]:bg-[#002661]"
    ]
  end

  defp color_variant("bordered", "success") do
    [
      "text-[#166C3B] [&_.fieldset-field]:border-[#166C3B] [&_.fieldset-field]:bg-[#EAF6ED]",
      "dark:text-[#7FD99A] dark:[&_.fieldset-field]:border-[#7FD99A] dark:[&_.fieldset-field]:bg-[#002F14]",
      "[&_.fieldset-legend]:bg-[#EAF6ED] dark:[&_.fieldset-legend]:bg-[#002F14]"
    ]
  end

  defp color_variant("bordered", "warning") do
    [
      "text-[#976A01] [&_.fieldset-field]:border-[#976A01] [&_.fieldset-field]:bg-[#FFF7E6]",
      "dark:text-[#FDD067] dark:[&_.fieldset-field]:border-[#FDD067] dark:[&_.fieldset-field]:bg-[#322300]",
      "[&_.fieldset-legend]:bg-[#FFF7E6] dark:[&_.fieldset-legend]:bg-[#322300]"
    ]
  end

  defp color_variant("bordered", "danger") do
    [
      "text-[#BB032A] [&_.fieldset-field]:border-[#BB032A] [&_.fieldset-field]:bg-[#FFF0EE]",
      "dark:text-[#FFB2AB] dark:[&_.fieldset-field]:border-[#FFB2AB] dark:[&_.fieldset-field]:bg-[#520810]",
      "[&_.fieldset-legend]:bg-[#FFF0EE] dark:[&_.fieldset-legend]:bg-[#520810]"
    ]
  end

  defp color_variant("bordered", "info") do
    [
      "text-[#0B84BA] [&_.fieldset-field]:border-[#0B84BA] [&_.fieldset-field]:bg-[#E7F6FD]",
      "dark:text-[#6EC9F2] dark:[&_.fieldset-field]:border-[#6EC9F2] dark:[&_.fieldset-field]:bg-[#03212F]",
      "[&_.fieldset-legend]:bg-[#E7F6FD] dark:[&_.fieldset-legend]:bg-[#03212F]"
    ]
  end

  defp color_variant("bordered", "misc") do
    [
      "text-[#653C94] [&_.fieldset-field]:border-[#653C94] [&_.fieldset-field]:bg-[#F6F0FE]",
      "dark:text-[#CBA2FA] dark:[&_.fieldset-field]:border-[#CBA2FA] dark:[&_.fieldset-field]:bg-[#221431]",
      "[&_.fieldset-legend]:bg-[#F6F0FE] dark:[&_.fieldset-legend]:bg-[#221431]"
    ]
  end

  defp color_variant("bordered", "dawn") do
    [
      "text-[#7E4B2A] [&_.fieldset-field]:border-[#7E4B2A] [&_.fieldset-field]:bg-[#FBF2ED]",
      "dark:text-[#E4B190] dark:[&_.fieldset-field]:border-[#E4B190] dark:[&_.fieldset-field]:bg-[#2A190E]",
      "[&_.fieldset-legend]:bg-[#FBF2ED] dark:[&_.fieldset-legend]:bg-[#2A190E]"
    ]
  end

  defp color_variant("bordered", "silver") do
    [
      "text-[#727272] [&_.fieldset-field]:border-[#727272] [&_.fieldset-field]:bg-[#F3F3F3]",
      "dark:text-[#BBBBBB] dark:[&_.fieldset-field]:border-[#BBBBBB] dark:[&_.fieldset-field]:bg-[#4B4B4B]",
      "[&_.fieldset-legend]:bg-[#F3F3F3] dark:[&_.fieldset-legend]:bg-[#4B4B4B]"
    ]
  end

  defp color_variant("transparent", "natural") do
    [
      "text-[#4B4B4B] dark:text-[#DDDDDD]"
    ]
  end

  defp color_variant("transparent", "primary") do
    [
      "text-[#007F8C] dark:text-[#01B8CA]"
    ]
  end

  defp color_variant("transparent", "secondary") do
    [
      "text-[#266EF1] dark:text-[#6DAAFB]"
    ]
  end

  defp color_variant("transparent", "success") do
    [
      "text-[#0E8345] dark:text-[#06C167]"
    ]
  end

  defp color_variant("transparent", "warning") do
    [
      "text-[#CA8D01] dark:text-[#FDC034]"
    ]
  end

  defp color_variant("transparent", "danger") do
    [
      "text-[#DE1135] dark:text-[#FC7F79]"
    ]
  end

  defp color_variant("transparent", "info") do
    [
      "text-[#0B84BA] dark:text-[#3EB7ED]"
    ]
  end

  defp color_variant("transparent", "misc") do
    [
      "text-[#8750C5] dark:text-[#BA83F9]"
    ]
  end

  defp color_variant("transparent", "dawn") do
    [
      "text-[#A86438] dark:text-[#DB976B]"
    ]
  end

  defp color_variant("transparent", "silver") do
    [
      "text-[#868686] dark:text-[#A6A6A6]"
    ]
  end

  defp color_variant("gradient", "natural") do
    [
      "[&_.fieldset-field]:bg-gradient-to-br from-[#282828] to-[#727272] text-white",
      "dark:from-[#A6A6A6] dark:to-[#FFFFFF] dark:text-black",
      "[&_.fieldset-legend]:bg-[#282828] dark:[&_.fieldset-legend]:bg-[#A6A6A6]"
    ]
  end

  defp color_variant("gradient", "primary") do
    [
      "[&_.fieldset-field]:bg-gradient-to-br from-[#016974] to-[#01B8CA] text-white",
      "dark:from-[#01B8CA] dark:to-[#B0E7EF] dark:text-black",
      "[&_.fieldset-legend]:bg-[#016974] dark:[&_.fieldset-legend]:bg-[#01B8CA]"
    ]
  end

  defp color_variant("gradient", "secondary") do
    [
      "[&_.fieldset-field]:bg-gradient-to-br from-[#175BCC] to-[#6DAAFB] text-white",
      "dark:from-[#6DAAFB] dark:to-[#CDDEFF] dark:text-black",
      "[&_.fieldset-legend]:bg-[#175BCC] dark:[&_.fieldset-legend]:bg-[#6DAAFB]"
    ]
  end

  defp color_variant("gradient", "success") do
    [
      "[&_.fieldset-field]:bg-gradient-to-br from-[#166C3B] to-[#06C167] text-white",
      "dark:from-[#06C167] dark:to-[#B1EAC2] dark:text-black",
      "[&_.fieldset-legend]:bg-[#166C3B] dark:[&_.fieldset-legend]:bg-[#06C167]"
    ]
  end

  defp color_variant("gradient", "warning") do
    [
      "[&_.fieldset-field]:bg-gradient-to-br from-[#976A01] to-[#FDC034] text-white",
      "dark:from-[#FDC034] dark:to-[#FEDF99] dark:text-black",
      "[&_.fieldset-legend]:bg-[#976A01] dark:[&_.fieldset-legend]:bg-[#FDC034]"
    ]
  end

  defp color_variant("gradient", "danger") do
    [
      "[&_.fieldset-field]:bg-gradient-to-br from-[#BB032A] to-[#FC7F79] text-white",
      "dark:from-[#FC7F79] dark:to-[#FFD2CD] dark:text-black",
      "[&_.fieldset-legend]:bg-[#BB032A] dark:[&_.fieldset-legend]:bg-[#FC7F79]"
    ]
  end

  defp color_variant("gradient", "info") do
    [
      "[&_.fieldset-field]:bg-gradient-to-br from-[#08638C] to-[#3EB7ED] text-white",
      "dark:from-[#3EB7ED] dark:to-[#9FDBF6] dark:text-black",
      "[&_.fieldset-legend]:bg-[#08638C] dark:[&_.fieldset-legend]:bg-[#3EB7ED]"
    ]
  end

  defp color_variant("gradient", "misc") do
    [
      "[&_.fieldset-field]:bg-gradient-to-br from-[#653C94] to-[#BA83F9] text-white",
      "dark:from-[#BA83F9] dark:to-[#DDC1FC] dark:text-black",
      "[&_.fieldset-legend]:bg-[#653C94] dark:[&_.fieldset-legend]:bg-[#BA83F9]"
    ]
  end

  defp color_variant("gradient", "dawn") do
    [
      "[&_.fieldset-field]:bg-gradient-to-br from-[#7E4B2A] to-[#DB976B] text-white",
      "dark:from-[#DB976B] dark:to-[#EDCBB5] dark:text-black",
      "[&_.fieldset-legend]:bg-[#7E4B2A] dark:[&_.fieldset-legend]:bg-[#DB976B]"
    ]
  end

  defp color_variant("gradient", "silver") do
    [
      "[&_.fieldset-field]:bg-gradient-to-br from-[#5E5E5E] to-[#A6A6A6] text-white",
      "dark:from-[#868686] dark:to-[#BBBBBB] dark:text-black",
      "[&_.fieldset-legend]:bg-[#5E5E5E] dark:[&_.fieldset-legend]:bg-[#868686]"
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
