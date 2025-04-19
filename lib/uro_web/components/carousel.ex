defmodule UroWeb.Components.Carousel do
  @moduledoc """
  Provides a versatile and customizable carousel component for the `UroWeb.Components.Carousel`
  project.

  This component enables the creation of image carousels with various features such as
  slide indicators, navigation controls, and dynamic slide content.

  ## Features

  - **Slides**: Define multiple slides, each with custom images, titles, descriptions, and links.
  - **Navigation Controls**: Include previous and next buttons to manually navigate through the slides.
  - **Indicators**: Optional indicators show the current slide and allow direct navigation to any slide.
  - **Overlay Options**: Customize the appearance of the overlay for a more distinct visual style.
  - **Responsive Design**: Supports various sizes and padding options to adapt to different screen sizes.
  ```

  This module offers an easy-to-use interface for building carousels with consistent
  styling and behavior across your application, while providing the flexibility to
  meet various design requirements.
  """

  use Phoenix.Component
  alias Phoenix.LiveView.JS
  import UroWeb.Components.Image, only: [image: 1]

  @doc """
  The `carousel` component is used to create interactive image carousels with customizable attributes
  such as `size`, `padding`, and `overlay`. It supports adding multiple slides with different content,
  and includes options for navigation controls and indicators.

  ## Examples

  ```elixir
  <.carousel id="carousel-test-one" indicator={true}>
    <:slide
      content_position="end"
      title="This is a dummy title 1"
      description="This is a description for our carousel and this is a dummy text"
      image="https://example.com/slides/1.webp"
      navigate="/examples/navbar"
    />
    <:slide
      content_position="center"
      title="This is a dummy title 2"
      image="https://example.com/slides/2.webp"
    />
    <:slide
      content_position="start"
      title="This is a dummy title 3"
      image="https://example.com/slides/3.webp"
    />
    <:slide title="This is a dummy title 4" image="https://example.com/slides/3.webp"/>
    <:slide title="This is a dummy title 5" image="https://example.com/slides/4.webp"/>
    <:slide
      title="This is a dummy title 6"
      image="https://example.com/slides/5.webp"
    />
    <:slide
      title="This is a dummy title 7"
      image="https://example.com/slides/6.webp"
      content_position="end"
      navigate="/examples/popover"
    />
    <:slide
      image="https://example.com/slides/8.webp"
      content_position="end"
      title="This is a dummy title 8"
      description="This is a description for our carousel and this is a dummy text"
      navigate="/examples/list"
    />
  </.carousel>
  ```

  > If you want to reduce the volume of this component when sending from the server to the client,
  > it is better not to activate the indicator option. In the next versions, javascript will be used
  > to solve this problem
  """
  @doc type: :component
  attr :id, :string,
    required: true,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :overlay, :string, default: "base", doc: "Determines an overlay"

  attr :size, :string,
    default: "large",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :padding, :string, default: "medium", doc: "Determines padding for items"
  attr :text_position, :string, default: "center", doc: "Determines the element' text position"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  attr :indicator, :boolean, default: false, doc: "Specifies whether to show element indicators"
  attr :control, :boolean, default: true, doc: "Determines whether to show navigation controls"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  slot :slide, required: true do
    attr :image, :string, doc: "Image displayed alongside of an item"
    attr :image_class, :string, doc: "Determines custom class for the image"

    attr :navigate, :string,
      doc: "Defines the path for navigation within the application using a `navigate` attribute."

    attr :patch, :string, doc: "Specifies the path for navigation using a LiveView patch."
    attr :href, :string, doc: "Sets the URL for an external link."
    attr :title, :string, doc: "Specifies the title of the element"
    attr :description, :string, doc: "Determines a short description"
    attr :title_class, :string, doc: "Determines custom class for the title"
    attr :description_class, :string, doc: "Determines custom class for the description"
    attr :wrapper_class, :string, doc: "Determines custom class for the wrapper"
    attr :content_position, :string, doc: "Determines the alignment of the element's content"
    attr :class, :string, doc: "Custom CSS class for additional styling"
    attr :active, :boolean, doc: "Indicates whether the element is currently active and visible"
  end

  def carousel(assigns) do
    assigns =
      assign_new(assigns, :actived_carousel, fn ->
        Enum.find_index(assigns.slide, &(Map.get(&1, :active) == true)) || 0
      end)

    ~H"""
    <div>
      <div
        id={@id}
        phx-remove={unselect_carousel(@id, length(@slide))}
        phx-mounted={
          JS.exec("phx-remove", to: "##{@id}") |> select_carousel(@id, @actived_carousel + 1)
        }
        class={[
          "relative w-full",
          "[&_.slide:not(.active-slide)]:absolute [&_.slide]:inset-0 [&_.slide:not(.active-slide)]:opacity-0",
          "[&_.slide]:transition-all [&_.slide]:delay-75 [&_.slide]:duration-1000 [&_.slide]:ease-in-out",
          "[&_.slide.active-slide]:z-10",
          text_position(@text_position),
          padding_size(@padding),
          color_class(@overlay),
          size_class(@size)
        ]}
      >
        <div
          :for={{slide, index} <- Enum.with_index(@slide, 1)}
          id={"#{@id}-carousel-slide-#{index}"}
          class={["slide h-full", slide[:class]]}
          phx-select={JS.exec("phx-remove", to: "##{@id}") |> select_carousel(@id, index)}
        >
          <div class="relative w-full">
            <button
              :if={@control}
              class={[
                "carousel-controls drop-shadow-2xl w-fit absolute top-0 bottom-0 left-0 p-5 flex justify-center items-center",
                "z-10 text-white transition-all ease-in-out duration-300 hover:bg-black/5"
              ]}
              id={"#{@id}-carousel-pervious-btn-#{index}"}
              phx-click={
                index - 1 != 0 &&
                  JS.exec("phx-select", to: "##{@id}-carousel-slide-#{index - 1}")
              }
            >
              <.icon name="hero-chevron-left" class="size-5 md:size-7 lg:size-9" />
            </button>

            <.slide_image id={@id} index={index} {slide}>
              <.slide_content id={@id} index={index} {slide} />
            </.slide_image>

            <button
              :if={@control}
              id={"#{@id}-carousel-next-btn-#{index}"}
              class={[
                "carousel-controls drop-shadow-2xl w-fit absolute top-0 bottom-0 right-0 p-5 flex justify-center items-center",
                "z-10 text-white transition-all ease-in-out duration-300"
              ]}
              phx-click={
                index + 1 <= length(@slide) &&
                  JS.exec("phx-select", to: "##{@id}-carousel-slide-#{index + 1}")
              }
            >
              <.icon name="hero-chevron-right" class="size-5 md:size-7 lg:size-9" />
            </button>
          </div>
        </div>
        <.slide_indicators :if={@indicator} id={@id} count={length(@slide)} />
      </div>
    </div>
    """
  end

  @doc type: :component
  attr :id, :string,
    required: true,
    doc: "A unique identifier is used to manage state and interaction"

  attr :navigate, :string,
    default: nil,
    doc: "Defines the path for navigation within the application using a `navigate` attribute."

  attr :patch, :string,
    default: nil,
    doc: "Specifies the path for navigation using a LiveView patch."

  attr :href, :string, default: nil, doc: "Sets the URL for an external link."
  attr :image, :string, required: true, doc: "Image displayed alongside of an item"
  attr :image_class, :string, default: nil, doc: "Sets classes for images"
  attr :index, :integer, required: true, doc: "Determines item index"
  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  defp slide_image(%{navigate: nav, patch: pat, href: hrf} = assigns)
       when is_binary(nav) or is_binary(pat) or is_binary(hrf) do
    ~H"""
    <.link navigate={@navigate} patch={@patch} href={@href}>
      <.image
        class={["max-w-full", @image_class]}
        src={@image}
        id={"#{@id}-carousel-slide-image-#{@index}"}
      />
      {render_slot(@inner_block)}
    </.link>
    """
  end

  defp slide_image(assigns) do
    ~H"""
    <.image
      class={["max-w-full", @image_class]}
      src={@image}
      id={"#{@id}-carousel-slide-image-#{@index}"}
    />
    {render_slot(@inner_block)}
    """
  end

  @doc type: :component
  attr :id, :string,
    required: true,
    doc: "A unique identifier is used to manage state and interaction"

  attr :title, :string, default: nil, doc: "Specifies the title of the element"
  attr :description, :string, default: nil, doc: "Determines a short description"
  attr :title_class, :string, default: "text-white", doc: "Determines custom class for the title"

  attr :description_class, :string,
    default: nil,
    doc: "Determines custom class for the description"

  attr :wrapper_class, :string, default: nil, doc: "Determines custom class for the wrapper"

  attr :content_position, :string,
    default: "",
    doc: "Determines the alignment of the element's content"

  attr :index, :integer, required: true, doc: "Determines item index"

  defp slide_content(assigns) do
    ~H"""
    <div
      :if={!is_nil(@title) || !is_nil(@description)}
      class="carousel-overlay absolute inset-0"
      id={"#{@id}-carousel-slide-content-#{@index}"}
    >
      <div
        class={[
          "description-wrapper h-full mx-auto flex flex-col gap-5",
          content_position(@content_position),
          @wrapper_class
        ]}
        id={"#{@id}-carousel-slide-content-position-#{@index}"}
      >
        <div
          :if={!is_nil(@title)}
          id={"#{@id}-carousel-slide-content-title-#{@index}"}
          class={["carousel-title", @title_class]}
        >
          {@title}
        </div>
        <p
          :if={!is_nil(@description)}
          id={"#{@id}-carousel-slide-content-description-#{@index}"}
          class={["carousel-description", @description_class]}
        >
          {@description}
        </p>
      </div>
    </div>
    """
  end

  @doc type: :component
  attr :id, :string,
    required: true,
    doc: "A unique identifier is used to manage state and interaction"

  attr :count, :integer, required: true, doc: "Count of items"

  defp slide_indicators(assigns) do
    ~H"""
    <div
      id={"#{@id}-carousel-slide-indicator"}
      class={[
        "absolute inset-x-0 bottom-0 z-10 flex justify-center gap-3 py-2.5",
        "[&>.carousel-indicator]:h-1 [&>.carousel-indicator]:w-6 [&>.carousel-indicator]:bg-white",
        "[&>.carousel-indicator.active-indicator]:opacity-100",
        "[&>.carousel-indicator]:opacity-40 [&>.carousel-indicator]:transition-all",
        "[&>.carousel-indicator]:duration-500 [&>.carousel-indicator]:ease-in-out shadow"
      ]}
    >
      <button
        :for={indicator_item <- 1..@count}
        id={"#{@id}-carousel-indicator-#{indicator_item}"}
        data-indicator-index={"#{indicator_item}"}
        phx-click={JS.exec("phx-select", to: "##{@id}-carousel-slide-#{indicator_item}")}
        class="carousel-indicator"
        aria-label={"Slide #{indicator_item}"}
      />
    </div>
    """
  end

  defp size_class("extra_small") do
    "text-xs [&_.description-wrapper]:max-w-80 [&_.carousel-title]:md:text-xl [&_.carousel-title]:md:text-3xl"
  end

  defp size_class("small") do
    "text-sm [&_.description-wrapper]:max-w-96 [&_.carousel-title]:md:text-xl [&_.carousel-title]:md:text-4xl"
  end

  defp size_class("medium") do
    "text-base [&_.description-wrapper]:max-w-xl [&_.carousel-title]:md:text-2xl [&_.carousel-title]:md:text-5xl"
  end

  defp size_class("large") do
    "text-lg [&_.description-wrapper]:max-w-2xl [&_.carousel-title]:md:text-3xl [&_.carousel-title]:md:text-6xl"
  end

  defp size_class("extra_large") do
    "text-xl [&_.description-wrapper]:max-w-3xl [&_.carousel-title]:md:text-3xl [&_.carousel-title]:md:text-7xl"
  end

  defp size_class(params) when is_binary(params), do: params

  defp padding_size("extra_small"),
    do: "[&_.description-wrapper]:p-2.5 md:[&_.description-wrapper]:p-6"

  defp padding_size("small"), do: "[&_.description-wrapper]:p-3 md:[&_.description-wrapper]:p-7"

  defp padding_size("medium"),
    do: "[&_.description-wrapper]:p-3.5 md:[&_.description-wrapper]:p-8"

  defp padding_size("large"), do: "[&_.description-wrapper]:p-4 md:[&_.description-wrapper]:p-9"

  defp padding_size("extra_large"),
    do: "[&_.description-wrapper]:p-5 md:[&_.description-wrapper]:p-10"

  defp padding_size(params) when is_binary(params), do: params

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

  defp text_position("start") do
    "[&_.description-wrapper]:text-start"
  end

  defp text_position("end") do
    "[&_.description-wrapper]:text-end"
  end

  defp text_position("center") do
    "[&_.description-wrapper]:text-center"
  end

  defp text_position(params) when is_binary(params), do: params

  defp color_class("base") do
    [
      "[&_.carousel-overlay]:bg-white/30 text-[#09090b] hover:[&_.carousel-controls]:bg-[#e4e4e7]/5",
      "dark:[&_.carousel-overlay]:bg-[#18181B]/30 dark:text-[#FAFAFA] dark:hover:[&_.carousel-controls]:bg-[#27272a]/5"
    ]
  end

  defp color_class("natural") do
    [
      "[&_.carousel-overlay]:bg-[#4B4B4B]/30 text-white hover:[&_.carousel-controls]:bg-[#4B4B4B]/5",
      "dark:[&_.carousel-overlay]:bg-[#DDDDDD]/30 text-black dark:hover:[&_.carousel-controls]:bg-[#DDDDDD]/5"
    ]
  end

  defp color_class("white") do
    "[&_.carousel-overlay]:bg-white/30 text-[#3E3E3E] hover:[&_.carousel-controls]:bg-white/5"
  end

  defp color_class("primary") do
    [
      "[&_.carousel-overlay]:bg-[#007F8C]/30 text-white hover:[&_.carousel-controls]:bg-[#007F8C]/5",
      "dark:[&_.carousel-overlay]:bg-[#01B8CA]/30 text-black dark:hover:[&_.carousel-controls]:bg-[#01B8CA]/5"
    ]
  end

  defp color_class("secondary") do
    [
      "[&_.carousel-overlay]:bg-[#266EF1]/30 text-white hover:[&_.carousel-controls]:bg-[#266EF1]/5",
      "dark:[&_.carousel-overlay]:bg-[#6DAAFB]/30 text-black dark:hover:[&_.carousel-controls]:bg-[#6DAAFB]/5"
    ]
  end

  defp color_class("success") do
    [
      "[&_.carousel-overlay]:bg-[#0E8345]/30 text-white hover:[&_.carousel-controls]:bg-[#0E8345]/5",
      "dark:[&_.carousel-overlay]:bg-[#06C167]/30 text-black dark:hover:[&_.carousel-controls]:bg-[#06C167]/5"
    ]
  end

  defp color_class("warning") do
    [
      "[&_.carousel-overlay]:bg-[#CA8D01]/30 text-white hover:[&_.carousel-controls]:bg-[#CA8D01]/5",
      "dark:[&_.carousel-overlay]:bg-[#FDC034]/30 text-black dark:hover:[&_.carousel-controls]:bg-[#FDC034]/5"
    ]
  end

  defp color_class("danger") do
    [
      "[&_.carousel-overlay]:bg-[#DE1135]/30 text-white hover:[&_.carousel-controls]:bg-[#DE1135]/5",
      "dark:[&_.carousel-overlay]:bg-[#FC7F79]/30 text-black dark:hover:[&_.carousel-controls]:bg-[#FC7F79]/5"
    ]
  end

  defp color_class("info") do
    [
      "[&_.carousel-overlay]:bg-[#0B84BA]/30 text-white hover:[&_.carousel-controls]:bg-[#0B84BA]/5",
      "dark:[&_.carousel-overlay]:bg-[#3EB7ED]/30 text-black dark:hover:[&_.carousel-controls]:bg-[#3EB7ED]/5"
    ]
  end

  defp color_class("misc") do
    [
      "[&_.carousel-overlay]:bg-[#8750C5]/30 text-white hover:[&_.carousel-controls]:bg-[#8750C5]/5",
      "dark:[&_.carousel-overlay]:bg-[#BA83F9]/30 text-black dark:hover:[&_.carousel-controls]:bg-[#BA83F9]/5"
    ]
  end

  defp color_class("dawn") do
    [
      "[&_.carousel-overlay]:bg-[#A86438]/30 text-white hover:[&_.carousel-controls]:bg-[#A86438]/5",
      "dark:[&_.carousel-overlay]:bg-[#DB976B]/30 text-black dark:hover:[&_.carousel-controls]:bg-[#DB976B]/5"
    ]
  end

  defp color_class("silver") do
    [
      "[&_.carousel-overlay]:bg-[#868686]/30 text-white hover:[&_.carousel-controls]:bg-[#868686]/5",
      "dark:[&_.carousel-overlay]:bg-[#A6A6A6]/30 text-black dark:hover:[&_.carousel-controls]:bg-[#A6A6A6]/5"
    ]
  end

  defp color_class("dark") do
    "[&_.carousel-overlay]:bg-[#282828]/30 text-white hover:[&_.carousel-controls]:bg-[#282828]/5"
  end

  defp color_class(params) when is_binary(params), do: params

  @doc """
  Sets the specified slide as active and enables the navigation controls in the carousel.

  ## Parameters

    - `js`: A `Phoenix.LiveView.JS` structure for composing JavaScript commands.
    Defaults to an empty `%JS{}` if not provided.
    - `id`: The unique identifier of the carousel component.
    - `count`: The index of the slide to be selected as active.

  ## Functionality

  Performs the following actions:

    - Adds the `active-slide` CSS class to the specified slide, making it visible in the carousel.
    - Removes the `disabled` attribute from the previous and next navigation buttons
    for the active slide, allowing user interaction.

  ### Example:

    ```elixir
    select_carousel(%JS{}, id, count)
    ```

  This function is used to display a specific slide in the carousel and enable
  the navigation controls for that slide.
  """

  def select_carousel(js \\ %JS{}, id, count) when is_binary(id) do
    JS.add_class(js, "active-slide",
      to: "##{id}-carousel-slide-#{count}",
      transition: "duration-0"
    )
    |> JS.remove_attribute("disabled", to: "##{id}-carousel-pervious-btn-#{count}")
    |> JS.remove_attribute("disabled", to: "##{id}-carousel-next-btn-#{count}")
    |> JS.set_attribute({"aria-current", "true"}, to: "##{id}-carousel-indicator-#{count}")
    |> JS.add_class("active-indicator", to: "##{id}-carousel-indicator-#{count}")
  end

  @doc """
  Removes the active state from all slides and disables navigation controls in the carousel.

  ## Parameters

    - `js`: A `Phoenix.LiveView.JS` structure for composing JavaScript commands.
    Defaults to an empty `%JS{}` if not provided.
    - `id`: The unique identifier of the carousel component.
    - `count`: The total number of slides in the carousel.

  ## Functionality

  Iterates through each slide in the carousel, performing the following actions:

    - Disables the previous and next navigation buttons by setting the `disabled` attribute.
    - Removes the `active-slide` CSS class from all slides to hide them.
    - Removes the `active-indicator` CSS class from all slide indicators.

  ### Example:

  ```elixir
  unselect_carousel(%JS{}, id, count)
  ```

  This function is used to reset the carousel state, making all slides inactive and disabling
  the navigation controls.
  """

  def unselect_carousel(js \\ %JS{}, id, count) do
    Enum.reduce(1..count, js, fn item, acc ->
      acc
      |> JS.set_attribute({"disabled", "true"}, to: "##{id}-carousel-pervious-btn-#{item}")
      |> JS.set_attribute({"disabled", "true"}, to: "##{id}-carousel-next-btn-#{item}")
      |> JS.set_attribute({"aria-current", "false"}, to: "##{id}-carousel-indicator-#{item}")
      |> JS.remove_class("active-slide",
        to: "##{id}-carousel-slide-#{item}",
        transition: "duration-0"
      )
      |> JS.remove_class("active-indicator", to: "##{id}-carousel-indicator-#{item}")
    end)
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
