defmodule UroWeb.Components.FileField do
  @moduledoc """
  The `UroWeb.Components.FileField` module provides a versatile and customizable component
  for handling file uploads in Phoenix LiveView applications.

  This module supports various configurations, allowing users to upload files or
  images through traditional file inputs or interactive dropzones.

  ### Key Features:
  - **Custom Styling Options:** Allows for customized styles, including colors, borders, and rounded corners.
  - **Flexible Input Types:** Supports both live uploads and standard file inputs.
  - **Dropzone Functionality:** Provides an interactive drag-and-drop area for file
  uploads with customizable icons and descriptions.
  - **Error Handling:** Displays error messages for issues like file size, file type,
  and maximum number of files.
  - **Upload Progress:** Shows real-time upload progress for each file.

  This component is designed to simplify file handling in forms and offers a visually
  appealing and user-friendly experience for uploading files in LiveView applications.
  """

  use Phoenix.Component
  import UroWeb.Components.Progress, only: [progress: 1]
  import UroWeb.Components.Spinner, only: [spinner: 1]

  @doc """
  Renders a `file_input` field with customizable styles, labels, and live upload capabilities.

  It can be used as a simple file input or as a dropzone with drag-and-drop support for files and images.

  ## Examples

  ```elixir
  <.file_field color="danger" />
  <.file_field target={:avatar} uploads={@uploads} dropzone/>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :label_class, :string, default: nil, doc: "Custom CSS class for the label styling"
  attr :color, :string, default: "base", doc: "Determines color theme"
  attr :variant, :string, default: "base", doc: "Determines the style"
  attr :border, :string, default: "extra_small", doc: "Determines border style"
  attr :rounded, :string, default: "small", doc: "Determines the border radius"
  attr :live, :boolean, default: false, doc: "Specifies whether this upload is live or input file"
  attr :space, :string, default: "medium", doc: "Space between items"

  attr :size, :string,
    default: "extra_small",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :label, :string, default: nil, doc: "Specifies text for the label"
  attr :dashed, :boolean, default: true, doc: "Determines dashed border"
  attr :error_icon, :string, default: nil, doc: "Icon to be displayed alongside error messages"
  attr :errors, :list, default: [], doc: "List of error messages to be displayed"
  attr :uploads, :any, doc: "LiveView upload map"
  attr :name, :any, doc: "Name of input"
  attr :value, :any, doc: "Value of input"

  attr :dropzone, :boolean, default: false, doc: ""
  attr :dropzone_type, :string, default: "file", doc: "file, image"
  attr :target, :atom, doc: "Name of upload input when is used as Live Upload"
  attr :dropzone_icon, :string, default: "hero-cloud-arrow-up", doc: ""
  attr :dropzone_title, :string, default: "Click to upload, or drag and drop a file", doc: ""
  attr :dropzone_description, :string, default: nil, doc: "Specifies description for dropzone"

  attr :field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form"

  attr :rest, :global,
    include:
      ~w(autocomplete disabled form checked multiple readonly min max step required title autofocus),
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  @spec file_field(map()) :: Phoenix.LiveView.Rendered.t()
  def file_field(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:name, fn ->
      if assigns.rest[:multiple], do: field.name <> "[]", else: field.name
    end)
    |> assign_new(:value, fn -> field.value end)
    |> file_field()
  end

  def file_field(%{dropzone: true, dropzone_type: "file"} = assigns) do
    targeted_upload = assigns.uploads[assigns.target]

    assigns =
      assigns
      |> assign_new(:entries, fn -> targeted_upload.entries end)
      |> assign_new(:upload_error, fn -> targeted_upload end)
      |> assign_new(:upload, fn -> targeted_upload end)

    ~H"""
    <div class={[
      color_variant(@variant, @color),
      border_class(@border, @variant),
      rounded_size(@rounded),
      size_class(@size),
      @dashed && "[&_.dropzone-wrapper]:border-dashed",
      @class
    ]}>
      <label
        class={[
          "dropzone-wrapper group flex flex-col items-center justify-center w-full cursor-pointer"
        ]}
        phx-drop-target={@upload.ref}
        for={@id}
      >
        <div class="flex flex-col gap-3 items-center justify-center pt-5 pb-6">
          <.icon name={@dropzone_icon} class="size-14" />
          <div class="mb-2 font-semibold">
            {@dropzone_title}
          </div>

          <div>
            {@dropzone_description}
          </div>
        </div>
        <.live_file_input id={@id} upload={@upload} class="hidden" />
      </label>

      <.error :for={msg <- @errors} icon={@error_icon}>{msg}</.error>

      <div class="mt-5 space-y-4">
        <%= for entry <- @entries do %>
          <div class="upload-item border rounded relative p-3">
            <div class="flex justify-around gap-3">
              <.icon name="hero-document-arrow-up" class="size-8" />
              <div class="w-full space-y-3">
                <div class="text-ellipsis	overflow-hidden w-44 whitespace-nowrap">
                  {entry.client_name}
                </div>

                <div>
                  {convert_to_mb(entry.client_size)} <span>MB</span>
                </div>

                <.progress
                  value={entry.progress}
                  color={@color}
                  size="extra_small"
                />
              </div>
            </div>

            <button
              type="button"
              phx-click="cancel-upload"
              phx-value-ref={entry.ref}
              aria-label="cancel"
              class="absolute top-2 right-2 text-custome-black-100/60 hover:text-custome-black-100"
            >
              <.icon name="hero-x-mark" class="size-4" />
            </button>

            <%= for err <- upload_errors(@upload_error, entry) do %>
              <p class="text-rose-600 font-medium text-xs mt-3">Error: {error_to_string(err)}</p>
            <% end %>
          </div>
        <% end %>
      </div>

      <%= for err <- upload_errors(@upload_error) do %>
        <p class="text-rose-600 font-medium text-xs">{error_to_string(err)}</p>
      <% end %>
    </div>
    """
  end

  def file_field(%{dropzone: true, dropzone_type: "image"} = assigns) do
    targeted_upload = assigns.uploads[assigns.target]

    assigns =
      assigns
      |> assign_new(:entries, fn -> targeted_upload.entries end)
      |> assign_new(:upload_error, fn -> targeted_upload end)
      |> assign_new(:upload, fn -> targeted_upload end)

    ~H"""
    <div class={[
      color_variant(@variant, @color),
      border_class(@border, @variant),
      rounded_size(@rounded),
      size_class(@size),
      @dashed && "[&_.dropzone-wrapper]:border-dashed",
      @class
    ]}>
      <label
        class={[
          "dropzone-wrapper group flex flex-col items-center justify-center w-full cursor-pointer"
        ]}
        phx-drop-target={@upload.ref}
        for={@id}
      >
        <div class="flex flex-col gap-3 items-center justify-center pt-5 pb-6">
          <.icon name={@dropzone_icon} class="size-14" />
          <div class="mb-2 font-semibold">
            {@dropzone_title}
          </div>

          <div>
            {@dropzone_description}
          </div>
        </div>
        <.live_file_input id={@id} upload={@upload} class="hidden" />
      </label>

      <.error :for={msg <- @errors} icon={@error_icon}>{msg}</.error>

      <%= for err <- upload_errors(@upload_error) do %>
        <p class="text-rose-600 font-semibold text-sm my-5">{error_to_string(err)}</p>
      <% end %>

      <div class="flex flex-wrap gap-3 my-3">
        <%= for entry <- @entries do %>
          <div>
            <div class="relative">
            <div class="rounded w-24 h-24 overflow-hidden">
              <figure class="w-full h-full object-cover">
                <.live_img_preview entry={entry} class="w-full h-full object-cover rounded" />
              </figure>
            </div>

            <button
              type="button"
              phx-click="cancel-upload"
              phx-value-ref={entry.ref}
              aria-label="cancel"
              class="bg-black/30 rounded p-px text-white flex justify-center items-center absolute top-2 right-2 z-10"
            >
              <.icon name="hero-x-mark" class="size-4" />
            </button>


            <div
              :if={!entry.done?}
              role="status"
              class="absolute inset-0 bg-black/25 flex justify-center items-center"
            >
              <.spinner color="base" />
            </div>
            </div>
            <%= for err <- upload_errors(@upload_error, entry) do %>
              <p class="text-rose-600 font-medium text-xs mt-3">Error: {error_to_string(err)}</p>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  def file_field(assigns) do
    ~H"""
    <div class={[
      rounded_size(@rounded),
      color_class(@color),
      space_class(@space),
      @class
    ]}>
      <.label for={@id}>{@label}</.label>

      <%= if @live do %>
        <.live_file_input
          upload={@upload}
          id={@id}
          class={[
            "file-field block w-full cursor-pointer focus:outline-none file:border-0 file:cursor-pointer",
            "file:py-3 file:px-8 file:font-bold file:-ms-4 file:me-4"
          ]}
          {@rest}
        />
      <% else %>
        <input
          name={@name}
          id={@id}
          class={[
            "file-field block w-full cursor-pointer focus:outline-none file:border-0 file:cursor-pointer",
            "file:py-3 file:px-8 file:font-bold file:-ms-4 file:me-4"
          ]}
          type="file"
          {@rest}
        />
      <% end %>

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

  def convert_to_mb(size_in_bytes) when is_integer(size_in_bytes) do
    Float.round(size_in_bytes / (1024 * 1024), 2)
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(:too_many_files), do: "You have selected too many files"

  defp border_class(_, variant) when variant in ["default", "shadow", "transparent", "gradient"],
    do: nil

  defp border_class("none", _), do: nil
  defp border_class("extra_small", _), do: "[&_.dropzone-wrapper]:border"
  defp border_class("small", _), do: "[&_.dropzone-wrapper]:border-2"
  defp border_class("medium", _), do: "[&_.dropzone-wrapper]:border-[3px]"
  defp border_class("large", _), do: "[&_.dropzone-wrapper]:border-4"
  defp border_class("extra_large", _), do: "[&_.dropzone-wrapper]:border-[5px]"
  defp border_class(params, _) when is_binary(params), do: params

  defp size_class("extra_small"), do: "[&_.dropzone-wrapper]:h-52"

  defp size_class("small"), do: "[&_.dropzone-wrapper]:h-56"

  defp size_class("medium"), do: "[&_.dropzone-wrapper]:h-60"

  defp size_class("large"), do: "[&_.dropzone-wrapper]:h-64"

  defp size_class("extra_large"), do: "[&_.dropzone-wrapper]:h-72"

  defp size_class(params) when is_binary(params), do: params

  defp rounded_size("none"), do: nil

  defp rounded_size("extra_small"),
    do: "[&_.file-field]:rounded-sm [&_.dropzone-wrapper]:rounded-sm"

  defp rounded_size("small"), do: "[&_.file-field]:rounded [&_.dropzone-wrapper]:rounded"

  defp rounded_size("medium"), do: "[&_.file-field]:rounded-md [&_.dropzone-wrapper]:rounded-md"

  defp rounded_size("large"), do: "[&_.file-field]:rounded-lg [&_.dropzone-wrapper]:rounded-lg"

  defp rounded_size("extra_large"),
    do: "[&_.file-field]:rounded-xl [&_.dropzone-wrapper]:rounded-xl"

  defp rounded_size(params) when is_binary(params), do: params

  defp space_class("none"), do: nil

  defp space_class("extra_small"), do: "space-y-1"

  defp space_class("small"), do: "space-y-1.5"

  defp space_class("medium"), do: "space-y-2"

  defp space_class("large"), do: "space-y-2.5"

  defp space_class("extra_large"), do: "space-y-3"

  defp space_class(params) when is_binary(params), do: params

  defp color_class("base") do
    [
      "[&_.file-field]:bg-white file:[&_.file-field]:text-[#09090b] [&_.file-field]:text-[#09090b] file:[&_.file-field]:bg-[#e4e4e7]",
      "dark:[&_.file-field]:bg-[#27272a] dark:file:[&_.file-field]:bg-[#18181B]",
      "dark:file:[&_.file-field]:text-[#FAFAFA] dark:[&_.file-field]:text-[#FAFAFA]"
    ]
  end

  defp color_class("natural") do
    [
      "[&_.file-field]:bg-[#4B4B4B] file:[&_.file-field]:text-white [&_.file-field]:text-white file:[&_.file-field]:bg-[#282828]",
      "dark:[&_.file-field]:bg-[#E8E8E8] dark:file:[&_.file-field]:bg-[#DDDDDD]",
      "dark:file:[&_.file-field]:text-black dark:[&_.file-field]:text-black"
    ]
  end

  defp color_class("primary") do
    [
      "[&_.file-field]:bg-[#007F8C] file:[&_.file-field]:text-white [&_.file-field]:text-white file:[&_.file-field]:bg-[#016974]",
      "dark:[&_.file-field]:bg-[#77D5E3] dark:file:[&_.file-field]:bg-[#01B8CA]",
      "dark:file:[&_.file-field]:text-black dark:[&_.file-field]:text-black"
    ]
  end

  defp color_class("secondary") do
    [
      "[&_.file-field]:bg-[#266EF1] file:[&_.file-field]:text-white [&_.file-field]:text-white file:[&_.file-field]:bg-[#175BCC]",
      "dark:[&_.file-field]:bg-[#A9C9FF] dark:file:[&_.file-field]:bg-[#6DAAFB]",
      "dark:file:[&_.file-field]:text-black dark:[&_.file-field]:text-black"
    ]
  end

  defp color_class("success") do
    [
      "[&_.file-field]:bg-[#0E8345] file:[&_.file-field]:text-white [&_.file-field]:text-white file:[&_.file-field]:bg-[#166C3B]",
      "dark:[&_.file-field]:bg-[#7FD99A] dark:file:[&_.file-field]:bg-[#06C167]",
      "dark:file:[&_.file-field]:text-black dark:[&_.file-field]:text-black"
    ]
  end

  defp color_class("warning") do
    [
      "[&_.file-field]:bg-[#CA8D01] file:[&_.file-field]:text-white [&_.file-field]:text-white file:[&_.file-field]:bg-[#976A01]",
      "dark:[&_.file-field]:bg-[#FDD067] dark:file:[&_.file-field]:bg-[#FDC034]",
      "dark:file:[&_.file-field]:text-black dark:[&_.file-field]:text-black"
    ]
  end

  defp color_class("danger") do
    [
      "[&_.file-field]:bg-[#DE1135] file:[&_.file-field]:text-white [&_.file-field]:text-white file:[&_.file-field]:bg-[#BB032A]",
      "dark:[&_.file-field]:bg-[#FFB2AB] dark:file:[&_.file-field]:bg-[#FC7F79]",
      "dark:file:[&_.file-field]:text-black dark:[&_.file-field]:text-black"
    ]
  end

  defp color_class("info") do
    [
      "[&_.file-field]:bg-[#0B84BA] file:[&_.file-field]:text-white [&_.file-field]:text-white file:[&_.file-field]:bg-[#08638C]",
      "dark:[&_.file-field]:bg-[#6EC9F2] dark:file:[&_.file-field]:bg-[#3EB7ED]",
      "dark:file:[&_.file-field]:text-black dark:[&_.file-field]:text-black"
    ]
  end

  defp color_class("misc") do
    [
      "[&_.file-field]:bg-[#8750C5] file:[&_.file-field]:text-white [&_.file-field]:text-white file:[&_.file-field]:bg-[#653C94]",
      "dark:[&_.file-field]:bg-[#CBA2FA] dark:file:[&_.file-field]:bg-[#BA83F9]",
      "dark:file:[&_.file-field]:text-black dark:[&_.file-field]:text-black"
    ]
  end

  defp color_class("dawn") do
    [
      "[&_.file-field]:bg-[#A86438] file:[&_.file-field]:text-white [&_.file-field]:text-white file:[&_.file-field]:bg-[#7E4B2A]",
      "dark:[&_.file-field]:bg-[#E4B190] dark:file:[&_.file-field]:bg-[#DB976B]",
      "dark:file:[&_.file-field]:text-black dark:[&_.file-field]:text-black"
    ]
  end

  defp color_class("silver") do
    [
      "[&_.file-field]:bg-[#868686] file:[&_.file-field]:text-white [&_.file-field]:text-white file:[&_.file-field]:bg-[#727272]",
      "dark:[&_.file-field]:bg-[#BBBBBB] dark:file:[&_.file-field]:bg-[#A6A6A6]",
      "dark:file:[&_.file-field]:text-black dark:[&_.file-field]:text-black"
    ]
  end

  defp color_class(params) when is_binary(params), do: params

  defp color_variant("base", _) do
    [
      "text-[#09090b] [&_.dropzone-wrapper]:border-[#e4e4e7] [&_.dropzone-wrapper]:bg-white shadow-sm",
      "dark:text-[#FAFAFA] dark:[&_.dropzone-wrapper]:border-[#27272a] dark:[&_.dropzone-wrapper]:bg-[#18181B]"
    ]
  end

  defp color_variant("default", "white") do
    [
      "[&_.dropzone-wrapper]:bg-white text-black"
    ]
  end

  defp color_variant("default", "dark") do
    [
      "[&_.dropzone-wrapper]:bg-[#282828] text-white"
    ]
  end

  defp color_variant("default", "natural") do
    [
      "[&_.dropzone-wrapper]:bg-[#4B4B4B] text-white dark:[&_.dropzone-wrapper]:bg-[#DDDDDD] dark:text-black"
    ]
  end

  defp color_variant("default", "primary") do
    [
      "[&_.dropzone-wrapper]:bg-[#007F8C] text-white dark:[&_.dropzone-wrapper]:bg-[#01B8CA] dark:text-black"
    ]
  end

  defp color_variant("default", "secondary") do
    [
      "[&_.dropzone-wrapper]:bg-[#266EF1] text-white dark:[&_.dropzone-wrapper]:bg-[#6DAAFB] dark:text-black"
    ]
  end

  defp color_variant("default", "success") do
    [
      "[&_.dropzone-wrapper]:bg-[#0E8345] text-white dark:[&_.dropzone-wrapper]:bg-[#06C167] dark:text-black"
    ]
  end

  defp color_variant("default", "warning") do
    [
      "[&_.dropzone-wrapper]:bg-[#CA8D01] text-white dark:[&_.dropzone-wrapper]:bg-[#FDC034] dark:text-black"
    ]
  end

  defp color_variant("default", "danger") do
    [
      "[&_.dropzone-wrapper]:bg-[#DE1135] text-white dark:[&_.dropzone-wrapper]:bg-[#FC7F79] dark:text-black"
    ]
  end

  defp color_variant("default", "info") do
    [
      "[&_.dropzone-wrapper]:bg-[#0B84BA] text-white dark:[&_.dropzone-wrapper]:bg-[#3EB7ED] dark:text-black"
    ]
  end

  defp color_variant("default", "misc") do
    [
      "[&_.dropzone-wrapper]:bg-[#8750C5] text-white dark:[&_.dropzone-wrapper]:bg-[#BA83F9] dark:text-black"
    ]
  end

  defp color_variant("default", "dawn") do
    [
      "[&_.dropzone-wrapper]:bg-[#A86438] text-white dark:[&_.dropzone-wrapper]:bg-[#DB976B] dark:text-black"
    ]
  end

  defp color_variant("default", "silver") do
    [
      "[&_.dropzone-wrapper]:bg-[#868686] text-white dark:[&_.dropzone-wrapper]:bg-[#A6A6A6] dark:text-black"
    ]
  end

  defp color_variant("outline", "natural") do
    [
      "text-[#4B4B4B] [&_.dropzone-wrapper]:border-[#4B4B4B] dark:text-[#DDDDDD] dark:[&_.dropzone-wrapper]:border-[#DDDDDD]"
    ]
  end

  defp color_variant("outline", "primary") do
    [
      "text-[#007F8C] [&_.dropzone-wrapper]:border-[#007F8C]  dark:text-[#01B8CA] dark:[&_.dropzone-wrapper]:border-[#01B8CA]"
    ]
  end

  defp color_variant("outline", "secondary") do
    [
      "text-[#266EF1] [&_.dropzone-wrapper]:border-[#266EF1] dark:text-[#6DAAFB] dark:[&_.dropzone-wrapper]:border-[#6DAAFB]"
    ]
  end

  defp color_variant("outline", "success") do
    [
      "text-[#0E8345] [&_.dropzone-wrapper]:border-[#0E8345] dark:text-[#06C167] dark:[&_.dropzone-wrapper]:border-[#06C167]"
    ]
  end

  defp color_variant("outline", "warning") do
    [
      "text-[#CA8D01] [&_.dropzone-wrapper]:border-[#CA8D01] dark:text-[#FDC034] dark:[&_.dropzone-wrapper]:border-[#FDC034]"
    ]
  end

  defp color_variant("outline", "danger") do
    [
      "text-[#DE1135] [&_.dropzone-wrapper]:border-[#DE1135] dark:text-[#FC7F79] dark:[&_.dropzone-wrapper]:border-[#FC7F79]"
    ]
  end

  defp color_variant("outline", "info") do
    [
      "text-[#0B84BA] [&_.dropzone-wrapper]:border-[#0B84BA] dark:text-[#3EB7ED] dark:[&_.dropzone-wrapper]:border-[#3EB7ED]"
    ]
  end

  defp color_variant("outline", "misc") do
    [
      "text-[#8750C5] [&_.dropzone-wrapper]:border-[#8750C5] dark:text-[#BA83F9] dark:[&_.dropzone-wrapper]:border-[#BA83F9]"
    ]
  end

  defp color_variant("outline", "dawn") do
    [
      "text-[#A86438] [&_.dropzone-wrapper]:border-[#A86438] dark:text-[#DB976B] dark:[&_.dropzone-wrapper]:border-[#DB976B]"
    ]
  end

  defp color_variant("outline", "silver") do
    [
      "text-[#868686] [&_.dropzone-wrapper]:border-[#868686] dark:text-[#A6A6A6] dark:[&_.dropzone-wrapper]:border-[#A6A6A6]"
    ]
  end

  defp color_variant("shadow", "natural") do
    [
      "[&_.dropzone-wrapper]:bg-[#4B4B4B] text-white dark:[&_.dropzone-wrapper]:bg-[#DDDDDD] dark:text-black",
      "[&_.dropzone-wrapper]:shadow-[0px_4px_6px_-4px_rgba(134,134,134,0.5)] [&_.dropzone-wrapper]:shadow-[0px_10px_15px_-3px_rgba(134,134,134,0.5)]",
      "dark:[&_.dropzone-wrapper]:shadow-none"
    ]
  end

  defp color_variant("shadow", "primary") do
    [
      "[&_.dropzone-wrapper]:bg-[#007F8C] text-white dark:[&_.dropzone-wrapper]:bg-[#01B8CA] dark:text-black",
      "[&_.dropzone-wrapper]:shadow-[0px_4px_6px_-4px_rgba(0,149,164,0.5)] [&_.dropzone-wrapper]:shadow-[0px_10px_15px_-3px_rgba(0,149,164,0.5)]",
      "dark:[&_.dropzone-wrapper]:shadow-none"
    ]
  end

  defp color_variant("shadow", "secondary") do
    [
      "[&_.dropzone-wrapper]:bg-[#266EF1] text-white dark:[&_.dropzone-wrapper]:bg-[#6DAAFB] dark:text-black",
      "[&_.dropzone-wrapper]:shadow-[0px_4px_6px_-4px_rgba(6,139,238,0.5)] [&_.dropzone-wrapper]:shadow-[0px_10px_15px_-3px_rgba(6,139,238,0.5)]",
      "dark:[&_.dropzone-wrapper]:shadow-none"
    ]
  end

  defp color_variant("shadow", "success") do
    [
      "[&_.dropzone-wrapper]:bg-[#0E8345] text-white hover:[&_.dropzone-wrapper]:bg-[#166C3B] dark:[&_.dropzone-wrapper]:bg-[#06C167] dark:text-black",
      "[&_.dropzone-wrapper]:shadow-[0px_4px_6px_-4px_rgba(0,154,81,0.5)] [&_.dropzone-wrapper]:shadow-[0px_10px_15px_-3px_rgba(0,154,81,0.5)]",
      "dark:[&_.dropzone-wrapper]:shadow-none"
    ]
  end

  defp color_variant("shadow", "warning") do
    [
      "[&_.dropzone-wrapper]:bg-[#CA8D01] text-white dark:[&_.dropzone-wrapper]:bg-[#FDC034] dark:text-black",
      "[&_.dropzone-wrapper]:shadow-[0px_4px_6px_-4px_rgba(252,176,1,0.5)] [&_.dropzone-wrapper]:shadow-[0px_10px_15px_-3px_rgba(252,176,1,0.5)]",
      "dark:[&_.dropzone-wrapper]:shadow-none"
    ]
  end

  defp color_variant("shadow", "danger") do
    [
      "[&_.dropzone-wrapper]:bg-[#DE1135] text-white dark:[&_.dropzone-wrapper]:bg-[#FC7F79] dark:text-black",
      "[&_.dropzone-wrapper]:shadow-[0px_4px_6px_-4px_rgba(248,52,70,0.5)] [&_.dropzone-wrapper]:shadow-[0px_10px_15px_-3px_rgba(248,52,70,0.5)]",
      "dark:[&_.dropzone-wrapper]:shadow-none"
    ]
  end

  defp color_variant("shadow", "info") do
    [
      "[&_.dropzone-wrapper]:bg-[#0B84BA] text-white dark:[&_.dropzone-wrapper]:bg-[#3EB7ED] dark:text-black",
      "[&_.dropzone-wrapper]:shadow-[0px_4px_6px_-4px_rgba(14,165,233,0.5)] [&_.dropzone-wrapper]:shadow-[0px_10px_15px_-3px_rgba(14,165,233,0.5)]",
      "dark:[&_.dropzone-wrapper]:shadow-none"
    ]
  end

  defp color_variant("shadow", "misc") do
    [
      "[&_.dropzone-wrapper]:bg-[#8750C5] text-white dark:[&_.dropzone-wrapper]:bg-[#BA83F9] dark:text-black",
      "[&_.dropzone-wrapper]:shadow-[0px_4px_6px_-4px_rgba(169,100,247,0.5)] [&_.dropzone-wrapper]:shadow-[0px_10px_15px_-3px_rgba(169,100,247,0.5)]",
      "dark:[&_.dropzone-wrapper]:shadow-none"
    ]
  end

  defp color_variant("shadow", "dawn") do
    [
      "[&_.dropzone-wrapper]:bg-[#A86438] text-white dark:[&_.dropzone-wrapper]:bg-[#DB976B] dark:text-black",
      "[&_.dropzone-wrapper]:shadow-[0px_4px_6px_-4px_rgba(210,125,70,0.5)] [&_.dropzone-wrapper]:shadow-[0px_10px_15px_-3px_rgba(210,125,70,0.5)]",
      "dark:[&_.dropzone-wrapper]:shadow-none"
    ]
  end

  defp color_variant("shadow", "silver") do
    [
      "[&_.dropzone-wrapper]:bg-[#868686] text-white dark:[&_.dropzone-wrapper]:bg-[#A6A6A6] dark:text-black",
      "[&_.dropzone-wrapper]:shadow-[0px_4px_6px_-4px_rgba(134,134,134,0.5)] [&_.dropzone-wrapper]:shadow-[0px_10px_15px_-3px_rgba(134,134,134,0.5)]",
      "dark:[&_.dropzone-wrapper]:shadow-none"
    ]
  end

  defp color_variant("bordered", "white") do
    [
      "[&_.dropzone-wrapper]:bg-white text-black [&_.dropzone-wrapper]:border-[#DDDDDD]"
    ]
  end

  defp color_variant("bordered", "dark") do
    [
      "[&_.dropzone-wrapper]:bg-[#282828] text-white [&_.dropzone-wrapper]:border-[#727272]"
    ]
  end

  defp color_variant("bordered", "natural") do
    [
      "text-[#282828] [&_.dropzone-wrapper]:border-[#282828] [&_.dropzone-wrapper]:bg-[#F3F3F3]",
      "dark:text-[#E8E8E8] dark:[&_.dropzone-wrapper]:border-[#E8E8E8] dark:[&_.dropzone-wrapper]:bg-[#4B4B4B]"
    ]
  end

  defp color_variant("bordered", "primary") do
    [
      "text-[#016974] [&_.dropzone-wrapper]:border-[#016974] [&_.dropzone-wrapper]:bg-[#E2F8FB]",
      "dark:text-[#77D5E3] dark:[&_.dropzone-wrapper]:border-[#77D5E3] dark:[&_.dropzone-wrapper]:bg-[#002D33]"
    ]
  end

  defp color_variant("bordered", "secondary") do
    [
      "text-[#175BCC] [&_.dropzone-wrapper]:border-[#175BCC] [&_.dropzone-wrapper]:bg-[#EFF4FE]",
      "dark:text-[#A9C9FF] dark:[&_.dropzone-wrapper]:border-[#A9C9FF] dark:[&_.dropzone-wrapper]:bg-[#002661]"
    ]
  end

  defp color_variant("bordered", "success") do
    [
      "text-[#166C3B] [&_.dropzone-wrapper]:border-[#166C3B] [&_.dropzone-wrapper]:bg-[#EAF6ED]",
      "dark:text-[#7FD99A] dark:[&_.dropzone-wrapper]:border-[#7FD99A] dark:[&_.dropzone-wrapper]:bg-[#002F14]"
    ]
  end

  defp color_variant("bordered", "warning") do
    [
      "text-[#976A01] [&_.dropzone-wrapper]:border-[#976A01] [&_.dropzone-wrapper]:bg-[#FFF7E6]",
      "dark:text-[#FDD067] dark:[&_.dropzone-wrapper]:border-[#FDD067] dark:[&_.dropzone-wrapper]:bg-[#322300]"
    ]
  end

  defp color_variant("bordered", "danger") do
    [
      "text-[#BB032A] [&_.dropzone-wrapper]:border-[#BB032A] [&_.dropzone-wrapper]:bg-[#FFF0EE]",
      "dark:text-[#FFB2AB] dark:[&_.dropzone-wrapper]:border-[#FFB2AB] dark:[&_.dropzone-wrapper]:bg-[#520810]"
    ]
  end

  defp color_variant("bordered", "info") do
    [
      "text-[#0B84BA] [&_.dropzone-wrapper]:border-[#0B84BA] [&_.dropzone-wrapper]:bg-[#E7F6FD]",
      "dark:text-[#6EC9F2] dark:[&_.dropzone-wrapper]:border-[#6EC9F2] dark:[&_.dropzone-wrapper]:bg-[#03212F]"
    ]
  end

  defp color_variant("bordered", "misc") do
    [
      "text-[#653C94] [&_.dropzone-wrapper]:border-[#653C94] [&_.dropzone-wrapper]:bg-[#F6F0FE]",
      "dark:text-[#CBA2FA] dark:[&_.dropzone-wrapper]:border-[#CBA2FA] dark:[&_.dropzone-wrapper]:bg-[#221431]"
    ]
  end

  defp color_variant("bordered", "dawn") do
    [
      "text-[#7E4B2A] [&_.dropzone-wrapper]:border-[#7E4B2A] [&_.dropzone-wrapper]:bg-[#FBF2ED]",
      "dark:text-[#E4B190] dark:[&_.dropzone-wrapper]:border-[#E4B190] dark:[&_.dropzone-wrapper]:bg-[#2A190E]"
    ]
  end

  defp color_variant("bordered", "silver") do
    [
      "text-[#727272] [&_.dropzone-wrapper]:border-[#727272] [&_.dropzone-wrapper]:bg-[#F3F3F3]",
      "dark:text-[#BBBBBB] dark:[&_.dropzone-wrapper]:border-[#BBBBBB] dark:[&_.dropzone-wrapper]:bg-[#4B4B4B]"
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
      "[&_.dropzone-wrapper]:bg-gradient-to-br from-[#282828] to-[#727272] text-white",
      "dark:from-[#A6A6A6] dark:to-[#FFFFFF] dark:text-black"
    ]
  end

  defp color_variant("gradient", "primary") do
    [
      "[&_.dropzone-wrapper]:bg-gradient-to-br from-[#016974] to-[#01B8CA] text-white",
      "dark:from-[#01B8CA] dark:to-[#B0E7EF] dark:text-black"
    ]
  end

  defp color_variant("gradient", "secondary") do
    [
      "[&_.dropzone-wrapper]:bg-gradient-to-br from-[#175BCC] to-[#6DAAFB] text-white",
      "dark:from-[#6DAAFB] dark:to-[#CDDEFF] dark:text-black"
    ]
  end

  defp color_variant("gradient", "success") do
    [
      "[&_.dropzone-wrapper]:bg-gradient-to-br from-[#166C3B] to-[#06C167] text-white",
      "dark:from-[#06C167] dark:to-[#B1EAC2] dark:text-black"
    ]
  end

  defp color_variant("gradient", "warning") do
    [
      "[&_.dropzone-wrapper]:bg-gradient-to-br from-[#976A01] to-[#FDC034] text-white",
      "dark:from-[#FDC034] dark:to-[#FEDF99] dark:text-black"
    ]
  end

  defp color_variant("gradient", "danger") do
    [
      "[&_.dropzone-wrapper]:bg-gradient-to-br from-[#BB032A] to-[#FC7F79] text-white",
      "dark:from-[#FC7F79] dark:to-[#FFD2CD] dark:text-black"
    ]
  end

  defp color_variant("gradient", "info") do
    [
      "[&_.dropzone-wrapper]:bg-gradient-to-br from-[#08638C] to-[#3EB7ED] text-white",
      "dark:from-[#3EB7ED] dark:to-[#9FDBF6] dark:text-black"
    ]
  end

  defp color_variant("gradient", "misc") do
    [
      "[&_.dropzone-wrapper]:bg-gradient-to-br from-[#653C94] to-[#BA83F9] text-white",
      "dark:from-[#BA83F9] dark:to-[#DDC1FC] dark:text-black"
    ]
  end

  defp color_variant("gradient", "dawn") do
    [
      "[&_.dropzone-wrapper]:bg-gradient-to-br from-[#7E4B2A] to-[#DB976B] text-white",
      "dark:from-[#DB976B] dark:to-[#EDCBB5] dark:text-black"
    ]
  end

  defp color_variant("gradient", "silver") do
    [
      "[&_.dropzone-wrapper]:bg-gradient-to-br from-[#5E5E5E] to-[#A6A6A6] text-white",
      "dark:from-[#868686] dark:to-[#BBBBBB] dark:text-black"
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
    <span class={[@name] ++ @class} />
    """
  end

  defp icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end
end
