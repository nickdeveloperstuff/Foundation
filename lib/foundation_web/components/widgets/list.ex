defmodule FoundationWeb.Components.Widgets.List do
  use Phoenix.Component
  
  attr :span, :integer, default: 12
  attr :spacing, :integer, default: 3
  attr :direction, :string, default: "vertical"
  attr :class, :string, default: ""
  slot :item, required: true

  def list_widget(assigns) do
    ~H"""
    <ul class={[
      "span-#{@span}",
      @direction == "horizontal" && "flex flex-row",
      @direction == "vertical" && "flex flex-col",
      "gap-#{@spacing}",
      @class
    ]}>
      <li :for={item <- @item} class="list-item">
        {render_slot(item)}
      </li>
    </ul>
    """
  end
end