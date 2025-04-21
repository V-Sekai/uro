defmodule UroWeb.Components.Table do
  @moduledoc """
  `UroWeb.Components.Table` is a versatile component for creating customizable tables in a
  Phoenix LiveView application. This module offers a wide range of configurations to tailor table
  presentations, including options for styling, borders, text alignment, padding, and various visual variants.

  It provides components for table structure (`table/1`), headers (`th/1`), rows (`tr/1`), and cells
  (`td/1`). These elements can be easily customized to fit different design requirements,
  such as fixed layouts, border styles, and hover effects.

  By utilizing slots, the module allows for the inclusion of dynamic content in the table's header and
  footer sections, with the ability to embed icons and custom classes for a polished and interactive interface.
  """

  use Phoenix.Component
  use Gettext, backend: Uro.Gettext

  @doc """
  Renders a customizable `table` component that supports custom styling for rows, columns,
  and table headers. This component allows for specifying borders, padding, rounded corners,
  and text alignment.

  It also supports fixed layout and various configurations for headers, footers, and cells.

  ## Examples

  ```elixir
  <.table>
    <:header>Name</:header>
    <:header>Age</:header>
    <:header>Address</:header>
    <:header>Email</:header>
    <:header>Job</:header>
    <:header>Action</:header>

    <.tr>
      <.td>Jim Emerald</.td>
      <.td>27</.td>
      <.td>London No. 1 Lake Park</.td>
      <.td>test@mail.com</.td>
      <.td>Frontend Developer</.td>
      <.td><.rating select={3} count={5} /></.td>
    </.tr>

    <.tr>
      <.td>Alex Brown</.td>
      <.td>32</.td>
      <.td>New York No. 2 River Park</.td>
      <.td>alex@mail.com</.td>
      <.td>Backend Developer</.td>
      <.td><.rating select={4} count={5} /></.td>
    </.tr>

    <.tr>
      <.td>John Doe</.td>
      <.td>28</.td>
      <.td>Los Angeles No. 3 Sunset Boulevard</.td>
      <.td>john@mail.com</.td>
      <.td>UI/UX Designer</.td>
      <.td><.rating select={5} count={5} /></.td>
    </.tr>

    <:footer>Total</:footer>
    <:footer>3 Employees</:footer>
  </.table>


  <.table id="users" rows={@users}>
    <:col :let={user} label="id">{user.id}</:col>
    <:col :let={user} label="username">{user.username}</:col>
  </.table>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :variant, :string, default: "base", doc: "Determines the style"
  attr :rounded, :string, default: "", doc: "Determines the border radius"
  attr :padding, :string, default: "small", doc: "Determines padding for items"
  attr :text_size, :string, default: "small", doc: "Determines text size"
  attr :color, :string, default: "natural", doc: "Determines color theme"
  attr :border, :string, default: "extra_small", doc: "Determines border style"
  attr :header_border, :string, default: "", doc: "Sets the border style for the table header"
  attr :rows_border, :string, default: "", doc: "Sets the border style for rows in the table"
  attr :cols_border, :string, default: "", doc: "Sets the border style for columns in the table"
  attr :thead_class, :string, default: nil, doc: "Adds custom CSS classes to the table header"
  attr :footer_class, :string, default: nil, doc: "Adds custom CSS classes to the table footer"
  attr :table_fixed, :boolean, default: false, doc: "Enables or disables the table's fixed layout"
  attr :text_position, :string, default: "left", doc: "Determines the element's text position"
  attr :space, :string, default: "medium", doc: "Determines the table row spaces"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  slot :header do
    attr :class, :any, doc: "Custom CSS class for additional styling"
    attr :icon, :any, doc: "Icon displayed alongside of an item"
    attr :icon_class, :any, doc: "Determines custom class for the icon"
  end

  slot :footer do
    attr :class, :any, doc: "Custom CSS class for additional styling"
    attr :icon, :any, doc: "Icon displayed alongside of an item"
    attr :icon_class, :any, doc: "Determines custom class for the icon"
  end

  attr :rows, :list, default: []
  attr :row_id, :any, default: nil, doc: "the function for generating the row id"
  attr :row_click, :any, default: nil, doc: "the function for handling phx-click on each row"

  attr :row_item, :any,
    default: &Function.identity/1,
    doc: "the function for mapping each row before calling the :col and :action slots"

  slot :col, required: false do
    attr :label, :string
  end

  slot :action, doc: "the slot for showing user actions in the last table column"

  def table(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
      end

    ~H"""
    <div class="-m-1.5 overflow-x-auto">
      <div class="p-1.5 min-w-full inline-block align-middle">
        <div class={[
          "overflow-hidden",
          color_variant(@variant, @color),
          text_position(@text_position),
          rounded_size(@rounded, @variant),
          text_size(@text_size),
          border_class(@border, @variant),
          padding_size(@padding),
          rows_space(@space, @variant),
          @header_border && header_border(@header_border, @variant),
          @rows_border != "" && rows_border(@rows_border, @variant),
          @cols_border && cols_border(@cols_border, @variant)
        ]}>
          <table
            class={[
              "min-w-full",
              @rows != [] && "divide-y",
              @table_fixed && "table-fixed",
              @variant == "separated" || (@variant == "base_separated" && "border-separate"),
              @class
            ]}
            {@rest}
          >
            <thead class={@thead_class}>
              <.tr>
                <.th
                  :for={{header, index} <- Enum.with_index(@header, 1)}
                  id={"#{@id}-table-header-#{index}"}
                  scope="col"
                  class={header[:class]}
                >
                  <.icon
                    :if={header[:icon]}
                    name={header[:icon]}
                    class={["table-header-icon block me-2", header[:icon_class]]}
                  />
                  {render_slot(header)}
                </.th>
              </.tr>

              <.tr :if={@col}>
                <.th :for={col <- @col} class="font-normal">{col[:label]}</.th>
                <.th :if={@action != []} class="relative">
                  <span class="sr-only">{gettext("Actions")}</span>
                </.th>
              </.tr>
            </thead>

            <tbody
              id={@id}
              phx-update={match?(%Phoenix.LiveView.LiveStream{}, @rows) && "stream"}
              class={@rows != [] && "divide-y"}
            >
              {render_slot(@inner_block)}

              <.tr :for={row <- @rows} :if={@rows != []} id={@row_id && @row_id.(row)}>
                <.td
                  :for={{col, i} <- Enum.with_index(@col)}
                  phx-click={@row_click && @row_click.(row)}
                  class={@row_click && "hover:cursor-pointer"}
                >
                  <div class="relative">
                    <span class="absolute -inset-y-px right-0 -left-4" />
                    <span class={["relative", i == 0 && "font-semibold"]}>
                      {render_slot(col, @row_item.(row))}
                    </span>
                  </div>
                </.td>

                <.td :if={@action} class="relative w-14 p-0">
                  <div class="relative whitespace-nowrap py-4 text-right text-sm font-medium">
                    <span class="absolute -inset-y-px -right-4 left-0" />
                    <span :for={action <- @action} class="relative ml-4 font-semibold leading-6">
                      {render_slot(action, @row_item.(row))}
                    </span>
                  </div>
                </.td>
              </.tr>
            </tbody>

            <tfoot :if={length(@footer) > 0} class={@footer_class}>
              <.tr>
                <.td
                  :for={{footer, index} <- Enum.with_index(@footer, 1)}
                  id={"#{@id}-table-footer-#{index}"}
                  class={footer[:class]}
                >
                  <div class="flex items-center">
                    <.icon
                      :if={footer[:icon]}
                      name={footer[:icon]}
                      class={["table-footer-icon block me-2", footer[:icon_class]]}
                    />
                    {render_slot(footer)}
                  </div>
                </.td>
              </.tr>
            </tfoot>
          </table>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders a table header cell (`<th>`) component with customizable class and scope attributes.
  This component allows for additional styling and accepts global attributes.

  ## Examples

  ```elixir
  <.th>Column Title</.th>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :scope, :string, default: nil, doc: "Specifies the scope of the table header cell"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def th(assigns) do
    ~H"""
    <th id={@id} scope={@scope} class={["table-header", @class]} {@rest}>
      {render_slot(@inner_block)}
    </th>
    """
  end

  @doc """
  Renders a table row (<tr>) component with customizable class attributes.
  This component allows for additional styling and accepts global attributes.

  ## Examples

  ```elixir
  <.tr>
    <.td>Data 1</.td>
    <.td>Data 2</.td>
  </.tr>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def tr(assigns) do
    ~H"""
    <tr id={@id} class={["table-row", @class]} {@rest}>
      {render_slot(@inner_block)}
    </tr>
    """
  end

  @doc """
  Renders a table data cell (`<td>`) component with customizable class attributes.
  This component allows for additional styling and accepts global attributes.

  ## Examples
  ```elixir
  <.td>Data</.td>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def td(assigns) do
    ~H"""
    <td id={@id} class={["table-data-cell", @class]} {@rest}>
      {render_slot(@inner_block)}
    </td>
    """
  end

  defp rounded_size("extra_small", "separated") do
    [
      "[&_.border-separate_tr_td:first-child]:rounded-s-sm [&_.border-separate_tr_td:first-child]:rounded-s-sm",
      "[&_.border-separate_tr_td:last-child]:rounded-e-sm [&_.border-separate_tr_td:last-child]:rounded-e-sm",
      "[&_.border-separate_tr_th:first-child]:rounded-s-sm [&_.border-separate_tr_th:first-child]:rounded-s-sm",
      "[&_.border-separate_tr_th:last-child]:rounded-e-sm [&_.border-separate_tr_th:last-child]:rounded-e-sm"
    ]
  end

  defp rounded_size("small", "separated") do
    [
      "[&_.border-separate_tr_td:first-child]:rounded-s [&_.border-separate_tr_td:first-child]:rounded-s",
      "[&_.border-separate_tr_td:last-child]:rounded-e [&_.border-separate_tr_td:last-child]:rounded-e",
      "[&_.border-separate_tr_th:first-child]:rounded-s [&_.border-separate_tr_th:first-child]:rounded-s",
      "[&_.border-separate_tr_th:last-child]:rounded-e [&_.border-separate_tr_th:last-child]:rounded-e"
    ]
  end

  defp rounded_size("medium", "separated") do
    [
      "[&_.border-separate_tr_td:first-child]:rounded-s-md [&_.border-separate_tr_td:first-child]:rounded-s-md",
      "[&_.border-separate_tr_td:last-child]:rounded-e-md [&_.border-separate_tr_td:last-child]:rounded-e-md",
      "[&_.border-separate_tr_th:first-child]:rounded-s-md [&_.border-separate_tr_th:first-child]:rounded-s-md",
      "[&_.border-separate_tr_th:last-child]:rounded-e-md [&_.border-separate_tr_th:last-child]:rounded-e-md"
    ]
  end

  defp rounded_size("large", "separated") do
    [
      "[&_.border-separate_tr_td:first-child]:rounded-s-lg [&_.border-separate_tr_td:first-child]:rounded-s-lg",
      "[&_.border-separate_tr_td:last-child]:rounded-e-lg [&_.border-separate_tr_td:last-child]:rounded-e-lg",
      "[&_.border-separate_tr_th:first-child]:rounded-s-lg [&_.border-separate_tr_th:first-child]:rounded-s-lg",
      "[&_.border-separate_tr_th:last-child]:rounded-e-lg [&_.border-separate_tr_th:last-child]:rounded-e-lg"
    ]
  end

  defp rounded_size("extra_large", "separated") do
    [
      "[&_.border-separate_tr_td:first-child]:rounded-s-xl [&_.border-separate_tr_td:first-child]:rounded-s-xl",
      "[&_.border-separate_tr_td:last-child]:rounded-e-xl [&_.border-separate_tr_td:last-child]:rounded-e-xl",
      "[&_.border-separate_tr_th:first-child]:rounded-s-xl [&_.border-separate_tr_th:first-child]:rounded-s-xl",
      "[&_.border-separate_tr_th:last-child]:rounded-e-xl [&_.border-separate_tr_th:last-child]:rounded-e-xl"
    ]
  end

  defp rounded_size("extra_small", "base_separated") do
    [
      "[&_.border-separate_tr_td:first-child]:rounded-s-sm [&_.border-separate_tr_td:first-child]:rounded-s-sm",
      "[&_.border-separate_tr_td:last-child]:rounded-e-sm [&_.border-separate_tr_td:last-child]:rounded-e-sm",
      "[&_.border-separate_tr_th:first-child]:rounded-s-sm [&_.border-separate_tr_th:first-child]:rounded-s-sm",
      "[&_.border-separate_tr_th:last-child]:rounded-e-sm [&_.border-separate_tr_th:last-child]:rounded-e-sm"
    ]
  end

  defp rounded_size("small", "base_separated") do
    [
      "[&_.border-separate_tr_td:first-child]:rounded-s [&_.border-separate_tr_td:first-child]:rounded-s",
      "[&_.border-separate_tr_td:last-child]:rounded-e [&_.border-separate_tr_td:last-child]:rounded-e",
      "[&_.border-separate_tr_th:first-child]:rounded-s [&_.border-separate_tr_th:first-child]:rounded-s",
      "[&_.border-separate_tr_th:last-child]:rounded-e [&_.border-separate_tr_th:last-child]:rounded-e"
    ]
  end

  defp rounded_size("medium", "base_separated") do
    [
      "[&_.border-separate_tr_td:first-child]:rounded-s-md [&_.border-separate_tr_td:first-child]:rounded-s-md",
      "[&_.border-separate_tr_td:last-child]:rounded-e-md [&_.border-separate_tr_td:last-child]:rounded-e-md",
      "[&_.border-separate_tr_th:first-child]:rounded-s-md [&_.border-separate_tr_th:first-child]:rounded-s-md",
      "[&_.border-separate_tr_th:last-child]:rounded-e-md [&_.border-separate_tr_th:last-child]:rounded-e-md"
    ]
  end

  defp rounded_size("large", "base_separated") do
    [
      "[&_.border-separate_tr_td:first-child]:rounded-s-lg [&_.border-separate_tr_td:first-child]:rounded-s-lg",
      "[&_.border-separate_tr_td:last-child]:rounded-e-lg [&_.border-separate_tr_td:last-child]:rounded-e-lg",
      "[&_.border-separate_tr_th:first-child]:rounded-s-lg [&_.border-separate_tr_th:first-child]:rounded-s-lg",
      "[&_.border-separate_tr_th:last-child]:rounded-e-lg [&_.border-separate_tr_th:last-child]:rounded-e-lg"
    ]
  end

  defp rounded_size("extra_large", "base_separated") do
    [
      "[&_.border-separate_tr_td:first-child]:rounded-s-xl [&_.border-separate_tr_td:first-child]:rounded-s-xl",
      "[&_.border-separate_tr_td:last-child]:rounded-e-xl [&_.border-separate_tr_td:last-child]:rounded-e-xl",
      "[&_.border-separate_tr_th:first-child]:rounded-s-xl [&_.border-separate_tr_th:first-child]:rounded-s-xl",
      "[&_.border-separate_tr_th:last-child]:rounded-e-xl [&_.border-separate_tr_th:last-child]:rounded-e-xl"
    ]
  end

  defp rounded_size("extra_small", _), do: "rounded-sm"

  defp rounded_size("small", _), do: "rounded"

  defp rounded_size("medium", _), do: "rounded-md"

  defp rounded_size("large", _), do: "rounded-lg"

  defp rounded_size("extra_large", _), do: "rounded-xl"

  defp rounded_size(params, _) when is_binary(params), do: [params]

  defp text_size("extra_small"), do: "text-xs"
  defp text_size("small"), do: "text-sm"
  defp text_size("medium"), do: "text-base"
  defp text_size("large"), do: "text-lg"
  defp text_size("extra_large"), do: "text-xl"
  defp text_size(params) when is_binary(params), do: [params]

  defp text_position("left"), do: "[&_table]:text-left [&_table_thead]:text-left"
  defp text_position("right"), do: "[&_table]:text-right [&_table_thead]:text-right"
  defp text_position("center"), do: "[&_table]:text-center [&_table_thead]:text-center"
  defp text_position("justify"), do: "[&_table]:text-justify [&_table_thead]:text-justify"
  defp text_position("start"), do: "[&_table]:text-start [&_table_thead]:text-start"
  defp text_position("end"), do: "[&_table]:text-end [&_table_thead]:text-end"
  defp text_position(params) when is_binary(params), do: params

  defp border_class(_, variant)
       when variant in [
              "default",
              "shadow",
              "transparent",
              "stripped",
              "hoverable",
              "separated",
              "base_separated"
            ],
       do: nil

  defp border_class("extra_small", _), do: "border"
  defp border_class("small", _), do: "border-2"
  defp border_class("medium", _), do: "border-[3px]"
  defp border_class("large", _), do: "border-4"
  defp border_class("extra_large", _), do: "border-[5px]"
  defp border_class(params, _) when is_binary(params), do: [params]

  defp cols_border(_, variant)
       when variant in ["default", "shadow", "transparent", "stripped", "hoverable", "separated"],
       do: nil

  defp cols_border("extra_small", _) do
    [
      "[&_table_thead_th:not(:last-child)]:border-e",
      "[&_table_tbody_td:not(:last-child)]:border-e",
      "[&_table_tfoot_td:not(:last-child)]:border-e"
    ]
  end

  defp cols_border("small", _) do
    [
      "[&_table_thead_th:not(:last-child)]:border-e-2",
      "[&_table_tbody_td:not(:last-child)]:border-e-2",
      "[&_table_tfoot_td:not(:last-child)]:border-e-2"
    ]
  end

  defp cols_border("medium", _) do
    [
      "[&_table_thead_th:not(:last-child)]:border-e-[3px]",
      "[&_table_tbody_td:not(:last-child)]:border-e-[3px]",
      "[&_table_tfoot_td:not(:last-child)]:border-e-[3px]"
    ]
  end

  defp cols_border("large", _) do
    [
      "[&_table_thead_th:not(:last-child)]:border-e-4",
      "[&_table_tbody_td:not(:last-child)]:border-e-4",
      "[&_table_tfoot_td:not(:last-child)]:border-e-4"
    ]
  end

  defp cols_border("extra_large", _) do
    [
      "[&_table_thead_th:not(:last-child)]:border-e-[5px]",
      "[&_table_tbody_td:not(:last-child)]:border-e-[5px]",
      "[&_table_tfoot_td:not(:last-child)]:border-e-[5px]"
    ]
  end

  defp cols_border(params, _) when is_binary(params), do: [params]

  defp rows_border(_, variant)
       when variant in ["default", "shadow", "transparent", "stripped", "hoverable", "separated"],
       do: nil

  defp rows_border("none", "base_separated"), do: nil

  defp rows_border("extra_small", "base_separated") do
    [
      "[&_td]:border-y [&_th]:border-y",
      "[&_td:first-child]:border-s [&_th:first-child]:border-s",
      "[&_td:last-child]:border-e [&_th:last-child]:border-e"
    ]
  end

  defp rows_border("small", "base_separated") do
    [
      "[&_td]:border-y-2 [&_th]:border-y-2",
      "[&_td:first-child]:border-s-2 [&_th:first-child]:border-s-2",
      "[&_td:last-child]:border-e-2 [&_th:last-child]:border-e-2"
    ]
  end

  defp rows_border("medium", "base_separated") do
    [
      "[&_td]:border-y-[3px] [&_th]:border-y-[3px]",
      "[&_td:first-child]:border-s-3 [&_th:first-child]:border-s-3",
      "[&_td:last-child]:border-e-3 [&_th:last-child]:border-e-3"
    ]
  end

  defp rows_border("large", "base_separated") do
    [
      "[&_td]:border-y-4 [&_th]:border-y-4",
      "[&_td:first-child]:border-s-4 [&_th:first-child]:border-s-4",
      "[&_td:last-child]:border-e-4 [&_th:last-child]:border-e-4"
    ]
  end

  defp rows_border("extra_large", "base_separated") do
    [
      "[&_td]:border-y-[5px] [&_th]:border-y-[5px]",
      "[&_td:first-child]:border-s-5 [&_th:first-child]:border-s-5",
      "[&_td:last-child]:border-e-5 [&_th:last-child]:border-e-5"
    ]
  end

  defp rows_border("none", _), do: nil
  defp rows_border("extra_small", _), do: "[&_table_tbody]:divide-y"
  defp rows_border("small", _), do: "[&_table_tbody]:divide-y-2"
  defp rows_border("medium", _), do: "[&_table_tbody]:divide-y-[3px]"
  defp rows_border("large", _), do: "[&_table_tbody]:divide-y-4"
  defp rows_border("extra_large", _), do: "[&_table_tbody]:divide-y-[5px]"
  defp rows_border(params, _) when is_binary(params), do: [params]

  defp header_border(_, variant)
       when variant in [
              "default",
              "shadow",
              "transparent",
              "stripped",
              "hoverable",
              "separated",
              "base_separated"
            ],
       do: nil

  defp header_border("extra_small", _), do: "[&_table]:divide-y"
  defp header_border("small", _), do: "[&_table]:divide-y-2"
  defp header_border("medium", _), do: "[&_table]:divide-y-[3px]"
  defp header_border("large", _), do: "[&_table]:divide-y-4"
  defp header_border("extra_large", _), do: "[&_table]:divide-y-[5px]"
  defp header_border(params, _) when is_binary(params), do: [params]

  defp rows_space(_, variant)
       when variant in [
              "default",
              "shadow",
              "transparent",
              "stripped",
              "hoverable",
              "bordered",
              "base",
              "base_hoverable",
              "base_stripped",
              "outline"
            ],
       do: nil

  defp rows_space("extra_small", _), do: "[&_table]:border-spacing-y-0.5"
  defp rows_space("small", _), do: "[&_table]:border-spacing-y-1"
  defp rows_space("medium", _), do: "[&_table]:border-spacing-y-2"
  defp rows_space("large", _), do: "[&_table]:border-spacing-y-3"
  defp rows_space("extra_large", _), do: "[&_table]:border-spacing-y-4"
  defp rows_space(params, _) when is_binary(params), do: [params]

  defp padding_size("extra_small") do
    [
      "[&_table_.table-data-cell]:px-3 [&_table_.table-data-cell]:py-1.5",
      "[&_table_.table-header]:px-3 [&_table_.table-header]:py-1.5"
    ]
  end

  defp padding_size("small") do
    [
      "[&_table_.table-data-cell]:px-4 [&_table_.table-data-cell]:py-2",
      "[&_table_.table-header]:px-4 [&_table_.table-header]:py-2"
    ]
  end

  defp padding_size("medium") do
    [
      "[&_table_.table-data-cell]:px-5 [&_table_.table-data-cell]:py-2.5",
      "[&_table_.table-header]:px-5 [&_table_.table-header]:py-2.5"
    ]
  end

  defp padding_size("large") do
    [
      "[&_table_.table-data-cell]:px-6 [&_table_.table-data-cell]:py-3",
      "[&_table_.table-header]:px-6 [&_table_.table-header]:py-3"
    ]
  end

  defp padding_size("extra_large") do
    [
      "[&_table_.table-data-cell]:px-7 [&_table_.table-data-cell]:py-3.5",
      "[&_table_.table-header]:px-7 [&_table_.table-header]:py-3.5"
    ]
  end

  defp padding_size(params) when is_binary(params), do: params

  defp color_variant("base", _) do
    [
      "[&_table]:bg-white dark:[&_table]:bg-[#18181B] [&_table]:text-[#09090b] dark:[&_table]:text-[#FAFAFA]",
      "border-[#e4e4e7] dark:border-[#27272a]",
      "[&_*]:divide-[#e4e4e7] [&_td]:border-[#e4e4e7] [&_th]:border-[#e4e4e7]",
      "dark:[&_*]:divide-[#27272a] dark:[&_td]:border-[#27272a] dark:[&_th]:border-[#27272a]",
      "shadow-sm"
    ]
  end

  defp color_variant("base_separated", _) do
    [
      "[&_table_tr]:bg-white [&_table]:text-[#09090b] dark:[&_table_tr]:bg-[#18181B] dark:[&_table]:text-[#FAFAFA]",
      "[&_td]:border-[#e4e4e7] dark:[&_td]:border-[#27272a]",
      "[&_th]:border-[#e4e4e7] dark:[&_th]:border-[#27272a]"
    ]
  end

  defp color_variant("base_hoverable", _) do
    [
      "[&_table]:bg-white [&_table]:text-[#09090b] dark:[&_table]:bg-[#18181B] dark:[&_table]:text-[#FAFAFA]",
      "hover:[&_table_tbody_tr]:bg-[#e4e4e7] dark:hover:[&_table_tbody_tr]:bg-[#27272a]",
      "border-[#e4e4e7] dark:border-[#27272a]",
      "[&_*]:divide-[#e4e4e7] [&_td]:border-[#e4e4e7] [&_th]:border-[#e4e4e7]",
      "dark:[&_*]:divide-[#27272a] dark:[&_td]:border-[#27272a] dark:[&_th]:border-[#27272a]"
    ]
  end

  defp color_variant("base_stripped", _) do
    [
      "[&_table]:bg-white [&_table]:text-[#09090b] dark:[&_table]:bg-[#18181B] dark:[&_table]:text-[#FAFAFA]",
      "odd:[&_table_tbody_tr]:bg-[#F8F9FA] dark:odd:[&_table_tbody_tr]:bg-[#242424]",
      "border-[#e4e4e7] dark:border-[#27272a]",
      "[&_*]:divide-[#e4e4e7] [&_td]:border-[#e4e4e7] [&_th]:border-[#e4e4e7]",
      "dark:[&_*]:divide-[#27272a] dark:[&_td]:border-[#27272a] dark:[&_th]:border-[#27272a]"
    ]
  end

  defp color_variant("bordered", "white") do
    "[&_table]:bg-white text-[#3E3E3E] border-[#DADADA] [&_*]:divide-[#DADADA] [&_td]:border-[#DADADA] [&_th]:border-[#DADADA]"
  end

  defp color_variant("bordered", "natural") do
    [
      "[&_table]:bg-[#F3F3F3] dark:[&_table]:bg-[#4B4B4B] [&_table]:text-[#282828] dark:[&_table]:text-[#E8E8E8]",
      "border-[#282828] dark:border-[#E8E8E8]",
      "[&_*]:divide-[#282828] [&_td]:border-[#282828] [&_th]:border-[#282828]",
      "dark:[&_*]:divide-[#E8E8E8] dark:[&_td]:border-[#E8E8E8] dark:[&_th]:border-[#E8E8E8]"
    ]
  end

  defp color_variant("bordered", "primary") do
    [
      "[&_table]:bg-[#E2F8FB] dark:[&_table]:bg-[#002D33] [&_table]:text-[#016974] dark:[&_table]:text-[#77D5E3]",
      "border-[#016974] dark:border-[#77D5E3]",
      "[&_*]:divide-[#016974] [&_td]:border-[#016974] [&_th]:border-[#016974]",
      "dark:[&_*]:divide-[#77D5E3] dark:[&_td]:border-[#77D5E3] dark:[&_th]:border-[#77D5E3]"
    ]
  end

  defp color_variant("bordered", "secondary") do
    [
      "[&_table]:bg-[#EFF4FE] dark:[&_table]:bg-[#002661] [&_table]:text-[#175BCC] dark:[&_table]:text-[#A9C9FF]",
      "border-[#175BCC] dark:border-[#A9C9FF]",
      "[&_*]:divide-[#175BCC] [&_td]:border-[#175BCC] [&_th]:border-[#175BCC]",
      "dark:[&_*]:divide-[#A9C9FF] dark:[&_td]:border-[#A9C9FF] dark:[&_th]:border-[#A9C9FF]"
    ]
  end

  defp color_variant("bordered", "success") do
    [
      "[&_table]:bg-[#EAF6ED] dark:[&_table]:bg-[#002F14] [&_table]:text-[#166C3B] dark:[&_table]:text-[#7FD99A]",
      "border-[#166C3B] dark:border-[#7FD99A]",
      "[&_*]:divide-[#166C3B] [&_td]:border-[#166C3B] [&_th]:border-[#166C3B]",
      "dark:[&_*]:divide-[#7FD99A] dark:[&_td]:border-[#7FD99A] dark:[&_th]:border-[#7FD99A]"
    ]
  end

  defp color_variant("bordered", "warning") do
    [
      "[&_table]:bg-[#FFF7E6] dark:[&_table]:bg-[#322300] [&_table]:text-[#976A01] dark:[&_table]:text-[#FDD067]",
      "border-[#976A01] dark:border-[#FDD067]",
      "[&_*]:divide-[#976A01] [&_td]:border-[#976A01] [&_th]:border-[#976A01]",
      "dark:[&_*]:divide-[#FDD067] dark:[&_td]:border-[#FDD067] dark:[&_th]:border-[#FDD067]"
    ]
  end

  defp color_variant("bordered", "danger") do
    [
      "[&_table]:bg-[#FFF0EE] dark:[&_table]:bg-[#520810] [&_table]:text-[#BB032A] dark:[&_table]:text-[#FFB2AB]",
      "border-[#BB032A] dark:border-[#FFB2AB]",
      "[&_*]:divide-[#BB032A] [&_td]:border-[#BB032A] [&_th]:border-[#BB032A]",
      "dark:[&_*]:divide-[#FFB2AB] dark:[&_td]:border-[#FFB2AB] dark:[&_th]:border-[#FFB2AB]"
    ]
  end

  defp color_variant("bordered", "info") do
    [
      "[&_table]:bg-[#E7F6FD] dark:[&_table]:bg-[#03212F] [&_table]:text-[#0B84BA] dark:[&_table]:text-[#6EC9F2]",
      "border-[#0B84BA] dark:border-[#6EC9F2]",
      "[&_*]:divide-[#0B84BA] [&_td]:border-[#0B84BA] [&_th]:border-[#0B84BA]",
      "dark:[&_*]:divide-[#6EC9F2] dark:[&_td]:border-[#6EC9F2] dark:[&_th]:border-[#6EC9F2]"
    ]
  end

  defp color_variant("bordered", "misc") do
    [
      "[&_table]:bg-[#F6F0FE] dark:[&_table]:bg-[#221431] [&_table]:text-[#653C94] dark:[&_table]:text-[#CBA2FA]",
      "border-[#653C94] dark:border-[#CBA2FA]",
      "[&_*]:divide-[#653C94] [&_td]:border-[#653C94] [&_th]:border-[#653C94]",
      "dark:[&_*]:divide-[#CBA2FA] dark:[&_td]:border-[#CBA2FA] dark:[&_th]:border-[#CBA2FA]"
    ]
  end

  defp color_variant("bordered", "dawn") do
    [
      "[&_table]:bg-[#FBF2ED] dark:[&_table]:bg-[#2A190E] [&_table]:text-[#7E4B2A] dark:[&_table]:text-[#E4B190]",
      "border-[#7E4B2A] dark:border-[#E4B190]",
      "[&_*]:divide-[#7E4B2A] [&_td]:border-[#7E4B2A] [&_th]:border-[#7E4B2A]",
      "dark:[&_*]:divide-[#E4B190] dark:[&_td]:border-[#E4B190] dark:[&_th]:border-[#E4B190]"
    ]
  end

  defp color_variant("bordered", "silver") do
    [
      "[&_table]:bg-[#4B4B4B] dark:[&_table]:bg-[#2A190E] [&_table]:text-[#727272] dark:[&_table]:text-[#BBBBBB]",
      "border-[#727272] dark:border-[#BBBBBB]",
      "[&_*]:divide-[#727272] [&_td]:border-[#727272] [&_th]:border-[#727272]",
      "dark:[&_*]:divide-[#BBBBBB] dark:[&_td]:border-[#BBBBBB] dark:[&_th]:border-[#BBBBBB]"
    ]
  end

  defp color_variant("bordered", "dark") do
    "[&_table]:bg-[#282828] text-white border-[#050404] [&_*]:divide-[#050404] [&_td]:border-[#050404] [&_th]:border-[#050404]"
  end

  defp color_variant("outline", "natural") do
    [
      "[&_table]:text-[#4B4B4B] border-[#4B4B4B] dark:[&_table]:text-[#DDDDDD] dark:border-[#DDDDDD]",
      "[&_*]:divide-[#4B4B4B] [&_td]:border-[#4B4B4B] [&_th]:border-[#4B4B4B]",
      "dark:[&_*]:divide-[#DDDDDD] dark:[&_td]:border-[#DDDDDD] dark:[&_th]:border-[#DDDDDD]"
    ]
  end

  defp color_variant("outline", "primary") do
    [
      "[&_table]:text-[#007F8C] border-[#007F8C] dark:[&_table]:text-[#01B8CA] dark:border-[#01B8CA]",
      "[&_*]:divide-[#007F8C] [&_td]:border-[#007F8C] [&_th]:border-[#007F8C]",
      "dark:[&_*]:divide-[#01B8CA] dark:[&_td]:border-[#01B8CA] dark:[&_th]:border-[#01B8CA]"
    ]
  end

  defp color_variant("outline", "secondary") do
    [
      "[&_table]:text-[#007F8C] border-[#007F8C] dark:[&_table]:text-[#01B8CA] dark:border-[#01B8CA]",
      "[&_*]:divide-[#007F8C] [&_td]:border-[#007F8C] [&_th]:border-[#007F8C]",
      "dark:[&_*]:divide-[#01B8CA] dark:[&_td]:border-[#01B8CA] dark:[&_th]:border-[#01B8CA]"
    ]
  end

  defp color_variant("outline", "success") do
    [
      "[&_table]:text-[#0E8345] border-[#0E8345] dark:[&_table]:text-[#06C167] dark:border-[#06C167]",
      "[&_*]:divide-[#0E8345] [&_td]:border-[#0E8345] [&_th]:border-[#0E8345]",
      "dark:[&_*]:divide-[#06C167] dark:[&_td]:border-[#06C167] dark:[&_th]:border-[#06C167]"
    ]
  end

  defp color_variant("outline", "warning") do
    [
      "[&_table]:text-[#CA8D01] border-[#CA8D01] dark:[&_table]:text-[#FDC034] dark:border-[#FDC034]",
      "[&_*]:divide-[#CA8D01] [&_td]:border-[#CA8D01] [&_th]:border-[#CA8D01]",
      "dark:[&_*]:divide-[#FDC034] dark:[&_td]:border-[#FDC034] dark:[&_th]:border-[#FDC034]"
    ]
  end

  defp color_variant("outline", "danger") do
    [
      "[&_table]:text-[#DE1135] border-[#DE1135] dark:[&_table]:text-[#FC7F79] dark:border-[#FC7F79]",
      "[&_*]:divide-[#DE1135] [&_td]:border-[#DE1135] [&_th]:border-[#DE1135]",
      "dark:[&_*]:divide-[#FC7F79] dark:[&_td]:border-[#FC7F79] dark:[&_th]:border-[#FC7F79]"
    ]
  end

  defp color_variant("outline", "info") do
    [
      "[&_table]:text-[#0B84BA] border-[#0B84BA] dark:[&_table]:text-[#3EB7ED] dark:border-[#3EB7ED]",
      "[&_*]:divide-[#0B84BA] [&_td]:border-[#0B84BA] [&_th]:border-[#0B84BA]",
      "dark:[&_*]:divide-[#3EB7ED] dark:[&_td]:border-[#3EB7ED] dark:[&_th]:border-[#3EB7ED]"
    ]
  end

  defp color_variant("outline", "misc") do
    [
      "[&_table]:text-[#8750C5] border-[#8750C5] dark:[&_table]:text-[#BA83F9] dark:border-[#BA83F9]",
      "[&_*]:divide-[#8750C5] [&_td]:border-[#8750C5] [&_th]:border-[#8750C5]",
      "dark:[&_*]:divide-[#BA83F9] dark:[&_td]:border-[#BA83F9] dark:[&_th]:border-[#BA83F9]"
    ]
  end

  defp color_variant("outline", "dawn") do
    [
      "[&_table]:text-[#A86438] border-[#A86438] dark:[&_table]:text-[#DB976B] dark:border-[#DB976B]",
      "[&_*]:divide-[#A86438] [&_td]:border-[#A86438] [&_th]:border-[#A86438]",
      "dark:[&_*]:divide-[#DB976B] dark:[&_td]:border-[#DB976B] dark:[&_th]:border-[#DB976B]"
    ]
  end

  defp color_variant("outline", "silver") do
    [
      "[&_table]:text-[#868686] border-[#868686] dark:[&_table]:text-[#A6A6A6] dark:border-[#A6A6A6]",
      "[&_*]:divide-[#868686] [&_td]:border-[#868686] [&_th]:border-[#868686]",
      "dark:[&_*]:divide-[#A6A6A6] dark:[&_td]:border-[#A6A6A6] dark:[&_th]:border-[#A6A6A6]"
    ]
  end

  defp color_variant("default", "white") do
    "bg-white text-black"
  end

  defp color_variant("default", "natural") do
    "[&_table]:bg-[#4B4B4B] [&_table]:text-white dark:[&_table]:bg-[#DDDDDD] dark:[&_table]:text-black"
  end

  defp color_variant("default", "primary") do
    "[&_table]:bg-[#007F8C] [&_table]:text-white dark:[&_table]:bg-[#01B8CA] dark:[&_table]:text-black"
  end

  defp color_variant("default", "secondary") do
    "[&_table]:bg-[#266EF1] [&_table]:text-white dark:[&_table]:bg-[#6DAAFB] dark:[&_table]:text-black"
  end

  defp color_variant("default", "success") do
    "[&_table]:bg-[#0E8345] [&_table]:text-white dark:[&_table]:bg-[#06C167] dark:[&_table]:text-black"
  end

  defp color_variant("default", "warning") do
    "[&_table]:bg-[#CA8D01] [&_table]:text-white dark:[&_table]:bg-[#FDC034] dark:[&_table]:text-black"
  end

  defp color_variant("default", "danger") do
    "[&_table]:bg-[#DE1135] [&_table]:text-white dark:[&_table]:bg-[#FC7F79] dark:[&_table]:text-black"
  end

  defp color_variant("default", "info") do
    "[&_table]:bg-[#0B84BA] [&_table]:text-white dark:[&_table]:bg-[#3EB7ED] dark:[&_table]:text-black"
  end

  defp color_variant("default", "misc") do
    "[&_table]:bg-[#8750C5] [&_table]:text-white dark:[&_table]:bg-[#BA83F9] dark:[&_table]:text-black"
  end

  defp color_variant("default", "dawn") do
    "[&_table]:bg-[#A86438] [&_table]:text-white dark:[&_table]:bg-[#DB976B] dark:[&_table]:text-black"
  end

  defp color_variant("default", "silver") do
    "[&_table]:bg-[#868686] [&_table]:text-white dark:[&_table]:bg-[#A6A6A6] dark:[&_table]:text-black"
  end

  defp color_variant("default", "dark") do
    "[&_table]:bg-[#282828] [&_table]:text-white"
  end

  defp color_variant("shadow", "natural") do
    [
      "[&_table]:bg-[#4B4B4B] [&_table]:text-white dark:[&_table]:bg-[#DDDDDD] dark:[&_table]:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(134,134,134,0.5)] shadow-[0px_10px_15px_-3px_rgba(134,134,134,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "primary") do
    [
      "[&_table]:bg-[#007F8C] [&_table]:text-white dark:[&_table]:bg-[#01B8CA] dark:[&_table]:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(0,149,164,0.5)] shadow-[0px_10px_15px_-3px_rgba(0,149,164,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "secondary") do
    [
      "[&_table]:bg-[#266EF1] [&_table]:text-white dark:[&_table]:bg-[#6DAAFB] dark:[&_table]:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(6,139,238,0.5)] shadow-[0px_10px_15px_-3px_rgba(6,139,238,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "success") do
    [
      "[&_table]:bg-[#0E8345] [&_table]:text-white dark:[&_table]:bg-[#06C167] dark:[&_table]:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(0,154,81,0.5)] shadow-[0px_10px_15px_-3px_rgba(0,154,81,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "warning") do
    [
      "[&_table]:bg-[#CA8D01] [&_table]:text-white dark:[&_table]:bg-[#FDC034] dark:[&_table]:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(252,176,1,0.5)] shadow-[0px_10px_15px_-3px_rgba(252,176,1,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "danger") do
    [
      "[&_table]:bg-[#DE1135] [&_table]:text-white dark:[&_table]:bg-[#FC7F79] dark:[&_table]:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(248,52,70,0.5)] shadow-[0px_10px_15px_-3px_rgba(248,52,70,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "info") do
    [
      "[&_table]:bg-[#0B84BA] [&_table]:text-white dark:[&_table]:bg-[#3EB7ED] dark:[&_table]:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(14,165,233,0.5)] shadow-[0px_10px_15px_-3px_rgba(14,165,233,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "misc") do
    [
      "[&_table]:bg-[#8750C5] [&_table]:text-white dark:[&_table]:bg-[#BA83F9] dark:[&_table]:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(169,100,247,0.5)] shadow-[0px_10px_15px_-3px_rgba(169,100,247,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "dawn") do
    [
      "[&_table]:bg-[#A86438] [&_table]:text-white dark:[&_table]:bg-[#DB976B] dark:[&_table]:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(210,125,70,0.5)] shadow-[0px_10px_15px_-3px_rgba(210,125,70,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "silver") do
    [
      "[&_table]:bg-[#868686] [&_table]:text-white dark:[&_table]:bg-[#A6A6A6] dark:[&_table]:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(134,134,134,0.5)] shadow-[0px_10px_15px_-3px_rgba(134,134,134,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("transparent", "natural") do
    [
      "[&_table]:text-[#4B4B4B] dark:[&_table]:text-[#DDDDDD]"
    ]
  end

  defp color_variant("transparent", "primary") do
    [
      "[&_table]:text-[#007F8C] dark:[&_table]:text-[#01B8CA]"
    ]
  end

  defp color_variant("transparent", "secondary") do
    [
      "[&_table]:text-[#266EF1] dark:[&_table]:text-[#6DAAFB]"
    ]
  end

  defp color_variant("transparent", "success") do
    [
      "[&_table]:text-[#0E8345] dark:[&_table]:text-[#06C167]"
    ]
  end

  defp color_variant("transparent", "warning") do
    [
      "[&_table]:text-[#CA8D01] dark:[&_table]:text-[#FDC034]"
    ]
  end

  defp color_variant("transparent", "danger") do
    [
      "[&_table]:text-[#DE1135] dark:[&_table]:text-[#FC7F79]"
    ]
  end

  defp color_variant("transparent", "info") do
    [
      "[&_table]:text-[#0B84BA] dark:[&_table]:text-[#3EB7ED]"
    ]
  end

  defp color_variant("transparent", "misc") do
    [
      "[&_table]:text-[#8750C5] dark:[&_table]:text-[#BA83F9]"
    ]
  end

  defp color_variant("transparent", "dawn") do
    [
      "[&_table]:text-[#A86438] dark:[&_table]:text-[#DB976B]"
    ]
  end

  defp color_variant("transparent", "silver") do
    [
      "[&_table]:text-[#868686] dark:[&_table]:text-[#A6A6A6]"
    ]
  end

  defp color_variant("hoverable", "white") do
    [
      "[&_table]:bg-white hover:[&_table_tbody_tr]:bg-[#DADADA] text-[#3E3E3E]"
    ]
  end

  defp color_variant("hoverable", "natural") do
    [
      "[&_table]:bg-[#4B4B4B] [&_table]:text-white dark:[&_table]:bg-[#DDDDDD] dark:[&_table]:text-black",
      "hover:[&_table_tbody_tr]:bg-[#282828] dark:hover:[&_table_tbody_tr]:bg-[#E8E8E8]"
    ]
  end

  defp color_variant("hoverable", "primary") do
    [
      "[&_table]:bg-[#007F8C] [&_table]:text-white dark:[&_table]:bg-[#01B8CA] dark:[&_table]:text-black",
      "hover:[&_table_tbody_tr]:bg-[#016974] dark:hover:[&_table_tbody_tr]:bg-[#77D5E3]"
    ]
  end

  defp color_variant("hoverable", "secondary") do
    [
      "[&_table]:bg-[#266EF1] [&_table]:text-white dark:[&_table]:bg-[#6DAAFB] dark:[&_table]:text-black",
      "hover:[&_table_tbody_tr]:bg-[#175BCC] dark:hover:[&_table_tbody_tr]:bg-[#A9C9FF]"
    ]
  end

  defp color_variant("hoverable", "success") do
    [
      "[&_table]:bg-[#0E8345] [&_table]:text-white dark:[&_table]:bg-[#06C167] dark:[&_table]:text-black",
      "hover:[&_table_tbody_tr]:bg-[#06C167] dark:hover:[&_table_tbody_tr]:bg-[#7FD99A]"
    ]
  end

  defp color_variant("hoverable", "warning") do
    [
      "[&_table]:bg-[#CA8D01] [&_table]:text-white dark:[&_table]:bg-[#FDC034] dark:[&_table]:text-black",
      "hover:[&_table_tbody_tr]:bg-[#976A01] dark:hover:[&_table_tbody_tr]:bg-[#FDD067]"
    ]
  end

  defp color_variant("hoverable", "danger") do
    [
      "[&_table]:bg-[#DE1135] [&_table]:text-white dark:[&_table]:bg-[#FC7F79] dark:[&_table]:text-black",
      "hover:[&_table_tbody_tr]:bg-[#BB032A] dark:hover:[&_table_tbody_tr]:bg-[#FFB2AB]"
    ]
  end

  defp color_variant("hoverable", "info") do
    [
      "[&_table]:bg-[#0B84BA] [&_table]:text-white dark:[&_table]:bg-[#3EB7ED] dark:[&_table]:text-black",
      "hover:[&_table_tbody_tr]:bg-[#08638C] dark:hover:[&_table_tbody_tr]:bg-[#6EC9F2]"
    ]
  end

  defp color_variant("hoverable", "misc") do
    [
      "[&_table]:bg-[#8750C5] [&_table]:text-white dark:[&_table]:bg-[#BA83F9] dark:[&_table]:text-black",
      "hover:[&_table_tbody_tr]:bg-[#653C94] dark:hover:[&_table_tbody_tr]:bg-[#CBA2FA]"
    ]
  end

  defp color_variant("hoverable", "dawn") do
    [
      "[&_table]:bg-[#A86438] [&_table]:text-white dark:[&_table]:bg-[#DB976B] dark:[&_table]:text-black",
      "hover:[&_table_tbody_tr]:bg-[#7E4B2A] dark:hover:[&_table_tbody_tr]:bg-[#E4B190]"
    ]
  end

  defp color_variant("hoverable", "silver") do
    [
      "[&_table]:bg-[#868686] [&_table]:text-white dark:[&_table]:bg-[#A6A6A6] dark:[&_table]:text-black",
      "hover:[&_table_tbody_tr]:bg-[#727272] dark:hover:[&_table_tbody_tr]:bg-[#BBBBBB]"
    ]
  end

  defp color_variant("hoverable", "dark") do
    [
      "[&_table]:bg-[#282828] [&_table]:text-white hover:[&_table_tbody_tr]:bg-black"
    ]
  end

  defp color_variant("stripped", "white") do
    [
      "[&_table]:bg-white odd:[&_table_tbody_tr]:bg-[#DADADA] text-[#3E3E3E]"
    ]
  end

  defp color_variant("stripped", "natural") do
    [
      "[&_table]:bg-[#4B4B4B] [&_table]:text-white dark:[&_table]:bg-[#DDDDDD] dark:[&_table]:text-black",
      "odd:[&_table_tbody_tr]:bg-[#282828] dark:odd:[&_table_tbody_tr]:bg-[#E8E8E8]"
    ]
  end

  defp color_variant("stripped", "primary") do
    [
      "[&_table]:bg-[#007F8C] [&_table]:text-white dark:[&_table]:bg-[#01B8CA] dark:[&_table]:text-black",
      "odd:[&_table_tbody_tr]:bg-[#016974] dark:odd:[&_table_tbody_tr]:bg-[#77D5E3]"
    ]
  end

  defp color_variant("stripped", "secondary") do
    [
      "[&_table]:bg-[#266EF1] [&_table]:text-white dark:[&_table]:bg-[#6DAAFB] dark:[&_table]:text-black",
      "odd:[&_table_tbody_tr]:bg-[#175BCC] dark:odd:[&_table_tbody_tr]:bg-[#A9C9FF]"
    ]
  end

  defp color_variant("stripped", "success") do
    [
      "[&_table]:bg-[#0E8345] [&_table]:text-white dark:[&_table]:bg-[#06C167] dark:[&_table]:text-black",
      "odd:[&_table_tbody_tr]:bg-[#06C167] dark:odd:[&_table_tbody_tr]:bg-[#7FD99A]"
    ]
  end

  defp color_variant("stripped", "warning") do
    [
      "[&_table]:bg-[#CA8D01] [&_table]:text-white dark:[&_table]:bg-[#FDC034] dark:[&_table]:text-black",
      "odd:[&_table_tbody_tr]:bg-[#976A01] dark:odd:[&_table_tbody_tr]:bg-[#FDD067]"
    ]
  end

  defp color_variant("stripped", "danger") do
    [
      "[&_table]:bg-[#DE1135] [&_table]:text-white dark:[&_table]:bg-[#FC7F79] dark:[&_table]:text-black",
      "odd:[&_table_tbody_tr]:bg-[#BB032A] dark:odd:[&_table_tbody_tr]:bg-[#FFB2AB]"
    ]
  end

  defp color_variant("stripped", "info") do
    [
      "[&_table]:bg-[#0B84BA] [&_table]:text-white dark:[&_table]:bg-[#3EB7ED] dark:[&_table]:text-black",
      "odd:[&_table_tbody_tr]:bg-[#08638C] dark:odd:[&_table_tbody_tr]:bg-[#6EC9F2]"
    ]
  end

  defp color_variant("stripped", "misc") do
    [
      "[&_table]:bg-[#8750C5] [&_table]:text-white dark:[&_table]:bg-[#BA83F9] dark:[&_table]:text-black",
      "odd:[&_table_tbody_tr]:bg-[#653C94] dark:odd:[&_table_tbody_tr]:bg-[#CBA2FA]"
    ]
  end

  defp color_variant("stripped", "dawn") do
    [
      "[&_table]:bg-[#A86438] [&_table]:text-white dark:[&_table]:bg-[#DB976B] dark:[&_table]:text-black",
      "odd:[&_table_tbody_tr]:bg-[#7E4B2A] dark:odd:[&_table_tbody_tr]:bg-[#E4B190]"
    ]
  end

  defp color_variant("stripped", "silver") do
    [
      "[&_table]:bg-[#868686] [&_table]:text-white dark:[&_table]:bg-[#A6A6A6] dark:[&_table]:text-black",
      "odd:[&_table_tbody_tr]:bg-[#727272] dark:odd:[&_table_tbody_tr]:bg-[#BBBBBB]"
    ]
  end

  defp color_variant("stripped", "dark") do
    [
      "[&_table]:bg-[#282828] [&_table]:text-white odd:[&_table_tbody_tr]:bg-black"
    ]
  end

  defp color_variant("separated", "white") do
    "[&_table_tr]:bg-white [&_table]:text-black"
  end

  defp color_variant("separated", "natural") do
    "[&_table_tr]:bg-[#4B4B4B] [&_table]:text-white dark:[&_table_tr]:bg-[#DDDDDD] dark:[&_table]:text-black"
  end

  defp color_variant("separated", "primary") do
    "[&_table_tr]:bg-[#007F8C] [&_table]:text-white dark:[&_table_tr]:bg-[#01B8CA] dark:[&_table]:text-black"
  end

  defp color_variant("separated", "secondary") do
    "[&_table_tr]:bg-[#266EF1] [&_table]:text-white dark:[&_table_tr]:bg-[#6DAAFB] dark:[&_table]:text-black"
  end

  defp color_variant("separated", "success") do
    "[&_table_tr]:bg-[#0E8345] [&_table]:text-white dark:[&_table_tr]:bg-[#06C167] dark:[&_table]:text-black"
  end

  defp color_variant("separated", "warning") do
    "[&_table_tr]:bg-[#CA8D01] [&_table]:text-white dark:[&_table_tr]:bg-[#FDC034] dark:[&_table]:text-black"
  end

  defp color_variant("separated", "danger") do
    "[&_table_tr]:bg-[#DE1135] [&_table]:text-white dark:[&_table_tr]:bg-[#FC7F79] dark:[&_table]:text-black"
  end

  defp color_variant("separated", "info") do
    "[&_table_tr]:bg-[#0B84BA] [&_table]:text-white dark:[&_table_tr]:bg-[#3EB7ED] dark:[&_table]:text-black"
  end

  defp color_variant("separated", "misc") do
    "[&_table_tr]:bg-[#8750C5] [&_table]:text-white dark:[&_table_tr]:bg-[#BA83F9] dark:[&_table]:text-black"
  end

  defp color_variant("separated", "dawn") do
    "[&_table_tr]:bg-[#A86438] [&_table]:text-white dark:[&_table_tr]:bg-[#DB976B] dark:[&_table]:text-black"
  end

  defp color_variant("separated", "silver") do
    "[&_table_tr]:bg-[#868686] [&_table]:text-white dark:[&_table_tr]:bg-[#A6A6A6] dark:[&_table]:text-black"
  end

  defp color_variant("separated", "dark") do
    "[&_table_tr]:bg-[#282828] [&_table]:text-white"
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
