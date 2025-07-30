defmodule FoundationWeb.Components.Widgets.Badge do
  use Phoenix.Component
  
  attr :variant, :string, default: "neutral"
  attr :size, :string, default: "md"
  attr :outline, :boolean, default: false
  attr :class, :string, default: ""
  slot :inner_block, required: true
  
  def badge_widget(assigns) do
    ~H"""
    <span class={[
      "badge",
      variant_class(@variant, @outline),
      size_class(@size),
      @class
    ]}>
      {render_slot(@inner_block)}
    </span>
    """
  end
  
  defp variant_class("success", false), do: "badge-success"
  defp variant_class("success", true), do: "badge-success badge-outline"
  defp variant_class("error", false), do: "badge-error"
  defp variant_class("error", true), do: "badge-error badge-outline"
  defp variant_class("warning", false), do: "badge-warning"
  defp variant_class("warning", true), do: "badge-warning badge-outline"
  defp variant_class("info", false), do: "badge-info"
  defp variant_class("info", true), do: "badge-info badge-outline"
  defp variant_class("primary", false), do: "badge-primary"
  defp variant_class("primary", true), do: "badge-primary badge-outline"
  defp variant_class("secondary", false), do: "badge-secondary"
  defp variant_class("secondary", true), do: "badge-secondary badge-outline"
  defp variant_class("accent", false), do: "badge-accent"
  defp variant_class("accent", true), do: "badge-accent badge-outline"
  defp variant_class(_, false), do: "badge-neutral"
  defp variant_class(_, true), do: "badge-neutral badge-outline"
  
  defp size_class("xs"), do: "badge-xs"
  defp size_class("sm"), do: "badge-sm"
  defp size_class("md"), do: "badge-md"
  defp size_class("lg"), do: "badge-lg"
  defp size_class(_), do: "badge-md"
end