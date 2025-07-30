defmodule FoundationWeb.Components.Widgets.Form do
  use Phoenix.Component
  
  attr :for, :any, required: true
  attr :action, :string, default: "#"
  attr :columns, :integer, default: 1
  attr :gap, :integer, default: 6
  attr :class, :string, default: ""
  attr :rest, :global
  slot :inner_block, required: true

  def form_widget(assigns) do
    ~H"""
    <.form for={@for} action={@action} class={@class} {@rest}>
      <div class={[
        "grid",
        "grid-cols-#{@columns}",
        "gap-#{@gap}",
        "@container"
      ]}>
        {render_slot(@inner_block)}
      </div>
    </.form>
    """
  end
end