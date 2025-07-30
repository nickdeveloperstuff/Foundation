defmodule FoundationWeb.Components.Widgets.Input do
  use Phoenix.Component
  
  attr :span, :integer, default: 12
  attr :label, :string, required: true
  attr :name, :string, required: true
  attr :type, :string, default: "text"
  attr :error, :string, default: nil
  attr :class, :string, default: ""
  attr :rest, :global

  def input_widget(assigns) do
    ~H"""
    <div class={["span-#{@span}", "form-control"]}>
      <label class="label pb-2">
        <span class="label-text">{@label}</span>
      </label>
      <input 
        type={@type}
        name={@name}
        class={[
          "input",
          "input-bordered",
          "w-full",
          @error && "input-error",
          @class
        ]}
        {@rest}
      />
      <label :if={@error} class="label pt-2">
        <span class="label-text-alt text-error">{@error}</span>
      </label>
    </div>
    """
  end
end