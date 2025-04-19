defmodule UroWeb.Components.Stepper do
  @moduledoc """
  The `UroWeb.Components.Stepper` module provides a flexible and interactive stepper component
  for Phoenix LiveView applications. It supports both horizontal and vertical layouts,
  making it ideal for displaying multi-step processes, such as onboarding, forms, or any
  workflow that requires users to follow a sequence of steps.

  This module allows extensive customization options, including size, color themes, border styles,
  and spacing between steps. Each step can display icons, titles, descriptions, and custom content.
  The component also offers various step states like `current`, `loading`, `completed`, and `canceled`,
  enabling a visual indication of the user's progress.

  The `UroWeb.Components.Stepper` enhances user experience by providing a clear and concise representation
  of step-by-step workflows, ensuring users can easily track their position and progress within the application.
  """

  use Phoenix.Component

  @doc """
  Renders a customizable `stepper` component that visually represents a multi-step process.
  This component can be configured to display either horizontally or vertically, with various
  styling options like color, size, and spacing.

  ## Examples

  ```elixir
  <.stepper color="info" size="extra_large">
    <.stepper_section step="current" title="First step" description="Create an account" />
    <.stepper_section title="Second Step" description="Verify email" />
    <.stepper_section title="Third Step" description="Get full access" />
  </.stepper>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :size, :string,
    default: "small",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :margin, :string, default: "medium", doc: "Determines the element margin"
  attr :color, :string, default: "natural", doc: "Determines color theme"
  attr :space, :string, default: "", doc: "Space between items"
  attr :border, :string, default: "extra_small", doc: "Determines border style"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :max_width, :string, default: "", doc: "Determines the style of element max width"
  attr :seperator_size, :string, default: "extra_small", doc: "Determines the seperator size"
  attr :variant, :string, default: "base", doc: "Determines the style"
  attr :vertical, :boolean, default: false, doc: "Determines whether element is vertical"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :col_step, :boolean, default: false, doc: "Custom CSS class for additional styling"

  attr :col_step_position, :string,
    default: "start",
    doc: "Custom CSS class for additional styling"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  @spec stepper(map()) :: Phoenix.LiveView.Rendered.t()
  def stepper(%{vertical: true} = assigns) do
    ~H"""
    <div class={[
      "vertical-stepper relative flex flex-col",
      "[&_.vertical-step:last-child_.stepper-seperator]:hidden",
      step_visibility(),
      border_class(@border),
      space_class(@space),
      size_class(@size),
      color_variant(@color, @variant),
      @font_weight,
      @class
    ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  def stepper(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "group flex flex-row flex-start items-center flex-wrap gap-y-5",
        "[&_.stepper-seperator:last-child]:hidden",
        step_visibility(),
        size_class(@size),
        color_variant(@color, @variant),
        border_class(@border),
        wrapper_width(@max_width),
        seperator_margin(@margin),
        seperator_size(@seperator_size),
        col_step_position(@col_step_position),
        @col_step && "col-step",
        @col_step_position && "col-step-position",
        @font_weight,
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders a `stepper_section` within the stepper component, representing each individual step of
  a multi-step process.

  This section can display information such as the step number, title, description, and an icon.
  It can also be customized to show different states, such as current, loading, completed, or canceled.

  ## Examples

  Horizontal Step Section:

  ```elixir
  <.stepper_section step="current" title="First step" description="Create an account" />
  <.stepper_section title="Second Step" description="Verify email" />
  <.stepper_section title="Third Step" description="Get full access" />
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :size, :string,
    default: "small",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :step, :string,
    values: ["none", "current", "loading", "completed", "canceled"],
    default: "none"

  attr :icon, :string, default: nil, doc: "Icon displayed alongside of an item"
  attr :title, :string, default: nil, doc: "Specifies the title of the element"
  attr :description, :string, default: nil, doc: "Determines a short description"
  attr :step_number, :integer, default: 1
  attr :vertical, :boolean, default: false, doc: "Determines whether element is vertical"

  attr :clickable, :boolean,
    default: true,
    doc: "Determines if the element can be activated on click"

  attr :reverse, :boolean, default: false, doc: "Switches the order of the element and label"
  attr :space, :string, default: "small", doc: "Switches the order of the element and label"
  attr :border, :string, default: "", doc: "Determines border style"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def stepper_section(%{vertical: true} = assigns) do
    ~H"""
    <button
      id={@id}
      class={[
        "stepper-#{@step}-step",
        "vertical-step overflow-hidden flex flex-row text-start gap-4",
        @class
      ]}
      disabled={!@clickable}
      {@rest}
    >
      <span class="block relative">
        <span class="stepper-seperator block h-screen absolute start-1/2"></span>
        <span
          :if={@icon}
          class={[
            "stepper-step relative border-2 rounded-full flex justify-center items-center shrink-0",
            "transition-all ease-in-out duration-400 delay-100"
          ]}
        >
          <.icon name={@icon} class="step-symbol stepper-icon" />
          <.loader :if={@step== "loading"} />
          <.icon
            :if={@step== "completed"}
            name="hero-check-solid"
            class={[
              "stepper-icon stepper-completed-icon",
              "transition-all ease-in-out duration-400 delay-100"
            ]}
          />
        </span>

        <span
          :if={!@icon}
          class={[
            "stepper-step relative border-2 rounded-full flex justify-center items-center shrink-0",
            "transition-all ease-in-out duration-400 delay-100"
          ]}
        >
          <span class="step-symbol">{@step_number}</span>
          <.loader :if={@step== "loading"} />
          <.icon
            :if={@step== "completed"}
            name="hero-check-solid"
            class={[
              "stepper-icon stepper-completed-icon",
              "transition-all ease-in-out duration-400 delay-100"
            ]}
          />
        </span>
      </span>

      <span class="block">
        <span :if={@title} class="block font-bold text-wrap">
          {@title}
        </span>

        <span :if={@description} class="block text-xs text-wrap">
          {@description}
        </span>
        {render_slot(@inner_block)}
      </span>
    </button>
    """
  end

  def stepper_section(assigns) do
    ~H"""
    <button
      id={@id}
      class={[
        "stepper-#{@step}-step",
        "text-start flex flex-nowrap shrink-0",
        "group-[:not(.col-step)]:justify-center group-[:not(.col-step)]:items-center",
        @reverse && "flex-row-reverse text-end",
        "group-[.col-step]:flex-col group-[.col-step]:gap-3",
        content_space(@space, @reverse),
        @class
      ]}
      disabled={!@clickable}
      {@rest}
    >
      <span
        :if={@icon}
        class={[
          "stepper-step border-2 rounded-full flex justify-center items-center shrink-0",
          "transition-all ease-in-out duration-400 delay-100"
        ]}
      >
        <.icon name={@icon} class="step-symbol stepper-icon" />
        <.loader :if={@step== "loading"} />
        <.icon
          name="hero-check-solid"
          :if={@step== "completed"}
          class={[
            "stepper-icon stepper-completed-icon",
            "transition-all ease-in-out duration-400 delay-100"
          ]}
        />
      </span>

      <span
        :if={!@icon}
        class={[
          "stepper-step border-2 rounded-full flex justify-center items-center shrink-0",
          "transition-all ease-in-out duration-400 delay-100"
        ]}
      >
        <span class="step-symbol">{@step_number}</span>
        <.loader :if={@step== "loading"} />
        <.icon
          name="hero-check-solid"
          :if={@step== "completed"}
          class={[
            "stepper-icon stepper-completed-icon",
            "transition-all ease-in-out duration-400 delay-100"
          ]}
        />
      </span>

      <span class={[
        "stepper-content block",
      ]}>
        <span :if={@title} class="block font-bold text-wrap">
          {@title}
        </span>

        <span :if={@description} class="block text-xs text-wrap">
          {@description}
        </span>
        {render_slot(@inner_block)}
      </span>
    </button>

    <div class="stepper-seperator w-full flex-1"></div>
    """
  end

  defp loader(assigns) do
    ~H"""
     <svg
      aria-hidden="true"
      class="stepper-icon stepper-loading-icon text-gray-200 dark:text-gray-400 animate-spin"
      stroke="currentColor"
      viewBox="0 0 100 101"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <path
        d="M100 50.5908C100 78.2051 77.6142 100.591 50 100.591C22.3858 100.591 0 78.2051 0 50.5908C0 22.9766 22.3858 0.59082 50 0.59082C77.6142 0.59082 100 22.9766 100 50.5908ZM9.08144 50.5908C9.08144 73.1895 27.4013 91.5094 50 91.5094C72.5987 91.5094 90.9186 73.1895 90.9186 50.5908C90.9186 27.9921 72.5987 9.67226 50 9.67226C27.4013 9.67226 9.08144 27.9921 9.08144 50.5908Z"
        fill="currentColor"
      />
      <path
        d="M93.9676 39.0409C96.393 38.4038 97.8624 35.9116 97.0079 33.5539C95.2932 28.8227 92.871 24.3692 89.8167 20.348C85.8452 15.1192 80.8826 10.7238 75.2124 7.41289C69.5422 4.10194 63.2754 1.94025 56.7698 1.05124C51.7666 0.367541 46.6976 0.446843 41.7345 1.27873C39.2613 1.69328 37.813 4.19778 38.4501 6.62326C39.0873 9.04874 41.5694 10.4717 44.0505 10.1071C47.8511 9.54855 51.7191 9.52689 55.5402 10.0491C60.8642 10.7766 65.9928 12.5457 70.6331 15.2552C75.2735 17.9648 79.3347 21.5619 82.5849 25.841C84.9175 28.9121 86.7997 32.2913 88.1811 35.8758C89.083 38.2158 91.5421 39.6781 93.9676 39.0409Z"
        fill="currentFill"
      />
    </svg>
    """
  end

  defp step_visibility() do
    [
      "[&_.stepper-icon]:hidden",
      "[&_.stepper-icon]:invisible",
      "[&_.stepper-icon]:opacity-0",
      "[&_.stepper-loading-icon]:block",
      "[&_.stepper-loading-icon]:visible",
      "[&_.stepper-loading-icon]:opacity-100",
      "[&_.stepper-completed-step_.stepper-completed-icon]:block",
      "[&_.stepper-completed-step_.stepper-completed-icon]:visible",
      "[&_.stepper-completed-step_.stepper-completed-icon]:opacity-100",
      "[&_.stepper-completed-step_.step-symbol]:hidden",
      "[&_.stepper-completed-step_.step-symbol]:invisible",
      "[&_.stepper-completed-step_.step-symbol]:opacity-0",
      "[&_.stepper-loading-step_.step-symbol]:hidden",
      "[&_.stepper-loading-step_.step-symbol]:invisible",
      "[&_.stepper-loading-step_.step-symbol]:opacity-0"
    ]
  end

  defp content_space("extra_small", reverse?) do
    [
      (reverse? && "group-[:not(.col-step)_.stepper-content]:me-1") ||
        "group-[:not(.col-step)_.stepper-content]:ms-1"
    ]
  end

  defp content_space("small", reverse?) do
    [
      (reverse? && "group-[:not(.col-step)_.stepper-content]:me-2") ||
        "group-[:not(.col-step)_.stepper-content]:ms-2"
    ]
  end

  defp content_space("medium", reverse?) do
    [
      (reverse? && "group-[:not(.col-step)_.stepper-content]:me-3") ||
        "group-[:not(.col-step)_.stepper-content]:ms-3"
    ]
  end

  defp content_space("large", reverse?) do
    [
      (reverse? && "group-[:not(.col-step)_.stepper-content]:me-4") ||
        "group-[:not(.col-step)_.stepper-content]:ms-4"
    ]
  end

  defp content_space("extra_large", reverse?) do
    [
      (reverse? && "group-[:not(.col-step)_.stepper-content]:me-5") ||
        "group-[:not(.col-step)_.stepper-content]:ms-5"
    ]
  end

  defp col_step_position("start") do
    [
      "[&.col-step-position>button]:items-start [&.col-step-position>button]:text-start"
    ]
  end

  defp col_step_position("end") do
    [
      "[&.col-step-position>button]:items-end [&.col-step-position>button]:text-end"
    ]
  end

  defp col_step_position("center") do
    [
      "[&.col-step-position>button]:items-center [&.col-step-position>button]:text-center"
    ]
  end

  defp seperator_margin("none") do
    [
      "[&_.stepper-seperator]:mx-0"
    ]
  end

  defp seperator_margin("extra_small") do
    [
      "[&_.stepper-seperator]:mx-1",
      "xl:[&_.stepper-seperator]:mx-3"
    ]
  end

  defp seperator_margin("small") do
    [
      "[&_.stepper-seperator]:mx-2",
      "xl:[&_.stepper-seperator]:mx-4"
    ]
  end

  defp seperator_margin("medium") do
    [
      "[&_.stepper-seperator]:mx-2",
      "xl:[&_.stepper-seperator]:mx-6"
    ]
  end

  defp seperator_margin("large") do
    [
      "[&_.stepper-seperator]:mx-3",
      "xl:[&_.stepper-seperator]:mx-8"
    ]
  end

  defp seperator_margin("extra_large") do
    [
      "[&_.stepper-seperator]:mx-3",
      "xl:[&_.stepper-seperator]:mx-10"
    ]
  end

  defp seperator_margin(params) when is_binary(params), do: params

  defp border_class("extra_small") do
    [
      "[&.vertical-stepper_.stepper-seperator]:border-s",
      "[&:not(.vertical-stepper)_.stepper-seperator]:border-t"
    ]
  end

  defp border_class("small") do
    [
      "[&.vertical-stepper_.stepper-seperator]:border-s-2",
      "[&:not(.vertical-stepper)_.stepper-seperator]:border-t-2"
    ]
  end

  defp border_class("medium") do
    [
      "[&.vertical-stepper_.stepper-seperator]:border-s-[3px]",
      "[&:not(.vertical-stepper)_.stepper-seperator]:border-t-[3px]"
    ]
  end

  defp border_class("large") do
    [
      "[&.vertical-stepper_.stepper-seperator]:border-s-4",
      "[&:not(.vertical-stepper)_.stepper-seperator]:border-t-4"
    ]
  end

  defp border_class("extra_large") do
    [
      "[&.vertical-stepper_.stepper-seperator]:border-s-[5px]",
      "[&:not(.vertical-stepper)_.stepper-seperator]:border-t-[5px]"
    ]
  end

  defp border_class(params) when is_binary(params), do: params

  defp space_class("extra_small"), do: "space-y-1"

  defp space_class("small"), do: "space-y-2"

  defp space_class("medium"), do: "space-y-3"

  defp space_class("large"), do: "space-y-4"

  defp space_class("extra_large"), do: "space-y-5"

  defp space_class(params) when is_binary(params), do: params

  defp wrapper_width("extra_small"), do: "max-w-1/4"
  defp wrapper_width("small"), do: "max-w-2/4"
  defp wrapper_width("medium"), do: "max-w-3/4"
  defp wrapper_width("large"), do: "max-w-11/12"
  defp wrapper_width("extra_large"), do: "max-"
  defp wrapper_width(params) when is_binary(params), do: params

  defp size_class("extra_small") do
    [
      "text-xs [&_.stepper-step]:size-7 [&_.stepper-icon]:size-4",
      "[&_.vertical-step:not(:last-child)]:min-h-10",
      "[&_.stepper-loading-icon]:w-8"
    ]
  end

  defp size_class("small") do
    [
      "text-sm [&_.stepper-step]:size-8 [&_.stepper-icon]:size-5",
      "[&_.vertical-step:not(:last-child)]:min-h-12",
      "[&_.stepper-loading-icon]:w-10"
    ]
  end

  defp size_class("medium") do
    [
      "text-base [&_.stepper-step]:size-9 [&_.stepper-icon]:size-6",
      "[&_.vertical-step:not(:last-child)]:min-h-14",
      "[&_.stepper-loading-icon]:w-11"
    ]
  end

  defp size_class("large") do
    [
      "text-lg [&_.stepper-step]:size-10 [&_.stepper-icon]:size-7",
      "[&_.vertical-step:not(:last-child)]:min-h-16",
      "[&_.stepper-loading-icon]:w-12"
    ]
  end

  defp size_class("extra_large") do
    [
      "text-xl [&_.stepper-step]:size-11 [&_.stepper-icon]:size-8",
      "[&_.vertical-step:not(:last-child)]:min-h-20",
      "[&_.stepper-loading-icon]:w-14"
    ]
  end

  defp size_class(params) when is_binary(params), do: params

  defp seperator_size("extra_small"), do: "[&_.stepper-seperator]:h-px"
  defp seperator_size("small"), do: "[&_.stepper-seperator]:h-0.5"
  defp seperator_size("medium"), do: "[&_.stepper-seperator]:h-1"
  defp seperator_size("large"), do: "[&_.stepper-seperator]:h-1.5"
  defp seperator_size("extra_large"), do: "[&_.stepper-seperator]:h-2"
  defp seperator_size(params) when is_binary(params), do: params

  # colors
  # stepper-loading-step, stepper-current-step, stepper-completed-step, stepper-canceled-step

  defp color_variant("base", _) do
    [
      "[&_.stepper-step]:bg-white [&_.stepper-step]:text-[#09090b] [&_.stepper-loading-icon]:fill-[#2563EB]",
      "[&_.stepper-step]:border-[#e4e4e7] [&_.stepper-current-step_.stepper-step]:border-[#2563EB]",
      "[&_.stepper-current-step_.stepper-step]:text-[#2563EB]",
      "[&_.stepper-completed-step_.stepper-step]:bg-[#14B8A6] [&_.stepper-completed-step_.stepper-step]:border-[#14B8A6]",
      "[&_.stepper-completed-step_.stepper-step]:text-white",
      "dark:[&_.stepper-step]:bg-[#18181B] dark:[&_.stepper-step]:text-[#FAFAFA] dark:[&_.stepper-step]:border-[#27272a]",
      "dark:[&_.stepper-current-step_.stepper-step]:text-[#1971C2]",
      "dark:[&_.stepper-current-step_.stepper-step]:border-[#1971C2]",
      "dark:[&_.stepper-completed-step_.stepper-step]:bg-[#099268] dark:[&_.stepper-completed-step_.stepper-step]:border-[#099268]",
      "dark:[&_.stepper-completed-step_.stepper-step]:text-white",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#FA5252] [&_.stepper-canceled-step_.stepper-step]:border-[#FA5252]",
      "[&_.stepper-canceled-step_.stepper-step]:text-white",
      "dark:[&_.stepper-canceled-step_.stepper-step]:bg-[#E03131] dark:[&_.stepper-canceled-step_.stepper-step]:border-[#E03131]",
      "dark:[&_.stepper-canceled-step_.stepper-step]:text-white",
      "[&_.stepper-seperator]:border-[#e4e4e7] dark:[&_.stepper-seperator]:border-[#27272a]",
      "[&_.stepper-completed-step+.stepper-seperator]:border-[#14B8A6] dark:[&_.stepper-completed-step+.stepper-seperator]:border-[#099268]",
      "[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-[#14B8A6]",
      "dark:[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-[#099268]"
    ]
  end

  defp color_variant("natural", "default") do
    [
      "[&_.stepper-step]:bg-[#F3F3F3] [&_.stepper-step]:text-[#282828] [&_.stepper-loading-icon]:fill-[#374151]",
      "[&_.stepper-step]:border-transparent [&_.stepper-current-step_.stepper-step]:border-[#282828]",
      "[&_.stepper-completed-step_.stepper-step]:bg-[#E8E8E8] [&_.stepper-completed-step_.stepper-step]:border-black",
      "dark:[&_.stepper-step]:bg-[#4B4B4B] dark:[&_.stepper-step]:text-[#E8E8E8]",
      "dark:[&_.stepper-current-step_.stepper-step]:border-[#E8E8E8]",
      "dark:[&_.stepper-completed-step_.stepper-step]:bg-[#5E5E5E] dark:[&_.stepper-completed-step_.stepper-step]:border-white",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#950F22] [&_.stepper-canceled-step_.stepper-step]:border-[#950F22]",
      "[&_.stepper-canceled-step_.stepper-step]:text-white",
      "dark:[&_.stepper-canceled-step_.stepper-step]:bg-[#FFD2CD] dark:[&_.stepper-canceled-step_.stepper-step]:border-[#FFD2CD]",
      "dark:[&_.stepper-canceled-step_.stepper-step]:text-black",
      "[&_.stepper-seperator]:border-[#282828] dark:[&_.stepper-seperator]:border-[#E8E8E8]",
      "[&_.stepper-completed-step+.stepper-seperator]:border-black dark:[&_.stepper-completed-step+.stepper-seperator]:border-white",
      "[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-black",
      "dark:[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-white"
    ]
  end

  defp color_variant("primary", "default") do
    [
      "[&_.stepper-step]:bg-[#E2F8FB] [&_.stepper-step]:text-[#016974] [&_.stepper-loading-icon]:fill-[#374151]",
      "[&_.stepper-step]:border-transparent [&_.stepper-current-step_.stepper-step]:border-[#016974]",
      "[&_.stepper-completed-step_.stepper-step]:bg-[#CDEEF3] [&_.stepper-completed-step_.stepper-step]:border-[#1A535A]",
      "dark:[&_.stepper-step]:bg-[#002D33] dark:[&_.stepper-step]:text-[#77D5E3]",
      "dark:[&_.stepper-current-step_.stepper-step]:border-[#77D5E3]",
      "dark:[&_.stepper-completed-step_.stepper-step]:bg-[#1A535A] dark:[&_.stepper-completed-step_.stepper-step]:border-[#B0E7EF]",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#950F22] [&_.stepper-canceled-step_.stepper-step]:border-[#950F22]",
      "[&_.stepper-canceled-step_.stepper-step]:text-white",
      "dark:[&_.stepper-canceled-step_.stepper-step]:bg-[#FFD2CD] dark:[&_.stepper-canceled-step_.stepper-step]:border-[#FFD2CD]",
      "dark:[&_.stepper-canceled-step_.stepper-step]:text-black",
      "[&_.stepper-seperator]:border-[#016974] dark:[&_.stepper-seperator]:border-[#77D5E3]",
      "[&_.stepper-completed-step+.stepper-seperator]:border-[#1A535A] dark:[&_.stepper-completed-step+.stepper-seperator]:border-[#B0E7EF]",
      "[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-[#1A535A]",
      "dark:[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-[#B0E7EF]"
    ]
  end

  defp color_variant("secondary", "default") do
    [
      "[&_.stepper-step]:bg-[#EFF4FE] [&_.stepper-step]:text-[#175BCC] [&_.stepper-loading-icon]:fill-[#374151]",
      "[&_.stepper-step]:border-transparent [&_.stepper-current-step_.stepper-step]:border-[#175BCC]",
      "[&_.stepper-completed-step_.stepper-step]:bg-[#DEE9FE] [&_.stepper-completed-step_.stepper-step]:border-[#1948A3]",
      "dark:[&_.stepper-step]:bg-[#002661] dark:[&_.stepper-step]:text-[#A9C9FF]",
      "dark:[&_.stepper-current-step_.stepper-step]:border-[#A9C9FF]",
      "dark:[&_.stepper-completed-step_.stepper-step]:bg-[#1948A3] dark:[&_.stepper-completed-step_.stepper-step]:border-[#CDDEFF]",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#950F22] [&_.stepper-canceled-step_.stepper-step]:border-[#950F22]",
      "[&_.stepper-canceled-step_.stepper-step]:text-white",
      "dark:[&_.stepper-canceled-step_.stepper-step]:bg-[#FFD2CD] dark:[&_.stepper-canceled-step_.stepper-step]:border-[#FFD2CD]",
      "dark:[&_.stepper-canceled-step_.stepper-step]:text-black",
      "[&_.stepper-seperator]:border-[#175BCC] dark:[&_.stepper-seperator]:border-[#A9C9FF]",
      "[&_.stepper-completed-step+.stepper-seperator]:border-[#1948A3] dark:[&_.stepper-completed-step+.stepper-seperator]:border-[#CDDEFF]",
      "[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-[#1948A3]",
      "dark:[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-[#CDDEFF]"
    ]
  end

  defp color_variant("success", "default") do
    [
      "[&_.stepper-step]:bg-[#EAF6ED] [&_.stepper-step]:text-[#166C3B] [&_.stepper-loading-icon]:fill-[#374151]",
      "[&_.stepper-step]:border-transparent [&_.stepper-current-step_.stepper-step]:border-[#166C3B]",
      "[&_.stepper-completed-step_.stepper-step]:bg-[#D3EFDA] [&_.stepper-completed-step_.stepper-step]:border-[#0D572D]",
      "dark:[&_.stepper-step]:bg-[#002F14] dark:[&_.stepper-step]:text-[#7FD99A]",
      "dark:[&_.stepper-current-step_.stepper-step]:border-[#7FD99A]",
      "dark:[&_.stepper-completed-step_.stepper-step]:bg-[#0D572D] dark:[&_.stepper-completed-step_.stepper-step]:border-[#B1EAC2]",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#950F22] [&_.stepper-canceled-step_.stepper-step]:border-[#950F22]",
      "[&_.stepper-canceled-step_.stepper-step]:text-white",
      "dark:[&_.stepper-canceled-step_.stepper-step]:bg-[#FFD2CD] dark:[&_.stepper-canceled-step_.stepper-step]:border-[#FFD2CD]",
      "dark:[&_.stepper-canceled-step_.stepper-step]:text-black",
      "[&_.stepper-seperator]:border-[#166C3B] dark:[&_.stepper-seperator]:border-[#7FD99A]",
      "[&_.stepper-completed-step+.stepper-seperator]:border-[#0D572D] dark:[&_.stepper-completed-step+.stepper-seperator]:border-[#B1EAC2]",
      "[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-[#0D572D]",
      "dark:[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-[#B1EAC2]"
    ]
  end

  defp color_variant("warning", "default") do
    [
      "[&_.stepper-step]:bg-[#FFF7E6] [&_.stepper-step]:text-[#976A01] [&_.stepper-loading-icon]:fill-[#374151]",
      "[&_.stepper-step]:border-transparent [&_.stepper-current-step_.stepper-step]:border-[#976A01]",
      "[&_.stepper-completed-step_.stepper-step]:bg-[#FEEFCC] [&_.stepper-completed-step_.stepper-step]:border-[#654600]",
      "dark:[&_.stepper-step]:bg-[#322300] dark:[&_.stepper-step]:text-[#FDD067]",
      "dark:[&_.stepper-current-step_.stepper-step]:border-[#FDD067]",
      "dark:[&_.stepper-completed-step_.stepper-step]:bg-[#654600] dark:[&_.stepper-completed-step_.stepper-step]:border-[#FEDF99]",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#950F22] [&_.stepper-canceled-step_.stepper-step]:border-[#950F22]",
      "[&_.stepper-canceled-step_.stepper-step]:text-white",
      "dark:[&_.stepper-canceled-step_.stepper-step]:bg-[#FFD2CD] dark:[&_.stepper-canceled-step_.stepper-step]:border-[#FFD2CD]",
      "dark:[&_.stepper-canceled-step_.stepper-step]:text-black",
      "[&_.stepper-seperator]:border-[#976A01] dark:[&_.stepper-seperator]:border-[#FDD067]",
      "[&_.stepper-completed-step+.stepper-seperator]:border-[#654600] dark:[&_.stepper-completed-step+.stepper-seperator]:border-[#FEDF99]",
      "[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-[#654600]",
      "dark:[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-[#FEDF99]"
    ]
  end

  defp color_variant("danger", "default") do
    [
      "[&_.stepper-step]:bg-[#FFF0EE] [&_.stepper-step]:text-[#BB032A] [&_.stepper-loading-icon]:fill-[#374151]",
      "[&_.stepper-step]:border-transparent [&_.stepper-current-step_.stepper-step]:border-[#BB032A]",
      "[&_.stepper-completed-step_.stepper-step]:bg-[#FFE1DE] [&_.stepper-completed-step_.stepper-step]:border-[#950F22]",
      "dark:[&_.stepper-step]:bg-[#520810] dark:[&_.stepper-step]:text-[#FFB2AB]",
      "dark:[&_.stepper-current-step_.stepper-step]:border-[#FFB2AB]",
      "dark:[&_.stepper-completed-step_.stepper-step]:bg-[#950F22] dark:[&_.stepper-completed-step_.stepper-step]:border-[#FFD2CD]",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#950F22] [&_.stepper-canceled-step_.stepper-step]:border-[#950F22]",
      "[&_.stepper-canceled-step_.stepper-step]:text-white",
      "dark:[&_.stepper-canceled-step_.stepper-step]:bg-[#FFD2CD] dark:[&_.stepper-canceled-step_.stepper-step]:border-[#FFD2CD]",
      "dark:[&_.stepper-canceled-step_.stepper-step]:text-black",
      "[&_.stepper-seperator]:border-[#BB032A] dark:[&_.stepper-seperator]:border-[#FFB2AB]",
      "[&_.stepper-completed-step+.stepper-seperator]:border-[#950F22] dark:[&_.stepper-completed-step+.stepper-seperator]:border-[#FFD2CD]",
      "[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-[#950F22]",
      "dark:[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-[#FFD2CD]"
    ]
  end

  defp color_variant("info", "default") do
    [
      "[&_.stepper-step]:bg-[#E7F6FD] [&_.stepper-step]:text-[#08638C] [&_.stepper-loading-icon]:fill-[#374151]",
      "[&_.stepper-step]:border-transparent [&_.stepper-current-step_.stepper-step]:border-[#08638C]",
      "[&_.stepper-completed-step_.stepper-step]:bg-[#CFEDFB] [&_.stepper-completed-step_.stepper-step]:border-[#06425D]",
      "dark:[&_.stepper-step]:bg-[#03212F] dark:[&_.stepper-step]:text-[#6EC9F2]",
      "dark:[&_.stepper-current-step_.stepper-step]:border-[#6EC9F2]",
      "dark:[&_.stepper-completed-step_.stepper-step]:bg-[#06425D] dark:[&_.stepper-completed-step_.stepper-step]:border-[#9FDBF6]",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#950F22] [&_.stepper-canceled-step_.stepper-step]:border-[#950F22]",
      "[&_.stepper-canceled-step_.stepper-step]:text-white",
      "dark:[&_.stepper-canceled-step_.stepper-step]:bg-[#FFD2CD] dark:[&_.stepper-canceled-step_.stepper-step]:border-[#FFD2CD]",
      "dark:[&_.stepper-canceled-step_.stepper-step]:text-black",
      "[&_.stepper-seperator]:border-[#08638C] dark:[&_.stepper-seperator]:border-[#6EC9F2]",
      "[&_.stepper-completed-step+.stepper-seperator]:border-[#06425D] dark:[&_.stepper-completed-step+.stepper-seperator]:border-[#9FDBF6]",
      "[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-[#06425D]",
      "dark:[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-[#9FDBF6]"
    ]
  end

  defp color_variant("misc", "default") do
    [
      "[&_.stepper-step]:bg-[#F6F0FE] [&_.stepper-step]:text-[#653C94] [&_.stepper-loading-icon]:fill-[#374151]",
      "[&_.stepper-step]:border-transparent [&_.stepper-current-step_.stepper-step]:border-[#653C94]",
      "[&_.stepper-completed-step_.stepper-step]:bg-[#EEE0FD] [&_.stepper-completed-step_.stepper-step]:border-[#442863]",
      "dark:[&_.stepper-step]:bg-[#221431] dark:[&_.stepper-step]:text-[#CBA2FA]",
      "dark:[&_.stepper-current-step_.stepper-step]:border-[#CBA2FA]",
      "dark:[&_.stepper-completed-step_.stepper-step]:bg-[#44286] dark:[&_.stepper-completed-step_.stepper-step]:border-[#DDC1FC]",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#950F22] [&_.stepper-canceled-step_.stepper-step]:border-[#950F22]",
      "[&_.stepper-canceled-step_.stepper-step]:text-white",
      "dark:[&_.stepper-canceled-step_.stepper-step]:bg-[#FFD2CD] dark:[&_.stepper-canceled-step_.stepper-step]:border-[#FFD2CD]",
      "dark:[&_.stepper-canceled-step_.stepper-step]:text-black",
      "[&_.stepper-seperator]:border-[#653C94] dark:[&_.stepper-seperator]:border-[#CBA2FA]",
      "[&_.stepper-completed-step+.stepper-seperator]:border-[#442863] dark:[&_.stepper-completed-step+.stepper-seperator]:border-[#DDC1FC]",
      "[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-[#442863]",
      "dark:[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-[#DDC1FC]"
    ]
  end

  defp color_variant("dawn", "default") do
    [
      "[&_.stepper-step]:bg-[#FBF2ED] [&_.stepper-step]:text-[#7E4B2A] [&_.stepper-loading-icon]:fill-[#374151]",
      "[&_.stepper-step]:border-transparent [&_.stepper-current-step_.stepper-step]:border-[#7E4B2A]",
      "[&_.stepper-completed-step_.stepper-step]:bg-[#F6E5DA] [&_.stepper-completed-step_.stepper-step]:border-[#54321C]",
      "dark:[&_.stepper-step]:bg-[#2A190E] dark:[&_.stepper-step]:text-[#E4B190]",
      "dark:[&_.stepper-current-step_.stepper-step]:border-[#E4B190]",
      "dark:[&_.stepper-completed-step_.stepper-step]:bg-[#54321C] dark:[&_.stepper-completed-step_.stepper-step]:border-[#EDCBB5]",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#950F22] [&_.stepper-canceled-step_.stepper-step]:border-[#950F22]",
      "[&_.stepper-canceled-step_.stepper-step]:text-white",
      "dark:[&_.stepper-canceled-step_.stepper-step]:bg-[#FFD2CD] dark:[&_.stepper-canceled-step_.stepper-step]:border-[#FFD2CD]",
      "dark:[&_.stepper-canceled-step_.stepper-step]:text-black",
      "[&_.stepper-seperator]:border-[#7E4B2A] dark:[&_.stepper-seperator]:border-[#E4B190]",
      "[&_.stepper-completed-step+.stepper-seperator]:border-[#54321C] dark:[&_.stepper-completed-step+.stepper-seperator]:border-[#EDCBB5]",
      "[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-[#54321C]",
      "dark:[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-[#EDCBB5]"
    ]
  end

  defp color_variant("silver", "default") do
    [
      "[&_.stepper-step]:bg-[#F3F3F3] [&_.stepper-step]:text-[#727272] [&_.stepper-loading-icon]:fill-[#374151]",
      "[&_.stepper-step]:border-transparent [&_.stepper-current-step_.stepper-step]:border-[#727272]",
      "[&_.stepper-completed-step_.stepper-step]:bg-[#E8E8E8] [&_.stepper-completed-step_.stepper-step]:border-[#5E5E5E]",
      "dark:[&_.stepper-step]:bg-[#4B4B4B] dark:[&_.stepper-step]:text-[#BBBBBB]",
      "dark:[&_.stepper-current-step_.stepper-step]:border-[#BBBBBB]",
      "dark:[&_.stepper-completed-step_.stepper-step]:bg-[#5E5E5E] dark:[&_.stepper-completed-step_.stepper-step]:border-[#DDDDDD]",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#950F22] [&_.stepper-canceled-step_.stepper-step]:border-[#950F22]",
      "[&_.stepper-canceled-step_.stepper-step]:text-white",
      "dark:[&_.stepper-canceled-step_.stepper-step]:bg-[#FFD2CD] dark:[&_.stepper-canceled-step_.stepper-step]:border-[#FFD2CD]",
      "dark:[&_.stepper-canceled-step_.stepper-step]:text-black",
      "[&_.stepper-seperator]:border-[#727272] dark:[&_.stepper-seperator]:border-[#BBBBBB]",
      "[&_.stepper-completed-step+.stepper-seperator]:border-[#5E5E5E] dark:[&_.stepper-completed-step+.stepper-seperator]:border-[#DDDDDD]",
      "[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-[#5E5E5E]",
      "dark:[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-[#DDDDDD]"
    ]
  end

  defp color_variant("natural", "gradient") do
    [
      "[&_.stepper-step]:bg-gradient-to-br from-[#282828] to-[#727272] [&_.stepper-step]:text-white",
      "dark:from-[#A6A6A6] dark:to-[#FFFFFF] dark:[&_.stepper-step]:text-black",
      "[&_.stepper-step]:text-[#282828] [&_.stepper-loading-icon]:fill-[#374151]",
      "[&_.stepper-step]:border-transparent [&_.stepper-current-step_.stepper-step]:border-[#282828]",
      "[&_.stepper-completed-step_.stepper-step]:bg-[#E8E8E8] [&_.stepper-completed-step_.stepper-step]:border-black",
      "dark:[&_.stepper-current-step_.stepper-step]:border-[#E8E8E8]",
      "dark:[&_.stepper-completed-step_.stepper-step]:bg-[#5E5E5E] dark:[&_.stepper-completed-step_.stepper-step]:border-white",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#950F22] [&_.stepper-canceled-step_.stepper-step]:border-[#950F22]",
      "[&_.stepper-canceled-step_.stepper-step]:text-white",
      "dark:[&_.stepper-canceled-step_.stepper-step]:bg-[#FFD2CD] dark:[&_.stepper-canceled-step_.stepper-step]:border-[#FFD2CD]",
      "dark:[&_.stepper-canceled-step_.stepper-step]:text-black",
      "[&_.stepper-seperator]:border-[#282828] dark:[&_.stepper-seperator]:border-[#E8E8E8]",
      "[&_.stepper-completed-step+.stepper-seperator]:border-black dark:[&_.stepper-completed-step+.stepper-seperator]:border-white",
      "[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-black",
      "dark:[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-white"
    ]
  end

  defp color_variant("primary", "gradient") do
    [
      "[&_.stepper-step]:bg-gradient-to-br from-[#016974] to-[#01B8CA] [&_.stepper-step]:text-white",
      "dark:from-[#01B8CA] dark:to-[#B0E7EF] dark:[&_.stepper-step]:text-black",
      "[&_.stepper-loading-icon]:fill-[#374151]",
      "[&_.stepper-step]:border-transparent [&_.stepper-current-step_.stepper-step]:border-[#016974]",
      "[&_.stepper-completed-step_.stepper-step]:bg-[#CDEEF3] [&_.stepper-completed-step_.stepper-step]:border-[#1A535A]",
      "dark:[&_.stepper-current-step_.stepper-step]:border-[#77D5E3]",
      "dark:[&_.stepper-completed-step_.stepper-step]:bg-[#1A535A] dark:[&_.stepper-completed-step_.stepper-step]:border-[#B0E7EF]",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#950F22] [&_.stepper-canceled-step_.stepper-step]:border-[#950F22]",
      "[&_.stepper-canceled-step_.stepper-step]:text-white",
      "dark:[&_.stepper-canceled-step_.stepper-step]:bg-[#FFD2CD] dark:[&_.stepper-canceled-step_.stepper-step]:border-[#FFD2CD]",
      "dark:[&_.stepper-canceled-step_.stepper-step]:text-black",
      "[&_.stepper-seperator]:border-[#016974] dark:[&_.stepper-seperator]:border-[#77D5E3]",
      "[&_.stepper-completed-step+.stepper-seperator]:border-[#1A535A] dark:[&_.stepper-completed-step+.stepper-seperator]:border-[#B0E7EF]",
      "[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-[#1A535A]",
      "dark:[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-[#B0E7EF]"
    ]
  end

  defp color_variant("secondary", "gradient") do
    [
      "[&_.stepper-step]:bg-gradient-to-br from-[#175BCC] to-[#6DAAFB] [&_.stepper-step]:text-white",
      "dark:from-[#6DAAFB] dark:to-[#CDDEFF] dark:[&_.stepper-step]:text-black",
      "[&_.stepper-loading-icon]:fill-[#374151]",
      "[&_.stepper-step]:border-transparent [&_.stepper-current-step_.stepper-step]:border-[#175BCC]",
      "[&_.stepper-completed-step_.stepper-step]:bg-[#DEE9FE] [&_.stepper-completed-step_.stepper-step]:border-[#1948A3]",
      "dark:[&_.stepper-current-step_.stepper-step]:border-[#A9C9FF]",
      "dark:[&_.stepper-completed-step_.stepper-step]:bg-[#1948A3] dark:[&_.stepper-completed-step_.stepper-step]:border-[#CDDEFF]",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#950F22] [&_.stepper-canceled-step_.stepper-step]:border-[#950F22]",
      "[&_.stepper-canceled-step_.stepper-step]:text-white",
      "dark:[&_.stepper-canceled-step_.stepper-step]:bg-[#FFD2CD] dark:[&_.stepper-canceled-step_.stepper-step]:border-[#FFD2CD]",
      "dark:[&_.stepper-canceled-step_.stepper-step]:text-black",
      "[&_.stepper-seperator]:border-[#175BCC] dark:[&_.stepper-seperator]:border-[#A9C9FF]",
      "[&_.stepper-completed-step+.stepper-seperator]:border-[#1948A3] dark:[&_.stepper-completed-step+.stepper-seperator]:border-[#CDDEFF]",
      "[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-[#1948A3]",
      "dark:[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-[#CDDEFF]"
    ]
  end

  defp color_variant("success", "gradient") do
    [
      "[&_.stepper-step]:bg-gradient-to-br from-[#166C3B] to-[#06C167] [&_.stepper-step]:text-white",
      "dark:from-[#06C167] dark:to-[#B1EAC2] dark:[&_.stepper-step]:text-black",
      "[&_.stepper-loading-icon]:fill-[#374151]",
      "[&_.stepper-step]:border-transparent [&_.stepper-current-step_.stepper-step]:border-[#166C3B]",
      "[&_.stepper-completed-step_.stepper-step]:bg-[#D3EFDA] [&_.stepper-completed-step_.stepper-step]:border-[#0D572D]",
      "dark:[&_.stepper-current-step_.stepper-step]:border-[#7FD99A]",
      "dark:[&_.stepper-completed-step_.stepper-step]:bg-[#0D572D] dark:[&_.stepper-completed-step_.stepper-step]:border-[#B1EAC2]",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#950F22] [&_.stepper-canceled-step_.stepper-step]:border-[#950F22]",
      "[&_.stepper-canceled-step_.stepper-step]:text-white",
      "dark:[&_.stepper-canceled-step_.stepper-step]:bg-[#FFD2CD] dark:[&_.stepper-canceled-step_.stepper-step]:border-[#FFD2CD]",
      "dark:[&_.stepper-canceled-step_.stepper-step]:text-black",
      "[&_.stepper-seperator]:border-[#166C3B] dark:[&_.stepper-seperator]:border-[#7FD99A]",
      "[&_.stepper-completed-step+.stepper-seperator]:border-[#0D572D] dark:[&_.stepper-completed-step+.stepper-seperator]:border-[#B1EAC2]",
      "[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-[#0D572D]",
      "dark:[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-[#B1EAC2]"
    ]
  end

  defp color_variant("warning", "gradient") do
    [
      "[&_.stepper-step]:bg-gradient-to-br from-[#976A01] to-[#FDC034] [&_.stepper-step]:text-white",
      "dark:from-[#FDC034] dark:to-[#FEDF99] dark:[&_.stepper-step]:text-black",
      "[&_.stepper-loading-icon]:fill-[#374151]",
      "[&_.stepper-step]:border-transparent [&_.stepper-current-step_.stepper-step]:border-[#976A01]",
      "[&_.stepper-completed-step_.stepper-step]:bg-[#FEEFCC] [&_.stepper-completed-step_.stepper-step]:border-[#654600]",
      "dark:[&_.stepper-current-step_.stepper-step]:border-[#FDD067]",
      "dark:[&_.stepper-completed-step_.stepper-step]:bg-[#654600] dark:[&_.stepper-completed-step_.stepper-step]:border-[#FEDF99]",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#950F22] [&_.stepper-canceled-step_.stepper-step]:border-[#950F22]",
      "[&_.stepper-canceled-step_.stepper-step]:text-white",
      "dark:[&_.stepper-canceled-step_.stepper-step]:bg-[#FFD2CD] dark:[&_.stepper-canceled-step_.stepper-step]:border-[#FFD2CD]",
      "dark:[&_.stepper-canceled-step_.stepper-step]:text-black",
      "[&_.stepper-seperator]:border-[#976A01] dark:[&_.stepper-seperator]:border-[#FDD067]",
      "[&_.stepper-completed-step+.stepper-seperator]:border-[#654600] dark:[&_.stepper-completed-step+.stepper-seperator]:border-[#FEDF99]",
      "[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-[#654600]",
      "dark:[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-[#FEDF99]"
    ]
  end

  defp color_variant("danger", "gradient") do
    [
      "[&_.stepper-step]:bg-gradient-to-br from-[#BB032A] to-[#FC7F79] [&_.stepper-step]:text-white",
      "dark:from-[#FC7F79] dark:to-[#FFD2CD] dark:[&_.stepper-step]:text-black",
      "[&_.stepper-loading-icon]:fill-[#374151]",
      "[&_.stepper-step]:border-transparent [&_.stepper-current-step_.stepper-step]:border-[#BB032A]",
      "[&_.stepper-completed-step_.stepper-step]:bg-[#FFE1DE] [&_.stepper-completed-step_.stepper-step]:border-[#950F22]",
      "dark:[&_.stepper-current-step_.stepper-step]:border-[#FFB2AB]",
      "dark:[&_.stepper-completed-step_.stepper-step]:bg-[#950F22] dark:[&_.stepper-completed-step_.stepper-step]:border-[#FFD2CD]",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#950F22] [&_.stepper-canceled-step_.stepper-step]:border-[#950F22]",
      "[&_.stepper-canceled-step_.stepper-step]:text-white",
      "dark:[&_.stepper-canceled-step_.stepper-step]:bg-[#FFD2CD] dark:[&_.stepper-canceled-step_.stepper-step]:border-[#FFD2CD]",
      "dark:[&_.stepper-canceled-step_.stepper-step]:text-black",
      "[&_.stepper-seperator]:border-[#BB032A] dark:[&_.stepper-seperator]:border-[#FFB2AB]",
      "[&_.stepper-completed-step+.stepper-seperator]:border-[#950F22] dark:[&_.stepper-completed-step+.stepper-seperator]:border-[#FFD2CD]",
      "[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-[#950F22]",
      "dark:[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-[#FFD2CD]"
    ]
  end

  defp color_variant("info", "gradient") do
    [
      "[&_.stepper-step]:bg-gradient-to-br from-[#08638C] to-[#3EB7ED] [&_.stepper-step]:text-white",
      "dark:from-[#3EB7ED] dark:to-[#9FDBF6] dark:[&_.stepper-step]:text-black",
      "[&_.stepper-loading-icon]:fill-[#374151]",
      "[&_.stepper-step]:border-transparent [&_.stepper-current-step_.stepper-step]:border-[#08638C]",
      "[&_.stepper-completed-step_.stepper-step]:bg-[#CFEDFB] [&_.stepper-completed-step_.stepper-step]:border-[#06425D]",
      "dark:[&_.stepper-current-step_.stepper-step]:border-[#6EC9F2]",
      "dark:[&_.stepper-completed-step_.stepper-step]:bg-[#06425D] dark:[&_.stepper-completed-step_.stepper-step]:border-[#9FDBF6]",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#950F22] [&_.stepper-canceled-step_.stepper-step]:border-[#950F22]",
      "[&_.stepper-canceled-step_.stepper-step]:text-white",
      "dark:[&_.stepper-canceled-step_.stepper-step]:bg-[#FFD2CD] dark:[&_.stepper-canceled-step_.stepper-step]:border-[#FFD2CD]",
      "dark:[&_.stepper-canceled-step_.stepper-step]:text-black",
      "[&_.stepper-seperator]:border-[#08638C] dark:[&_.stepper-seperator]:border-[#6EC9F2]",
      "[&_.stepper-completed-step+.stepper-seperator]:border-[#06425D] dark:[&_.stepper-completed-step+.stepper-seperator]:border-[#9FDBF6]",
      "[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-[#06425D]",
      "dark:[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-[#9FDBF6]"
    ]
  end

  defp color_variant("misc", "gradient") do
    [
      "[&_.stepper-step]:bg-gradient-to-br from-[#653C94] to-[#BA83F9] [&_.stepper-step]:text-white",
      "dark:from-[#BA83F9] dark:to-[#DDC1FC] dark:[&_.stepper-step]:text-black",
      "[&_.stepper-loading-icon]:fill-[#374151]",
      "[&_.stepper-step]:border-transparent [&_.stepper-current-step_.stepper-step]:border-[#653C94]",
      "[&_.stepper-completed-step_.stepper-step]:bg-[#EEE0FD] [&_.stepper-completed-step_.stepper-step]:border-[#442863]",
      "dark:[&_.stepper-current-step_.stepper-step]:border-[#CBA2FA]",
      "dark:[&_.stepper-completed-step_.stepper-step]:bg-[#44286] dark:[&_.stepper-completed-step_.stepper-step]:border-[#DDC1FC]",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#950F22] [&_.stepper-canceled-step_.stepper-step]:border-[#950F22]",
      "[&_.stepper-canceled-step_.stepper-step]:text-white",
      "dark:[&_.stepper-canceled-step_.stepper-step]:bg-[#FFD2CD] dark:[&_.stepper-canceled-step_.stepper-step]:border-[#FFD2CD]",
      "dark:[&_.stepper-canceled-step_.stepper-step]:text-black",
      "[&_.stepper-seperator]:border-[#653C94] dark:[&_.stepper-seperator]:border-[#CBA2FA]",
      "[&_.stepper-completed-step+.stepper-seperator]:border-[#442863] dark:[&_.stepper-completed-step+.stepper-seperator]:border-[#DDC1FC]",
      "[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-[#442863]",
      "dark:[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-[#DDC1FC]"
    ]
  end

  defp color_variant("dawn", "gradient") do
    [
      "[&_.stepper-step]:bg-gradient-to-br from-[#7E4B2A] to-[#DB976B] [&_.stepper-step]:text-white",
      "dark:from-[#DB976B] dark:to-[#EDCBB5] dark:[&_.stepper-step]:text-black",
      "[&_.stepper-loading-icon]:fill-[#374151]",
      "[&_.stepper-step]:border-transparent [&_.stepper-current-step_.stepper-step]:border-[#7E4B2A]",
      "[&_.stepper-completed-step_.stepper-step]:bg-[#F6E5DA] [&_.stepper-completed-step_.stepper-step]:border-[#54321C]",
      "dark:[&_.stepper-current-step_.stepper-step]:border-[#E4B190]",
      "dark:[&_.stepper-completed-step_.stepper-step]:bg-[#54321C] dark:[&_.stepper-completed-step_.stepper-step]:border-[#EDCBB5]",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#950F22] [&_.stepper-canceled-step_.stepper-step]:border-[#950F22]",
      "[&_.stepper-canceled-step_.stepper-step]:text-white",
      "dark:[&_.stepper-canceled-step_.stepper-step]:bg-[#FFD2CD] dark:[&_.stepper-canceled-step_.stepper-step]:border-[#FFD2CD]",
      "dark:[&_.stepper-canceled-step_.stepper-step]:text-black",
      "[&_.stepper-seperator]:border-[#7E4B2A] dark:[&_.stepper-seperator]:border-[#E4B190]",
      "[&_.stepper-completed-step+.stepper-seperator]:border-[#54321C] dark:[&_.stepper-completed-step+.stepper-seperator]:border-[#EDCBB5]",
      "[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-[#54321C]",
      "dark:[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-[#EDCBB5]"
    ]
  end

  defp color_variant("silver", "gradient") do
    [
      "[&_.stepper-step]:bg-gradient-to-br from-[#5E5E5E] to-[#A6A6A6] [&_.stepper-step]:text-white",
      "dark:from-[#868686] dark:to-[#BBBBBB] dark:[&_.stepper-step]:text-black",
      "[&_.stepper-loading-icon]:fill-[#374151]",
      "[&_.stepper-step]:border-transparent [&_.stepper-current-step_.stepper-step]:border-[#727272]",
      "[&_.stepper-completed-step_.stepper-step]:bg-[#E8E8E8] [&_.stepper-completed-step_.stepper-step]:border-[#5E5E5E]",
      "dark:[&_.stepper-current-step_.stepper-step]:border-[#BBBBBB]",
      "dark:[&_.stepper-completed-step_.stepper-step]:bg-[#5E5E5E] dark:[&_.stepper-completed-step_.stepper-step]:border-[#DDDDDD]",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#950F22] [&_.stepper-canceled-step_.stepper-step]:border-[#950F22]",
      "[&_.stepper-canceled-step_.stepper-step]:text-white",
      "dark:[&_.stepper-canceled-step_.stepper-step]:bg-[#FFD2CD] dark:[&_.stepper-canceled-step_.stepper-step]:border-[#FFD2CD]",
      "dark:[&_.stepper-canceled-step_.stepper-step]:text-black",
      "[&_.stepper-seperator]:border-[#727272] dark:[&_.stepper-seperator]:border-[#BBBBBB]",
      "[&_.stepper-completed-step+.stepper-seperator]:border-[#5E5E5E] dark:[&_.stepper-completed-step+.stepper-seperator]:border-[#DDDDDD]",
      "[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-[#5E5E5E]",
      "dark:[&.vertical-stepper_.stepper-completed-step_.stepper-seperator]:border-[#DDDDDD]"
    ]
  end

  defp color_variant(_, params) when is_binary(params), do: params

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
