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
    <div class={["navbar bg-base-100 px-6", @class]}>
      <div class="navbar-start">
        <div class="text-xl font-bold">{@brand}</div>
      </div>
      <div class="navbar-center hidden lg:flex">
        <ul class="menu menu-horizontal gap-2">
          <li :for={item <- @nav_item}>
            <.link 
              navigate={item[:path]} 
              class={item[:active] && "active"}
            >
              {render_slot(item)}
            </.link>
          </li>
        </ul>
      </div>
      <div :if={@actions != []} class="navbar-end gap-4">
        {render_slot(@actions)}
      </div>
    </div>
    """
  end
end