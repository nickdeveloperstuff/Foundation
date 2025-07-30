defmodule FoundationWeb.Components.Widgets.Button do
  use Phoenix.Component
  
  attr :variant, :string, default: "primary"
  attr :size, :string, default: "md"
  attr :span, :integer, default: nil
  attr :align, :string, default: "start"
  attr :class, :string, default: ""
  attr :rest, :global
  slot :inner_block, required: true

  def button_widget(assigns) do
    ~H"""
    <div class={[
      @span && "span-#{@span}",
      "flex",
      align_class(@align)
    ]}>
      <button class={[
        "btn",
        "btn-#{@variant}",
        "btn-#{@size}",
        spacing_class(@size),
        @class
      ]} {@rest}>
        {render_slot(@inner_block)}
      </button>
    </div>
    """
  end

  defp align_class("start"), do: "justify-start"
  defp align_class("center"), do: "justify-center"
  defp align_class("end"), do: "justify-end"
  
  defp spacing_class("sm"), do: "px-3 py-2"
  defp spacing_class("md"), do: "px-4 py-3"
  defp spacing_class("lg"), do: "px-6 py-4"
end