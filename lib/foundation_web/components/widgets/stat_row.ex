defmodule FoundationWeb.Components.Widgets.StatRow do
  use Phoenix.Component
  
  attr :label, :string, required: true
  attr :value, :string, required: true
  attr :size, :string, default: "md" # "sm", "md", "lg"
  attr :class, :string, default: ""
  
  def stat_row_widget(assigns) do
    ~H"""
    <div class={[
      "flex justify-between items-center",
      spacing_class(@size),
      @class
    ]}>
      <span class={label_class(@size)}>
        {@label}
      </span>
      <span class={value_class(@size)}>
        {@value}
      </span>
    </div>
    """
  end
  
  defp label_class("sm"), do: "text-xs text-base-content/70"
  defp label_class("md"), do: "text-sm text-base-content/70"
  defp label_class("lg"), do: "text-base text-base-content/70"
  defp label_class(_), do: "text-sm text-base-content/70"
  
  defp value_class("sm"), do: "text-sm font-semibold"
  defp value_class("md"), do: "text-base font-bold"
  defp value_class("lg"), do: "text-lg font-bold"
  defp value_class(_), do: "text-base font-bold"
  
  defp spacing_class("sm"), do: "py-1"
  defp spacing_class("md"), do: "py-2"
  defp spacing_class("lg"), do: "py-3"
  defp spacing_class(_), do: "py-2"
end