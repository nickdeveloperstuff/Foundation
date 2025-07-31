defmodule FoundationWeb.Components.Widgets.TaskForm do
  use Phoenix.Component
  import FoundationWeb.Components.Widgets.Input
  import FoundationWeb.Components.Widgets.Button
  import Phoenix.HTML.Form
  import FoundationWeb.CoreComponents, only: [translate_error: 1]
  
  attr :form, :any, required: true
  attr :data_source, :atom, default: :static
  attr :debug_mode, :boolean, default: false
  
  def task_form_widget(assigns) do
    ~H"""
    <div class="relative">
      <div :if={@debug_mode} class="absolute -top-8 right-0 text-xs px-2 py-1 bg-base-300 rounded">
        Form: {@data_source}
      </div>
      
      <.form for={@form} phx-submit="save_task" phx-change="validate_task" class="space-y-4">
        <!-- Title Field -->
        <div>
          <.input_widget
            name={input_name(@form, :title)}
            label="Task Title"
            placeholder="Enter task title"
          />
          <%= for error <- @form.errors[:title] || [] do %>
            <p class="text-error text-sm mt-1">{translate_error(error)}</p>
          <% end %>
        </div>
        
        <!-- Description Field -->
        <div>
          <label class="label pb-2">
            <span class="label-text">Description</span>
          </label>
          <textarea
            name={input_name(@form, :description)}
            class="textarea textarea-bordered w-full"
            placeholder="Describe the task (optional)"
            rows="3"
          >{input_value(@form, :description)}</textarea>
          <%= for error <- @form.errors[:description] || [] do %>
            <p class="text-error text-sm mt-1">{translate_error(error)}</p>
          <% end %>
        </div>
        
        <!-- Status Field -->
        <div>
          <label class="label pb-2">
            <span class="label-text">Status</span>
          </label>
          <select name={input_name(@form, :status)} class="select select-bordered w-full">
            <option value="pending" selected={input_value(@form, :status) == :pending}>Pending</option>
            <option value="in_progress" selected={input_value(@form, :status) == :in_progress}>In Progress</option>
            <option value="completed" selected={input_value(@form, :status) == :completed}>Completed</option>
          </select>
          <%= for error <- @form.errors[:status] || [] do %>
            <p class="text-error text-sm mt-1">{translate_error(error)}</p>
          <% end %>
        </div>
        
        <!-- Priority Field -->
        <div>
          <label class="label pb-2">
            <span class="label-text">Priority</span>
          </label>
          <select name={input_name(@form, :priority)} class="select select-bordered w-full">
            <option value="low" selected={input_value(@form, :priority) == :low}>Low</option>
            <option value="medium" selected={input_value(@form, :priority) == :medium}>Medium</option>
            <option value="high" selected={input_value(@form, :priority) == :high}>High</option>
            <option value="urgent" selected={input_value(@form, :priority) == :urgent}>Urgent</option>
          </select>
          <%= for error <- @form.errors[:priority] || [] do %>
            <p class="text-error text-sm mt-1">{translate_error(error)}</p>
          <% end %>
        </div>
        
        <!-- Form Actions -->
        <div class="flex justify-end gap-2 pt-4">
          <.button_widget type="button" variant="ghost" phx-click="close_modal">
            Cancel
          </.button_widget>
          <.button_widget type="submit" variant="primary">
            Create Task
          </.button_widget>
        </div>
      </.form>
    </div>
    """
  end
end