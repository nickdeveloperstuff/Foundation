defmodule FoundationWeb.Components.Widgets.Navigation do
  use Phoenix.Component
  
  attr :brand, :string, required: true
  attr :class, :string, default: ""
  slot :nav_item, required: true do
    attr :path, :string
    attr :active, :boolean
  end
  slot :actions

  def navigation_widget(assigns) do
    ~H"""
    <nav class={["flex flex-col h-full", @class]}>
      <div class="mb-8">
        <h1 class="text-xl font-bold">{@brand}</h1>
      </div>
      
      <ul class="menu menu-vertical gap-1 flex-1">
        <li :for={item <- @nav_item}>
          <.link 
            navigate={item[:path]} 
            class={[
              "rounded-lg hover:bg-base-300",
              item[:active] && "bg-primary text-primary-content hover:bg-primary"
            ]}
          >
            {render_slot(item)}
          </.link>
        </li>
      </ul>
      
      <div :if={@actions != []} class="mt-auto pt-4 border-t border-base-300">
        {render_slot(@actions)}
      </div>
    </nav>
    """
  end
end