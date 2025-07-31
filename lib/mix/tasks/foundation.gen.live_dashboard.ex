defmodule Mix.Tasks.Foundation.Gen.LiveDashboard do
  @moduledoc """
  Generates a new LiveView with widget integration ready for Ash.
  
  ## Usage
  
      mix foundation.gen.live_dashboard MyDashboard
      
  This creates a LiveView at lib/foundation_web/live/my_dashboard_live.ex
  """
  
  use Mix.Task
  
  @shortdoc "Generates a widget-based LiveView dashboard"
  
  def run([name]) do
    Mix.Task.run("app.start")
    
    # Convert name to module and file names
    module_name = Macro.camelize(name)
    file_name = Macro.underscore(name)
    
    # Template for new LiveView
    content = """
    defmodule FoundationWeb.#{module_name}Live do
      use FoundationWeb, :live_view
      
      alias FoundationWeb.WidgetData
      
      import FoundationWeb.Components.Widgets.Card
      import FoundationWeb.Components.Widgets.Stat
      import FoundationWeb.Components.Widgets.Heading
      import FoundationWeb.Components.LayoutWidgets
      
      def mount(_params, _session, socket) do
        # TODO: Change to :ash when ready to connect to real data
        data_source = :static
        
        socket = 
          socket
          |> assign(:data_source, data_source)
          |> assign(:debug_mode, true)
          |> assign_initial_data(data_source)
          
        if data_source == :ash do
          WidgetData.subscribe_to_updates([:#{file_name}])
        end
          
        {:ok, socket}
      end
      
      def render(assigns) do
        ~H\"\"\"
        <.grid_layout>
          <.heading_widget variant="page">
            #{String.replace(module_name, ~r/([A-Z])/, " \\1") |> String.trim()}
            <:description>
              TODO: Add description for your dashboard
            </:description>
          </.heading_widget>
          
          <.card_widget span={3}>
            <:header>Metric 1</:header>
            <.stat_widget 
              value="TODO"
              change="+0%"
              change_label="TODO"
              trend="up"
              data_source={@data_source}
              debug_mode={@debug_mode}
            />
          </.card_widget>
          
          <.card_widget span={3}>
            <:header>Metric 2</:header>
            <.stat_widget 
              value="TODO"
              change="+0%"
              change_label="TODO"
              trend="up"
              data_source={@data_source}
              debug_mode={@debug_mode}
            />
          </.card_widget>
        </.grid_layout>
        \"\"\"
      end
      
      defp assign_initial_data(socket, :static) do
        socket
        # TODO: Add your static data here
      end
      
      defp assign_initial_data(socket, :ash) do
        # TODO: Use WidgetData.assign_widget_data when ready
        socket
      end
      
      def handle_info({:widget_data_updated, :#{file_name}, data}, socket) do
        # TODO: Handle real-time updates
        {:noreply, socket}
      end
    end
    """
    
    # Write file
    path = "lib/foundation_web/live/#{file_name}_live.ex"
    File.write!(path, content)
    
    Mix.shell().info("Created #{path}")
    Mix.shell().info("\nNext steps:")
    Mix.shell().info("1. Add route to router.ex: live \"/#{String.replace(file_name, "_", "-")}\", #{module_name}Live")
    Mix.shell().info("2. Update static data in assign_initial_data")
    Mix.shell().info("3. Change data_source to :ash when ready")
  end
  
  def run(_) do
    Mix.shell().error("Usage: mix foundation.gen.live_dashboard DashboardName")
  end
end