defmodule FoundationWeb.TaskDashboardLive do
  use FoundationWeb, :live_view
  
  # Import all the widgets we'll use
  alias FoundationWeb.WidgetData
  import FoundationWeb.Components.Widgets.Card
  import FoundationWeb.Components.Widgets.Stat
  import FoundationWeb.Components.Widgets.Table
  import FoundationWeb.Components.Widgets.Heading
  import FoundationWeb.Components.Widgets.Button
  import FoundationWeb.Components.Widgets.Badge
  import FoundationWeb.Components.Widgets.Modal
  import FoundationWeb.Components.Widgets.TaskForm
  import FoundationWeb.Components.LayoutWidgets
  alias Phoenix.LiveView.JS
  
  def mount(_params, _session, socket) do
    # Switch to Ash data
    data_source = :ash  # Changed from :static
    
    # Subscribe to updates if connected
    if connected?(socket) && data_source == :ash do
      WidgetData.subscribe_to_updates([:task_updates])
    end
    
    socket = 
      socket
      |> assign(:data_source, data_source)
      |> assign(:debug_mode, true)  # Shows data source on widgets
      |> assign(:show_task_modal, false)  # Modal visibility state
      |> load_task_data(data_source)  # Changed this line
      
    {:ok, socket}
  end
  
  # Add static data for development
  defp assign_static_data(socket) do
    # Sample tasks
    tasks = [
      %{
        id: 1,
        title: "Complete project documentation",
        description: "Write comprehensive docs for the new feature",
        status: :completed,
        priority: :high,
        inserted_at: "2024-07-31 10:00:00"
      },
      %{
        id: 2,
        title: "Review pull requests",
        description: "Check team's PRs and provide feedback",
        status: :in_progress,
        priority: :medium,
        inserted_at: "2024-07-31 11:30:00"
      },
      %{
        id: 3,
        title: "Fix login bug",
        description: "Users report intermittent login failures",
        status: :pending,
        priority: :urgent,
        inserted_at: "2024-07-31 09:15:00"
      },
      %{
        id: 4,
        title: "Update dependencies",
        description: "Monthly security updates",
        status: :pending,
        priority: :low,
        inserted_at: "2024-07-30 14:20:00"
      }
    ]
    
    # Calculate statistics
    total_tasks = length(tasks)
    completed_tasks = Enum.count(tasks, & &1.status == :completed)
    urgent_tasks = Enum.count(tasks, & &1.priority == :urgent)
    in_progress = Enum.count(tasks, & &1.status == :in_progress)
    
    socket
    |> assign(:tasks, tasks)
    |> assign(:total_tasks, total_tasks)
    |> assign(:completed_tasks, completed_tasks)
    |> assign(:urgent_tasks, urgent_tasks)
    |> assign(:in_progress_tasks, in_progress)
  end
  
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-base-100">
      <.grid_layout>
        <!-- Page Header -->
        <.heading_widget variant="page" span={12}>
          Task Manager Dashboard
          <:description>
            Monitor and manage your tasks efficiently
          </:description>
        </.heading_widget>
        
        <!-- Statistics Row - 4 cards -->
        <.card_widget span={3}>
          <:header>Total Tasks</:header>
          <.stat_widget 
            value={@total_tasks}
            label="All tasks"
            size="lg"
            data_source={@data_source}
            debug_mode={@debug_mode}
          />
        </.card_widget>
        
        <.card_widget span={3}>
          <:header>In Progress</:header>
          <.stat_widget 
            value={@in_progress_tasks}
            label="Currently active"
            size="lg"
            data_source={@data_source}
            debug_mode={@debug_mode}
          />
        </.card_widget>
        
        <.card_widget span={3}>
          <:header>Completed</:header>
          <.stat_widget 
            value={@completed_tasks}
            label="Finished tasks"
            size="lg"
            data_source={@data_source}
            debug_mode={@debug_mode}
          />
        </.card_widget>
        
        <.card_widget span={3}>
          <:header>Urgent</:header>
          <.stat_widget 
            value={@urgent_tasks}
            label="Need attention"
            size="lg"
            data_source={@data_source}
            debug_mode={@debug_mode}
          />
        </.card_widget>
        
        <!-- Action buttons -->
        <div class="col-span-12 flex justify-between items-center mt-6 mb-4">
          <h2 class="text-xl font-semibold">Task List</h2>
          <.button_widget variant="primary" phx-click="open_task_modal">
            <.icon name="hero-plus" class="w-4 h-4 mr-2" />
            Add Task
          </.button_widget>
        </div>
        
        <!-- Task Table -->
        <.card_widget span={12}>
          <.table_widget id="tasks-table" rows={@tasks}>
            <:col label="Title" :let={row}>
              <div>
                <div class="font-medium">{row.title}</div>
                <div class="text-sm text-base-content/60">{row.description}</div>
              </div>
            </:col>
            
            <:col label="Status" :let={row}>
              <.badge_widget variant={status_color(row.status)}>
                {format_status(row.status)}
              </.badge_widget>
            </:col>
            
            <:col label="Priority" :let={row}>
              <.badge_widget variant={priority_color(row.priority)}>
                {format_priority(row.priority)}
              </.badge_widget>
            </:col>
            
            <:col label="Created" :let={row}>
              {row.inserted_at}
            </:col>
          </.table_widget>
        </.card_widget>
        
        <!-- Task Creation Modal -->
        <.modal_widget 
          :if={@show_task_modal} 
          id="task-modal"
          title="Create New Task"
        >
          <.task_form_widget 
            form={@task_form || create_task_form()}
            data_source={@data_source}
            debug_mode={@debug_mode}
          />
        </.modal_widget>
      </.grid_layout>
    </div>
    """
  end
  
  # Helper functions for formatting
  defp status_color(:completed), do: "success"
  defp status_color(:in_progress), do: "warning"
  defp status_color(:pending), do: "neutral"
  defp status_color(_), do: "neutral"
  
  defp priority_color(:urgent), do: "error"
  defp priority_color(:high), do: "warning"
  defp priority_color(:medium), do: "info"
  defp priority_color(:low), do: "neutral"
  defp priority_color(_), do: "neutral"
  
  defp format_status(status) do
    status
    |> to_string()
    |> String.replace("_", " ")
    |> String.capitalize()
  end
  
  defp format_priority(priority) do
    priority
    |> to_string()
    |> String.capitalize()
  end
  
  # Create a simple form for static data
  defp create_task_form() do
    Foundation.TaskManager.Task
    |> AshPhoenix.Form.for_create(:create, as: "form")
  end
  
  defp load_task_data(socket, :static) do
    assign_static_data(socket)
  end
  
  defp load_task_data(socket, :ash) do
    WidgetData.assign_task_data(socket, :ash)
  end
  
  # Event Handlers
  
  # Open the modal
  def handle_event("open_task_modal", _params, socket) do
    form = create_task_form()
    
    socket = 
      socket
      |> assign(:show_task_modal, true)
      |> assign(:task_form, form)
    
    {:noreply, socket}
  end
  
  # Close the modal
  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, :show_task_modal, false)}
  end
  
  # Handle form validation (for now, just keep the form data)
  def handle_event("validate_task", %{"form" => params}, socket) do
    form = 
      socket.assigns.task_form
      |> AshPhoenix.Form.validate(params)
    
    {:noreply, assign(socket, :task_form, form)}
  end
  
  # Handle form submission
  def handle_event("save_task", %{"form" => params}, socket) do
    form = 
      socket.assigns.task_form
      |> AshPhoenix.Form.validate(params)
    
    case AshPhoenix.Form.submit(form) do
      {:ok, _task} ->
        # Broadcast the update to all connected clients
        WidgetData.broadcast_task_update(:created)
        
        socket = 
          socket
          |> assign(:show_task_modal, false)
          |> put_flash(:info, "Task created successfully!")
        
        {:noreply, socket}
        
      {:error, form} ->
        {:noreply, assign(socket, :task_form, form)}
    end
  end
  
  # Handle real-time updates
  def handle_info({:widget_data_updated, :task_updates, data}, socket) do
    socket = 
      socket
      |> assign(:tasks, data.tasks)
      |> assign(:total_tasks, data.total_tasks)
      |> assign(:completed_tasks, data.completed_tasks)
      |> assign(:in_progress_tasks, data.in_progress_tasks)
      |> assign(:urgent_tasks, data.urgent_tasks)
    
    # Show a notification for actions from other users
    socket = 
      case data.action do
        :created -> put_flash(socket, :info, "New task added")
        :updated -> put_flash(socket, :info, "Task updated")
        :deleted -> put_flash(socket, :info, "Task deleted")
        _ -> socket
      end
    
    {:noreply, socket}
  end
end