defmodule UroWeb.Components.Accordion do
  @moduledoc """
  The `UroWeb.Components.Accordion` module provides a flexible and customizable accordion
  component for Phoenix LiveView applications.

  It supports a variety of configuration options including size, variant, color, padding,
  and border styles.

  ### Features

  - **Customizable Design**: Supports multiple variants such as `"default"`, `"outline"`,
  `"bordered"`, `"outline_separated"`, `"bordered_separated"`, `"transparent"`, and `"menu"`.
  - **Size and Spacing**: Provides control over the size and spacing of accordion items
  using predefined values such as `"extra_small"`, `"small"`, `"medium"`,
  `"large"`, and `"extra_large"`.
  - **Color Themes**: Offers a range of color options including `"primary"`,
  `"secondary"`, `"success"`, `"warning"`, `"danger"`, `"info"`, `"silver"`, `"dark"`, and more.
  - **Interactive Animations**: Includes interactive JavaScript-based animations
  for showing and hiding content with smooth transitions.
  - **Icon and Media Support**: Allows the inclusion of icons and images within
  accordion items, enhancing the visual appeal and usability of the component.
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS

  @doc """
  The `accordion` component provides a collapsible structure with various styling options,
  ideal for organizing content into expandable panels. It supports customizable attributes such
  as `variant`, `color`, and `media_size.

  ## Examples
  ```elixir
  <.accordion id="test-108" media_size="medium" color="secondary">
    <:item
      title="Accordion Version native"
      description="Need to be something like this yeehh!?"
      image="https://img.icons8.com/clouds/256/000000/futurama-bender.png"
    >
      Lorem ipsum dolor, sit amet consectetur adipisicing elit. Omnis fugit, voluptas nam quia,
      sunt sapiente itaque velit illo sed nesciunt molestias commodi, veniam adipisci quo
      laboriosam in ipsa illum tenetur.
    </:item>
    <:item
      title="Accordion Version native"
      description="Need to be something like this yeehh!?"
      image="https://img.icons8.com/clouds/256/000000/futurama-bender.png"
    >
      Lorem ipsum dolor, sit amet consectetur adipisicing elit. Omnis fugit, voluptas nam quia,
      sunt sapiente itaque velit illo sed nesciunt molestias commodi, veniam adipisci quo
      laboriosam in ipsa illum tenetur.
    </:item>
  </.accordion>
  ```
  """
  @doc type: :component
  attr :id, :string,
    required: true,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :variant, :string, default: "base", doc: "Determines the style"
  attr :space, :string, default: "small", doc: "Space between items"
  attr :color, :string, default: "natural", doc: "Determines color theme"
  attr :border, :string, default: "extra_small", doc: "Determines border style"
  attr :padding, :string, default: "small", doc: "Determines padding for items"
  attr :rounded, :string, default: "none", doc: "Determines the border radius"

  attr :chevron_icon, :string,
    default: "hero-chevron-right",
    doc: "Determines the icon for the chevron"

  attr :chevron_class, :string, default: nil, doc: "Determines the icon for the chevron"

  attr :media_size, :string, default: "small", doc: "Determines size of the media elements"

  attr :size, :string,
    default: "",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  slot :item, required: true, doc: "Specifies item slot of a accordion" do
    attr :title, :string,
      required: true,
      doc: "Specifies the title of the element",
      doc: "Specifies the title of the element"

    attr :description, :string, doc: "Determines a short description"
    attr :icon, :string, doc: "Icon displayed alongside of an item"
    attr :class, :string, doc: "Custom CSS class for additional styling"
    attr :image, :string, doc: "Image displayed alongside of an item"
    attr :icon_wrapper_class, :string, doc: "Image displayed alongside of an item"
    attr :hover, :string, doc: "Determines custom class for the hover"
    attr :image_class, :string, doc: "Determines custom class for the image"
    attr :icon_class, :string, doc: "Determines custom class for the icon"
    attr :content_class, :string, doc: "Determines custom class for the content"
    attr :title_class, :string, doc: "Determines custom class for the title"
    attr :summary_class, :string, doc: "Determines custom class for the summary"
    attr :font_weight, :string, doc: "Determines custom class for the font weight"
    attr :open, :boolean, doc: "Whether the accordion item is initially open or closed"
  end

  attr :rest, :global,
    include: ~w(left_chevron right_chevron chevron hide_chevron),
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  def accordion(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "overflow-hidden w-full h-fit",
        @variant == "menu" && menu_rounded(@rounded),
        @variant != "menu" && rounded_size(@rounded, @variant),
        color_variant(@variant, @color),
        space_class(@space, @variant),
        border_class(@border, @variant),
        media_size(@media_size),
        padding_size(@padding),
        size_class(@size),
        @class
      ]}
      {drop_rest(@rest)}
    >
      <div
        :for={{item, index} <- Enum.with_index(@item, 1)}
        class={["group accordion-item-wrapper", item[:class]]}
      >
        <div
          id={"#{@id}-#{index}-role-button"}
          role="button"
          class={[
            "accordion-summary block w-full",
            "transition-all duration-100 ease-in-out [&.active-accordion-button_.accordion-chevron]:rotate-90",
            item[:summary_class]
          ]}
        >
          <.native_chevron_position
            id={"#{@id}-#{index}-open-chevron"}
            phx-click={
              show_accordion_content("#{@id}-#{index}")
              |> JS.hide()
              |> JS.show(to: "##{@id}-#{index}-close-chevron")
            }
            position={chevron_position(@rest)}
            chevron_icon={@chevron_icon}
            chevron_class={@chevron_class}
            item={item}
            hide_chevron={@rest[:hide_chevron] || false}
          />

          <.native_chevron_position
            id={"#{@id}-#{index}-close-chevron"}
            phx-click={
              hide_accordion_content("#{@id}-#{index}")
              |> JS.hide()
              |> JS.show(to: "##{@id}-#{index}-open-chevron")
            }
            position={chevron_position(@rest)}
            chevron_icon={@chevron_icon}
            chevron_class={@chevron_class}
            item={item}
            class="hidden"
            hide_chevron={@rest[:hide_chevron] || false}
          />
        </div>
        <.focus_wrap
          id={"#{@id}-#{index}"}
          class="accordion-content-wrapper relative hidden transition [&:not(.active)_.accordion-content]:grid-rows-[0fr] [&.active_.accordion-content]:grid-rows-[1fr]"
        >
          <div
            id={"#{@id}-#{index}-content"}
            class={[
              "accordion-content transition-all duration-500 grid",
              item[:content_class]
            ]}
          >
            <div class="overflow-hidden">
              {render_slot(item)}
            </div>
          </div>
        </.focus_wrap>
      </div>
    </div>
    """
  end

  @doc """
  The Native Accordion component provides an expandable structure that uses the native `<details>`
  HTML element.

  It offers various customization options such as `variant`, `color`, and `media_size` for
  styling and configuration.

  ## Examples
  ```elixir
  <.native_accordion name="example-zero" media_size="small">
    <:item
      title="Accordion Version native"
      description="Need to be something like this yeehh!?"
      image="https://img.icons8.com/clouds/256/000000/futurama-bender.png"
    >
      Lorem ipsum dolor, sit amet consectetur adipisicing elit. Omnis fugit, voluptas nam quia,
      sunt sapiente itaque velit illo sed nesciunt molestias commodi, veniam adipisci quo
      laboriosam in ipsa illum tenetur.
    </:item>
    <:item
      title="Accordion Version native"
      description="Need to be something like this yeehh!?"
      image="https://img.icons8.com/clouds/256/000000/futurama-bender.png"
    >
      Lorem ipsum dolor, sit amet consectetur adipisicing elit. Omnis fugit, voluptas nam quia,
      sunt sapiente itaque velit illo sed nesciunt molestias commodi, veniam adipisci quo
      laboriosam in ipsa illum tenetur.
    </:item>
  </.native_accordion>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :name, :string, default: nil, doc: "Specifies the name of the element"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :variant, :string, default: "base", doc: "Determines the style"
  attr :space, :string, default: "small", doc: "Space between items"
  attr :color, :string, default: "natural", doc: "Determines color theme"
  attr :border, :string, default: "extra_small", doc: "Determines border style"

  attr :padding, :string, default: "small", doc: "Determines padding for items"

  attr :rounded, :string, default: "none", doc: "Determines the border radius"

  attr :media_size, :string, default: "small", doc: "Determines size of the media elements"

  attr :chevron_icon, :string,
    default: "hero-chevron-right",
    doc: "Determines the icon for the chevron"

  attr :chevron_class, :string, default: nil, doc: "Determines the icon for the chevron"

  slot :item, required: true, doc: "Specifies item slot of a accordion" do
    attr :title, :string, required: true, doc: "Specifies the title of the element"
    attr :description, :string, doc: "Determines a short description"
    attr :icon, :string, doc: "Icon displayed alongside of an item"
    attr :class, :string, doc: "Custom CSS class for additional styling"
    attr :image, :string, doc: "Image displayed alongside of an item"
    attr :image_class, :string, doc: "Determines custom class for the image"
    attr :icon_class, :string, doc: "Determines custom class for the icon"
    attr :content_class, :string, doc: "Determines custom class for the content"
    attr :title_class, :string, doc: "Determines custom class for the title"
    attr :summary_class, :string, doc: "Determines custom class for the summary"
    attr :open, :boolean, doc: "Whether the accordion item is initially open or closed"
  end

  attr :rest, :global,
    include: ~w(left_chevron right_chevron chevron hide_chevron),
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  def native_accordion(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "overflow-hidden",
        @variant == "menu" && menu_rounded(@rounded),
        @variant != "menu" && rounded_size(@rounded, @variant),
        space_class(@space, @variant),
        padding_size(@padding),
        border_class(@border, @variant),
        media_size(@media_size),
        color_variant(@variant, @color),
        @class
      ]}
      {drop_rest(@rest)}
    >
      <details
        :for={item <- @item}
        name={@name}
        class={["group accordion-item-wrapper", item[:class]]}
        open={item[:open] || false}
      >
        <summary class={[
          "accordion-summary w-full group-open:mb-1",
          "cursor-pointer transition-[margin,background,text] duration-[250ms] ease-in-out list-none",
          item_color(@variant, @color),
          item[:summary_class]
        ]}>
          <.native_chevron_position
            position={chevron_position(@rest)}
            chevron_icon={@chevron_icon}
            item={item}
            hide_chevron={@rest[:hide_chevron] || false}
          />
        </summary>

        <div class={[
          "-mt-1 shrink-0 transition-all duration-1000 ease-in-out opacity-0 group-open:opacity-100",
          "-translate-y-4	group-open:translate-y-0 custom-accordion-content",
          item_color(@variant, @color),
          item[:content_class]
        ]}>
          {render_slot(item)}
        </div>
      </details>
    </div>
    """
  end

  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :item, :map, doc: "Determines each item"
  attr :position, :string, values: ["left", "right"], doc: "Determines the element position"
  attr :chevron_icon, :string, doc: "Determines the icon for the chevron"
  attr :chevron_class, :string, default: nil, doc: "Determines the icon for the chevron"
  attr :hide_chevron, :boolean, default: false, doc: "Hide chevron icon"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  defp native_chevron_position(%{position: "left"} = assigns) do
    ~H"""
    <div id={@id} class={[@class]} {@rest}>
      <div class={[
        "flex flex-nowrap items-center rtl:justify-start ltr:justify-start gap-2",
        @item[:hover]
      ]}>
        <.icon
          :if={!@hide_chevron}
          name={@chevron_icon}
          class={[
            "accordion-chevron transition-transform duration-300",
            "ease-in-out group-open:rotate-90 rotate-180 rtl:rotate-0 shrink-0",
            @chevron_class
          ]}
        />

        <div class="flex items-center gap-2">
          <img
            :if={!is_nil(@item[:image])}
            class={["accordion-title-media shrink-0", @item[:image_class]]}
            src={@item[:image]}
          />

          <div class={["shrink-0", @item[:icon_wrapper_class]]}>
            <.icon
              :if={!is_nil(@item[:icon])}
              name={@item[:icon]}
              class={@item[:icon_class] || "accordion-title-media"}
            />
          </div>

          <div class={["space-y-2"]}>
            <div class={[
              @item[:title_class],
              @item[:font_weight]
            ]}>
              {@item[:title]}
            </div>

            <div :if={!is_nil(@item[:description])} class="text-xs font-light">
              {@item[:description]}
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp native_chevron_position(%{position: "right"} = assigns) do
    ~H"""
    <div id={@id} class={[@class]} {@rest}>
      <div class={[
        "flex items-center justify-between gap-2",
        @item[:hover]
      ]}>
        <div class="flex items-center gap-2">
          <img
            :if={!is_nil(@item[:image])}
            class={["accordion-title-media shrink-0", @item[:image_class]]}
            src={@item[:image]}
          />

          <div class={["shrink-0", @item[:icon_wrapper_class]]}>
            <.icon
              :if={!is_nil(@item[:icon])}
              name={@item[:icon]}
              class={@item[:icon_class] || "accordion-title-media"}
            />
          </div>

          <div class={["space-y-2", @item[:title_class]]}>
            <div class={[
              @item[:title_class],
              @item[:font_weight]
            ]}>
              {@item[:title]}
            </div>

            <div :if={!is_nil(@item[:description])} class="text-xs font-light">
              {@item[:description]}
            </div>
          </div>
        </div>

        <.icon
          :if={!@hide_chevron}
          name={@chevron_icon}
          class={[
            "accordion-chevron transition-transform duration-300",
            "ease-in-out group-open:rotate-90 rtl:rotate-180 shrink-0",
            @chevron_class
          ]}
        />
      </div>
    </div>
    """
  end

  @doc """
  Shows the content of an accordion item and applies the necessary CSS classes to indicate
  its active state.

  ## Parameters

    - `js`: (optional) An existing `Phoenix.LiveView.JS` structure to apply transformations on.
    Defaults to a new `%JS{}`.
    - `id`: A string representing the unique identifier of the accordion item. It is used
    to target the specific DOM elements for showing content and applying classes.

  ## Returns

    - A `Phoenix.LiveView.JS` structure with commands to show the accordion content,
    add the `active` class to the content, and add the `active-accordion-button`
    class to the corresponding button.

  ## Example
  ```elixir
  show_accordion_content(%JS{}, "accordion-item-1")
  ```

  This example will show the content of the accordion item with the ID `accordion-item-1`
  and add the active classes to it.
  """
  def show_accordion_content(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(to: "##{id}")
    |> JS.add_class("active", to: "##{id}")
    |> JS.add_class("active-accordion-button", to: "##{id}-role-button")
  end

  @doc """
  Hides the content of an accordion item and removes the active CSS classes to indicate its
  inactive state.

  ## Parameters

    - `js`: (optional) An existing `Phoenix.LiveView.JS` structure to apply transformations on.
    Defaults to a new `%JS{}`.
    - `id`: A string representing the unique identifier of the accordion item. It is used to
    target the specific DOM elements for hiding content and removing classes.

  ## Returns

    - A `Phoenix.LiveView.JS` structure with commands to remove the `active` class from
    the content and the `active-accordion-button` class from the corresponding button.

  ## Example
  ```elixir
  hide_accordion_content(%JS{}, "accordion-item-1")
  ```
  This example will hide the content of the accordion item with the ID "accordion-item-1" and remove
  the active classes from it.
  """
  def hide_accordion_content(js \\ %JS{}, id) do
    js
    |> JS.remove_class("active", to: "##{id}")
    |> JS.remove_class("active-accordion-button", to: "##{id}-role-button")
  end

  defp space_class(_, variant)
       when variant not in ["outline_separated", "bordered_separated", "base_separated"],
       do: nil

  defp space_class("extra_small", _), do: "accordion-item-gap space-y-2"

  defp space_class("small", _), do: "accordion-item-gap space-y-3"

  defp space_class("medium", _), do: "accordion-item-gap space-y-4"

  defp space_class("large", _), do: "accordion-item-gap space-y-5"

  defp space_class("extra_large", _), do: "accordion-item-gap space-y-6"

  defp space_class("none", _), do: nil

  defp space_class(params, _) when is_binary(params), do: params

  defp menu_rounded("extra_small"), do: "[&_.accordion-summary]:rounded-sm"

  defp menu_rounded("small"), do: "[&_.accordion-summary]:rounded"

  defp menu_rounded("medium"), do: "[&_.accordion-summary]:rounded-md"

  defp menu_rounded("large"), do: "[&_.accordion-summary]:rounded-lg"

  defp menu_rounded("extra_large"), do: "[&_.accordion-summary]:rounded-xl"

  defp menu_rounded("full"), do: "[&_.accordion-summary]:rounded-full"

  defp menu_rounded(params) when is_binary(params), do: params

  defp media_size("extra_small"), do: "[&>.accordion-item-wrapper_.accordion-title-media]:size-12"

  defp media_size("small"), do: "[&>.accordion-item-wrapper_.accordion-title-media]:size-14"

  defp media_size("medium"), do: "[&>.accordion-item-wrapper_.accordion-title-media]:size-16"

  defp media_size("large"), do: "[&>.accordion-item-wrapper_.accordion-title-media]:size-20"

  defp media_size("extra_large"), do: "[&>.accordion-item-wrapper_.accordion-title-media]:size-24"

  defp media_size(params) when is_binary(params), do: params

  defp size_class("extra_small") do
    [
      "text-xs [&_.accordion-summary]:py-1 [&_.accordion-summary]:px-2"
    ]
  end

  defp size_class("small") do
    [
      "text-sm [&_.accordion-summary]:py-1.5 [&_.accordion-summary]:px-3"
    ]
  end

  defp size_class("medium") do
    [
      "text-base [&_.accordion-summary]:py-2 [&_.accordion-summary]:px-4"
    ]
  end

  defp size_class("large") do
    [
      "text-lg [&_.accordion-summary]:py-2.5 [&_.accordion-summary]:px-5"
    ]
  end

  defp size_class("extra_large") do
    [
      "text-xl [&_.accordion-summary]:py-3 [&_.accordion-summary]:px-5"
    ]
  end

  defp size_class(params) when is_binary(params), do: params

  defp rounded_size("extra_small", variant)
       when variant in ["outline_separated", "bordered_separated", "base_separated"] do
    [
      "[&_.accordion-item-wrapper_.accordion-summary]:rounded-sm"
    ]
  end

  defp rounded_size("small", variant)
       when variant in ["outline_separated", "bordered_separated", "base_separated"] do
    [
      "[&_.accordion-item-wrapper_.accordion-summary]:rounded"
    ]
  end

  defp rounded_size("medium", variant)
       when variant in ["outline_separated", "bordered_separated", "base_separated"] do
    [
      "[&_.accordion-item-wrapper_.accordion-summary]:rounded-md"
    ]
  end

  defp rounded_size("medium", variant)
       when variant in ["outline_separated", "bordered_separated", "base_separated"] do
    [
      "[&_.accordion-item-wrapper_.accordion-summary]:rounded-md"
    ]
  end

  defp rounded_size("large", variant)
       when variant in ["outline_separated", "bordered_separated", "base_separated"] do
    [
      "[&_.accordion-item-wrapper_.accordion-summary]:rounded-lg"
    ]
  end

  defp rounded_size("extra_large", variant)
       when variant in ["outline_separated", "bordered_separated", "base_separated"] do
    [
      "[&_.accordion-item-wrapper_.accordion-summary]:rounded-xl"
    ]
  end

  defp rounded_size("extra_small", variant)
       when variant in ["default", "bordered", "outline", "base", "shadow", "gradient"] do
    [
      "rounded-sm [&:not(.accordion-item-gap)>.accordion-item-wrapper:first-child>.accordion-summary]:rounded-t-sm",
      "[&.accordion-item-gap>.accordion-item-wrapper>.accordion-summary]:rounded-t-sm",
      "[&.accordion-item-gap>.accordion-item-wrapper>:not(.accordion-summary)]:rounded-b-sm"
    ]
  end

  defp rounded_size("small", variant)
       when variant in ["default", "bordered", "outline", "base", "shadow", "gradient"] do
    [
      "rounded [&:not(.accordion-item-gap)>.accordion-item-wrapper:first-child>.accordion-summary]:rounded-t",
      "[&.accordion-item-gap>.accordion-item-wrapper>.accordion-summary]:rounded-t",
      "[&.accordion-item-gap>.accordion-item-wrapper>:not(.accordion-summary)]:rounded-b"
    ]
  end

  defp rounded_size("medium", variant)
       when variant in ["default", "bordered", "outline", "base", "shadow", "gradient"] do
    [
      "rounded-md [&:not(.accordion-item-gap)>.accordion-item-wrapper:first-child>.accordion-summary]:rounded-t-md",
      "[&.accordion-item-gap>.accordion-item-wrapper>.accordion-summary]:rounded-t-md",
      "[&.accordion-item-gap>.accordion-item-wrapper>:not(.accordion-summary)]:rounded-b-md"
    ]
  end

  defp rounded_size("large", variant)
       when variant in ["default", "bordered", "outline", "base", "shadow", "gradient"] do
    [
      "rounded-lg [&:not(.accordion-item-gap)>.accordion-item-wrapper:first-child>.accordion-summary]:rounded-t-lg",
      "[&.accordion-item-gap>.accordion-item-wrapper>.accordion-summary]:rounded-t-lg",
      "[&.accordion-item-gap>.accordion-item-wrapper>:not(.accordion-summary)]:rounded-b-lg"
    ]
  end

  defp rounded_size("extra_large", variant)
       when variant in ["default", "bordered", "outline", "base", "shadow", "gradient"] do
    [
      "rounded-xl [&:not(.accordion-item-gap)>.accordion-item-wrapper:first-child>.accordion-summary]:rounded-t-xl",
      "[&.accordion-item-gap>.accordion-item-wrapper>.accordion-summary]:rounded-t-xl",
      "[&.accordion-item-gap>.accordion-item-wrapper>:not(.accordion-summary)]:rounded-b-xl"
    ]
  end

  defp rounded_size("none", _), do: nil

  defp rounded_size(params, _) when is_binary(params), do: params

  defp padding_size("extra_small") do
    [
      "[&>.accordion-item-wrapper>.accordion-summary]:p-1",
      "[&>.accordion-item-wrapper>.custom-accordion-content]:p-1",
      "[&>.accordion-item-wrapper>.accordion-content-wrapper>.accordion-content]:px-1",
      "[&>.accordion-item-wrapper>.accordion-content-wrapper.active>.accordion-content]:py-1"
    ]
  end

  defp padding_size("small") do
    [
      "[&>.accordion-item-wrapper>.accordion-summary]:p-2",
      "[&>.accordion-item-wrapper>.custom-accordion-content]:p-2",
      "[&>.accordion-item-wrapper>.accordion-content-wrapper>.accordion-content]:px-2",
      "[&>.accordion-item-wrapper>.accordion-content-wrapper.active>.accordion-content]:py-2"
    ]
  end

  defp padding_size("medium") do
    [
      "[&>.accordion-item-wrapper>.accordion-summary]:p-3",
      "[&>.accordion-item-wrapper>.custom-accordion-content]:p-3",
      "[&>.accordion-item-wrapper>.accordion-content-wrapper>.accordion-content]:px-3",
      "[&>.accordion-item-wrapper>.accordion-content-wrapper.active>.accordion-content]:py-3"
    ]
  end

  defp padding_size("large") do
    [
      "[&>.accordion-item-wrapper>.accordion-summary]:p-4",
      "[&>.accordion-item-wrapper>.custom-accordion-content]:p-4",
      "[&>.accordion-item-wrapper>.accordion-content-wrapper>.accordion-content]:px-4",
      "[&>.accordion-item-wrapper>.accordion-content-wrapper.active>.accordion-content]:py-4"
    ]
  end

  defp padding_size("extra_large") do
    [
      "[&>.accordion-item-wrapper>.accordion-summary]:p-5",
      "[&>.accordion-item-wrapper>.custom-accordion-content]:p-5",
      "[&>.accordion-item-wrapper>.accordion-content-wrapper>.accordion-content]:px-5",
      "[&>.accordion-item-wrapper>.accordion-content-wrapper.active>.accordion-content]:py-5"
    ]
  end

  defp padding_size("zero"), do: "[&>.accordion-item-wrapper>.accordion-summary]:p-0"
  defp padding_size(params) when is_binary(params), do: params

  defp border_class(_, variant) when variant in ["default", "shadow", "transparent", "gradient"],
    do: nil

  defp border_class("none", "outline") do
    [
      "border-0",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-b-0",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-b-0"
    ]
  end

  defp border_class("extra_small", "outline") do
    [
      "border",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-b"
    ]
  end

  defp border_class("small", "outline") do
    [
      "border-2",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-b-2",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-b-2"
    ]
  end

  defp border_class("medium", "outline") do
    [
      "border-[3px]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-b-[3px]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-b-[3px]"
    ]
  end

  defp border_class("large", "outline") do
    [
      "border-4",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-b-4",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-b-4"
    ]
  end

  defp border_class("extra_large", "outline") do
    [
      "border-[5px]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-b-[5px]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-b-[5px]"
    ]
  end

  defp border_class("none", "bordered") do
    [
      "border-0",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-b-0",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-b-0"
    ]
  end

  defp border_class("extra_small", "bordered") do
    [
      "border",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-b"
    ]
  end

  defp border_class("small", "bordered") do
    [
      "border-2",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-b-2",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-b-2"
    ]
  end

  defp border_class("medium", "bordered") do
    [
      "border-[3px]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-b-[3px]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-b-[3px]"
    ]
  end

  defp border_class("large", "bordered") do
    [
      "border-4",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-b-4",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-b-4"
    ]
  end

  defp border_class("extra_large", "bordered") do
    [
      "border-[5px]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-b-[5px]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-b-[5px]"
    ]
  end

  defp border_class("none", "bordered_separated") do
    "[&>.accordion-item-wrapper>.accordion-summary]:border-0"
  end

  defp border_class("extra_small", "bordered_separated") do
    "[&>.accordion-item-wrapper>.accordion-summary]:border"
  end

  defp border_class("small", "bordered_separated") do
    "[&>.accordion-item-wrapper>.accordion-summary]:border-2"
  end

  defp border_class("medium", "bordered_separated") do
    "[&>.accordion-item-wrapper>.accordion-summary]:border-[3px]"
  end

  defp border_class("large", "bordered_separated") do
    "[&>.accordion-item-wrapper>.accordion-summary]:border-4"
  end

  defp border_class("extra_large", "bordered_separated") do
    "[&>.accordion-item-wrapper>.accordion-summary]:border-[5px]"
  end

  defp border_class("none", "outline_separated") do
    "[&>.accordion-item-wrapper>.accordion-summary]:border-0"
  end

  defp border_class("extra_small", "outline_separated") do
    "[&>.accordion-item-wrapper>.accordion-summary]:border"
  end

  defp border_class("small", "outline_separated") do
    "[&>.accordion-item-wrapper>.accordion-summary]:border-2"
  end

  defp border_class("medium", "outline_separated") do
    "[&>.accordion-item-wrapper>.accordion-summary]:border-[3px]"
  end

  defp border_class("large", "outline_separated") do
    "[&>.accordion-item-wrapper>.accordion-summary]:border-4"
  end

  defp border_class("extra_large", "outline_separated") do
    "[&>.accordion-item-wrapper>.accordion-summary]:border-[5px]"
  end

  defp border_class("none", "base") do
    [
      "border-0",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-b-0",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-b-0"
    ]
  end

  defp border_class("extra_small", "base") do
    [
      "border",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-b",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-b"
    ]
  end

  defp border_class("small", "base") do
    [
      "border-2",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-b-2",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-b-2"
    ]
  end

  defp border_class("medium", "base") do
    [
      "border-[3px]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-b-[3px]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-b-[3px]"
    ]
  end

  defp border_class("large", "base") do
    [
      "border-4",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-b-4",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-b-4"
    ]
  end

  defp border_class("extra_large", "base") do
    [
      "border-[5px]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-b-[5px]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-b-[5px]"
    ]
  end

  defp border_class("none", "base_separated") do
    "[&>.accordion-item-wrapper>.accordion-summary]:border-0"
  end

  defp border_class("extra_small", "base_separated") do
    "[&>.accordion-item-wrapper>.accordion-summary]:border"
  end

  defp border_class("small", "base_separated") do
    "[&>.accordion-item-wrapper>.accordion-summary]:border-2"
  end

  defp border_class("medium", "base_separated") do
    "[&>.accordion-item-wrapper>.accordion-summary]:border-[3px]"
  end

  defp border_class("large", "base_separated") do
    "[&>.accordion-item-wrapper>.accordion-summary]:border-4"
  end

  defp border_class("extra_large", "base_separated") do
    "[&>.accordion-item-wrapper>.accordion-summary]:border-[5px]"
  end

  defp border_class(params, _) when is_binary(params), do: params

  defp color_variant("base", _) do
    [
      "text-[#09090b] border-[#e4e4e7] bg-white",
      "dark:text-[#FAFAFA] dark:border-[#27272a] dark:bg-[#18181B]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#F8F9FA] dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#242424]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#e4e4e7]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#e4e4e7]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#27272a]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#27272a]"
    ]
  end

  defp color_variant("base_separated", _) do
    [
      "text-[#09090b] [&>.accordion-item-wrapper>.accordion-summary]:border-[#e4e4e7]",
      "[&>.accordion-item-wrapper]:bg-white",
      "dark:text-[#FAFAFA] dark:[&>.accordion-item-wrapper>.accordion-summary]:border-[#27272a]",
      "dark:[&>.accordion-item-wrapper]:bg-[#18181B]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#F8F9FA] dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#242424]"
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

  defp color_variant("default", "white") do
    [
      "bg-white text-black",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#DDDDDD]",
      "dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#DDDDDD]"
    ]
  end

  defp color_variant("default", "dark") do
    [
      "bg-[#282828] text-white",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#4B4B4B]",
      "dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#4B4B4B]"
    ]
  end

  defp color_variant("default", "natural") do
    [
      "bg-[#4B4B4B] text-white dark:bg-[#DDDDDD] dark:text-black",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#282828]",
      "dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#E8E8E8]"
    ]
  end

  defp color_variant("default", "primary") do
    [
      "bg-[#007F8C] text-white hover:bg-[#016974] dark:bg-[#01B8CA] dark:text-black",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#016974]",
      "dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#77D5E3]"
    ]
  end

  defp color_variant("default", "secondary") do
    [
      "bg-[#266EF1] text-white dark:bg-[#6DAAFB] dark:text-black",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#175BCC]",
      "dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#A9C9FF]"
    ]
  end

  defp color_variant("default", "success") do
    [
      "bg-[#0E8345] text-white dark:bg-[#06C167] dark:text-black",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#166C3B]",
      "dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#7FD99A]"
    ]
  end

  defp color_variant("default", "warning") do
    [
      "bg-[#CA8D01] text-white dark:bg-[#FDC034] dark:text-black",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#976A01]",
      "dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#FDD067]"
    ]
  end

  defp color_variant("default", "danger") do
    [
      "bg-[#DE1135] text-white dark:bg-[#FC7F79] dark:text-black",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#BB032A]",
      "dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#FFB2AB]"
    ]
  end

  defp color_variant("default", "info") do
    [
      "bg-[#0B84BA] text-white dark:bg-[#3EB7ED] dark:text-black",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#08638C]",
      "dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#6EC9F2]"
    ]
  end

  defp color_variant("default", "misc") do
    [
      "bg-[#8750C5] text-white dark:bg-[#BA83F9] dark:text-black",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#653C94]",
      "dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#CBA2FA]"
    ]
  end

  defp color_variant("default", "dawn") do
    [
      "bg-[#A86438] text-white dark:bg-[#DB976B] dark:text-black",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#7E4B2A]",
      "dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#E4B190]"
    ]
  end

  defp color_variant("default", "silver") do
    [
      "bg-[#868686] text-white dark:bg-[#A6A6A6] dark:text-black",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#727272]",
      "dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#BBBBBB]"
    ]
  end

  defp color_variant("outline", "natural") do
    [
      "border-[#4B4B4B] dark:border-[#DDDDDD] text-[#4B4B4B] dark:text-[#DDDDDD]",
      "hover:text-[#282828] dark:hover:text-[#E8E8E8]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#4B4B4B]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#4B4B4B]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#DDDDDD]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#DDDDDD]"
    ]
  end

  defp color_variant("outline", "primary") do
    [
      "border-[#007F8C] dark:border-[#01B8CA] text-[#007F8C] dark:text-[#01B8CA]",
      "hover:text-[#016974] dark:hover:text-[#77D5E3]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#007F8C]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#007F8C]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#01B8CA]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#01B8CA]"
    ]
  end

  defp color_variant("outline", "secondary") do
    [
      "border-[#266EF1] dark:border-[#6DAAFB] text-[#266EF1] dark:text-[#6DAAFB]",
      "hover:text-[#175BCC] dark:hover:text-[#A9C9FF]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#266EF1]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#266EF1]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#6DAAFB]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#6DAAFB]"
    ]
  end

  defp color_variant("outline", "success") do
    [
      "border-[#0E8345] dark:border-[#06C167] text-[#0E8345] dark:text-[#06C167]",
      "hover:text-[#166C3B] dark:hover:text-[#7FD99A]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#0E8345]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#0E8345]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#06C167]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#06C167]"
    ]
  end

  defp color_variant("outline", "warning") do
    [
      "border-[#CA8D01] dark:border-[#FDC034] text-[#CA8D01] dark:text-[#FDC034]",
      "hover:text-[#976A01] dark:hover:text-[#FDD067]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#CA8D01]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#CA8D01]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#FDC034]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#FDC034]"
    ]
  end

  defp color_variant("outline", "danger") do
    [
      "border-[#DE1135] dark:border-[#FC7F79] text-[#DE1135] dark:text-[#FC7F79]",
      "hover:text-[#BB032A] dark:hover:text-[#FFB2AB]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#DE1135]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#DE1135]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#FC7F79]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#FC7F79]"
    ]
  end

  defp color_variant("outline", "info") do
    [
      "border-[#0B84BA] dark:border-[#3EB7ED] text-[#0B84BA] dark:text-[#3EB7ED]",
      "hover:text-[#08638C] dark:hover:text-[#6EC9F2]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#0B84BA]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#0B84BA]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#3EB7ED]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#3EB7ED]"
    ]
  end

  defp color_variant("outline", "misc") do
    [
      "border-[#8750C5] dark:border-[#BA83F9] text-[#8750C5] dark:text-[#BA83F9]",
      "hover:text-[#653C94] dark:hover:text-[#CBA2FA]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#8750C5]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#8750C5]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#BA83F9]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#BA83F9]"
    ]
  end

  defp color_variant("outline", "dawn") do
    [
      "border-[#A86438] dark:border-[#DB976B] text-[#A86438] dark:text-[#DB976B]",
      "hover:text-[#7E4B2A] dark:hover:text-[#7E4B2A]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#A86438]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#A86438]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#DB976B]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#DB976B]"
    ]
  end

  defp color_variant("outline", "silver") do
    [
      "border-[#868686] dark:border-[#A6A6A6] text-[#868686] dark:text-[#A6A6A6]",
      "hover:text-[#727272] dark:hover:text-[#BBBBBB]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#868686]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#868686]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#A6A6A6]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#A6A6A6]"
    ]
  end

  defp color_variant("bordered", "white") do
    [
      ":bg-white text-black border-[#DDDDDD]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#DDDDDD]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#DDDDDD]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#DDDDDD]"
    ]
  end

  defp color_variant("bordered", "dark") do
    [
      ":bg-[#282828] text-white border-[#727272]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#727272]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#727272]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#727272]"
    ]
  end

  defp color_variant("bordered", "natural") do
    [
      "text-[#282828] border-[#282828] bg-[#F3F3F3]",
      "dark:text-[#E8E8E8] dark:border-[#E8E8E8] dark:bg-[#4B4B4B]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#E8E8E8] dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#5E5E5E]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#282828]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#282828]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#E8E8E8]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#E8E8E8]"
    ]
  end

  defp color_variant("bordered", "primary") do
    [
      "text-[#016974] border-[#016974] bg-[#E2F8FB]",
      "dark:text-[#77D5E3] dark:border-[#77D5E3] dark:bg-[#002D33]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#CDEEF3] dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#1A535A]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#016974]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#016974]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#77D5E3]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#77D5E3]"
    ]
  end

  defp color_variant("bordered", "secondary") do
    [
      "text-[#175BCC] border-[#175BCC] bg-[#EFF4FE]",
      "dark:text-[#A9C9FF] dark:border-[#A9C9FF] dark:bg-[#002661]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#DEE9FE] dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#1948A3]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#175BCC]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#175BCC]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#A9C9FF]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#A9C9FF]"
    ]
  end

  defp color_variant("bordered", "success") do
    [
      "text-[#166C3B] border-[#166C3B] bg-[#EAF6ED]",
      "dark:text-[#7FD99A] dark:border-[#7FD99A] dark:bg-[#002F14]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#D3EFDA] dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#0D572D]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#166C3B]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#166C3B]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#7FD99A]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#7FD99A]"
    ]
  end

  defp color_variant("bordered", "warning") do
    [
      "text-[#976A01] border-[#976A01] bg-[#FFF7E6]",
      "dark:text-[#FDD067] dark:border-[#FDD067] dark:bg-[#322300]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#FEEFCC] dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#654600]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#976A01]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#976A01]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#FDD067]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#FDD067]"
    ]
  end

  defp color_variant("bordered", "danger") do
    [
      "text-[#BB032A] border-[#BB032A] bg-[#FFF0EE]",
      "dark:text-[#FFB2AB] dark:border-[#FFB2AB] dark:bg-[#520810]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#FFE1DE] dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#950F22]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#BB032A]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#BB032A]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#FFB2AB]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#FFB2AB]"
    ]
  end

  defp color_variant("bordered", "info") do
    [
      "text-[#0B84BA] border-[#0B84BA] bg-[#E7F6FD]",
      "dark:text-[#6EC9F2] dark:border-[#6EC9F2] dark:bg-[#03212F]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#CFEDFB] dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#06425D]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#0B84BA]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#0B84BA]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#6EC9F2]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#6EC9F2]"
    ]
  end

  defp color_variant("bordered", "misc") do
    [
      "text-[#653C94] border-[#653C94] bg-[#F6F0FE]",
      "dark:text-[#CBA2FA] dark:border-[#CBA2FA] dark:bg-[#221431]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#EEE0FD] dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#442863]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#653C94]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#653C94]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#CBA2FA]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#CBA2FA]"
    ]
  end

  defp color_variant("bordered", "dawn") do
    [
      "text-[#7E4B2A] border-[#7E4B2A] bg-[#FBF2ED]",
      "dark:text-[#E4B190] dark:border-[#E4B190] dark:bg-[#2A190E]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#F6E5DA] dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#54321C]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#7E4B2A]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#7E4B2A]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#E4B190]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#E4B190]"
    ]
  end

  defp color_variant("bordered", "silver") do
    [
      "text-[#727272] border-[#727272] bg-[#F3F3F3]",
      "dark:text-[#BBBBBB] dark:border-[#BBBBBB] dark:bg-[#4B4B4B]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#E8E8E8] dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#5E5E5E]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#727272]",
      "[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#727272]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-summary]:border-[#BBBBBB]",
      "dark:[&>.accordion-item-wrapper:not(:last-child)>.accordion-content-wrapper.active]:border-[#BBBBBB]"
    ]
  end

  defp color_variant("bordered_separated", "natural") do
    [
      "text-[#282828] [&>.accordion-item-wrapper>.accordion-summary]:border-[#282828]",
      "[&>.accordion-item-wrapper]:bg-[#F3F3F3]",
      "dark:text-[#E8E8E8] dark:[&>.accordion-item-wrapper>.accordion-summary]:border-[#E8E8E8]",
      "dark:[&>.accordion-item-wrapper]:bg-[#4B4B4B]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#E8E8E8] dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#5E5E5]"
    ]
  end

  defp color_variant("bordered_separated", "primary") do
    [
      "text-[#016974] [&>.accordion-item-wrapper>.accordion-summary]:border-[#016974]",
      "[&>.accordion-item-wrapper]:bg-[#E2F8FB]",
      "dark:text-[#77D5E3] dark:[&>.accordion-item-wrapper>.accordion-summary]:border-[#77D5E3]",
      "dark:[&>.accordion-item-wrapper]:bg-[#002D33]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#CDEEF3] dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#1A535A]"
    ]
  end

  defp color_variant("bordered_separated", "secondary") do
    [
      "text-[#175BCC] [&>.accordion-item-wrapper>.accordion-summary]:border-[#175BCC]",
      "[&>.accordion-item-wrapper]:bg-[#EFF4FE]",
      "dark:text-[#A9C9FF] dark:[&>.accordion-item-wrapper>.accordion-summary]:border-[#A9C9FF]",
      "dark:[&>.accordion-item-wrapper]:bg-[#002661]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#DEE9FE] dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#1948A3]"
    ]
  end

  defp color_variant("bordered_separated", "success") do
    [
      "text-[#166C3B] [&>.accordion-item-wrapper>.accordion-summary]:border-[#166C3B]",
      "[&>.accordion-item-wrapper]:bg-[#EAF6ED]",
      "dark:text-[#7FD99A] dark:[&>.accordion-item-wrapper>.accordion-summary]:border-[#7FD99A]",
      "dark:[&>.accordion-item-wrapper]:bg-[#002F14]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#D3EFDA] dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#0D572D]"
    ]
  end

  defp color_variant("bordered_separated", "warning") do
    [
      "text-[#976A01] [&>.accordion-item-wrapper>.accordion-summary]:border-[#976A01]",
      "[&>.accordion-item-wrapper]:bg-[#FFF7E6]",
      "dark:text-[#FDD067] dark:[&>.accordion-item-wrapper>.accordion-summary]:border-[#FDD067]",
      "dark:[&>.accordion-item-wrapper]:bg-[#322300]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#FEEFCC] dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#654600]"
    ]
  end

  defp color_variant("bordered_separated", "danger") do
    [
      "text-[#BB032A] [&>.accordion-item-wrapper>.accordion-summary]:border-[#BB032A]",
      "[&>.accordion-item-wrapper]:bg-[#FFF0EE]",
      "dark:text-[#FFB2AB] dark:[&>.accordion-item-wrapper>.accordion-summary]:border-[#FFB2AB]",
      "dark:[&>.accordion-item-wrapper]:bg-[#520810]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#FFE1DE] dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#950F22]"
    ]
  end

  defp color_variant("bordered_separated", "info") do
    [
      "text-[#0B84BA] [&>.accordion-item-wrapper>.accordion-summary]:border-[#0B84BA]",
      "[&>.accordion-item-wrapper]:bg-[#E7F6FD]",
      "dark:text-[#6EC9F2] dark:[&>.accordion-item-wrapper>.accordion-summary]:border-[#6EC9F2]",
      "dark:[&>.accordion-item-wrapper]:bg-[#03212F]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#CFEDFB] dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#06425D]"
    ]
  end

  defp color_variant("bordered_separated", "misc") do
    [
      "text-[#653C94] [&>.accordion-item-wrapper>.accordion-summary]:border-[#653C94]",
      "[&>.accordion-item-wrapper]:bg-[#F6F0FE]",
      "dark:text-[#CBA2FA] dark:[&>.accordion-item-wrapper>.accordion-summary]:border-[#CBA2FA]",
      "dark:[&>.accordion-item-wrapper]:bg-[#221431]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#EEE0FD] dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#442863]"
    ]
  end

  defp color_variant("bordered_separated", "dawn") do
    [
      "text-[#7E4B2A] [&>.accordion-item-wrapper>.accordion-summary]:border-[#7E4B2A]",
      "[&>.accordion-item-wrapper]:bg-[#FBF2ED]",
      "dark:text-[#E4B190] dark:[&>.accordion-item-wrapper>.accordion-summary]:border-[#E4B190]",
      "dark:[&>.accordion-item-wrapper]:bg-[#2A190E]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#F6E5DA] dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#54321C]"
    ]
  end

  defp color_variant("bordered_separated", "silver") do
    [
      "text-[#727272] [&>.accordion-item-wrapper>.accordion-summary]:border-[#727272]",
      "[&>.accordion-item-wrapper]:bg-[#F3F3F3]",
      "dark:text-[#BBBBBB] dark:[&>.accordion-item-wrapper>.accordion-summary]:border-[#BBBBBB]",
      "dark:[&>.accordion-item-wrapper]:bg-[#4B4B4B]",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#E8E8E8] dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#5E5E5E]"
    ]
  end

  defp color_variant("outline_separated", "natural") do
    [
      "text-[#4B4B4B] [&>.accordion-item-wrapper>.accordion-summary]:border-[#4B4B4B]",
      "dark:text-[#DDDDDD] dark:[&>.accordion-item-wrapper>.accordion-summary]:border-[#DDDDDD]",
      "hover:text-[#282828] dark:hover:text-[#E8E8E8]"
    ]
  end

  defp color_variant("outline_separated", "primary") do
    [
      "text-[#007F8C] [&>.accordion-item-wrapper>.accordion-summary]:border-[#007F8C] ",
      "dark:text-[#01B8CA] dark:[&>.accordion-item-wrapper>.accordion-summary]:border-[#01B8CA]",
      "hover:text-[#016974] dark:hover:text-[#77D5E3]"
    ]
  end

  defp color_variant("outline_separated", "secondary") do
    [
      "text-[#266EF1] [&>.accordion-item-wrapper>.accordion-summary]:border-[#266EF1]",
      "dark:text-[#6DAAFB] dark:[&>.accordion-item-wrapper>.accordion-summary]:border-[#6DAAFB]",
      "hover:text-[#175BCC] dark:hover:text-[#A9C9FF]"
    ]
  end

  defp color_variant("outline_separated", "success") do
    [
      "text-[#0E8345] [&>.accordion-item-wrapper>.accordion-summary]:border-[#0E8345]",
      "dark:text-[#06C167] dark:[&>.accordion-item-wrapper>.accordion-summary]:border-[#06C167]",
      "hover:text-[#166C3B] dark:hover:text-[#7FD99A]"
    ]
  end

  defp color_variant("outline_separated", "warning") do
    [
      "text-[#CA8D01] [&>.accordion-item-wrapper>.accordion-summary]:border-[#CA8D01]",
      "dark:text-[#FDC034] dark:[&>.accordion-item-wrapper>.accordion-summary]:border-[#FDC034]",
      "hover:text-[#976A01] dark:hover:text-[#FDD067]"
    ]
  end

  defp color_variant("outline_separated", "danger") do
    [
      "text-[#DE1135] [&>.accordion-item-wrapper>.accordion-summary]:border-[#DE1135]",
      "dark:text-[#FC7F79] dark:[&>.accordion-item-wrapper>.accordion-summary]:border-[#FC7F79]",
      "hover:text-[#BB032A] dark:hover:text-[#FFB2AB]"
    ]
  end

  defp color_variant("outline_separated", "info") do
    [
      "text-[#0B84BA] [&>.accordion-item-wrapper>.accordion-summary]:border-[#0B84BA]",
      "dark:text-[#3EB7ED] dark:[&>.accordion-item-wrapper>.accordion-summary]:border-[#3EB7ED]",
      "hover:text-[#08638C] dark:hover:text-[#6EC9F2]"
    ]
  end

  defp color_variant("outline_separated", "misc") do
    [
      "text-[#8750C5] [&>.accordion-item-wrapper>.accordion-summary]:border-[#8750C5]",
      "dark:text-[#BA83F9] dark:[&>.accordion-item-wrapper>.accordion-summary]:border-[#BA83F9]",
      "hover:text-[#653C94] dark:hover:text-[#CBA2FA]"
    ]
  end

  defp color_variant("outline_separated", "dawn") do
    [
      "text-[#A86438] [&>.accordion-item-wrapper>.accordion-summary]:border-[#A86438]",
      "dark:text-[#DB976B] dark:[&>.accordion-item-wrapper>.accordion-summary]:border-[#DB976B]",
      "hover:text-[#7E4B2A] dark:hover:text-[#7E4B2A]"
    ]
  end

  defp color_variant("outline_separated", "silver") do
    [
      "text-[#868686] [&>.accordion-item-wrapper>.accordion-summary]:border-[#868686]",
      "dark:text-[#A6A6A6] dark:[&>.accordion-item-wrapper>.accordion-summary]:border-[#A6A6A6]",
      "hover:text-[#727272] dark:hover:text-[#BBBBBB]"
    ]
  end

  defp color_variant("menu", "white") do
    [
      "[&>.accordion-item-wrapper]:bg-white text-black"
    ]
  end

  defp color_variant("menu", "dark") do
    [
      "[&>.accordion-item-wrapper]:bg-[#282828] text-white"
    ]
  end

  defp color_variant("menu", "natural") do
    [
      "[&>.accordion-item-wrapper]:bg-[#4B4B4B] text-white",
      "dark:[&>.accordion-item-wrapper]:bg-[#DDDDDD] dark:text-black"
    ]
  end

  defp color_variant("menu", "primary") do
    [
      "[&>.accordion-item-wrapper]:bg-[#007F8C] text-white",
      "dark:[&>.accordion-item-wrapper]:bg-[#01B8CA] dark:text-black"
    ]
  end

  defp color_variant("menu", "secondary") do
    [
      "[&>.accordion-item-wrapper]:bg-[#266EF1] text-white",
      "dark:[&>.accordion-item-wrapper]:bg-[#6DAAFB] dark:text-black"
    ]
  end

  defp color_variant("menu", "success") do
    [
      "[&>.accordion-item-wrapper]:bg-[#0E8345] text-white",
      "dark:[&>.accordion-item-wrapper]:bg-[#06C167] dark:text-black"
    ]
  end

  defp color_variant("menu", "warning") do
    [
      "[&>.accordion-item-wrapper]:bg-[#CA8D01] text-white",
      "dark:[&>.accordion-item-wrapper]:bg-[#FDC034] dark:text-black"
    ]
  end

  defp color_variant("menu", "danger") do
    [
      "[&>.accordion-item-wrapper]:bg-[#DE1135] text-white",
      "dark:[&>.accordion-item-wrapper]:bg-[#FC7F79] dark:text-black"
    ]
  end

  defp color_variant("menu", "info") do
    [
      "[&>.accordion-item-wrapper]:bg-[#0B84BA] text-white",
      "dark:[&>.accordion-item-wrapper]:bg-[#3EB7ED] dark:text-black"
    ]
  end

  defp color_variant("menu", "misc") do
    [
      "[&>.accordion-item-wrapper]:bg-[#8750C5] text-white",
      "dark:[&>.accordion-item-wrapper]:bg-[#BA83F9] dark:text-black"
    ]
  end

  defp color_variant("menu", "dawn") do
    [
      "[&>.accordion-item-wrapper]:bg-[#A86438] text-white",
      "dark:[&>.accordion-item-wrapper]:bg-[#DB976B] dark:text-black"
    ]
  end

  defp color_variant("menu", "silver") do
    [
      "[&>.accordion-item-wrapper]:bg-[#868686] text-white",
      "dark:[&>.accordion-item-wrapper]:bg-[#A6A6A6] dark:text-black"
    ]
  end

  defp color_variant("shadow", "natural") do
    [
      "bg-[#4B4B4B] text-white dark:bg-[#DDDDDD] dark:text-black",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#282828]",
      "dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#E8E8E8]",
      "shadow-[0px_4px_6px_-4px_rgba(134,134,134,0.5)] shadow-[0px_10px_15px_-3px_rgba(134,134,134,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "primary") do
    [
      "bg-[#007F8C] text-white dark:bg-[#01B8CA] dark:text-black",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#016974]",
      "dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#77D5E3]",
      "shadow-[0px_4px_6px_-4px_rgba(0,149,164,0.5)] shadow-[0px_10px_15px_-3px_rgba(0,149,164,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "secondary") do
    [
      "bg-[#266EF1] text-white dark:bg-[#6DAAFB] dark:text-black",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#175BCC]",
      "dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#A9C9FF]",
      "shadow-[0px_4px_6px_-4px_rgba(6,139,238,0.5)] shadow-[0px_10px_15px_-3px_rgba(6,139,238,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "success") do
    [
      "bg-[#0E8345] text-white hover:bg-[#166C3B] dark:bg-[#06C167] dark:text-black",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#166C3B]",
      "dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#7FD99A]",
      "shadow-[0px_4px_6px_-4px_rgba(0,154,81,0.5)] shadow-[0px_10px_15px_-3px_rgba(0,154,81,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "warning") do
    [
      "bg-[#CA8D01] text-white dark:bg-[#FDC034] dark:text-black",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#976A01]",
      "dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#FDD067]",
      "shadow-[0px_4px_6px_-4px_rgba(252,176,1,0.5)] shadow-[0px_10px_15px_-3px_rgba(252,176,1,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "danger") do
    [
      "bg-[#DE1135] text-white dark:bg-[#FC7F79] dark:text-black",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#BB032A]",
      "dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#FFB2AB]",
      "shadow-[0px_4px_6px_-4px_rgba(248,52,70,0.5)] shadow-[0px_10px_15px_-3px_rgba(248,52,70,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "info") do
    [
      "bg-[#0B84BA] text-white dark:bg-[#3EB7ED] dark:text-black",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#08638C]",
      "dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#6EC9F2]",
      "shadow-[0px_4px_6px_-4px_rgba(14,165,233,0.5)] shadow-[0px_10px_15px_-3px_rgba(14,165,233,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "misc") do
    [
      "bg-[#8750C5] text-white dark:bg-[#BA83F9] dark:text-black",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#653C94]",
      "dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#CBA2FA]",
      "shadow-[0px_4px_6px_-4px_rgba(169,100,247,0.5)] shadow-[0px_10px_15px_-3px_rgba(169,100,247,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "dawn") do
    [
      "bg-[#A86438] text-white dark:bg-[#DB976B] dark:text-black",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#7E4B2A]",
      "dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#E4B190]",
      "shadow-[0px_4px_6px_-4px_rgba(210,125,70,0.5)] shadow-[0px_10px_15px_-3px_rgba(210,125,70,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "silver") do
    [
      "bg-[#868686] text-white dark:bg-[#A6A6A6] dark:text-black",
      "hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#727272]",
      "dark:hover:[&>.accordion-item-wrapper>.accordion-summary]:bg-[#BBBBBB]",
      "shadow-[0px_4px_6px_-4px_rgba(134,134,134,0.5)] shadow-[0px_10px_15px_-3px_rgba(134,134,134,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("gradient", "natural") do
    [
      "bg-gradient-to-br from-[#282828] to-[#727272] text-white",
      "dark:from-[#A6A6A6] dark:to-[#FFFFFF] dark:text-black"
    ]
  end

  defp color_variant("gradient", "primary") do
    [
      "bg-gradient-to-br from-[#016974] to-[#01B8CA] text-white",
      "dark:from-[#01B8CA] dark:to-[#B0E7EF] dark:text-black"
    ]
  end

  defp color_variant("gradient", "secondary") do
    [
      "bg-gradient-to-br from-[#175BCC] to-[#6DAAFB] text-white",
      "dark:from-[#6DAAFB] dark:to-[#CDDEFF] dark:text-black"
    ]
  end

  defp color_variant("gradient", "success") do
    [
      "bg-gradient-to-br from-[#166C3B] to-[#06C167] text-white",
      "dark:from-[#06C167] dark:to-[#B1EAC2] dark:text-black"
    ]
  end

  defp color_variant("gradient", "warning") do
    [
      "bg-gradient-to-br from-[#976A01] to-[#FDC034] text-white",
      "dark:from-[#FDC034] dark:to-[#FEDF99] dark:text-black"
    ]
  end

  defp color_variant("gradient", "danger") do
    [
      "bg-gradient-to-br from-[#BB032A] to-[#FC7F79] text-white",
      "dark:from-[#FC7F79] dark:to-[#FFD2CD] dark:text-black"
    ]
  end

  defp color_variant("gradient", "info") do
    [
      "bg-gradient-to-br from-[#08638C] to-[#3EB7ED] text-white",
      "dark:from-[#3EB7ED] dark:to-[#9FDBF6] dark:text-black"
    ]
  end

  defp color_variant("gradient", "misc") do
    [
      "bg-gradient-to-br from-[#653C94] to-[#BA83F9] text-white",
      "dark:from-[#BA83F9] dark:to-[#DDC1FC] dark:text-black"
    ]
  end

  defp color_variant("gradient", "dawn") do
    [
      "bg-gradient-to-br from-[#7E4B2A] to-[#DB976B] text-white",
      "dark:from-[#DB976B] dark:to-[#EDCBB5] dark:text-black"
    ]
  end

  defp color_variant("gradient", "silver") do
    [
      "bg-gradient-to-br from-[#5E5E5E] to-[#A6A6A6] text-white",
      "dark:from-[#868686] dark:to-[#BBBBBB] dark:text-black"
    ]
  end

  defp color_variant(params, _) when is_binary(params), do: params

  defp item_color("base", _) do
    [
      "group-open:bg-white group-open:text-[#09090b] dark:group-open:bg-[#18181B] dark:group-open:text-[#FAFAFA]"
    ]
  end

  defp item_color("base_separated", _) do
    [
      "group-open:bg-white group-open:text-[#09090b] dark:group-open:bg-[#18181B] dark:group-open:text-[#FAFAFA]"
    ]
  end

  defp item_color("default", "white") do
    [
      "group-open:bg-white text-black",
      "group-open:hover:[&:is(.accordion-summary)]:bg-[#DDDDDD]"
    ]
  end

  defp item_color("default", "dark") do
    [
      "group-open:bg-[#282828] text-white",
      "group-open:hover:[&:is(.accordion-summary)]:bg-[#4B4B4B]"
    ]
  end

  defp item_color("default", "natural") do
    [
      "group-open:bg-[#4B4B4B] text-white",
      "dark:group-open:bg-[#DDDDDD] dark:text-black",
      "group-open:hover:[&:is(.accordion-summary)]:bg-[#282828] dark:group-open:hover:[&:is(.accordion-summary)]:bg-[#E8E8E8]"
    ]
  end

  defp item_color("default", "primary") do
    [
      "group-open:bg-[#007F8C] text-white",
      "dark:group-open:bg-[#01B8CA] dark:text-black",
      "group-open:hover:[&:is(.accordion-summary)]:bg-[#016974] dark:group-open:hover:[&:is(.accordion-summary)]:bg-[#77D5E3]"
    ]
  end

  defp item_color("default", "secondary") do
    [
      "group-open:bg-[#266EF1] text-white",
      "dark:group-open:bg-[#6DAAFB] dark:text-black",
      "group-open:hover:[&:is(.accordion-summary)]:bg-[#175BCC] dark:group-open:hover:[&:is(.accordion-summary)]:bg-[#A9C9FF]"
    ]
  end

  defp item_color("default", "success") do
    [
      "group-open:bg-[#0E8345] text-white",
      "dark:group-open:bg-[#06C167] dark:text-black",
      "group-open:hover:[&:is(.accordion-summary)]:bg-[#282828] dark:group-open:hover:[&:is(.accordion-summary)]:bg-[#7FD99A]"
    ]
  end

  defp item_color("default", "warning") do
    [
      "group-open:bg-[#CA8D01] text-white",
      "dark:group-open:bg-[#FDC034] dark:text-black",
      "group-open:hover:[&:is(.accordion-summary)]:bg-[#976A01] dark:group-open:hover:[&:is(.accordion-summary)]:bg-[#FDD067]"
    ]
  end

  defp item_color("default", "danger") do
    [
      "group-open:bg-[#DE1135] text-white",
      "dark:group-open:bg-[#FC7F79] dark:text-black",
      "group-open:hover:[&:is(.accordion-summary)]:bg-[#BB032A] dark:group-open:hover:[&:is(.accordion-summary)]:bg-[#FFB2AB]"
    ]
  end

  defp item_color("default", "info") do
    [
      "group-open:bg-[#0B84BA] text-white",
      "dark:group-open:bg-[#3EB7ED] dark:text-black",
      "group-open:hover:[&:is(.accordion-summary)]:bg-[#08638C] dark:group-open:hover:[&:is(.accordion-summary)]:bg-[#6EC9F2]"
    ]
  end

  defp item_color("default", "misc") do
    [
      "group-open:bg-[#8750C5] text-white",
      "dark:group-open:bg-[#BA83F9] dark:text-black",
      "group-open:hover:[&:is(.accordion-summary)]:bg-[#653C94] dark:group-open:hover:[&:is(.accordion-summary)]:bg-[#CBA2FA]"
    ]
  end

  defp item_color("default", "dawn") do
    [
      "group-open:bg-[#A86438] text-white",
      "dark:group-open:bg-[#DB976B] dark:text-black",
      "group-open:hover:[&:is(.accordion-summary)]:bg-[#7E4B2A] dark:group-open:hover:[&:is(.accordion-summary)]:bg-[#E4B190]"
    ]
  end

  defp item_color("default", "silver") do
    [
      "group-open:bg-[#868686] text-white",
      "dark:group-open:bg-[#A6A6A6] dark:text-black",
      "group-open:hover:[&:is(.accordion-summary)]:bg-[#727272] dark:group-open:hover:[&:is(.accordion-summary)]:bg-[#BBBBBB]"
    ]
  end

  defp item_color("outline", "natural") do
    [
      "group-open:bg-[#4B4B4B] group-open:text-white dark:group-open:bg-[#DDDDDD] dark:group-open:text-black",
      "group-open:[&:is(.accordion-summary)]:border-b-0"
    ]
  end

  defp item_color("outline", "primary") do
    [
      "group-open:bg-[#007F8C] group-open:text-white dark:group-open:bg-[#01B8CA] dark:group-open:text-black",
      "group-open:[&:is(.accordion-summary)]:border-b-0"
    ]
  end

  defp item_color("outline", "secondary") do
    [
      "group-open:bg-[#266EF1] group-open:text-white dark:group-open:bg-[#6DAAFB] dark:group-open:text-black",
      "group-open:[&:is(.accordion-summary)]:border-b-0"
    ]
  end

  defp item_color("outline", "success") do
    [
      "group-open:bg-[#0E8345] group-open:text-white dark:group-open:bg-[#06C167] dark:group-open:text-black",
      "group-open:[&:is(.accordion-summary)]:border-b-0"
    ]
  end

  defp item_color("outline", "warning") do
    [
      "group-open:bg-[#CA8D01] group-open:text-white dark:group-open:bg-[#FDC034] dark:group-open:text-black",
      "group-open:[&:is(.accordion-summary)]:border-b-0"
    ]
  end

  defp item_color("outline", "danger") do
    [
      "group-open:bg-[#DE1135] group-open:text-white dark:group-open:bg-[#FC7F79] dark:group-open:text-black",
      "group-open:[&:is(.accordion-summary)]:border-b-0"
    ]
  end

  defp item_color("outline", "info") do
    [
      "group-open:bg-[#0B84BA] group-open:text-white dark:group-open:bg-[#3EB7ED] dark:group-open:text-black",
      "group-open:[&:is(.accordion-summary)]:border-b-0"
    ]
  end

  defp item_color("outline", "misc") do
    [
      "group-open:bg-[#8750C5] group-open:text-white dark:group-open:bg-[#BA83F9] dark:group-open:text-black",
      "group-open:[&:is(.accordion-summary)]:border-b-0"
    ]
  end

  defp item_color("outline", "dawn") do
    [
      "group-open:bg-[#A86438] group-open:text-white dark:group-open:bg-[#DB976B] dark:group-open:text-black",
      "group-open:[&:is(.accordion-summary)]:border-b-0"
    ]
  end

  defp item_color("outline", "silver") do
    [
      "group-open:bg-[#868686] group-open:text-white dark:group-open:bg-[#A6A6A6] dark:group-open:text-black",
      "group-open:[&:is(.accordion-summary)]:border-b-0"
    ]
  end

  defp item_color("bordered", "natural") do
    [
      "group-open:bg-[#4B4B4B] group-open:text-white dark:group-open:bg-[#DDDDDD] dark:group-open:text-black"
    ]
  end

  defp item_color("bordered", "primary") do
    [
      "group-open:bg-[#007F8C] group-open:text-white dark:group-open:bg-[#01B8CA] dark:group-open:text-black"
    ]
  end

  defp item_color("bordered", "secondary") do
    [
      "group-open:bg-[#266EF1] group-open:text-white dark:group-open:bg-[#6DAAFB] dark:group-open:text-black"
    ]
  end

  defp item_color("bordered", "success") do
    [
      "group-open:bg-[#0E8345] group-open:text-white dark:group-open:bg-[#06C167] dark:group-open:text-black"
    ]
  end

  defp item_color("bordered", "warning") do
    [
      "group-open:bg-[#CA8D01] group-open:text-white dark:group-open:bg-[#FDC034] dark:group-open:text-black"
    ]
  end

  defp item_color("bordered", "danger") do
    [
      "group-open:bg-[#DE1135] group-open:text-white dark:group-open:bg-[#FC7F79] dark:group-open:text-black"
    ]
  end

  defp item_color("bordered", "info") do
    [
      "group-open:bg-[#0B84BA] group-open:text-white dark:group-open:bg-[#3EB7ED] dark:group-open:text-black"
    ]
  end

  defp item_color("bordered", "misc") do
    [
      "group-open:bg-[#8750C5] group-open:text-white dark:group-open:bg-[#BA83F9] dark:group-open:text-black"
    ]
  end

  defp item_color("bordered", "dawn") do
    [
      "group-open:bg-[#A86438] group-open:text-white dark:group-open:bg-[#DB976B] dark:group-open:text-black"
    ]
  end

  defp item_color("bordered", "silver") do
    [
      "group-open:bg-[#868686] group-open:text-white dark:group-open:bg-[#A6A6A6] dark:group-open:text-black"
    ]
  end

  defp item_color("bordered_separated", "natural") do
    [
      "group-open:bg-[#4B4B4B] group-open:text-white dark:group-open:bg-[#DDDDDD] dark:group-open:text-black"
    ]
  end

  defp item_color("bordered_separated", "primary") do
    [
      "group-open:bg-[#007F8C] group-open:text-white dark:group-open:bg-[#01B8CA] dark:group-open:text-black"
    ]
  end

  defp item_color("bordered_separated", "secondary") do
    [
      "group-open:bg-[#266EF1] group-open:text-white dark:group-open:bg-[#6DAAFB] dark:group-open:text-black"
    ]
  end

  defp item_color("bordered_separated", "success") do
    [
      "group-open:bg-[#0E8345] group-open:text-white dark:group-open:bg-[#06C167] dark:group-open:text-black"
    ]
  end

  defp item_color("bordered_separated", "warning") do
    [
      "group-open:bg-[#CA8D01] group-open:text-white dark:group-open:bg-[#FDC034] dark:group-open:text-black"
    ]
  end

  defp item_color("bordered_separated", "danger") do
    [
      "group-open:bg-[#DE1135] group-open:text-white dark:group-open:bg-[#FC7F79] dark:group-open:text-black"
    ]
  end

  defp item_color("bordered_separated", "info") do
    [
      "group-open:bg-[#0B84BA] group-open:text-white dark:group-open:bg-[#3EB7ED] dark:group-open:text-black"
    ]
  end

  defp item_color("bordered_separated", "misc") do
    [
      "group-open:bg-[#8750C5] group-open:text-white dark:group-open:bg-[#BA83F9] dark:group-open:text-black"
    ]
  end

  defp item_color("bordered_separated", "dawn") do
    [
      "group-open:bg-[#A86438] group-open:text-white dark:group-open:bg-[#DB976B] dark:group-open:text-black"
    ]
  end

  defp item_color("bordered_separated", "silver") do
    [
      "group-open:bg-[#868686] group-open:text-white dark:group-open:bg-[#A6A6A6] dark:group-open:text-black"
    ]
  end

  defp item_color("outline_separated", "natural") do
    [
      "group-open:bg-[#4B4B4B] group-open:text-white dark:group-open:bg-[#DDDDDD] dark:group-open:text-black"
    ]
  end

  defp item_color("outline_separated", "primary") do
    [
      "group-open:bg-[#007F8C] group-open:text-white dark:group-open:bg-[#01B8CA] dark:group-open:text-black"
    ]
  end

  defp item_color("outline_separated", "secondary") do
    [
      "group-open:bg-[#266EF1] group-open:text-white dark:group-open:bg-[#6DAAFB] dark:group-open:text-black"
    ]
  end

  defp item_color("outline_separated", "success") do
    [
      "group-open:bg-[#0E8345] group-open:text-white dark:group-open:bg-[#06C167] dark:group-open:text-black"
    ]
  end

  defp item_color("outline_separated", "warning") do
    [
      "group-open:bg-[#CA8D01] group-open:text-white dark:group-open:bg-[#FDC034] dark:group-open:text-black"
    ]
  end

  defp item_color("outline_separated", "danger") do
    [
      "group-open:bg-[#DE1135] group-open:text-white dark:group-open:bg-[#FC7F79] dark:group-open:text-black"
    ]
  end

  defp item_color("outline_separated", "info") do
    [
      "group-open:bg-[#0B84BA] group-open:text-white dark:group-open:bg-[#3EB7ED] dark:group-open:text-black"
    ]
  end

  defp item_color("outline_separated", "misc") do
    [
      "group-open:bg-[#8750C5] group-open:text-white dark:group-open:bg-[#BA83F9] dark:group-open:text-black"
    ]
  end

  defp item_color("outline_separated", "dawn") do
    [
      "group-open:bg-[#A86438] group-open:text-white dark:group-open:bg-[#DB976B] dark:group-open:text-black"
    ]
  end

  defp item_color("outline_separated", "silver") do
    [
      "group-open:bg-[#868686] group-open:text-white dark:group-open:bg-[#A6A6A6] dark:group-open:text-black"
    ]
  end

  defp item_color(params, _) when is_binary(params), do: params

  defp chevron_position(%{left_chevron: true}), do: "left"
  defp chevron_position(%{right_chevron: true}), do: "right"
  defp chevron_position(%{chevron: true}), do: "right"
  defp chevron_position(_), do: "right"

  defp drop_rest(rest) do
    all_rest =
      ~w(left_chevron right_chevron chevron hide_chevron)
      |> Enum.map(&if(is_binary(&1), do: String.to_atom(&1), else: &1))

    Map.drop(rest, all_rest)
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
