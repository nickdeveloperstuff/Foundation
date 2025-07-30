defmodule FoundationWeb.Components.Widgets.Placeholder do
  use Phoenix.Component
  
  attr :height, :string, default: "md" # "sm", "md", "lg", "xl"
  attr :span, :integer, default: 12
  attr :icon, :string, default: nil
  attr :class, :string, default: ""
  slot :inner_block
  
  def placeholder_widget(assigns) do
    ~H"""
    <div class={[
      "span-#{@span}",
      height_class(@height),
      "bg-base-200 rounded-lg flex flex-col items-center justify-center",
      @class
    ]}>
      <span :if={@icon} class={[@icon, "size-8 text-base-content/30 mb-2"]} />
      <div :if={@inner_block != []} class="text-base-content/50">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end
  
  defp height_class("sm"), do: "h-32"
  defp height_class("md"), do: "h-48"
  defp height_class("lg"), do: "h-64"
  defp height_class("xl"), do: "h-96"
  defp height_class(_), do: "h-48"
end