defmodule FoundationWeb.Components.Widgets.Modal do
  use Phoenix.Component
  
  attr :id, :string, required: true
  attr :title, :string, required: true
  attr :max_width, :string, default: "max-w-2xl"
  attr :padding, :integer, default: 6
  attr :class, :string, default: ""
  slot :inner_block, required: true
  slot :actions

  def modal_widget(assigns) do
    ~H"""
    <dialog id={@id} class={["modal", @class]}>
      <div class={["modal-box", @max_width, "p-#{@padding}"]}>
        <h3 class="font-bold text-lg mb-4">{@title}</h3>
        <div class="py-4">
          {render_slot(@inner_block)}
        </div>
        <div :if={@actions != []} class="modal-action mt-6">
          {render_slot(@actions)}
        </div>
      </div>
      <form method="dialog" class="modal-backdrop">
        <button>close</button>
      </form>
    </dialog>
    """
  end
end