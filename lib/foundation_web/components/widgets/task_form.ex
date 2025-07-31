defmodule FoundationWeb.Components.Widgets.TaskForm do
  use Phoenix.Component
  import FoundationWeb.Components.Widgets.Input
  import FoundationWeb.Components.Widgets.Button
  
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
            name="task[title]"
            label="Task Title"
            placeholder="Enter task title"
            value={@form["title"]}
          />
        </div>
        
        <!-- Description Field -->
        <div>
          <label class="label pb-2">
            <span class="label-text">Description</span>
          </label>
          <textarea
            name="task[description]"
            class="textarea textarea-bordered w-full"
            placeholder="Describe the task (optional)"
            rows="3"
          >{@form["description"]}</textarea>
        </div>
        
        <!-- Status Field -->
        <div>
          <label class="label pb-2">
            <span class="label-text">Status</span>
          </label>
          <select name="task[status]" class="select select-bordered w-full">
            <option value="pending" selected={@form["status"] == "pending"}>Pending</option>
            <option value="in_progress" selected={@form["status"] == "in_progress"}>In Progress</option>
            <option value="completed" selected={@form["status"] == "completed"}>Completed</option>
          </select>
        </div>
        
        <!-- Priority Field -->
        <div>
          <label class="label pb-2">
            <span class="label-text">Priority</span>
          </label>
          <select name="task[priority]" class="select select-bordered w-full">
            <option value="low" selected={@form["priority"] == "low"}>Low</option>
            <option value="medium" selected={@form["priority"] == "medium"}>Medium</option>
            <option value="high" selected={@form["priority"] == "high"}>High</option>
            <option value="urgent" selected={@form["priority"] == "urgent"}>Urgent</option>
          </select>
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