defmodule FoundationWeb.Components.LayoutWidgets do
  use Phoenix.Component

  @doc "Full-screen grid layout"
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def grid_layout(assigns) do
    ~H"""
    <div class={["w-full @container", @class]}>
      <div class="grid grid-cols-12 gap-6 md:gap-8 lg:gap-10">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  @doc "Dashboard layout with sidebar"
  attr :class, :string, default: ""
  slot :sidebar, required: true
  slot :inner_block, required: true

  def dashboard_layout(assigns) do
    ~H"""
    <div class={["layout-full grid grid-cols-[280px_1fr] @container", @class]}>
      <aside class="bg-base-200 p-6 min-h-screen">
        {render_slot(@sidebar)}
      </aside>
      <main class="p-6 overflow-auto">
        {render_slot(@inner_block)}
      </main>
    </div>
    """
  end

  @doc "Centered content layout"
  attr :max_width, :string, default: "max-w-4xl"
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def centered_layout(assigns) do
    ~H"""
    <div class={["layout-full flex items-center justify-center p-6", @class]}>
      <div class={[@max_width, "w-full"]}>
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end
end