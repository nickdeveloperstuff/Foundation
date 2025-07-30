defmodule FoundationWeb.Storybook.Widgets.ButtonDoc do
  use Phoenix.LiveView

  def render(assigns) do
    ~H"""
    <div class="p-8">
      <h1 class="text-2xl font-bold mb-8">Button Widget</h1>
      
      <section class="mb-12">
        <h2 class="text-xl font-semibold mb-4">Sizes</h2>
        <div class="flex gap-4">
          <.button_widget size="sm">Small</.button_widget>
          <.button_widget size="md">Medium</.button_widget>
          <.button_widget size="lg">Large</.button_widget>
        </div>
      </section>

      <section class="mb-12">
        <h2 class="text-xl font-semibold mb-4">Grid Spans</h2>
        <div class="grid grid-cols-12 gap-4">
          <.button_widget span={3}>Span 3</.button_widget>
          <.button_widget span={6}>Span 6</.button_widget>
          <.button_widget span={3}>Span 3</.button_widget>
        </div>
      </section>
    </div>
    """
  end
end