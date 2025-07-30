defmodule FoundationWeb.Components.Widgets.Stat do
  use Phoenix.Component
  
  attr :value, :string, required: true
  attr :label, :string, default: nil
  attr :change, :string, default: nil
  attr :change_label, :string, default: nil
  attr :trend, :string, default: nil # "up", "down", "neutral"
  attr :span, :integer, default: nil
  attr :size, :string, default: "md" # "sm", "md", "lg"
  attr :class, :string, default: ""
  
  def stat_widget(assigns) do
    ~H"""
    <div class={[
      @span && "span-#{@span}",
      @class
    ]}>
      <div :if={@label} class={label_class(@size)}>
        {@label}
      </div>
      <div class={value_class(@size)}>
        {@value}
      </div>
      <div :if={@change} class={[
        change_class(@size),
        trend_color(@trend)
      ]}>
        {@change}
        <span :if={@change_label} class="ml-1">
          {@change_label}
        </span>
      </div>
    </div>
    """
  end
  
  defp value_class("sm"), do: "text-2xl font-bold"
  defp value_class("md"), do: "text-3xl font-bold"
  defp value_class("lg"), do: "text-4xl font-bold"
  defp value_class(_), do: "text-3xl font-bold"
  
  defp label_class("sm"), do: "text-sm text-base-content/70 mb-1"
  defp label_class("md"), do: "text-base text-base-content/70 mb-2"
  defp label_class("lg"), do: "text-lg text-base-content/70 mb-2"
  defp label_class(_), do: "text-base text-base-content/70 mb-2"
  
  defp change_class("sm"), do: "text-xs mt-1"
  defp change_class("md"), do: "text-sm mt-2"
  defp change_class("lg"), do: "text-base mt-2"
  defp change_class(_), do: "text-sm mt-2"
  
  defp trend_color("up"), do: "text-success"
  defp trend_color("down"), do: "text-error"
  defp trend_color("neutral"), do: "text-base-content/70"
  defp trend_color(_), do: "text-base-content/70"
end