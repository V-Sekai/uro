defmodule UroWeb.Components.Button do
  @moduledoc """
  Provides a comprehensive set of button components for the `UroWeb.Components.Button` project.
  These components are highly customizable, allowing various styles, sizes, colors,
  and configurations, including buttons with icons, gradients, and different indicator positions.

  ## Components

    - `button/1`: Renders a standard button with extensive customization options.
    - `button_group/1`: Renders a group of buttons with configurable layout and styling.
    - `input_button/1`: Renders a button with input attributes, useful for form submissions.
    - `button_link/1`: Renders a button as a link, supporting different navigation types.
    - `button_indicator/1`: A utility component to render indicators on buttons based on configuration.

  ## Configuration Options

  The module supports various predefined options for attributes like size, color,
  variant, and border style. These can be customized through the attributes of each
  component function to match specific design requirements.

  > This module makes it easy to render buttons with consistent styling and behavior
  > across your application while offering the flexibility needed for various use cases.
  """

  use Phoenix.Component
  import UroWeb.Components.Icon, only: [icon: 1]

  @indicator_positions [
    "indicator",
    "right_indicator",
    "left_indicator",
    "top_left_indicator",
    "top_center_indicator",
    "top_right_indicator",
    "middle_left_indicator",
    "middle_right_indicator",
    "bottom_left_indicator",
    "bottom_center_indicator",
    "bottom_right_indicator"
  ]

  @doc """
  The `button_group` component is used to group multiple buttons together with customizable
  attributes like `variant`, `color`, and `variation`.

  It supports different layout orientations, allowing buttons to be displayed horizontally or vertically.

  ## Examples

  ```elixir
  <.button_group>
    <.button icon="hero-adjustments-vertical">Button 1</.button>
    <.button icon="hero-adjustments-vertical" />
    <.button icon="hero-adjustments-vertical" />
    <.button>Button 3</.button>
  </.button_group>

  <.button_group>
    <.button>Button 1</.button>
    <.button>Button 2</.button>
    <.button>Button 3</.button>
    <.button>Button 4</.button>
    <.button>Button 5</.button>
  </.button_group>

  <.button_group color="success">
    <.button icon="hero-adjustments-vertical">Button 1</.button>
    <.button icon="hero-adjustments-vertical" color="success" />
    <.button icon="hero-adjustments-vertical" />
    <.button color="success">Button 3</.button>
  </.button_group>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :variation, :string,
    values: ["horizontal", "vertical"],
    default: "horizontal",
    doc: "Defines the layout orientation of the component"

  attr :color, :string, default: "base", doc: "Determines color theme"
  attr :rounded, :string, default: "small", doc: "Determines the border radius"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def button_group(assigns) do
    ~H"""
    <div
      id={@id}
      role="group"
      class={[
        default_classes(:grouped, false),
        variation(@variation),
        rounded_size(@rounded),
        border_class(@color),
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  The `button` component is used to create customizable buttons with various styles, icons, and indicators.

  It supports different types such as `button`, `submit`, and `reset`, and provides
  options for configuring size, color, and border radius.

  ## Examples

  ```elixir
  <.button variant="inverted_gradient" color="danger">Button 4</.button>
  <.button variant="inverted_gradient" color="info">Button 2</.button>
  <.button icon="hero-adjustments-vertical" variant="inverted_gradient" color="success"/>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :variant, :string, default: "base", doc: "Determines the style"

  attr :type, :any,
    values: ["button", "submit", "reset", nil],
    default: nil,
    doc: "Specifies the type of the element"

  attr :color, :string, default: "base", doc: "Determines color theme"
  attr :rounded, :string, default: "large", doc: "Determines the border radius"
  attr :border, :string, default: "extra_small", doc: "Determines border style"

  attr :size, :string,
    default: "large",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :content_position, :string,
    default: "center",
    doc: "Determines the alignment of the element's content"

  attr :display, :string,
    default: "inline-flex",
    doc: "Specifies the CSS display property for the element"

  attr :line_height, :string, default: "leading-5", doc: "Line height"
  attr :icon, :string, default: nil, doc: "Icon displayed alongside of an item"
  attr :icon_class, :string, default: nil, doc: "Determines custom class for the icon"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :full_width, :boolean, default: false, doc: "Make button full width"

  attr :indicator_class, :string,
    default: nil,
    doc: "Custom CSS class for styling the indicator element"

  attr :indicator_size, :string,
    default: "extra_small",
    doc: "Defines the size of the indicator element"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :content_class, :string, default: "block", doc: "Custom CSS class for additional styling"

  attr :rest, :global,
    include:
      ~w(disabled form name value right_icon left_icon pinging circle) ++ @indicator_positions,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  slot :loading, required: false do
    attr :class, :string, doc: "Custom CSS class for additional styling"

    attr :position, :string,
      values: ["start", "end"],
      doc: "Determines the element position"
  end

  def button(assigns) do
    assigns = assign_new(assigns, :indicator, fn -> is_indicators?(assigns[:rest]) end)

    ~H"""
    <button
      type={@type}
      id={@id}
      class={[
        default_classes(@rest[:pinging], @indicator),
        size_class(@size, @rest[:circle]),
        color_variant(@variant, @color, @indicator),
        content_position(@content_position),
        rounded_size(@rounded),
        border_size(@border, @variant),
        @full_width && "w-full",
        @line_height,
        @font_weight,
        @display,
        @class
      ]}
      {drop_rest(@rest)}
    >
      <span
        :for={loading <- @loading}
        :if={is_nil(loading[:position]) || loading[:position] == "start"}
        class={loading[:class]}
      >
        {render_slot(loading)}
      </span>

      <.button_indicator position="left" size={@indicator_size} class={@indicator_class} {@rest} />
      <.icon :if={icon_position(@icon, @rest) == "left"} name={@icon} class={@icon_class} />
      <span :if={@inner_block && render_slot(@inner_block)} class={[@content_class]}>
        {render_slot(@inner_block)}
      </span>
      <.icon :if={icon_position(@icon, @rest) == "right"} name={@icon} class={@icon_class} />
      <.button_indicator size={@indicator_size} class={@indicator_class} {@rest} />

      <span :for={loading <- @loading} :if={loading[:position] == "end"} class={loading[:class]}>
        {render_slot(loading)}
      </span>
    </button>
    """
  end

  @doc """
  The `input_button` component is used to create input elements with button-like styles and various
  customization options such as `color`, `size`, and `border`.

  It supports different input types like `button`, `submit`, and `reset`, allowing for
  flexible usage in forms and interactive elements.

  ## Examples

  ```elixir
  <.input_button value="input button" color="warning" />
  <.input_button value="input submit" type="submit" />
  <.input_button value="input reset" type="reset" color="silver" />
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :variant, :string, default: "base", doc: "Determines the style"
  attr :color, :string, default: "base", doc: "Determines color theme"
  attr :rounded, :string, default: "large", doc: "Determines the border radius"
  attr :value, :string, default: "", doc: "Value of input"
  attr :border, :string, default: "extra_small", doc: "Determines border style"

  attr :size, :string,
    default: "large",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :type, :string, default: "button", doc: "Determines type of input"
  attr :line_height, :string, default: "leading-5", doc: "Line height"

  attr :content_position, :string,
    default: "center",
    doc: "Determines the alignment of the element's content"

  attr :display, :string,
    default: "inline-block",
    doc: "Specifies the CSS display property for the element"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :full_width, :boolean, default: false, doc: "Make button full width"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  def input_button(assigns) do
    ~H"""
    <input
      type={@type}
      id={@id}
      value={@value}
      class={[
        default_classes(@rest[:pinging], false),
        size_class(@size, @rest[:circle]),
        color_variant(@variant, @color, false),
        content_position(@content_position),
        rounded_size(@rounded),
        border_size(@border, @variant),
        @full_width && "w-full",
        @font_weight,
        @line_height,
        @display,
        @class
      ]}
      {@rest}
    />
    """
  end

  @doc """
  The `button_link` component is used to create stylized link elements that resemble buttons.

  It supports different navigation methods like `navigate`, `patch`, and `href` along with
  customizable attributes for appearance and behavior.

  ## Examples

  ```elixir
  <.button_link navigate="/admin" icon="hero-adjustments-vertical" />
  <.button_link navigate="/admin">Button 3</.button_link>

  <.button_link navigate="/admin" icon="hero-adjustments-vertical">
    Button 1
  </.button_link>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :title, :string, default: nil, doc: "Specifies the title of the element"

  attr :navigate, :string,
    doc: "Defines the path for navigation within the application using a `navigate` attribute."

  attr :patch, :string, doc: "Specifies the path for navigation using a LiveView patch"
  attr :href, :string, doc: "Sets the URL for an external link"
  attr :variant, :string, default: "base", doc: "Determines the style"
  attr :color, :string, default: "base", doc: "Determines color theme"
  attr :rounded, :string, default: "large", doc: ""
  attr :border, :string, default: "extra_small", doc: "Determines border style"

  attr :size, :string,
    default: "large",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :content_class, :string, default: "block", doc: "Custom CSS class for additional styling"

  attr :display, :string,
    default: "inline-flex",
    doc: "Specifies the CSS display property for the element"

  attr :line_height, :string, default: "leading-5", doc: "Line height"
  attr :icon, :string, default: nil, doc: "Icon displayed alongside of an item"
  attr :icon_class, :string, default: nil, doc: "Determines custom class for the icon"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :full_width, :boolean, default: false, doc: "Make button full width"

  attr :indicator_class, :string,
    default: nil,
    doc: "Custom CSS class for styling the indicator element"

  attr :indicator_size, :string,
    default: "extra_small",
    doc: "Defines the size of the indicator element"

  attr :rest, :global,
    include:
      ~w(right_icon left_icon pinging circle download hreflang referrerpolicy rel target type csrf_token method replace) ++
        @indicator_positions,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  slot :loading, required: false do
    attr :class, :string, doc: "Custom CSS class for additional styling"

    attr :position, :string,
      values: ["start", "end"],
      doc: "Determines the element position"
  end

  def button_link(%{navigate: _navigate} = assigns) do
    assigns = assign_new(assigns, :indicator, fn -> is_indicators?(assigns[:rest]) end)

    ~H"""
    <.link
      navigate={@navigate}
      id={@id}
      class={[
        default_classes(@rest[:pinging], @indicator),
        size_class(@size, @rest[:circle]),
        color_variant(@variant, @color, @indicator),
        rounded_size(@rounded),
        border_size(@border, @variant),
        @full_width && "w-full",
        @font_weight,
        @line_height,
        @display,
        @class
      ]}
      {drop_rest(@rest)}
    >
      <span
        :for={loading <- @loading}
        :if={is_nil(loading[:position]) || loading[:position] == "start"}
        class={loading[:class]}
      >
        {render_slot(loading)}
      </span>

      <.button_indicator position="left" size={@indicator_size} class={@indicator_class} {@rest} />
      <.icon :if={icon_position(@icon, @rest) == "left"} name={@icon} class={@icon_class} />
      <span :if={(@inner_block && render_slot(@inner_block)) || @title} class={[@content_class]}>
        {render_slot(@inner_block) || @title}
      </span>
      <.icon :if={icon_position(@icon, @rest) == "right"} name={@icon} class={@icon_class} />
      <.button_indicator size={@indicator_size} class={@indicator_class} {@rest} />

      <span :for={loading <- @loading} :if={loading[:position] == "end"} class={loading[:class]}>
        {render_slot(loading)}
      </span>
    </.link>
    """
  end

  def button_link(%{patch: _patch} = assigns) do
    assigns = assign_new(assigns, :indicator, fn -> is_indicators?(assigns[:rest]) end)

    ~H"""
    <.link
      patch={@patch}
      id={@id}
      class={[
        default_classes(@rest[:pinging], @indicator),
        size_class(@size, @rest[:circle]),
        color_variant(@variant, @color, @indicator),
        rounded_size(@rounded),
        border_size(@border, @variant),
        @full_width && "w-full",
        @font_weight,
        @line_height,
        @class
      ]}
      {drop_rest(@rest)}
    >
      <span
        :for={loading <- @loading}
        :if={is_nil(loading[:position]) || loading[:position] == "start"}
        class={loading[:class]}
      >
        {render_slot(loading)}
      </span>

      <.button_indicator position="left" size={@indicator_size} class={@indicator_class} {@rest} />
      <.icon :if={icon_position(@icon, @rest) == "left"} name={@icon} />
      <span :if={(@inner_block && render_slot(@inner_block)) || @title} class={[@content_class]}>
        {render_slot(@inner_block) || @title}
      </span>
      <.icon :if={icon_position(@icon, @rest) == "right"} name={@icon} />
      <.button_indicator size={@indicator_size} class={@indicator_class} {@rest} />

      <span :for={loading <- @loading} :if={loading[:position] == "end"} class={loading[:class]}>
        {render_slot(loading)}
      </span>
    </.link>
    """
  end

  def button_link(%{href: _href} = assigns) do
    assigns = assign_new(assigns, :indicator, fn -> is_indicators?(assigns[:rest]) end)

    ~H"""
    <.link
      href={@href}
      id={@id}
      class={[
        default_classes(@rest[:pinging], @indicator),
        size_class(@size, @rest[:circle]),
        color_variant(@variant, @color, @indicator),
        rounded_size(@rounded),
        border_size(@border, @variant),
        @full_width && "w-full",
        @font_weight,
        @line_height,
        @class
      ]}
      {drop_rest(@rest)}
    >
      <span
        :for={loading <- @loading}
        :if={is_nil(loading[:position]) || loading[:position] == "start"}
        class={loading[:class]}
      >
        {render_slot(loading)}
      </span>

      <.button_indicator position="left" size={@indicator_size} class={@indicator_class} {@rest} />
      <.icon :if={icon_position(@icon, @rest) == "left"} name={@icon} />
      <span :if={(@inner_block && render_slot(@inner_block)) || @title} class={[@content_class]}>
        {render_slot(@inner_block) || @title}
      </span>
      <.icon :if={icon_position(@icon, @rest) == "right"} name={@icon} />
      <.button_indicator size={@indicator_size} class={@indicator_class} {@rest} />

      <span :for={loading <- @loading} :if={loading[:position] == "end"} class={loading[:class]}>
        {render_slot(loading)}
      </span>
    </.link>
    """
  end

  @doc """
  Renders a back navigation link.

  ## Examples

      <.back navigate={~p"/posts"}>Back to posts</.back>
  """
  @doc type: :component
  attr :navigate, :any, required: true
  slot :inner_block, required: true

  def back(assigns) do
    ~H"""
    <div class="mt-16">
      <.link
        navigate={@navigate}
        class="text-sm font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
      >
        <.icon name="hero-arrow-left-solid" class="h-3 w-3" />
        {render_slot(@inner_block)}
      </.link>
    </div>
    """
  end

  @doc type: :component
  attr :position, :string, default: "none", doc: "Determines the element position"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :size, :string,
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  defp button_indicator(%{position: "left", rest: %{left_indicator: true}} = assigns) do
    ~H"""
    <span aria-hidden="true" class={["indicator", indicator_size(@size), @class]} />
    """
  end

  defp button_indicator(%{position: "left", rest: %{indicator: true}} = assigns) do
    ~H"""
    <span aria-hidden="true" class={["indicator", indicator_size(@size), @class]} />
    """
  end

  defp button_indicator(%{position: "none", rest: %{right_indicator: true}} = assigns) do
    ~H"""
    <span aria-hidden="true" class={["indicator", indicator_size(@size), @class]} />
    """
  end

  defp button_indicator(%{position: "none", rest: %{top_left_indicator: true}} = assigns) do
    ~H"""
    <span
      aria-hidden="true"
      class={[
        "indicator",
        indicator_size(@size),
        @class || "absolute -translate-y-1/2 -translate-x-1/2 right-auto top-0 left-0"
      ]}
    />
    """
  end

  defp button_indicator(%{position: "none", rest: %{top_center_indicator: true}} = assigns) do
    ~H"""
    <span
      aria-hidden="true"
      class={[
        "indicator",
        indicator_size(@size),
        @class || "absolute top-0 -translate-y-1/2 translate-x-1/2 right-1/2"
      ]}
    />
    """
  end

  defp button_indicator(%{position: "none", rest: %{top_right_indicator: true}} = assigns) do
    ~H"""
    <span
      aria-hidden="true"
      class={[
        "indicator",
        indicator_size(@size),
        @class || "absolute -translate-y-1/2 translate-x-1/2 left-auto top-0 right-0"
      ]}
    />
    """
  end

  defp button_indicator(%{position: "none", rest: %{middle_left_indicator: true}} = assigns) do
    ~H"""
    <span
      aria-hidden="true"
      class={[
        "indicator",
        indicator_size(@size),
        @class || "absolute -translate-y-1/2 -translate-x-1/2 right-auto left-0 top-2/4"
      ]}
    />
    """
  end

  defp button_indicator(%{position: "none", rest: %{middle_right_indicator: true}} = assigns) do
    ~H"""
    <span
      aria-hidden="true"
      class={[
        "indicator",
        indicator_size(@size),
        @class || "absolute -translate-y-1/2 translate-x-1/2 left-auto right-0 top-2/4"
      ]}
    />
    """
  end

  defp button_indicator(%{position: "none", rest: %{bottom_left_indicator: true}} = assigns) do
    ~H"""
    <span
      aria-hidden="true"
      class={[
        "indicator",
        indicator_size(@size),
        @class || "absolute translate-y-1/2 -translate-x-1/2 right-auto bottom-0 left-0"
      ]}
    />
    """
  end

  defp button_indicator(%{position: "none", rest: %{bottom_center_indicator: true}} = assigns) do
    ~H"""
    <span
      aria-hidden="true"
      class={[
        "indicator",
        indicator_size(@size),
        @class || "absolute translate-y-1/2 translate-x-1/2 bottom-0 right-1/2"
      ]}
    />
    """
  end

  defp button_indicator(%{position: "none", rest: %{bottom_right_indicator: true}} = assigns) do
    ~H"""
    <span
      aria-hidden="true"
      class={[
        "indicator",
        indicator_size(@size),
        @class || "absolute translate-y-1/2 translate-x-1/2 left-auto bottom-0 right-0"
      ]}
    />
    """
  end

  defp button_indicator(assigns) do
    ~H"""
    """
  end

  defp border_size(_, variant)
       when variant in [
              "default",
              "shadow",
              "transparent",
              "subtle",
              "default_gradient",
              "outline_gradient",
              "inverted_gradient"
            ],
       do: nil

  defp border_size("none", _), do: nil
  defp border_size("extra_small", _), do: "border"
  defp border_size("small", _), do: "border-2"
  defp border_size("medium", _), do: "border-[3px]"
  defp border_size("large", _), do: "border-4"
  defp border_size("extra_large", _), do: "border-[5px]"
  defp border_size(params, _) when is_binary(params), do: params

  defp color_variant("base", _, indicator) do
    [
      "bg-white text-[#09090b] border-[#e4e4e7] hover:bg-[#F8F9FA]",
      "dark:bg-[#18181B] dark:text-[#FAFAFA] dark:border-[#27272a] dark:hover:bg-[#242424]",
      "disabled:bg-[#f1f3f5] disabled:text-[#adb5bd] dark:disabled:bg-[#2e2e2e] dark:disabled:text-[#696969]",
      "disabled:border-[#dee2e6] dark:disabled:border-[#424242]",
      "shadow-sm",
      indicator && "[&>.indicator]:bg-[#e4e4e7] dark:[&>.indicator]:bg-[#27272a]"
    ]
  end

  defp color_variant("default", "white", _) do
    ["bg-white text-black"]
  end

  defp color_variant("default", "dark", _) do
    ["bg-[#282828] text-white"]
  end

  defp color_variant("default", "natural", indicator) do
    [
      "bg-[#4B4B4B] text-white hover:bg-[#282828] dark:bg-[#DDDDDD]",
      "dark:text-black dark:hover:bg-[#E8E8E8]",
      "disabled:bg-[#F3F3F3] disabled:text-[#BBBBBB]",
      "dark:disabled:bg-[#4B4B4B] dark:disabled:text-[#868686]",
      indicator && "[&>.indicator]:bg-white dark:[&>.indicator]:bg-black"
    ]
  end

  defp color_variant("default", "primary", indicator) do
    [
      "bg-[#007F8C] text-white hover:bg-[#016974] dark:bg-[#01B8CA] ",
      "dark:text-black dark:hover:bg-[#77D5E3]",
      "disabled:bg-[#F3F3F3] disabled:text-[#BBBBBB]",
      "dark:disabled:bg-[#4B4B4B] dark:disabled:text-[#868686]",
      indicator && "[&>.indicator]:bg-[#1A535A] dark:[&>.indicator]:bg-[#B0E7EF]"
    ]
  end

  defp color_variant("default", "secondary", indicator) do
    [
      "bg-[#266EF1] text-white hover:bg-[#175BCC] dark:bg-[#6DAAFB]",
      "dark:text-black dark:hover:bg-[#A9C9FF]",
      "disabled:bg-[#F3F3F3] disabled:text-[#BBBBBB]",
      "dark:disabled:bg-[#4B4B4B] dark:disabled:text-[#868686]",
      indicator && "[&>.indicator]:bg-[#1948A3] dark:[&>.indicator]:bg-[#CDDEFF]"
    ]
  end

  defp color_variant("default", "success", indicator) do
    [
      "bg-[#0E8345] text-white hover:bg-[#166C3B] dark:bg-[#06C167]",
      "dark:text-black dark:hover:bg-[#7FD99A]",
      "disabled:bg-[#F3F3F3] disabled:text-[#BBBBBB]",
      "dark:disabled:bg-[#4B4B4B] dark:disabled:text-[#868686]",
      indicator && "[&>.indicator]:bg-[#047857] dark:[&>.indicator]:bg-[#B1EAC2]"
    ]
  end

  defp color_variant("default", "warning", indicator) do
    [
      "bg-[#CA8D01] text-white hover:bg-[#976A01] dark:bg-[#FDC034]",
      "dark:text-black dark:hover:bg-[#FDD067]",
      "disabled:bg-[#F3F3F3] disabled:text-[#BBBBBB]",
      "dark:disabled:bg-[#4B4B4B] dark:disabled:text-[#868686]",
      indicator && "[&>.indicator]:bg-[#FF8B08] dark:[&>.indicator]:bg-[#FEDF99]"
    ]
  end

  defp color_variant("default", "danger", indicator) do
    [
      "bg-[#DE1135] text-white hover:bg-[#BB032A] dark:bg-[#FC7F79]",
      "dark:text-black dark:hover:bg-[#FFB2AB]",
      "disabled:bg-[#F3F3F3] disabled:text-[#BBBBBB]",
      "dark:disabled:bg-[#4B4B4B] dark:disabled:text-[#868686]",
      indicator && "[&>.indicator]:bg-[#E73B3B] dark:[&>.indicator]:bg-[#FFD2CD]"
    ]
  end

  defp color_variant("default", "info", indicator) do
    [
      "bg-[#0B84BA] text-white hover:bg-[#08638C] dark:bg-[#3EB7ED]",
      "dark:text-black dark:hover:bg-[#6EC9F2]",
      "disabled:bg-[#F3F3F3] disabled:text-[#BBBBBB]",
      "dark:disabled:bg-[#4B4B4B] dark:disabled:text-[#868686]",
      indicator && "[&>.indicator]:bg-[#004FC4] dark:[&>.indicator]:bg-[#9FDBF6]"
    ]
  end

  defp color_variant("default", "misc", indicator) do
    [
      "bg-[#8750C5] text-white hover:bg-[#653C94] dark:bg-[#BA83F9]",
      "dark:text-black dark:hover:bg-[#CBA2FA]",
      "disabled:bg-[#F3F3F3] disabled:text-[#BBBBBB]",
      "dark:disabled:bg-[#4B4B4B] dark:disabled:text-[#868686]",
      indicator && "[&>.indicator]:bg-[#52059C] dark:[&>.indicator]:bg-[#DDC1FC]"
    ]
  end

  defp color_variant("default", "dawn", indicator) do
    [
      "bg-[#A86438] text-white hover:bg-[#7E4B2A] dark:bg-[#DB976B]",
      "dark:text-black dark:hover:bg-[#E4B190]",
      "disabled:bg-[#F3F3F3] disabled:text-[#BBBBBB]",
      "dark:disabled:bg-[#4B4B4B] dark:disabled:text-[#868686]",
      indicator && "[&>.indicator]:bg-[#4D4137] dark:[&>.indicator]:bg-[#EDCBB5]"
    ]
  end

  defp color_variant("default", "silver", indicator) do
    [
      "bg-[#868686] text-white hover:bg-[#727272] dark:bg-[#A6A6A6]",
      "dark:text-black dark:hover:bg-[#BBBBBB]",
      "disabled:bg-[#F3F3F3] disabled:text-[#BBBBBB]",
      "dark:disabled:bg-[#4B4B4B] dark:disabled:text-[#868686]",
      indicator && "[&>.indicator]:bg-[#707483] dark:[&>.indicator]:bg-[#DDDDDD]"
    ]
  end

  defp color_variant("outline", "natural", indicator) do
    [
      "bg-transparent text-[#4B4B4B] border-[#4B4B4B] hover:text-[#282828]",
      "hover:border-[#282828] dark:text-[#DDDDDD] dark:border-[#DDDDDD]",
      "dark:hover:text-[#E8E8E8] dark:hover:border-[#E8E8E8] disabled:text-[#DDDDDD]",
      "disabled:border-[#DDDDDD] dark:disabled:text-[#727272] dark:disabled:border-[#727272]",
      indicator && "[&>.indicator]:bg-black dark:[&>.indicator]:bg-white "
    ]
  end

  defp color_variant("outline", "primary", indicator) do
    [
      "bg-transparent text-[#007F8C] border-[#007F8C] hover:text-[#016974]",
      "hover:border-[#016974] dark:text-[#01B8CA] dark:border-[#01B8CA]",
      "dark:hover:text-[#77D5E3] dark:hover:border-[#77D5E3] disabled:text-[#DDDDDD]",
      "disabled:border-[#DDDDDD] dark:disabled:text-[#727272] dark:disabled:border-[#727272]",
      indicator && "[&>.indicator]:bg-[#1A535A] dark:[&>.indicator]:bg-[#B0E7EF]"
    ]
  end

  defp color_variant("outline", "secondary", indicator) do
    [
      "bg-transparent text-[#266EF1] border-[#266EF1] hover:text-[#175BCC]",
      "hover:border-[#175BCC] dark:text-[#6DAAFB] dark:border-[#6DAAFB]",
      "dark:hover:text-[#A9C9FF] dark:hover:border-[#A9C9FF] disabled:text-[#DDDDDD]",
      "disabled:border-[#DDDDDD] dark:disabled:text-[#727272] dark:disabled:border-[#727272]",
      indicator && "[&>.indicator]:bg-[#1948A3] dark:[&>.indicator]:bg-[#CDDEFF]"
    ]
  end

  defp color_variant("outline", "success", indicator) do
    [
      "bg-transparent text-[#0E8345] border-[#0E8345] hover:text-[#166C3B]",
      "hover:border-[#166C3B] dark:text-[#06C167] dark:border-[#06C167]",
      "dark:hover:text-[#7FD99A] dark:hover:border-[#7FD99A] disabled:text-[#DDDDDD]",
      "disabled:border-[#DDDDDD] dark:disabled:text-[#727272] dark:disabled:border-[#727272]",
      indicator && "[&>.indicator]:bg-[#0D572D] dark:[&>.indicator]:bg-[#B1EAC2]"
    ]
  end

  defp color_variant("outline", "warning", indicator) do
    [
      "bg-transparent text-[#CA8D01] border-[#CA8D01] hover:text-[#976A01]",
      "hover:border-[#976A01] dark:text-[#FDC034] dark:border-[#FDC034]",
      "dark:hover:text-[#FDD067] dark:hover:border-[#FDD067]  disabled:text-[#DDDDDD]",
      "disabled:border-[#DDDDDD] dark:disabled:text-[#727272] dark:disabled:border-[#727272]",
      indicator && "[&>.indicator]:bg-[#654600] dark:[&>.indicator]:bg-[#FEDF99]"
    ]
  end

  defp color_variant("outline", "danger", indicator) do
    [
      "bg-transparent text-[#DE1135] border-[#DE1135] hover:text-[#BB032A]",
      "hover:border-[#BB032A] dark:text-[#FC7F79] dark:border-[#FC7F79]",
      "dark:hover:text-[#FFB2AB] dark:hover:border-[#FFB2AB] disabled:text-[#DDDDDD]",
      "disabled:border-[#DDDDDD] dark:disabled:text-[#727272] dark:disabled:border-[#727272]",
      indicator && "[&>.indicator]:bg-[#950F22] dark:[&>.indicator]:bg-[#FFD2CD]"
    ]
  end

  defp color_variant("outline", "info", indicator) do
    [
      "bg-transparent text-[#0B84BA] border-[#0B84BA] hover:text-[#08638C]",
      "hover:border-[#08638C] dark:text-[#3EB7ED] dark:border-[#3EB7ED]",
      "dark:hover:text-[#6EC9F2] dark:hover:border-[#6EC9F2] disabled:text-[#DDDDDD]",
      "disabled:border-[#DDDDDD] dark:disabled:text-[#727272] dark:disabled:border-[#727272]",
      indicator && "[&>.indicator]:bg-[#06425D] dark:[&>.indicator]:bg-[#9FDBF6]"
    ]
  end

  defp color_variant("outline", "misc", indicator) do
    [
      "bg-transparent text-[#8750C5] border-[#8750C5] hover:text-[#653C94]",
      "hover:border-[#653C94] dark:text-[#BA83F9] dark:border-[#BA83F9]",
      "dark:hover:text-[#CBA2FA] dark:hover:border-[#CBA2FA] disabled:text-[#DDDDDD]",
      "disabled:border-[#DDDDDD] dark:disabled:text-[#727272] dark:disabled:border-[#727272]",
      indicator && "[&>.indicator]:bg-[#442863] dark:[&>.indicator]:bg-[#DDC1FC]"
    ]
  end

  defp color_variant("outline", "dawn", indicator) do
    [
      "bg-transparent text-[#A86438] border-[#A86438] hover:text-[#7E4B2A]",
      "hover:border-[#7E4B2A] dark:text-[#DB976B] dark:border-[#DB976B]",
      "dark:hover:text-[#E4B190] dark:hover:border-[#E4B190] disabled:text-[#DDDDDD]",
      "disabled:border-[#DDDDDD] dark:disabled:text-[#727272] dark:disabled:border-[#727272]",
      indicator && "[&>.indicator]:bg-[#54321C] dark:[&>.indicator]:bg-[#EDCBB5]"
    ]
  end

  defp color_variant("outline", "silver", indicator) do
    [
      "bg-transparent text-[#868686] border-[#868686] hover:text-[#727272]",
      "hover:border-[#727272] dark:text-[#A6A6A6] dark:border-[#A6A6A6]",
      "dark:hover:text-[#BBBBBB] dark:hover:border-[#BBBBBB] disabled:text-[#DDDDDD]",
      "disabled:border-[#DDDDDD] dark:disabled:text-[#727272] dark:disabled:border-[#727272]",
      indicator && "[&>.indicator]:bg-[#5E5E5E] dark:[&>.indicator]:bg-[#DDDDDD]"
    ]
  end

  defp color_variant("transparent", "natural", indicator) do
    [
      "bg-transparent text-[#4B4B4B] hover:text-[#282828]",
      "dark:text-[#DDDDDD] dark:hover:text-[#E8E8E8]",
      "disabled:text-[#DDDDDD] dark:disabled:text-[#727272]",
      indicator && "[&>.indicator]:bg-black dark:[&>.indicator]:bg-white"
    ]
  end

  defp color_variant("transparent", "primary", indicator) do
    [
      "bg-transparent text-[#007F8C] hover:text-[#016974]",
      "dark:text-[#01B8CA] dark:hover:text-[#77D5E3]",
      "disabled:text-[#DDDDDD] dark:disabled:text-[#727272]",
      indicator && "[&>.indicator]:bg-[#1A535A] dark:[&>.indicator]:bg-[#B0E7EF]"
    ]
  end

  defp color_variant("transparent", "secondary", indicator) do
    [
      "bg-transparent text-[#266EF1] hover:text-[#175BCC]",
      "dark:text-[#6DAAFB] dark:hover:text-[#A9C9FF]",
      "disabled:text-[#DDDDDD] dark:disabled:text-[#727272]",
      indicator && "[&>.indicator]:bg-[#1948A3] dark:[&>.indicator]:bg-[#CDDEFF]"
    ]
  end

  defp color_variant("transparent", "success", indicator) do
    [
      "bg-transparent text-[#0E8345] hover:text-[#166C3B]",
      "dark:text-[#06C167] dark:hover:text-[#7FD99A]",
      "disabled:text-[#DDDDDD] dark:disabled:text-[#727272]",
      indicator && "[&>.indicator]:bg-[#0D572D] dark:[&>.indicator]:bg-[#B1EAC2]"
    ]
  end

  defp color_variant("transparent", "warning", indicator) do
    [
      "bg-transparent text-[#CA8D01] hover:text-[#CA8D01]",
      "dark:text-[#FDC034] dark:hover:text-[#FDD067]",
      "disabled:text-[#DDDDDD] dark:disabled:text-[#727272]",
      indicator && "[&>.indicator]:bg-[#654600] dark:[&>.indicator]:bg-[#FEDF99]"
    ]
  end

  defp color_variant("transparent", "danger", indicator) do
    [
      "bg-transparent text-[#DE1135] hover:text-[#BB032A]",
      "dark:text-[#FC7F79] dark:hover:text-[#FFB2AB]",
      "disabled:text-[#DDDDDD] dark:disabled:text-[#727272]",
      indicator && "[&>.indicator]:bg-[#950F22] dark:[&>.indicator]:bg-[#FFD2CD]"
    ]
  end

  defp color_variant("transparent", "info", indicator) do
    [
      "bg-transparent text-[#0B84BA] hover:text-[#08638C]",
      "dark:text-[#3EB7ED] dark:hover:text-[#6EC9F2]",
      "disabled:text-[#DDDDDD] dark:disabled:text-[#727272]",
      indicator && "[&>.indicator]:bg-[#06425D] dark:[&>.indicator]:bg-[#9FDBF6]"
    ]
  end

  defp color_variant("transparent", "misc", indicator) do
    [
      "bg-transparent text-[#8750C5] hover:text-[#653C94]",
      "dark:text-[#BA83F9] dark:hover:text-[#CBA2FA]",
      "disabled:text-[#DDDDDD] dark:disabled:text-[#727272]",
      indicator && "[&>.indicator]:bg-[#442863] dark:[&>.indicator]:bg-[#DDC1FC]"
    ]
  end

  defp color_variant("transparent", "dawn", indicator) do
    [
      "bg-transparent text-[#A86438] hover:text-[#7E4B2A]",
      "dark:text-[#DB976B] dark:hover:text-[#E4B190]",
      "disabled:text-[#DDDDDD] dark:disabled:text-[#727272]",
      indicator && "[&>.indicator]:bg-[#54321C] dark:[&>.indicator]:bg-[#EDCBB5]"
    ]
  end

  defp color_variant("transparent", "silver", indicator) do
    [
      "bg-transparent text-[#868686] hover:text-[#727272]",
      "dark:text-[#A6A6A6] dark:hover:text-[#BBBBBB]",
      "disabled:text-[#DDDDDD] dark:disabled:text-[#727272]",
      indicator && "[&>.indicator]:bg-[#5E5E5E] dark:[&>.indicator]:bg-[#DDDDDD]"
    ]
  end

  defp color_variant("subtle", "natural", indicator) do
    [
      "bg-transparent text-[#4B4B4B] hover:text-[#282828] hover:bg-[#F3F3F3]",
      "dark:text-[#DDDDDD] dark:hover:text-[#E8E8E8] dark:hover:bg-[#4B4B4B]",
      "disabled:text-[#DDDDDD] dark:disabled:text-[#727272]",
      "disabled:hover:bg-transparent dark:disabled:hover:bg-transparent",
      indicator && "[&>.indicator]:bg-black dark:[&>.indicator]:bg-white"
    ]
  end

  defp color_variant("subtle", "primary", indicator) do
    [
      "bg-transparent text-[#007F8C] hover:text-[#016974] hover:bg-[#E2F8FB]",
      "dark:text-[#01B8CA] dark:hover:text-[#77D5E3] dark:hover:bg-[#002D33]",
      "disabled:text-[#DDDDDD] dark:disabled:text-[#727272]",
      "disabled:hover:bg-transparent dark:disabled:hover:bg-transparent",
      indicator && "[&>.indicator]:bg-[#1A535A] dark:[&>.indicator]:bg-[#B0E7EF]"
    ]
  end

  defp color_variant("subtle", "secondary", indicator) do
    [
      "bg-transparent text-[#266EF1] hover:text-[#175BCC] hover:bg-[#EFF4FE]",
      "dark:text-[#6DAAFB] dark:hover:text-[#A9C9FF] dark:hover:bg-[#002661]",
      "disabled:text-[#DDDDDD] dark:disabled:text-[#727272]",
      "disabled:hover:bg-transparent dark:disabled:hover:bg-transparent",
      indicator && "[&>.indicator]:bg-[#1948A3] dark:[&>.indicator]:bg-[#CDDEFF]"
    ]
  end

  defp color_variant("subtle", "success", indicator) do
    [
      "bg-transparent text-[#0E8345] hover:text-[#166C3B] hover:bg-[#EAF6ED]",
      "dark:text-[#06C167] dark:hover:text-[#7FD99A] dark:hover:bg-[#002F14]",
      "disabled:text-[#DDDDDD] dark:disabled:text-[#727272]",
      "disabled:hover:bg-transparent dark:disabled:hover:bg-transparent",
      indicator && "[&>.indicator]:bg-[#0D572D] dark:[&>.indicator]:bg-[#B1EAC2]"
    ]
  end

  defp color_variant("subtle", "warning", indicator) do
    [
      "bg-transparent text-[#CA8D01] hover:text-[#CA8D01] hover:bg-[#FFF7E6]",
      "dark:text-[#FDC034] dark:hover:text-[#FDD067] dark:hover:bg-[#322300]",
      "disabled:text-[#DDDDDD] dark:disabled:text-[#727272]",
      "disabled:hover:bg-transparent dark:disabled:hover:bg-transparent",
      indicator && "[&>.indicator]:bg-[#654600] dark:[&>.indicator]:bg-[#FEDF99]"
    ]
  end

  defp color_variant("subtle", "danger", indicator) do
    [
      "bg-transparent text-[#DE1135] hover:text-[#BB032A] hover:bg-[#FFF0EE]",
      "dark:text-[#FC7F79] dark:hover:text-[#FFB2AB] dark:hover:bg-[#520810]",
      "disabled:text-[#DDDDDD] dark:disabled:text-[#727272]",
      "disabled:hover:bg-transparent dark:disabled:hover:bg-transparent",
      indicator && "[&>.indicator]:bg-[#950F22] dark:[&>.indicator]:bg-[#FFD2CD]"
    ]
  end

  defp color_variant("subtle", "info", indicator) do
    [
      "bg-transparent text-[#0B84BA] hover:text-[#08638C] hover:bg-[#E7F6FD]",
      "dark:text-[#3EB7ED] dark:hover:text-[#6EC9F2] dark:hover:bg-[#03212F]",
      "disabled:text-[#DDDDDD] dark:disabled:text-[#727272]",
      "disabled:hover:bg-transparent dark:disabled:hover:bg-transparent",
      indicator && "[&>.indicator]:bg-[#06425D] dark:[&>.indicator]:bg-[#9FDBF6]"
    ]
  end

  defp color_variant("subtle", "misc", indicator) do
    [
      "bg-transparent text-[#8750C5] hover:text-[#653C94] hover:bg-[#F6F0FE]",
      "dark:text-[#BA83F9] dark:hover:text-[#CBA2FA] dark:hover:bg-[#221431]",
      "disabled:text-[#DDDDDD] dark:disabled:text-[#727272]",
      "disabled:hover:bg-transparent dark:disabled:hover:bg-transparent",
      indicator && "[&>.indicator]:bg-[#442863] dark:[&>.indicator]:bg-[#DDC1FC]"
    ]
  end

  defp color_variant("subtle", "dawn", indicator) do
    [
      "bg-transparent text-[#A86438] hover:text-[#7E4B2A] hover:bg-[#FBF2ED]",
      "dark:text-[#DB976B] dark:hover:text-[#E4B190] dark:hover:bg-[#2A190E]",
      "disabled:text-[#DDDDDD] dark:disabled:text-[#727272]",
      "disabled:hover:bg-transparent dark:disabled:hover:bg-transparent",
      indicator && "[&>.indicator]:bg-[#54321C] dark:[&>.indicator]:bg-[#EDCBB5]"
    ]
  end

  defp color_variant("subtle", "silver", indicator) do
    [
      "bg-transparent text-[#868686] hover:text-[#727272] hover:bg-[#F3F3F3]",
      "dark:text-[#A6A6A6] dark:hover:text-[#BBBBBB] dark:hover:bg-[#4B4B4B]",
      "disabled:text-[#DDDDDD] dark:disabled:text-[#727272]",
      "disabled:hover:bg-transparent dark:disabled:hover:bg-transparent",
      indicator && "[&>.indicator]:bg-[#5E5E5E] dark:[&>.indicator]:bg-[#DDDDDD]"
    ]
  end

  defp color_variant("bordered", "natural", indicator) do
    [
      "bg-white dark:bg-[#282828] text-[#4B4B4B] border-[#4B4B4B] hover:text-[#282828]",
      "hover:border-[#282828] dark:text-[#DDDDDD] dark:border-[#DDDDDD]",
      "dark:hover:text-[#E8E8E8] dark:hover:border-[#E8E8E8] disabled:text-[#DDDDDD]",
      "disabled:border-[#DDDDDD] dark:disabled:text-[#727272] dark:disabled:border-[#727272]",
      indicator && "[&>.indicator]:bg-black dark:[&>.indicator]:bg-white"
    ]
  end

  defp color_variant("bordered", "primary", indicator) do
    [
      "bg-white dark:bg-[#282828] text-[#007F8C] border-[#007F8C] hover:text-[#016974]",
      "hover:border-[#016974] dark:text-[#01B8CA] dark:border-[#01B8CA]",
      "dark:hover:text-[#77D5E3] dark:hover:border-[#77D5E3] disabled:text-[#DDDDDD]",
      "disabled:border-[#DDDDDD] dark:disabled:text-[#727272] dark:disabled:border-[#727272]",
      indicator && "[&>.indicator]:bg-[#1A535A] dark:[&>.indicator]:bg-[#B0E7EF]"
    ]
  end

  defp color_variant("bordered", "secondary", indicator) do
    [
      "bg-white dark:bg-[#282828] text-[#266EF1] border-[#266EF1] hover:text-[#175BCC]",
      "hover:border-[#175BCC] dark:text-[#6DAAFB] dark:border-[#6DAAFB]",
      "dark:hover:text-[#A9C9FF] dark:hover:border-[#A9C9FF] disabled:text-[#DDDDDD]",
      " disabled:border-[#DDDDDD] dark:disabled:text-[#727272] dark:disabled:border-[#727272]",
      indicator && "[&>.indicator]:bg-[#1948A3] dark:[&>.indicator]:bg-[#CDDEFF]"
    ]
  end

  defp color_variant("bordered", "success", indicator) do
    [
      "bg-white dark:bg-[#282828] text-[#0E8345] border-[#0E8345] hover:text-[#166C3B]",
      "hover:border-[#166C3B] dark:text-[#06C167] dark:border-[#06C167]",
      "dark:hover:text-[#7FD99A] dark:hover:border-[#7FD99A] disabled:text-[#DDDDDD]",
      "disabled:border-[#DDDDDD] dark:disabled:text-[#727272] dark:disabled:border-[#727272]",
      indicator && "[&>.indicator]:bg-[#0D572D] dark:[&>.indicator]:bg-[#B1EAC2]"
    ]
  end

  defp color_variant("bordered", "warning", indicator) do
    [
      "bg-white dark:bg-[#282828] text-[#CA8D01] border-[#CA8D01] hover:text-[#976A01]",
      "hover:border-[#976A01] dark:text-[#FDC034] dark:border-[#FDC034]",
      "dark:hover:text-[#FDD067] dark:hover:border-[#FDD067] disabled:text-[#DDDDDD]",
      "disabled:border-[#DDDDDD] dark:disabled:text-[#727272] dark:disabled:border-[#727272]",
      indicator && "[&>.indicator]:bg-[#654600] dark:[&>.indicator]:bg-[#FEDF99]"
    ]
  end

  defp color_variant("bordered", "danger", indicator) do
    [
      "bg-white dark:bg-[#282828] text-[#DE1135] border-[#DE1135] hover:text-[#BB032A]",
      "hover:border-[#BB032A] dark:text-[#FC7F79] dark:border-[#FC7F79]",
      "dark:hover:text-[#FFB2AB] dark:hover:border-[#FFB2AB] disabled:text-[#DDDDDD]",
      "disabled:border-[#DDDDDD] dark:disabled:text-[#727272] dark:disabled:border-[#727272]",
      indicator && "[&>.indicator]:bg-[#950F22] dark:[&>.indicator]:bg-[#FFD2CD]"
    ]
  end

  defp color_variant("bordered", "info", indicator) do
    [
      "bg-white dark:bg-[#282828] text-[#0B84BA] border-[#0B84BA] hover:text-[#0B84BA]",
      "hover:border-[#0B84BA] dark:text-[#3EB7ED] dark:border-[#3EB7ED]",
      "dark:hover:text-[#6EC9F2] dark:hover:border-[#6EC9F2] disabled:text-[#DDDDDD]",
      "disabled:border-[#DDDDDD] dark:disabled:text-[#727272] dark:disabled:border-[#727272]",
      indicator && "[&>.indicator]:bg-[#06425D] dark:[&>.indicator]:bg-[#9FDBF6]"
    ]
  end

  defp color_variant("bordered", "misc", indicator) do
    [
      "bg-white dark:bg-[#282828] text-[#8750C5] border-[#8750C5] hover:text-[#653C94]",
      "hover:border-[#653C94] dark:text-[#BA83F9] dark:border-[#BA83F9]",
      "dark:hover:text-[#CBA2FA] dark:hover:border-[#CBA2FA] disabled:text-[#DDDDDD]",
      "disabled:border-[#DDDDDD] dark:disabled:text-[#727272] dark:disabled:border-[#727272]",
      indicator && "[&>.indicator]:bg-[#442863] dark:[&>.indicator]:bg-[#DDC1FC]"
    ]
  end

  defp color_variant("bordered", "dawn", indicator) do
    [
      "bg-white dark:bg-[#282828] text-[#A86438] border-[#A86438] hover:text-[#7E4B2A]",
      "hover:border-[#7E4B2A] dark:text-[#DB976B] dark:border-[#DB976B]",
      "dark:hover:text-[#E4B190] dark:hover:border-[#E4B190] disabled:text-[#DDDDDD]",
      "disabled:border-[#DDDDDD] dark:disabled:text-[#727272] dark:disabled:border-[#727272]",
      indicator && "[&>.indicator]:bg-[#54321C] dark:[&>.indicator]:bg-[#EDCBB5]"
    ]
  end

  defp color_variant("bordered", "silver", indicator) do
    [
      "bg-white dark:bg-[#282828] text-[#868686] border-[#868686] hover:text-[#727272]",
      "hover:border-[#727272] dark:text-[#A6A6A6] dark:border-[#A6A6A6]",
      "dark:hover:text-[#BBBBBB] dark:hover:border-[#BBBBBB] disabled:text-[#DDDDDD]",
      "disabled:border-[#DDDDDD] dark:disabled:text-[#727272] dark:disabled:border-[#727272]",
      indicator && "[&>.indicator]:bg-[#5E5E5E] dark:[&>.indicator]:bg-[#DDDDDD]"
    ]
  end

  defp color_variant("shadow", "natural", indicator) do
    [
      "bg-[#4B4B4B] text-white hover:bg-[#282828] dark:bg-[#DDDDDD]",
      "dark:text-black dark:hover:bg-[#E8E8E8] disabled:bg-[#F3F3F3] disabled:text-[#BBBBBB]",
      "dark:disabled:bg-[#4B4B4B] dark:disabled:text-[#868686]",
      "shadow-[0px_4px_6px_-4px_rgba(134,134,134,0.5)] shadow-[0px_10px_15px_-3px_rgba(134,134,134,0.5)] dark:shadow-none",
      indicator && "[&>.indicator]:bg-white dark:[&>.indicator]:bg-black"
    ]
  end

  defp color_variant("shadow", "primary", indicator) do
    [
      "bg-[#007F8C] text-white hover:bg-[#016974] dark:bg-[#01B8CA]",
      "dark:text-black dark:hover:bg-[#77D5E3] disabled:bg-[#F3F3F3] disabled:text-[#BBBBBB]",
      "dark:disabled:bg-[#4B4B4B] dark:disabled:text-[#868686]",
      "shadow-[0px_4px_6px_-4px_rgba(0,149,164,0.5)] shadow-[0px_10px_15px_-3px_rgba(0,149,164,0.5)] dark:shadow-none",
      indicator && "[&>.indicator]:bg-[#1A535A] dark:[&>.indicator]:bg-[#B0E7EF]"
    ]
  end

  defp color_variant("shadow", "secondary", indicator) do
    [
      "bg-[#266EF1] text-white hover:bg-[#175BCC] dark:bg-[#6DAAFB]",
      "dark:text-black dark:hover:bg-[#A9C9FF] disabled:bg-[#F3F3F3] disabled:text-[#BBBBBB]",
      "dark:disabled:bg-[#4B4B4B] dark:disabled:text-[#868686]",
      "shadow-[0px_4px_6px_-4px_rgba(6,139,238,0.5)] shadow-[0px_10px_15px_-3px_rgba(6,139,238,0.5)] dark:shadow-none",
      indicator && "[&>.indicator]:bg-[#1948A3] dark:[&>.indicator]:bg-[#CDDEFF]"
    ]
  end

  defp color_variant("shadow", "success", indicator) do
    [
      "bg-[#0E8345] text-white hover:bg-[#166C3B] dark:bg-[#06C167]",
      "dark:text-black dark:hover:bg-[#7FD99A] disabled:bg-[#F3F3F3] disabled:text-[#BBBBBB]",
      "dark:disabled:bg-[#4B4B4B] dark:disabled:text-[#868686]",
      "shadow-[0px_4px_6px_-4px_rgba(0,154,81,0.5)] shadow-[0px_10px_15px_-3px_rgba(0,154,81,0.5)] dark:shadow-none",
      indicator && "[&>.indicator]:bg-[#047857] dark:[&>.indicator]:bg-[#B1EAC2]"
    ]
  end

  defp color_variant("shadow", "warning", indicator) do
    [
      "bg-[#CA8D01] text-white hover:bg-[#976A01] dark:bg-[#FDC034]",
      "dark:text-black dark:hover:bg-[#FDD067] disabled:bg-[#F3F3F3] disabled:text-[#BBBBBB]",
      "dark:disabled:bg-[#4B4B4B] dark:disabled:text-[#868686]",
      "shadow-[0px_4px_6px_-4px_rgba(252,176,1,0.5)] shadow-[0px_10px_15px_-3px_rgba(252,176,1,0.5)] dark:shadow-none",
      indicator && "[&>.indicator]:bg-[#FF8B08] dark:[&>.indicator]:bg-[#FEDF99]"
    ]
  end

  defp color_variant("shadow", "danger", indicator) do
    [
      "bg-[#DE1135] text-white hover:bg-[#BB032A] dark:bg-[#FC7F79]",
      "dark:text-black dark:hover:bg-[#FFB2AB] disabled:bg-[#F3F3F3] disabled:text-[#BBBBBB]",
      "dark:disabled:bg-[#4B4B4B] dark:disabled:text-[#868686]",
      "shadow-[0px_4px_6px_-4px_rgba(248,52,70,0.5)] shadow-[0px_10px_15px_-3px_rgba(248,52,70,0.5)] dark:shadow-none",
      indicator && "[&>.indicator]:bg-[#E73B3B] dark:[&>.indicator]:bg-[#FFD2CD]"
    ]
  end

  defp color_variant("shadow", "info", indicator) do
    [
      "bg-[#0B84BA] text-white hover:bg-[#08638C] dark:bg-[#3EB7ED]",
      "dark:text-black dark:hover:bg-[#6EC9F2] disabled:bg-[#F3F3F3] disabled:text-[#BBBBBB]",
      "dark:disabled:bg-[#4B4B4B] dark:disabled:text-[#868686]",
      "shadow-[0px_4px_6px_-4px_rgba(14,165,233,0.5)] shadow-[0px_10px_15px_-3px_rgba(14,165,233,0.5)] dark:shadow-none",
      indicator && "[&>.indicator]:bg-[#004FC4] dark:[&>.indicator]:bg-[#9FDBF6]"
    ]
  end

  defp color_variant("shadow", "misc", indicator) do
    [
      "bg-[#8750C5] text-white hover:bg-[#653C94] dark:bg-[#BA83F9]",
      "dark:text-black dark:hover:bg-[#CBA2FA] disabled:bg-[#F3F3F3] disabled:text-[#BBBBBB]",
      "dark:disabled:bg-[#4B4B4B] dark:disabled:text-[#868686]",
      "shadow-[0px_4px_6px_-4px_rgba(169,100,247,0.5)] shadow-[0px_10px_15px_-3px_rgba(169,100,247,0.5)] dark:shadow-none",
      indicator && "[&>.indicator]:bg-[#52059C] dark:[&>.indicator]:bg-[#DDC1FC]"
    ]
  end

  defp color_variant("shadow", "dawn", indicator) do
    [
      "bg-[#A86438] text-white hover:bg-[#7E4B2A] dark:bg-[#DB976B]",
      "dark:text-black dark:hover:bg-[#E4B190] disabled:bg-[#F3F3F3] disabled:text-[#BBBBBB]",
      "dark:disabled:bg-[#4B4B4B] dark:disabled:text-[#868686]",
      "shadow-[0px_4px_6px_-4px_rgba(210,125,70,0.5)] shadow-[0px_10px_15px_-3px_rgba(210,125,70,0.5)] dark:shadow-none",
      indicator && "[&>.indicator]:bg-[#4D4137] dark:[&>.indicator]:bg-[#EDCBB5]"
    ]
  end

  defp color_variant("shadow", "silver", indicator) do
    [
      "bg-[#868686] text-white hover:bg-[#727272] dark:bg-[#A6A6A6]",
      "dark:text-black dark:hover:bg-[#BBBBBB] disabled:bg-[#F3F3F3] disabled:text-[#BBBBBB]",
      "dark:disabled:bg-[#4B4B4B] dark:disabled:text-[#868686]",
      "shadow-[0px_4px_6px_-4px_rgba(134,134,134,0.5)] shadow-[0px_10px_15px_-3px_rgba(134,134,134,0.5)] dark:shadow-none",
      indicator && "[&>.indicator]:bg-[#707483] dark:[&>.indicator]:bg-[#DDDDDD]"
    ]
  end

  defp color_variant("inverted", "natural", indicator) do
    [
      "bg-transparent text-[#4B4B4B] border-[#4B4B4B] hover:text-[#282828]",
      "hover:border-[#282828] hover:bg-[#F3F3F3]",
      "dark:text-[#DDDDDD] dark:border-[#DDDDDD] dark:hover:text-[#E8E8E8]",
      "dark:hover:border-[#E8E8E8] dark:hover:bg-[#4B4B4B] disabled:text-[#DDDDDD]",
      "disabled:border-[#DDDDDD] dark:disabled:text-[#727272] dark:disabled:border-[#727272]",
      "disabled:hover:bg-transparent dark:disabled:hover:bg-transparent",
      indicator && "[&>.indicator]:bg-black dark:[&>.indicator]:bg-white"
    ]
  end

  defp color_variant("inverted", "primary", indicator) do
    [
      "bg-transparent text-[#007F8C] border-[#007F8C] hover:text-[#016974]",
      "hover:border-[#016974] hover:bg-[#E2F8FB]",
      "dark:text-[#01B8CA] dark:border-[#01B8CA] dark:hover:text-[#77D5E3]",
      "dark:hover:border-[#77D5E3] dark:hover:bg-[#002D33] disabled:text-[#DDDDDD]",
      "disabled:border-[#DDDDDD] dark:disabled:text-[#727272] dark:disabled:border-[#727272]",
      "disabled:hover:bg-transparent dark:disabled:hover:bg-transparent",
      indicator && "[&>.indicator]:bg-[#1A535A] dark:[&>.indicator]:bg-[#B0E7EF]"
    ]
  end

  defp color_variant("inverted", "secondary", indicator) do
    [
      "bg-transparent text-[#266EF1] border-[#266EF1] hover:text-[#175BCC]",
      "hover:border-[#175BCC] hover:bg-[#EFF4FE]",
      "dark:text-[#6DAAFB] dark:border-[#6DAAFB] dark:hover:text-[#A9C9FF]",
      "dark:hover:border-[#A9C9FF] dark:hover:bg-[#002661] disabled:text-[#DDDDDD]",
      " disabled:border-[#DDDDDD] dark:disabled:text-[#727272] dark:disabled:border-[#727272]",
      "disabled:hover:bg-transparent dark:disabled:hover:bg-transparent",
      indicator && "[&>.indicator]:bg-[#1948A3] dark:[&>.indicator]:bg-[#CDDEFF]"
    ]
  end

  defp color_variant("inverted", "success", indicator) do
    [
      "bg-transparent text-[#0E8345] border-[#0E8345] hover:text-[#166C3B]",
      "hover:border-[#166C3B] hover:bg-[#EAF6ED]",
      "dark:text-[#06C167] dark:border-[#06C167] dark:hover:text-[#7FD99A]",
      "dark:hover:border-[#7FD99A] dark:hover:bg-[#002F14] disabled:text-[#DDDDDD]",
      "disabled:border-[#DDDDDD] dark:disabled:text-[#727272] dark:disabled:border-[#727272]",
      "disabled:hover:bg-transparent dark:disabled:hover:bg-transparent",
      indicator && "[&>.indicator]:bg-[#0D572D] dark:[&>.indicator]:bg-[#B1EAC2]"
    ]
  end

  defp color_variant("inverted", "warning", indicator) do
    [
      "bg-transparent text-[#CA8D01] border-[#CA8D01] hover:text-[#976A01]",
      "hover:border-[#976A01] hover:bg-[#FFF7E6]",
      "dark:text-[#FDC034] dark:border-[#FDC034] dark:hover:text-[#FDD067]",
      "dark:hover:border-[#FDD067] dark:hover:bg-[#322300] disabled:text-[#DDDDDD]",
      "disabled:border-[#DDDDDD] dark:disabled:text-[#727272] dark:disabled:border-[#727272]",
      "disabled:hover:bg-transparent dark:disabled:hover:bg-transparent",
      indicator && "[&>.indicator]:bg-[#654600] dark:[&>.indicator]:bg-[#FEDF99]"
    ]
  end

  defp color_variant("inverted", "danger", indicator) do
    [
      "bg-transparent text-[#DE1135] border-[#DE1135] hover:text-[#BB032A]",
      "hover:border-[#BB032A] hover:bg-[#FFF0EE]",
      "dark:text-[#FC7F79] dark:border-[#FC7F79] dark:hover:text-[#FFB2AB]",
      "dark:hover:border-[#FFB2AB] dark:hover:bg-[#520810] disabled:text-[#DDDDDD]",
      "disabled:border-[#DDDDDD] dark:disabled:text-[#727272] dark:disabled:border-[#727272]",
      "disabled:hover:bg-transparent dark:disabled:hover:bg-transparent",
      indicator && "[&>.indicator]:bg-[#950F22] dark:[&>.indicator]:bg-[#FFD2CD]"
    ]
  end

  defp color_variant("inverted", "info", indicator) do
    [
      "bg-transparent text-[#0B84BA] border-[#0B84BA] hover:text-[#0B84BA]",
      "hover:border-[#0B84BA] hover:bg-[#E7F6FD]",
      "dark:text-[#3EB7ED] dark:border-[#3EB7ED] dark:hover:text-[#6EC9F2]",
      "dark:hover:border-[#6EC9F2] dark:hover:bg-[#03212F] disabled:text-[#DDDDDD]",
      "disabled:border-[#DDDDDD] dark:disabled:text-[#727272] dark:disabled:border-[#727272]",
      "disabled:hover:bg-transparent dark:disabled:hover:bg-transparent",
      indicator && "[&>.indicator]:bg-[#06425D] dark:[&>.indicator]:bg-[#9FDBF6]"
    ]
  end

  defp color_variant("inverted", "misc", indicator) do
    [
      "bg-transparent text-[#8750C5] border-[#8750C5] hover:text-[#653C94]",
      "hover:border-[#653C94] hover:bg-[#F6F0FE]",
      "dark:text-[#BA83F9] dark:border-[#BA83F9] dark:hover:text-[#CBA2FA]",
      "dark:hover:border-[#CBA2FA] dark:hover:bg-[#221431] disabled:text-[#DDDDDD]",
      "disabled:border-[#DDDDDD] dark:disabled:text-[#727272] dark:disabled:border-[#727272]",
      "disabled:hover:bg-transparent dark:disabled:hover:bg-transparent",
      indicator && "[&>.indicator]:bg-[#442863] dark:[&>.indicator]:bg-[#DDC1FC]"
    ]
  end

  defp color_variant("inverted", "dawn", indicator) do
    [
      "bg-transparent text-[#A86438] border-[#A86438] hover:text-[#7E4B2A]",
      "hover:border-[#7E4B2A] hover:bg-[#FBF2ED]",
      "dark:text-[#DB976B] dark:border-[#DB976B] dark:hover:text-[#E4B190]",
      "dark:hover:border-[#E4B190] dark:hover:bg-[#2A190E] disabled:text-[#DDDDDD]",
      "disabled:border-[#DDDDDD] dark:disabled:text-[#727272] dark:disabled:border-[#727272]",
      "disabled:hover:bg-transparent dark:disabled:hover:bg-transparent",
      indicator && "[&>.indicator]:bg-[#54321C] dark:[&>.indicator]:bg-[#EDCBB5]"
    ]
  end

  defp color_variant("inverted", "silver", indicator) do
    [
      "bg-transparent text-[#868686] border-[#868686] hover:text-[#727272]",
      "hover:border-[#727272] hover:bg-[#F3F3F3]",
      "dark:text-[#A6A6A6] dark:border-[#A6A6A6] dark:hover:text-[#BBBBBB]",
      "dark:hover:border-[#BBBBBB] dark:hover:bg-[#4B4B4B] disabled:text-[#DDDDDD]",
      "disabled:border-[#DDDDDD] dark:disabled:text-[#727272] dark:disabled:border-[#727272]",
      "disabled:hover:bg-transparent dark:disabled:hover:bg-transparent",
      indicator && "[&>.indicator]:bg-[#5E5E5E] dark:[&>.indicator]:bg-[#DDDDDD]"
    ]
  end

  defp color_variant("default_gradient", "natural", indicator) do
    [
      "bg-gradient-to-br hover:bg-gradient-to-bl",
      "from-[#282828] to-[#727272] text-white",
      "dark:from-[#A6A6A6] dark:to-[#FFFFFF] dark:text-black",
      "disabled:text-[#BBBBBB] dark:disabled:bg-[#4B4B4B] dark:disabled:text-[#868686]",
      "disabled:from-[#F3F3F3] disabled:to-[#F3F3F3]",
      "dark:disabled:from-[#4B4B4B] dark:disabled:to-[#4B4B4B]",
      indicator && "[&>.indicator]:bg-white dark:[&>.indicator]:bg-black"
    ]
  end

  defp color_variant("default_gradient", "primary", indicator) do
    [
      "bg-gradient-to-br hover:bg-gradient-to-bl",
      "from-[#016974] to-[#01B8CA] text-white",
      "dark:from-[#01B8CA] dark:to-[#B0E7EF] dark:text-black",
      "disabled:text-[#BBBBBB] dark:disabled:bg-[#4B4B4B] dark:disabled:text-[#868686]",
      "disabled:from-[#F3F3F3] disabled:to-[#F3F3F3]",
      "dark:disabled:from-[#4B4B4B] dark:disabled:to-[#4B4B4B]",
      indicator && "[&>.indicator]:bg-[#1A535A] dark:[&>.indicator]:bg-[#CDEEF3]"
    ]
  end

  defp color_variant("default_gradient", "secondary", indicator) do
    [
      "bg-gradient-to-br hover:bg-gradient-to-bl",
      "from-[#175BCC] to-[#6DAAFB] text-white",
      "dark:from-[#6DAAFB] dark:to-[#CDDEFF] dark:text-black",
      "disabled:text-[#BBBBBB] dark:disabled:bg-[#4B4B4B] dark:disabled:text-[#868686]",
      "disabled:from-[#F3F3F3] disabled:to-[#F3F3F3]",
      "dark:disabled:from-[#4B4B4B] dark:disabled:to-[#4B4B4B]",
      indicator && "[&>.indicator]:bg-[#1948A3] dark:[&>.indicator]:bg-[#DEE9FE]"
    ]
  end

  defp color_variant("default_gradient", "success", indicator) do
    [
      "bg-gradient-to-br hover:bg-gradient-to-bl",
      "from-[#166C3B] to-[#06C167] text-white",
      "dark:from-[#06C167] dark:to-[#B1EAC2] dark:text-black",
      "disabled:text-[#BBBBBB] dark:disabled:bg-[#4B4B4B] dark:disabled:text-[#868686]",
      "disabled:from-[#F3F3F3] disabled:to-[#F3F3F3]",
      "dark:disabled:from-[#4B4B4B] dark:disabled:to-[#4B4B4B]",
      indicator && "[&>.indicator]:bg-[#0D572D] dark:[&>.indicator]:bg-[#D3EFDA]"
    ]
  end

  defp color_variant("default_gradient", "warning", indicator) do
    [
      "bg-gradient-to-br hover:bg-gradient-to-bl",
      "from-[#976A01] to-[#FDC034] text-white",
      "dark:from-[#FDC034] dark:to-[#FEDF99] dark:text-black",
      "disabled:text-[#BBBBBB] dark:disabled:bg-[#4B4B4B] dark:disabled:text-[#868686]",
      "disabled:from-[#F3F3F3] disabled:to-[#F3F3F3]",
      "dark:disabled:from-[#4B4B4B] dark:disabled:to-[#4B4B4B]",
      indicator && "[&>.indicator]:bg-[#654600] dark:[&>.indicator]:bg-[#FEEFCC]"
    ]
  end

  defp color_variant("default_gradient", "danger", indicator) do
    [
      "bg-gradient-to-br hover:bg-gradient-to-bl",
      "from-[#BB032A] to-[#FC7F79] text-white",
      "dark:from-[#FC7F79] dark:to-[#FFD2CD] dark:text-black",
      "disabled:text-[#BBBBBB] dark:disabled:bg-[#4B4B4B] dark:disabled:text-[#868686]",
      "disabled:from-[#F3F3F3] disabled:to-[#F3F3F3]",
      "dark:disabled:from-[#4B4B4B] dark:disabled:to-[#4B4B4B]",
      indicator && "[&>.indicator]:bg-[#950F22] dark:[&>.indicator]:bg-[#FFE1DE]"
    ]
  end

  defp color_variant("default_gradient", "info", indicator) do
    [
      "bg-gradient-to-br hover:bg-gradient-to-bl",
      "from-[#08638C] to-[#3EB7ED] text-white",
      "dark:from-[#3EB7ED] dark:to-[#9FDBF6] dark:text-black",
      "disabled:text-[#BBBBBB] dark:disabled:bg-[#4B4B4B] dark:disabled:text-[#868686]",
      "disabled:from-[#F3F3F3] disabled:to-[#F3F3F3]",
      "dark:disabled:from-[#4B4B4B] dark:disabled:to-[#4B4B4B]",
      indicator && "[&>.indicator]:bg-[#06425D] dark:[&>.indicator]:bg-[#CFEDFB]"
    ]
  end

  defp color_variant("default_gradient", "misc", indicator) do
    [
      "bg-gradient-to-br hover:bg-gradient-to-bl",
      "from-[#653C94] to-[#BA83F9] text-white",
      "dark:from-[#BA83F9] dark:to-[#DDC1FC] dark:text-black",
      "disabled:text-[#BBBBBB] dark:disabled:bg-[#4B4B4B] dark:disabled:text-[#868686]",
      "disabled:from-[#F3F3F3] disabled:to-[#F3F3F3]",
      "dark:disabled:from-[#4B4B4B] dark:disabled:to-[#4B4B4B]",
      indicator && "[&>.indicator]:bg-[#442863] dark:[&>.indicator]:bg-[#EEE0FD]"
    ]
  end

  defp color_variant("default_gradient", "dawn", indicator) do
    [
      "bg-gradient-to-br hover:bg-gradient-to-bl",
      "from-[#7E4B2A] to-[#DB976B] text-white",
      "dark:from-[#DB976B] dark:to-[#EDCBB5] dark:text-black",
      "disabled:text-[#BBBBBB] dark:disabled:bg-[#4B4B4B] dark:disabled:text-[#868686]",
      "disabled:from-[#F3F3F3] disabled:to-[#F3F3F3]",
      "dark:disabled:from-[#4B4B4B] dark:disabled:to-[#4B4B4B]",
      indicator && "[&>.indicator]:bg-[#54321C] dark:[&>.indicator]:bg-[#F6E5DA]"
    ]
  end

  defp color_variant("default_gradient", "silver", indicator) do
    [
      "bg-gradient-to-br hover:bg-gradient-to-bl",
      "from-[#5E5E5E] to-[#A6A6A6] text-white",
      "dark:from-[#868686] dark:to-[#BBBBBB] dark:text-black",
      "disabled:text-[#BBBBBB] dark:disabled:bg-[#4B4B4B] dark:disabled:text-[#868686]",
      "disabled:from-[#F3F3F3] disabled:to-[#F3F3F3]",
      "dark:disabled:from-[#4B4B4B] dark:disabled:to-[#4B4B4B]",
      indicator && "[&>.indicator]:bg-[#4B4B4B] dark:[&>.indicator]:bg-[#E8E8E8]"
    ]
  end

  defp color_variant("outline_gradient", "natural", indicator) do
    [
      "gradient-button [&>*]:relative [&>*]:z-[1] relative bg-gradient-to-br hover:bg-gradient-to-bl",
      "from-[#282828] to-[#727272] text-[#4B4B4B] hover:text-[#282828]",
      "dark:from-[#A6A6A6] dark:to-[#FFFFFF] dark:text-[#DDDDDD] dark:hover:text-[#E8E8E8]",
      "before:bg-white dark:before:bg-[#282828] before:absolute before:inset-[2px] before:z-0",
      "disabled:from-[#DDDDDD] disabled:to-[#DDDDDD] disabled:text-[#DDDDDD]",
      "dark:disabled:from-[#727272] dark:disabled:to-[#727272] dark:disabled:text-[#727272]",
      indicator && "[&>.indicator]:bg-black dark:[&>.indicator]:bg-white"
    ]
  end

  defp color_variant("outline_gradient", "primary", indicator) do
    [
      "gradient-button [&>*]:relative [&>*]:z-[1] relative bg-gradient-to-br hover:bg-gradient-to-bl",
      "from-[#016974] to-[#01B8CA] text-[#007F8C] hover:text-[#016974]",
      "dark:from-[#01B8CA] dark:to-[#B0E7EF] dark:text-[#01B8CA] dark:hover:text-[#77D5E3]",
      "before:bg-white dark:before:bg-[#282828] before:absolute before:inset-[2px] before:z-0",
      "disabled:from-[#DDDDDD] disabled:to-[#DDDDDD] disabled:text-[#DDDDDD]",
      "dark:disabled:from-[#727272] dark:disabled:to-[#727272] dark:disabled:text-[#727272]",
      indicator && "[&>.indicator]:bg-[#1A535A] dark:[&>.indicator]:bg-[#B0E7EF]"
    ]
  end

  defp color_variant("outline_gradient", "secondary", indicator) do
    [
      "gradient-button [&>*]:relative [&>*]:z-[1] relative bg-gradient-to-br hover:bg-gradient-to-bl",
      "from-[#175BCC] to-[#6DAAFB] text-[#266EF1] hover:text-[#175BCC]",
      "dark:from-[#6DAAFB] dark:to-[#CDDEFF] dark:text-[#6DAAFB] dark:hover:text-[#A9C9FF]",
      "before:bg-white dark:before:bg-[#282828] before:absolute before:inset-[2px] before:z-0",
      "disabled:from-[#DDDDDD] disabled:to-[#DDDDDD] disabled:text-[#DDDDDD]",
      "dark:disabled:from-[#727272] dark:disabled:to-[#727272] dark:disabled:text-[#727272]",
      indicator && "[&>.indicator]:bg-[#1948A3] dark:[&>.indicator]:bg-[#CDDEFF]"
    ]
  end

  defp color_variant("outline_gradient", "success", indicator) do
    [
      "gradient-button [&>*]:relative [&>*]:z-[1] relative bg-gradient-to-br hover:bg-gradient-to-bl",
      "from-[#166C3B] to-[#06C167] text-[#0E8345] hover:text-[#166C3B]",
      "dark:from-[#06C167] dark:to-[#B1EAC2] dark:text-[#06C167] dark:hover:text-[#7FD99A]",
      "before:bg-white dark:before:bg-[#282828] before:absolute before:inset-[2px] before:z-0",
      "disabled:from-[#DDDDDD] disabled:to-[#DDDDDD] disabled:text-[#DDDDDD]",
      "dark:disabled:from-[#727272] dark:disabled:to-[#727272] dark:disabled:text-[#727272]",
      indicator && "[&>.indicator]:bg-[#0D572D] dark:[&>.indicator]:bg-[#B1EAC2]"
    ]
  end

  defp color_variant("outline_gradient", "warning", indicator) do
    [
      "gradient-button [&>*]:relative [&>*]:z-[1] relative bg-gradient-to-br hover:bg-gradient-to-bl",
      "from-[#976A01] to-[#FDC034] text-[#CA8D01] hover:text-[#976A01]",
      "dark:from-[#FDC034] dark:to-[#FEDF99] dark:text-[#FDC034] dark:hover:text-[#FDD067]",
      "before:bg-white dark:before:bg-[#282828] before:absolute before:inset-[2px] before:z-0",
      "disabled:from-[#DDDDDD] disabled:to-[#DDDDDD] disabled:text-[#DDDDDD]",
      "dark:disabled:from-[#727272] dark:disabled:to-[#727272] dark:disabled:text-[#727272]",
      indicator && "[&>.indicator]:bg-[#654600] dark:[&>.indicator]:bg-[#FEDF99]"
    ]
  end

  defp color_variant("outline_gradient", "danger", indicator) do
    [
      "gradient-button [&>*]:relative [&>*]:z-[1] relative bg-gradient-to-br hover:bg-gradient-to-bl",
      "from-[#BB032A] to-[#FC7F79] text-[#DE1135] hover:text-[#BB032A]",
      "dark:from-[#FC7F79] dark:to-[#FFD2CD] dark:text-[#FC7F79] dark:hover:text-[#FFB2AB]",
      "before:bg-white dark:before:bg-[#282828] before:absolute before:inset-[2px] before:z-0",
      "disabled:from-[#DDDDDD] disabled:to-[#DDDDDD] disabled:text-[#DDDDDD]",
      "dark:disabled:from-[#727272] dark:disabled:to-[#727272] dark:disabled:text-[#727272]",
      indicator && "[&>.indicator]:bg-[#950F22] dark:[&>.indicator]:bg-[#FFD2CD]"
    ]
  end

  defp color_variant("outline_gradient", "info", indicator) do
    [
      "gradient-button [&>*]:relative [&>*]:z-[1] relative bg-gradient-to-br hover:bg-gradient-to-bl",
      "from-[#08638C] to-[#3EB7ED] text-[#0B84BA] hover:text-[#08638C]",
      "dark:from-[#3EB7ED] dark:to-[#9FDBF6] dark:text-[#3EB7ED] dark:hover:text-[#6EC9F2]",
      "before:bg-white dark:before:bg-[#282828] before:absolute before:inset-[2px] before:z-0",
      "disabled:from-[#DDDDDD] disabled:to-[#DDDDDD] disabled:text-[#DDDDDD]",
      "dark:disabled:from-[#727272] dark:disabled:to-[#727272] dark:disabled:text-[#727272]",
      indicator && "[&>.indicator]:bg-[#06425D] dark:[&>.indicator]:bg-[#9FDBF6]"
    ]
  end

  defp color_variant("outline_gradient", "misc", indicator) do
    [
      "gradient-button [&>*]:relative [&>*]:z-[1] relative bg-gradient-to-br hover:bg-gradient-to-bl",
      "from-[#653C94] to-[#BA83F9] text-[#8750C5] hover:text-[#653C94]",
      "dark:from-[#BA83F9] dark:to-[#DDC1FC] dark:text-[#BA83F9] dark:hover:text-[#CBA2FA]",
      "before:bg-white dark:before:bg-[#282828] before:absolute before:inset-[2px] before:z-0",
      "disabled:from-[#DDDDDD] disabled:to-[#DDDDDD] disabled:text-[#DDDDDD]",
      "dark:disabled:from-[#727272] dark:disabled:to-[#727272] dark:disabled:text-[#727272]",
      indicator && "[&>.indicator]:bg-[#442863] dark:[&>.indicator]:bg-[#DDC1FC]"
    ]
  end

  defp color_variant("outline_gradient", "dawn", indicator) do
    [
      "gradient-button [&>*]:relative [&>*]:z-[1] relative bg-gradient-to-br hover:bg-gradient-to-bl",
      "from-[#7E4B2A] to-[#DB976B] text-[#A86438] hover:text-[#7E4B2A]",
      "dark:from-[#DB976B] dark:to-[#EDCBB5] dark:text-[#DB976B] dark:hover:text-[#DB976B]",
      "before:bg-white dark:before:bg-[#282828] before:absolute before:inset-[2px] before:z-0",
      "disabled:from-[#DDDDDD] disabled:to-[#DDDDDD] disabled:text-[#DDDDDD]",
      "dark:disabled:from-[#727272] dark:disabled:to-[#727272] dark:disabled:text-[#727272]",
      indicator && "[&>.indicator]:bg-[#54321C] dark:[&>.indicator]:bg-[#EDCBB5]"
    ]
  end

  defp color_variant("outline_gradient", "silver", indicator) do
    [
      "gradient-button [&>*]:relative [&>*]:z-[1] relative bg-gradient-to-br hover:bg-gradient-to-bl",
      "from-[#5E5E5E] to-[#A6A6A6] text-[#868686] hover:text-[#727272]",
      "dark:from-[#868686] dark:to-[#BBBBBB] dark:text-[#A6A6A6] dark:hover:text-[#BBBBBB]",
      "before:bg-white dark:before:bg-[#282828] before:absolute before:inset-[2px] before:z-0",
      "disabled:from-[#DDDDDD] disabled:to-[#DDDDDD] disabled:text-[#DDDDDD]",
      "dark:disabled:from-[#727272] dark:disabled:to-[#727272] dark:disabled:text-[#727272]",
      indicator && "[&>.indicator]:bg-[#5E5E5E] dark:[&>.indicator]:bg-[#DDDDDD]"
    ]
  end

  defp color_variant("inverted_gradient", "natural", indicator) do
    [
      "gradient-button [&>*]:relative [&>*]:z-[1] relative bg-gradient-to-br hover:bg-gradient-to-bl",
      "from-[#282828] to-[#727272] text-[#4B4B4B] hover:text-white",
      "dark:from-[#A6A6A6] dark:to-[#FFFFFF] dark:text-[#DDDDDD] dark:hover:text-black",
      "before:bg-white dark:before:bg-[#282828] before:transition",
      "before:ease-in-ou before:duration-100 duration before:absolute before:inset-[2px] before:z-0",
      "hover:before:bg-transparent dark:hover:before:bg-transparent",
      "disabled:from-[#DDDDDD] disabled:to-[#DDDDDD] disabled:text-[#DDDDDD]",
      "dark:disabled:from-[#727272] dark:disabled:to-[#727272] dark:disabled:text-[#727272]",
      "hover:disabled:bg-white dark:hover:disabled:before:bg-[#282828]",
      indicator && "[&>.indicator]:bg-black dark:[&>.indicator]:bg-white",
      indicator && "[&:hover>.indicator]:bg-white dark:[&:hover>.indicator]:bg-black"
    ]
  end

  defp color_variant("inverted_gradient", "primary", indicator) do
    [
      "gradient-button [&>*]:relative [&>*]:z-[1] relative bg-gradient-to-br hover:bg-gradient-to-bl",
      "from-[#016974] to-[#01B8CA] text-[#007F8C] hover:text-white",
      "dark:from-[#01B8CA] dark:to-[#B0E7EF] dark:text-[#01B8CA] dark:hover:text-black",
      "before:bg-white dark:before:bg-[#282828] before:transition",
      "before:ease-in-ou before:duration-100 duration before:absolute before:inset-[2px] before:z-0",
      "hover:before:bg-transparent dark:hover:before:bg-transparent",
      "disabled:from-[#DDDDDD] disabled:to-[#DDDDDD] disabled:text-[#DDDDDD]",
      "dark:disabled:from-[#727272] dark:disabled:to-[#727272] dark:disabled:text-[#727272]",
      "hover:disabled:bg-white dark:hover:disabled:before:bg-[#282828]",
      indicator && "[&>.indicator]:bg-[#1A535A] dark:[&>.indicator]:bg-[#CDEEF3]",
      indicator && "[&:hover>.indicator]:bg-[#CDEEF3] dark:[&:hover>.indicator]:bg-[#1A535A]"
    ]
  end

  defp color_variant("inverted_gradient", "secondary", indicator) do
    [
      "gradient-button [&>*]:relative [&>*]:z-[1] relative bg-gradient-to-br hover:bg-gradient-to-bl",
      "from-[#175BCC] to-[#6DAAFB] text-[#266EF1] hover:text-white",
      "dark:from-[#6DAAFB] dark:to-[#CDDEFF] dark:text-[#6DAAFB] dark:hover:text-black",
      "before:bg-white dark:before:bg-[#282828] before:transition",
      "before:ease-in-ou before:duration-100 duration before:absolute before:inset-[2px] before:z-0",
      "hover:before:bg-transparent dark:hover:before:bg-transparent",
      "disabled:from-[#DDDDDD] disabled:to-[#DDDDDD] disabled:text-[#DDDDDD]",
      "dark:disabled:from-[#727272] dark:disabled:to-[#727272] dark:disabled:text-[#727272]",
      "hover:disabled:bg-white dark:hover:disabled:before:bg-[#282828]",
      indicator && "[&>.indicator]:bg-[#1948A3] dark:[&>.indicator]:bg-[#CDDEFF]",
      indicator && "[&:hover>.indicator]:bg-[#CDDEFF] dark:[&:hover>.indicator]:bg-[#1948A3]"
    ]
  end

  defp color_variant("inverted_gradient", "success", indicator) do
    [
      "gradient-button [&>*]:relative [&>*]:z-[1] relative bg-gradient-to-br hover:bg-gradient-to-bl",
      "from-[#166C3B] to-[#06C167] text-[#0E8345] hover:text-white",
      "dark:from-[#06C167] dark:to-[#B1EAC2] dark:text-[#06C167] dark:hover:text-black",
      "before:bg-white dark:before:bg-[#282828] before:transition",
      "before:ease-in-ou before:duration-100 duration before:absolute before:inset-[2px] before:z-0",
      "hover:before:bg-transparent dark:hover:before:bg-transparent",
      "disabled:from-[#DDDDDD] disabled:to-[#DDDDDD] disabled:text-[#DDDDDD]",
      "dark:disabled:from-[#727272] dark:disabled:to-[#727272] dark:disabled:text-[#727272]",
      "hover:disabled:bg-white dark:hover:disabled:before:bg-[#282828]",
      indicator && "[&>.indicator]:bg-[#0D572D] dark:[&>.indicator]:bg-[#B1EAC2]",
      indicator && "[&:hover>.indicator]:bg-[#B1EAC2] dark:[&:hover>.indicator]:bg-[#0D572D]"
    ]
  end

  defp color_variant("inverted_gradient", "warning", indicator) do
    [
      "gradient-button [&>*]:relative [&>*]:z-[1] relative bg-gradient-to-br hover:bg-gradient-to-bl",
      "from-[#976A01] to-[#FDC034] text-[#CA8D01] hover:text-white",
      "dark:from-[#FDC034] dark:to-[#FEDF99] dark:text-[#FDC034] dark:hover:text-black",
      "before:bg-white dark:before:bg-[#282828] before:transition",
      "before:ease-in-ou before:duration-100 duration before:absolute before:inset-[2px] before:z-0",
      "hover:before:bg-transparent dark:hover:before:bg-transparent",
      "disabled:from-[#DDDDDD] disabled:to-[#DDDDDD] disabled:text-[#DDDDDD]",
      "dark:disabled:from-[#727272] dark:disabled:to-[#727272] dark:disabled:text-[#727272]",
      "hover:disabled:bg-white dark:hover:disabled:before:bg-[#282828]",
      indicator && "[&>.indicator]:bg-[#654600] dark:[&>.indicator]:bg-[#FEDF99]",
      indicator && "[&:hover>.indicator]:bg-[#FEDF99] dark:[&:hover>.indicator]:bg-[#654600]"
    ]
  end

  defp color_variant("inverted_gradient", "danger", indicator) do
    [
      "gradient-button [&>*]:relative [&>*]:z-[1] relative bg-gradient-to-br hover:bg-gradient-to-bl",
      "from-[#BB032A] to-[#FC7F79] text-[#DE1135] hover:text-white",
      "dark:from-[#FC7F79] dark:to-[#FFD2CD] dark:text-[#FC7F79] dark:hover:text-black",
      "before:bg-white dark:before:bg-[#282828] before:transition",
      "before:ease-in-ou before:duration-100 duration before:absolute before:inset-[2px] before:z-0",
      "hover:before:bg-transparent dark:hover:before:bg-transparent",
      "disabled:from-[#DDDDDD] disabled:to-[#DDDDDD] disabled:text-[#DDDDDD]",
      "dark:disabled:from-[#727272] dark:disabled:to-[#727272] dark:disabled:text-[#727272]",
      "hover:disabled:bg-white dark:hover:disabled:before:bg-[#282828]",
      indicator && "[&>.indicator]:bg-[#950F22] dark:[&>.indicator]:bg-[#FFD2CD]",
      indicator && "[&:hover>.indicator]:bg-[#FFD2CD] dark:[&:hover>.indicator]:bg-[#950F22]"
    ]
  end

  defp color_variant("inverted_gradient", "info", indicator) do
    [
      "gradient-button [&>*]:relative [&>*]:z-[1] relative bg-gradient-to-br hover:bg-gradient-to-bl",
      "from-[#08638C] to-[#3EB7ED] text-[#0B84BA] hover:text-white",
      "dark:from-[#3EB7ED] dark:to-[#9FDBF6] dark:text-[#3EB7ED] dark:hover:text-black",
      "before:bg-white dark:before:bg-[#282828] before:transition",
      "before:ease-in-ou before:duration-100 duration before:absolute before:inset-[2px] before:z-0",
      "hover:before:bg-transparent dark:hover:before:bg-transparent",
      "disabled:from-[#DDDDDD] disabled:to-[#DDDDDD] disabled:text-[#DDDDDD]",
      "dark:disabled:from-[#727272] dark:disabled:to-[#727272] dark:disabled:text-[#727272]",
      "hover:disabled:bg-white dark:hover:disabled:before:bg-[#282828]",
      indicator && "[&>.indicator]:bg-[#06425D] dark:[&>.indicator]:bg-[#9FDBF6]",
      indicator && "[&:hover>.indicator]:bg-[#9FDBF6] dark:[&:hover>.indicator]:bg-[#06425D]"
    ]
  end

  defp color_variant("inverted_gradient", "misc", indicator) do
    [
      "gradient-button [&>*]:relative [&>*]:z-[1] relative bg-gradient-to-br hover:bg-gradient-to-bl",
      "from-[#653C94] to-[#BA83F9] text-[#8750C5] hover:text-white",
      "dark:from-[#BA83F9] dark:to-[#DDC1FC] dark:text-[#BA83F9] dark:hover:text-black",
      "before:bg-white dark:before:bg-[#282828] before:transition",
      "before:ease-in-ou before:duration-100 duration before:absolute before:inset-[2px] before:z-0",
      "hover:before:bg-transparent dark:hover:before:bg-transparent",
      "disabled:from-[#DDDDDD] disabled:to-[#DDDDDD] disabled:text-[#DDDDDD]",
      "dark:disabled:from-[#727272] dark:disabled:to-[#727272] dark:disabled:text-[#727272]",
      "hover:disabled:bg-white dark:hover:disabled:before:bg-[#282828]",
      indicator && "[&>.indicator]:bg-[#442863] dark:[&>.indicator]:bg-[#DDC1FC]",
      indicator && "[&:hover>.indicator]:bg-[#DDC1FC] dark:[&:hover>.indicator]:bg-[#442863]"
    ]
  end

  defp color_variant("inverted_gradient", "dawn", indicator) do
    [
      "gradient-button [&>*]:relative [&>*]:z-[1] relative bg-gradient-to-br hover:bg-gradient-to-bl",
      "from-[#7E4B2A] to-[#DB976B] text-[#A86438] hover:text-white",
      "dark:from-[#DB976B] dark:to-[#EDCBB5] dark:text-[#DB976B] dark:hover:text-black",
      "before:bg-white dark:before:bg-[#282828] before:transition",
      "before:ease-in-ou before:duration-100 duration before:absolute before:inset-[2px] before:z-0",
      "hover:before:bg-transparent dark:hover:before:bg-transparent",
      "disabled:from-[#DDDDDD] disabled:to-[#DDDDDD] disabled:text-[#DDDDDD]",
      "dark:disabled:from-[#727272] dark:disabled:to-[#727272] dark:disabled:text-[#727272]",
      "hover:disabled:bg-white dark:hover:disabled:before:bg-[#282828]",
      indicator && "[&>.indicator]:bg-[#54321C] dark:[&>.indicator]:bg-[#EDCBB5]",
      indicator && "[&:hover>.indicator]:bg-[#EDCBB5] dark:[&:hover>.indicator]:bg-[#54321C]"
    ]
  end

  defp color_variant("inverted_gradient", "silver", indicator) do
    [
      "gradient-button [&>*]:relative [&>*]:z-[1] relative bg-gradient-to-br hover:bg-gradient-to-bl",
      "from-[#5E5E5E] to-[#A6A6A6] text-[#868686] hover:text-white",
      "dark:from-[#868686] dark:to-[#BBBBBB] dark:text-[#A6A6A6] dark:hover:text-black",
      "before:bg-white dark:before:bg-[#282828] before:transition",
      "before:ease-in-ou before:duration-100 duration before:absolute before:inset-[2px] before:z-0",
      "hover:before:bg-transparent dark:hover:before:bg-transparent",
      "disabled:from-[#DDDDDD] disabled:to-[#DDDDDD] disabled:text-[#DDDDDD]",
      "dark:disabled:from-[#727272] dark:disabled:to-[#727272] dark:disabled:text-[#727272]",
      "hover:disabled:bg-white dark:hover:disabled:before:bg-[#282828]",
      indicator && "[&>.indicator]:bg-[#E8E8E8] dark:[&>.indicator]:bg-[#DDDDDD]",
      indicator && "[&:hover>.indicator]:bg-[#DDDDDD] dark:[&:hover>.indicator]:bg-[#E8E8E8]"
    ]
  end

  defp color_variant(params, _, _) when is_binary(params), do: params

  defp border_class("base") do
    "border-[#e4e4e7] dark:border-[#27272a]"
  end

  defp border_class("natural") do
    "border-black dark:border-white"
  end

  defp border_class("transparent") do
    "border-transparent dark:border-transparent"
  end

  defp border_class("primary") do
    "border-[#000000] dark:border-[#B0E7EF]"
  end

  defp border_class("secondary") do
    "border-[#1948A3] dark:border-[#CDDEFF]"
  end

  defp border_class("success") do
    "border-[#0D572D] dark:border-[#B1EAC2]"
  end

  defp border_class("warning") do
    "border-[#654600] dark:border-[#FEDF99]"
  end

  defp border_class("danger") do
    "border-[#950F22] dark:border-[#FFD2CD]"
  end

  defp border_class("info") do
    "border-[#06425D] dark:border-[#9FDBF6]"
  end

  defp border_class("misc") do
    "border-[#442863] dark:border-[#DDC1FC]"
  end

  defp border_class("dawn") do
    "border-[#54321C] dark:border-[#EDCBB5]"
  end

  defp border_class("silver") do
    "border-[#5E5E5E] dark:border-[#DDDDDD]"
  end

  defp border_class(params) when is_binary(params), do: params

  defp rounded_size("extra_small"), do: "rounded-sm [&.gradient-button:before]:rounded-[1px]"

  defp rounded_size("small"), do: "rounded [&.gradient-button:before]:rounded-[2px]"

  defp rounded_size("medium"), do: "rounded-md [&.gradient-button:before]:rounded-[4px]"

  defp rounded_size("large"), do: "rounded-lg [&.gradient-button:before]:rounded-[5px]"

  defp rounded_size("extra_large"), do: "rounded-xl [&.gradient-button:before]:rounded-[9px]"

  defp rounded_size("full"), do: "rounded-full [&.gradient-button:before]:rounded-full"

  defp rounded_size("none"), do: nil

  defp rounded_size(params) when is_binary(params), do: params

  defp size_class("extra_small", circle) do
    [
      is_nil(circle) && "py-1 px-2",
      "text-[12px] [&>.indicator]:size-1",
      !is_nil(circle) && "size-6"
    ]
  end

  defp size_class("small", circle) do
    [
      is_nil(circle) && "py-1.5 px-3",
      "text-[13px] [&>.indicator]:size-1.5",
      !is_nil(circle) && "size-7"
    ]
  end

  defp size_class("medium", circle) do
    [
      is_nil(circle) && "py-2 px-4",
      "text-[14px] [&>.indicator]:size-2",
      !is_nil(circle) && "size-8"
    ]
  end

  defp size_class("large", circle) do
    [
      is_nil(circle) && "py-2.5 px-5",
      "text-[15px] [&>.indicator]:size-2.5",
      !is_nil(circle) && "size-9"
    ]
  end

  defp size_class("extra_large", circle) do
    [
      is_nil(circle) && "py-3 px-5",
      "text-[16px] [&>.indicator]:size-3",
      !is_nil(circle) && "size-10"
    ]
  end

  defp size_class(params, _circle) when is_binary(params), do: [params]

  defp icon_position(nil, _), do: false
  defp icon_position(_icon, %{left_icon: true}), do: "left"
  defp icon_position(_icon, %{right_icon: true}), do: "right"
  defp icon_position(_icon, _), do: "left"

  defp variation("horizontal") do
    "flex-row [&>*:not(:last-child)]:border-r"
  end

  defp variation("vertical") do
    "flex-col [&>*:not(:last-child)]:border-b"
  end

  defp indicator_size("extra_small"), do: "!size-2"
  defp indicator_size("small"), do: "!size-2.5"
  defp indicator_size("medium"), do: "!size-3"
  defp indicator_size("large"), do: "!size-3.5"
  defp indicator_size("extra_large"), do: "!size-4"
  defp indicator_size(params) when is_binary(params), do: params

  defp content_position("start") do
    "justify-start"
  end

  defp content_position("end") do
    "justify-end"
  end

  defp content_position("center") do
    "justify-center"
  end

  defp content_position("between") do
    "justify-between"
  end

  defp content_position("around") do
    "justify-around"
  end

  defp content_position(params) when is_binary(params), do: params

  defp default_classes(:grouped, _) do
    [
      "phx-submit-loading:opacity-75 overflow-hidden flex w-fit rounded-lg border cursor-pointer",
      "[&>*]:rounded-none [&>*]:border-0"
    ]
  end

  defp default_classes(pinging, indicator) do
    [
      "phx-submit-loading:opacity-75 relative gap-2 items-center cursor-pointer",
      "transition-all ease-in-ou duration-100 group",
      "disabled:cursor-not-allowed",
      "focus:outline-none",
      indicator &&
        "[&>.indicator]:inline-block [&>.indicator]:shrink-0 [&>.indicator]:rounded-full",
      !is_nil(pinging) && "[&>.indicator]:animate-ping"
    ]
  end

  defp drop_rest(rest) do
    all_rest =
      (["pinging", "circle", "right_icon", "left_icon"] ++ @indicator_positions)
      |> Enum.map(&if(is_binary(&1), do: String.to_atom(&1), else: &1))

    Map.drop(rest, all_rest)
  end

  defp is_indicators?(rest) do
    Enum.any?(@indicator_positions, &Map.get(rest, String.to_atom(&1)))
  end
end
