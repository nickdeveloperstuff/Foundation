defmodule FoundationWeb.Components.Widgets.Table do
  use Phoenix.Component
  
  attr :span, :integer, default: 12
  attr :id, :string, required: true
  attr :rows, :list, required: true
  attr :class, :string, default: ""
  slot :col, required: true do
    attr :label, :string
    attr :width, :string
  end

  def table_widget(assigns) do
    ~H"""
    <div class={["span-#{@span}", "overflow-x-auto", @class]}>
      <table class="table w-full">
        <thead>
          <tr>
            <th :for={col <- @col} class={[
              "px-6 py-4",
              col[:width]
            ]}>
              {col[:label]}
            </th>
          </tr>
        </thead>
        <tbody>
          <tr :for={row <- @rows}>
            <td :for={col <- @col} class="px-6 py-4">
              {render_slot(col, row)}
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end
end