defmodule UroWeb.Components.Progress do
  @moduledoc """
  The `UroWeb.Components.Progress` module provides a customizable progress bar component for
  Phoenix LiveView applications.

  It offers a range of styling options, including different sizes, colors, and variants,
  allowing developers to create both horizontal and vertical progress bars tailored to
  their design requirements.

  This component supports a variety of visual configurations, such as gradient backgrounds
  and rounded corners, and can be used in diverse use cases, from displaying loading states
  to indicating progress in forms and surveys.

  The module's flexibility is further enhanced by its use of `slots`, enabling developers
  to include custom label within the progress bar, making it a versatile choice for building
  interactive and dynamic UIs.
  """
  use Phoenix.Component
  alias Phoenix.LiveView.JS
  import Phoenix.LiveView.Utils, only: [random_id: 0]

  @doc """
  Renders a `progress` bar component that visually represents the completion status of a task.

  It supports both horizontal and vertical orientations and can be customized with various colors and styles.

  ## Examples

  ```elixir
  <.progress value={10} />
  <.progress color="primary" value={20} />
  <.progress color="secondary" value={30} />
  <.progress variation="vertical" color="primary" value={20} />

  <.progress>
    <.progress_section color="primary" value={10} />
    <.progress_section color="secondary" value={15} />
    <.progress_section color="misc" value={10} />
    <.progress_section color="danger" value={5} />
    <.progress_section color="warning" value={10} />
    <.progress_section color="success" value={10} />
    <.progress_section color="info" value={5} />
  </.progress>

  <.progress variation="horizontal" size="large" value={70}>
    <div class="absolute inset-y-0 left-0 flex items-center pl-3 text-white">
      70%
    </div>
  </.progress>

  <.progress variation="vertical" size="extra_large" value={80}>
    <div class="absolute bottom-0 left-0 flex items-center text-white">
      80%
    </div>
  </.progress>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :value, :integer, default: nil, doc: "Value of inout"

  attr :variation, :string,
    values: ["horizontal", "vertical"],
    default: "horizontal",
    doc: "Defines the layout orientation of the component"

  attr :color, :string, default: "natural", doc: "Determines color theme"
  attr :rounded, :string, default: "full", doc: "Determines the border radius"
  attr :variant, :string, default: "base", doc: "Determines the style"

  attr :size, :string,
    default: "small",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :csp_nonce, :string, default: nil, doc: "csp nonce"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, doc: "Inner block that renders HEEx label"

  def progress(assigns) do
    ~H"""
    <div
      class={[
        "bg-[#F4F4F4] dark:bg-[#B6B6B6] overflow-hidden",
        @variation == "vertical" && "flex items-end vertical-progress",
        size_class(@size, @variation),
        rounded_size(@rounded)
      ]}
      {@rest}
    >
      <.progress_section :if={@value} {assigns} />
      <div
        :if={msg = render_slot(@inner_block)}
        class={[
          "flex",
          (@variation == "horizontal" && "flex-row") || "flex-col"
        ]}
      >
        {msg}
      </div>
    </div>
    """
  end

  @doc """
  Renders a section of a progress bar component (`progress_section`).

  Each section represents a part of the progress with its own value and color, allowing for
  segmented progress bars.

  ## Examples

  ```elixir
  <.progress>
    <.progress_section color="primary" value={10} />
    <.progress_section color="secondary" value={15} />
    <.progress_section color="misc" value={10} />
    <.progress_section color="danger" value={5} />
    <.progress_section color="warning" value={10} />
    <.progress_section color="success" value={10} />
    <.progress_section color="info" value={5} />
  </.progress>
  ```
  """
  @doc type: :component
  attr :value, :integer, default: 0, doc: ""
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :variation, :string,
    values: ["horizontal", "vertical"],
    default: "horizontal",
    doc: "Defines the layout orientation of the component"

  attr :color, :string, default: "natural", doc: "Determines color theme"
  attr :variant, :string, default: "base", doc: "Determines the style"
  attr :csp_nonce, :string, default: nil, doc: "csp nonce"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :label, required: false do
    attr :class, :string, doc: "Custom CSS class for additional styling"
  end

  def progress_section(assigns) do
    assigns =
      assigns
      |> assign(:value, (is_integer(assigns.value) && assigns.value) || 0)
      |> assign_new(:id, fn -> random_id() end)

    ~H"""
    <style :if={@csp_nonce} nonce={@csp_nonce}>
      #<%= @id %> {
        <%= if @variation == "horizontal" do %>
          width: <%= @value %>%;
        <% else %>
          height: <%= @value %>%;
        <% end %>
      }
    </style>

    <div
      phx-mounted={
        is_nil(@csp_nonce) &&
          JS.set_attribute(
            {"style", (@variation == "horizontal" && "width: #{@value}%;") || "height: #{@value}%;"}
          )
      }
      id={@id}
      class={[
        "w-full progress-section",
        if(@variation == "vertical", do: "progress-vertical"),
        if(@variation == "horizontal" && !is_nil(@label),
          do: "flex justify-center items-center [&_span]:text-[11px]"
        ),
        color_variant(@variant, @color),
        @class
      ]}
    >
      <span :for={label <- @label} class={label[:class]}>
        {render_slot(label)}
      </span>
    </div>
    """
  end

  defp rounded_size("extra_small") do
    "rounded-sm [&:not(.vertical-progress)_.progress-section:last-of-type]:rounded-e-sm"
  end

  defp rounded_size("small") do
    "rounded [&:not(.vertical-progress)_.progress-section:last-of-type]:rounded-e"
  end

  defp rounded_size("medium") do
    "rounded-md [&:not(.vertical-progress)_.progress-section:last-of-type]:rounded-e-md"
  end

  defp rounded_size("large") do
    "rounded-lg [&:not(.vertical-progress)_.progress-section:last-of-type]:rounded-e-lg"
  end

  defp rounded_size("extra_large") do
    "rounded-xl [&:not(.vertical-progress)_.progress-section:last-of-type]:rounded-e-xl"
  end

  defp rounded_size("full") do
    "rounded-full [&:not(.vertical-progress)_.progress-section:last-of-type]:rounded-e-full"
  end

  defp rounded_size(params) when is_binary(params), do: params

  defp size_class("extra_small", "horizontal"), do: "text-xs h-1.5 [&>*]:h-1.5"

  defp size_class("small", "horizontal"), do: "text-sm h-2 [&>*]:h-2"

  defp size_class("medium", "horizontal"), do: "text-base h-3 [&>*]:h-3"

  defp size_class("large", "horizontal"), do: "text-lg h-4 [&>*]:h-4"

  defp size_class("extra_large", "horizontal"), do: "text-xl h-5 [&>*]:h-5"

  defp size_class("double_large", "horizontal"), do: "text-xl h-6 [&>*]:h-6"

  defp size_class("triple_large", "horizontal"), do: "text-xl h-7 [&>*]:h-7"

  defp size_class("quadruple_large", "horizontal"), do: "text-xl h-8 [&>*]:h-8"

  defp size_class("extra_small", "vertical"), do: "text-xs w-1 h-[5rem]"

  defp size_class("small", "vertical"), do: "text-sm w-2 h-[6rem]"

  defp size_class("medium", "vertical"), do: "text-base w-3 h-[7rem]"

  defp size_class("large", "vertical"), do: "text-lg w-4 h-[8rem]"

  defp size_class("extra_large", "vertical"), do: "text-xl w-5 h-[9rem]"

  defp size_class("double_large", "vertical"), do: "text-xl w-6 h-[10rem]"

  defp size_class("triple_large", "vertical"), do: "text-xl w-7 h-[11rem]"

  defp size_class("quadruple_large", "vertical"), do: "text-xl w-8  h-[12rem]"

  defp size_class(params, _) when is_binary(params), do: params

  defp color_variant("base", _) do
    [
      "text-[#09090b] bg-[#e4e4e7] dark:text-[#FAFAFA] dark:bg-[#27272a]"
    ]
  end

  defp color_variant("default", "white") do
    [
      "bg-white text-black"
    ]
  end

  defp color_variant("default", "dark") do
    [
      "bg-[#282828] text-white"
    ]
  end

  defp color_variant("default", "natural") do
    [
      "bg-[#4B4B4B] text-white dark:bg-[#DDDDDD] dark:text-black"
    ]
  end

  defp color_variant("default", "primary") do
    [
      "bg-[#007F8C] text-white dark:bg-[#01B8CA] dark:text-black"
    ]
  end

  defp color_variant("default", "secondary") do
    [
      "bg-[#266EF1] text-white dark:bg-[#6DAAFB] dark:text-black"
    ]
  end

  defp color_variant("default", "success") do
    [
      "bg-[#0E8345] text-white dark:bg-[#06C167] dark:text-black"
    ]
  end

  defp color_variant("default", "warning") do
    [
      "bg-[#CA8D01] text-white dark:bg-[#FDC034] dark:text-black"
    ]
  end

  defp color_variant("default", "danger") do
    [
      "bg-[#DE1135] text-white dark:bg-[#FC7F79] dark:text-black"
    ]
  end

  defp color_variant("default", "info") do
    [
      "bg-[#0B84BA] text-white dark:bg-[#3EB7ED] dark:text-black"
    ]
  end

  defp color_variant("default", "misc") do
    [
      "bg-[#8750C5] text-white dark:bg-[#BA83F9] dark:text-black"
    ]
  end

  defp color_variant("default", "dawn") do
    [
      "bg-[#A86438] text-white dark:bg-[#DB976B] dark:text-black"
    ]
  end

  defp color_variant("default", "silver") do
    [
      "bg-[#868686] text-white dark:bg-[#A6A6A6] dark:text-black"
    ]
  end

  defp color_variant("gradient", "natural") do
    [
      "[&:not(.progress-vertical)]:bg-gradient-to-r rtl:[&:not(.progress-vertical)]:bg-gradient-to-l",
      "[&:not(.progress-vertical)]:from-[#282828] [&:not(.progress-vertical)]:via-[#727272] [&:not(.progress-vertical)]:to-[#e9ecef] text-white",
      "[&.progress-vertical]:bg-gradient-to-b [&.progress-vertical]:from-[#e9ecef] [&.progress-vertical]:to-[#727272] [&.progress-vertical]:via-[#727272]",
      "dark:[&:not(.progress-vertical)]:from-[#A6A6A6] dark:[&:not(.progress-vertical)]:via-[#FFFFFF] dark:[&:not(.progress-vertical)]:to-[#e9ecef] text-black",
      "dark:[&.progress-vertical]:to-[#A6A6A6] dark:[&.progress-vertical]:via-[#A6A6A6] dark:[&.progress-vertical]:from-[#e9ecef]"
    ]
  end

  defp color_variant("gradient", "primary") do
    [
      "[&:not(.progress-vertical)]:bg-gradient-to-r rtl:[&:not(.progress-vertical)]:bg-gradient-to-l",
      "[&:not(.progress-vertical)]:from-[#016974] [&:not(.progress-vertical)]:via-[#01B8CA] [&:not(.progress-vertical)]:to-[#e9ecef] text-white",
      "[&.progress-vertical]:bg-gradient-to-b [&.progress-vertical]:from-[#e9ecef] [&.progress-vertical]:to-[#01B8CA] [&.progress-vertical]:via-[#01B8CA]",
      "dark:[&:not(.progress-vertical)]:from-[#01B8CA] dark:[&:not(.progress-vertical)]:via-[#B0E7EF] dark:[&:not(.progress-vertical)]:to-[#e9ecef] text-black",
      "dark:[&.progress-vertical]:to-[#B0E7EF] dark:[&.progress-vertical]:via-[#B0E7EF] dark:[&.progress-vertical]:from-[#e9ecef]"
    ]
  end

  defp color_variant("gradient", "secondary") do
    [
      "[&:not(.progress-vertical)]:bg-gradient-to-r rtl:[&:not(.progress-vertical)]:bg-gradient-to-l",
      "[&:not(.progress-vertical)]:from-[#175BCC] [&:not(.progress-vertical)]:via-[#6DAAFB] [&:not(.progress-vertical)]:to-[#e9ecef] text-white",
      "[&.progress-vertical]:bg-gradient-to-b [&.progress-vertical]:from-[#e9ecef] [&.progress-vertical]:to-[#6DAAFB] [&.progress-vertical]:via-[#6DAAFB]",
      "dark:[&:not(.progress-vertical)]:from-[#6DAAFB] dark:[&:not(.progress-vertical)]:via-[#CDDEFF] dark:[&:not(.progress-vertical)]:to-[#e9ecef] text-black",
      "dark:[&.progress-vertical]:to-[#CDDEFF] dark:[&.progress-vertical]:via-[#CDDEFF] dark:[&.progress-vertical]:from-[#e9ecef]"
    ]
  end

  defp color_variant("gradient", "success") do
    [
      "[&:not(.progress-vertical)]:bg-gradient-to-r rtl:[&:not(.progress-vertical)]:bg-gradient-to-l",
      "[&:not(.progress-vertical)]:from-[#166C3B] [&:not(.progress-vertical)]:via-[#06C167] [&:not(.progress-vertical)]:to-[#e9ecef] text-white",
      "[&.progress-vertical]:bg-gradient-to-b [&.progress-vertical]:from-[#e9ecef] [&.progress-vertical]:to-[#06C167] [&.progress-vertical]:via-[#06C167]",
      "dark:[&:not(.progress-vertical)]:from-[#06C167] dark:[&:not(.progress-vertical)]:via-[#B1EAC2] dark:[&:not(.progress-vertical)]:to-[#e9ecef] text-black",
      "dark:[&.progress-vertical]:to-[#B1EAC2] dark:[&.progress-vertical]:via-[#B1EAC2] dark:[&.progress-vertical]:from-[#e9ecef]"
    ]
  end

  defp color_variant("gradient", "warning") do
    [
      "[&:not(.progress-vertical)]:bg-gradient-to-r rtl:[&:not(.progress-vertical)]:bg-gradient-to-l",
      "[&:not(.progress-vertical)]:from-[#976A01] [&:not(.progress-vertical)]:via-[#FDC034] [&:not(.progress-vertical)]:to-[#e9ecef] text-white",
      "[&.progress-vertical]:bg-gradient-to-b [&.progress-vertical]:from-[#e9ecef] [&.progress-vertical]:to-[#976A01] [&.progress-vertical]:via-[#976A01]",
      "dark:[&:not(.progress-vertical)]:from-[#FDC034] dark:[&:not(.progress-vertical)]:via-[#FEDF99] dark:[&:not(.progress-vertical)]:to-[#e9ecef] text-black",
      "dark:[&.progress-vertical]:to-[#FEDF99] dark:[&.progress-vertical]:via-[#FEDF99] dark:[&.progress-vertical]:from-[#e9ecef]"
    ]
  end

  defp color_variant("gradient", "danger") do
    [
      "[&:not(.progress-vertical)]:bg-gradient-to-r rtl:[&:not(.progress-vertical)]:bg-gradient-to-l",
      "[&:not(.progress-vertical)]:from-[#BB032A] [&:not(.progress-vertical)]:via-[#FC7F79] [&:not(.progress-vertical)]:to-[#e9ecef] text-white",
      "[&.progress-vertical]:bg-gradient-to-b [&.progress-vertical]:from-[#e9ecef] [&.progress-vertical]:to-[#FC7F79] [&.progress-vertical]:via-[#FC7F79]",
      "dark:[&:not(.progress-vertical)]:from-[#FC7F79] dark:[&:not(.progress-vertical)]:via-[#FFD2CD] dark:[&:not(.progress-vertical)]:to-[#e9ecef] text-black",
      "dark:[&.progress-vertical]:to-[#FFD2CD] dark:[&.progress-vertical]:via-[#FFD2CD] dark:[&.progress-vertical]:from-[#e9ecef]"
    ]
  end

  defp color_variant("gradient", "info") do
    [
      "[&:not(.progress-vertical)]:bg-gradient-to-r rtl:[&:not(.progress-vertical)]:bg-gradient-to-l",
      "[&:not(.progress-vertical)]:from-[#08638C] [&:not(.progress-vertical)]:via-[#3EB7ED] [&:not(.progress-vertical)]:to-[#e9ecef] text-white",
      "[&.progress-vertical]:bg-gradient-to-b [&.progress-vertical]:from-[#e9ecef] [&.progress-vertical]:to-[#3EB7ED] [&.progress-vertical]:via-[#3EB7ED]",
      "dark:[&:not(.progress-vertical)]:from-[#3EB7ED] dark:[&:not(.progress-vertical)]:via-[#9FDBF6] dark:[&:not(.progress-vertical)]:to-[#e9ecef] text-black",
      "dark:[&.progress-vertical]:to-[#9FDBF6] dark:[&.progress-vertical]:via-[#9FDBF6] dark:[&.progress-vertical]:from-[#e9ecef]"
    ]
  end

  defp color_variant("gradient", "misc") do
    [
      "[&:not(.progress-vertical)]:bg-gradient-to-r rtl:[&:not(.progress-vertical)]:bg-gradient-to-l",
      "[&:not(.progress-vertical)]:from-[#653C94] [&:not(.progress-vertical)]:via-[#BA83F9] [&:not(.progress-vertical)]:to-[#e9ecef] text-white",
      "[&.progress-vertical]:bg-gradient-to-b [&.progress-vertical]:from-[#e9ecef] [&.progress-vertical]:to-[#BA83F9] [&.progress-vertical]:via-[#BA83F9]",
      "dark:[&:not(.progress-vertical)]:from-[#BA83F9] dark:[&:not(.progress-vertical)]:via-[#DDC1FC] dark:[&:not(.progress-vertical)]:to-[#e9ecef] text-black",
      "dark:[&.progress-vertical]:to-[#DDC1FC] dark:[&.progress-vertical]:via-[#DDC1FC] dark:[&.progress-vertical]:from-[#e9ecef]"
    ]
  end

  defp color_variant("gradient", "dawn") do
    [
      "[&:not(.progress-vertical)]:bg-gradient-to-r rtl:[&:not(.progress-vertical)]:bg-gradient-to-l",
      "[&:not(.progress-vertical)]:from-[#7E4B2A] [&:not(.progress-vertical)]:via-[#DB976B] [&:not(.progress-vertical)]:to-[#e9ecef] text-white",
      "[&.progress-vertical]:bg-gradient-to-b [&.progress-vertical]:from-[#e9ecef] [&.progress-vertical]:to-[#DB976B] [&.progress-vertical]:via-[#DB976B]",
      "dark:[&:not(.progress-vertical)]:from-[#DB976B] dark:[&:not(.progress-vertical)]:via-[#EDCBB5] dark:[&:not(.progress-vertical)]:to-[#e9ecef] text-black",
      "dark:[&.progress-vertical]:to-[#EDCBB5] dark:[&.progress-vertical]:via-[#EDCBB5] dark:[&.progress-vertical]:from-[#e9ecef]"
    ]
  end

  defp color_variant("gradient", "silver") do
    [
      "[&:not(.progress-vertical)]:bg-gradient-to-r rtl:[&:not(.progress-vertical)]:bg-gradient-to-l",
      "[&:not(.progress-vertical)]:from-[#5E5E5E] [&:not(.progress-vertical)]:via-[#A6A6A6] [&:not(.progress-vertical)]:to-[#e9ecef] text-white",
      "[&.progress-vertical]:bg-gradient-to-b [&.progress-vertical]:from-[#e9ecef] [&.progress-vertical]:to-[#5E5E5E] [&.progress-vertical]:via-[#5E5E5E]",
      "dark:[&:not(.progress-vertical)]:from-[#868686] dark:[&:not(.progress-vertical)]:via-[#BBBBBB] dark:[&:not(.progress-vertical)]:to-[#e9ecef] text-black",
      "dark:[&.progress-vertical]:to-[#BBBBBB] dark:[&.progress-vertical]:via-[#BBBBBB] dark:[&.progress-vertical]:from-[#e9ecef]"
    ]
  end

  defp color_variant(params, _) when is_binary(params), do: params
end
