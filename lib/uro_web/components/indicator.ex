defmodule UroWeb.Components.Indicator do
  @moduledoc """
  The `UroWeb.Components.Indicator` module provides a versatile component for visually highlighting
  specific areas or elements in your Phoenix application.

  It is designed to display small, circular indicators that can be used for notifications,
  status updates, or visual cues on UI elements.

  This component supports various sizes and colors and can be positioned in multiple areas
  relative to its parent element. Additionally, it has an optional ping animation for drawing
  attention to a specific point on the interface.

  The indicator can be used in diverse scenarios, such as showing the number of unread messages,
  indicating active states, or displaying connectivity status. It is customizable with different
  styles, making it adaptable to various design needs.
  """

  use Phoenix.Component

  @indicator_positions [
    "top_left",
    "top_center",
    "top_right",
    "middle_left",
    "middle_right",
    "bottom_left",
    "bottom_center",
    "bottom_right"
  ]

  @doc """
  Renders an `indicator` component with customizable size, color, and position.

  The indicator can be positioned around its parent element and supports various sizes and styles.

  ## Examples

  ```elixir
  <.indicator />
  <.indicator color="misc" />
  <.indicator size="extra_small" />
  <.indicator color="warning" size="extra_small" bottom_left />
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

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :color, :string, default: "base", doc: "Determines color theme"

  attr :rest, :global,
    include: ["pinging"] ++ @indicator_positions,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  def indicator(%{rest: %{top_left: true}} = assigns) do
    ~H"""
    <span
      id={@id}
      class={[
        indicator_size(@size),
        color_class(@color),
        "indicator block rounded-full absolute -translate-y-1/2 -translate-x-1/2 right-auto top-0 left-0 indicator-top-left",
        !is_nil(@rest[:pinging]) && "animate-ping",
        @class
      ]}
      {drop_rest(@rest)}
    />
    """
  end

  def indicator(%{rest: %{top_center: true}} = assigns) do
    ~H"""
    <span
      id={@id}
      class={[
        indicator_size(@size),
        color_class(@color),
        "indicator block rounded-full absolute top-0 -translate-y-1/2 translate-x-1/2 right-1/2",
        !is_nil(@rest[:pinging]) && "animate-ping",
        @class
      ]}
      {drop_rest(@rest)}
    />
    """
  end

  def indicator(%{rest: %{top_right: true}} = assigns) do
    ~H"""
    <span
      id={@id}
      class={[
        indicator_size(@size),
        color_class(@color),
        "indicator block rounded-full absolute -translate-y-1/2 translate-x-1/2 left-auto top-0 right-0  indicator-top-right",
        !is_nil(@rest[:pinging]) && "animate-ping",
        @class
      ]}
      {drop_rest(@rest)}
    />
    """
  end

  def indicator(%{rest: %{middle_left: true}} = assigns) do
    ~H"""
    <span
      id={@id}
      class={[
        indicator_size(@size),
        color_class(@color),
        "indicator block rounded-full absolute -translate-y-1/2 -translate-x-1/2 right-auto left-0 top-2/4",
        !is_nil(@rest[:pinging]) && "animate-ping",
        @class
      ]}
      {drop_rest(@rest)}
    />
    """
  end

  def indicator(%{rest: %{middle_right: true}} = assigns) do
    ~H"""
    <span
      id={@id}
      class={[
        indicator_size(@size),
        color_class(@color),
        "indicator block rounded-full absolute -translate-y-1/2 translate-x-1/2 left-auto right-0 top-2/4",
        !is_nil(@rest[:pinging]) && "animate-ping",
        @class
      ]}
      {drop_rest(@rest)}
    />
    """
  end

  def indicator(%{rest: %{bottom_left: true}} = assigns) do
    ~H"""
    <span
      id={@id}
      class={[
        indicator_size(@size),
        color_class(@color),
        "indicator block rounded-full absolute translate-y-1/2 -translate-x-1/2 right-auto bottom-0 left-0  indicator-bottom-left",
        !is_nil(@rest[:pinging]) && "animate-ping",
        @class
      ]}
      {drop_rest(@rest)}
    />
    """
  end

  def indicator(%{rest: %{bottom_center: true}} = assigns) do
    ~H"""
    <span
      id={@id}
      class={[
        indicator_size(@size),
        color_class(@color),
        "indicator block rounded-full absolute translate-y-1/2 translate-x-1/2 bottom-0 right-1/2",
        !is_nil(@rest[:pinging]) && "animate-ping",
        @class
      ]}
      {drop_rest(@rest)}
    />
    """
  end

  def indicator(%{rest: %{bottom_right: true}} = assigns) do
    ~H"""
    <span
      id={@id}
      class={[
        indicator_size(@size),
        color_class(@color),
        "indicator block rounded-full absolute translate-y-1/2 translate-x-1/2 left-auto bottom-0 right-0  indicator-bottom-right",
        !is_nil(@rest[:pinging]) && "animate-ping",
        @class
      ]}
      {drop_rest(@rest)}
    />
    """
  end

  def indicator(assigns) do
    ~H"""
    <span
      id={@id}
      class={[
        indicator_size(@size),
        color_class(@color),
        "block indicator rounded-full",
        !is_nil(@rest[:pinging]) && "animate-ping",
        @class
      ]}
      {drop_rest(@rest)}
    />
    """
  end

  defp indicator_size("extra_small"), do: "!size-2"

  defp indicator_size("small"), do: "!size-2.5"

  defp indicator_size("medium"), do: "!size-3"

  defp indicator_size("large"), do: "!size-3.5"

  defp indicator_size("extra_large"), do: "!size-4"

  defp indicator_size(params) when is_binary(params), do: params

  defp color_class("base"), do: "bg-[#e4e4e7] dark:bg-[#27272a]"

  defp color_class("white"), do: "bg-white"

  defp color_class("natural"), do: "bg-[#4B4B4B] dark:bg-[#DDDDDD]"

  defp color_class("primary"), do: "bg-[#007F8C] dark:bg-[#01B8CA]"

  defp color_class("secondary"), do: "bg-[#266EF1] dark:bg-[#6DAAFB]"

  defp color_class("success"), do: "bg-[#0E8345] dark:bg-[#06C167]"

  defp color_class("warning"), do: "bg-[#CA8D01] dark:bg-[#FDC034]"

  defp color_class("danger"), do: "bg-[#DE1135] dark:bg-[#FC7F79]"

  defp color_class("info"), do: "bg-[#0B84BA] dark:bg-[#3EB7ED]"

  defp color_class("misc"), do: "bg-[#8750C5] dark:bg-[#BA83F9]"

  defp color_class("dawn"), do: "bg-[#A86438] dark:bg-[#DB976B]"

  defp color_class("silver"), do: "bg-[#868686] dark:bg-[#A6A6A6]"

  defp color_class("dark"), do: "bg-[#282828]"

  defp color_class(params) when is_binary(params), do: params

  defp drop_rest(rest) do
    all_rest =
      (["pinging"] ++ @indicator_positions)
      |> Enum.map(&if(is_binary(&1), do: String.to_atom(&1), else: &1))

    Map.drop(rest, all_rest)
  end
end
