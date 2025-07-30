defmodule FoundationWeb.Components.Widgets do
  use Phoenix.Component

  @doc """
  Base widget wrapper that enforces layout rules
  """
  attr :span, :integer, default: 12, doc: "Grid columns to span (1-12)"
  attr :padding, :integer, default: 4, doc: "Padding using spacing scale"
  attr :gap, :integer, default: 4, doc: "Gap between child elements"
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def widget_wrapper(assigns) do
    ~H"""
    <div class={[
      "span-#{@span}",
      "p-#{@padding}",
      "gap-#{@gap}",
      @class
    ]}>
      {render_slot(@inner_block)}
    </div>
    """
  end
end