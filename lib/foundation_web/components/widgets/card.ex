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
      span_class(@span),
      "card",
      "bg-base-100",
      "shadow-xl",
      "h-fit",
      @class
    ]}>
      <div class={[
        "card-body",
        padding_class(@padding)
      ]}>
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
  
  defp padding_class(1), do: "p-1"
  defp padding_class(2), do: "p-2"
  defp padding_class(3), do: "p-3"
  defp padding_class(4), do: "p-4"
  defp padding_class(5), do: "p-5"
  defp padding_class(6), do: "p-6"
  defp padding_class(8), do: "p-8"
  defp padding_class(10), do: "p-10"
  defp padding_class(12), do: "p-12"
  defp padding_class(_), do: "p-6"
  
  defp span_class(1), do: "span-1"
  defp span_class(2), do: "span-2"
  defp span_class(3), do: "span-3"
  defp span_class(4), do: "span-4"
  defp span_class(5), do: "span-5"
  defp span_class(6), do: "span-6"
  defp span_class(7), do: "span-7"
  defp span_class(8), do: "span-8"
  defp span_class(9), do: "span-9"
  defp span_class(10), do: "span-10"
  defp span_class(11), do: "span-11"
  defp span_class(12), do: "span-12"
  defp span_class(_), do: "span-4"
end