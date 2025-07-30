defmodule FoundationWeb.Components.Widgets.Card do
  use Phoenix.Component
  
  attr :span, :integer, default: 4
  attr :padding, :integer, default: 6
  attr :class, :string, default: ""
  slot :header
  slot :inner_block, required: true
  slot :actions

  def card_widget(assigns) do
    ~H"""
    <div class={[
      "span-#{@span}",
      "card",
      "bg-base-100",
      "shadow-xl",
      @class
    ]}>
      <div class="card-body p-#{@padding}">
        <h2 :if={@header != []} class="card-title mb-4">
          {render_slot(@header)}
        </h2>
        <div class="flex-grow">
          {render_slot(@inner_block)}
        </div>
        <div :if={@actions != []} class="card-actions justify-end mt-6">
          {render_slot(@actions)}
        </div>
      </div>
    </div>
    """
  end
end