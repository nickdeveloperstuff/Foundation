defmodule FoundationWeb.Components.Widgets.Heading do
  use Phoenix.Component
  
  attr :variant, :string, default: "page"
  attr :span, :integer, default: 12
  attr :class, :string, default: ""
  slot :inner_block, required: true
  slot :description
  
  def heading_widget(assigns) do
    ~H"""
    <div class={[
      "span-#{@span}",
      spacing_class(@variant),
      @class
    ]}>
      <h1 class={heading_class(@variant)}>
        {render_slot(@inner_block)}
      </h1>
      <p :if={@description != []} class={description_class(@variant)}>
        {render_slot(@description)}
      </p>
    </div>
    """
  end
  
  defp heading_class("page"), do: "text-3xl font-bold"
  defp heading_class("section"), do: "text-2xl font-semibold"
  defp heading_class("subsection"), do: "text-xl font-medium"
  defp heading_class(_), do: "text-3xl font-bold"
  
  defp description_class("page"), do: "text-base-content/70 mt-2"
  defp description_class("section"), do: "text-base-content/60 mt-1 text-sm"
  defp description_class("subsection"), do: "text-base-content/50 mt-1 text-sm"
  defp description_class(_), do: "text-base-content/70 mt-2"
  
  defp spacing_class("page"), do: "mb-8"
  defp spacing_class("section"), do: "mb-6"
  defp spacing_class("subsection"), do: "mb-4"
  defp spacing_class(_), do: "mb-8"
end