defmodule FoundationWeb.NewestTryLive do
  use FoundationWeb, :live_view
  
  alias FoundationWeb.WidgetData
  
  # Import all approved widgets
  import FoundationWeb.Components.Widgets.Card
  import FoundationWeb.Components.Widgets.Stat
  import FoundationWeb.Components.Widgets.Table
  import FoundationWeb.Components.Widgets.Heading
  import FoundationWeb.Components.Widgets.Button
  import FoundationWeb.Components.Widgets.Badge
  import FoundationWeb.Components.LayoutWidgets
  
  def mount(_params, _session, socket) do
    # Using static data for dumb UI as per requirements
    data_source = :static
    
    socket = 
      socket
      |> assign(:data_source, data_source)
      |> assign(:debug_mode, true)
      |> assign_static_data()
      
    {:ok, socket}
  end
  
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-base-100 p-6 md:p-8 lg:p-10">
      <.grid_layout>
        <!-- Page Header -->
        <.heading_widget variant="page" span={12}>
          Dashboard Overview
          <:description>
            Monitor your key metrics and recent activities
          </:description>
        </.heading_widget>
      
      <!-- KPI Row - 4 metrics across -->
      <.card_widget span={3}>
        <:header>Revenue</:header>
        <.stat_widget 
          value={"$#{@revenue}"}
          change="+12.5%"
          change_label="vs last month"
          trend="up"
          data_source={@data_source}
          debug_mode={@debug_mode}
        />
      </.card_widget>
      
      <.card_widget span={3}>
        <:header>Active Users</:header>
        <.stat_widget 
          value={@user_count}
          change="+8.2%"
          change_label="vs last month"
          trend="up"
          data_source={@data_source}
          debug_mode={@debug_mode}
        />
      </.card_widget>
      
      <.card_widget span={3}>
        <:header>Total Orders</:header>
        <.stat_widget 
          value={@order_count}
          change="-2.1%"
          change_label="vs last month"
          trend="down"
          data_source={@data_source}
          debug_mode={@debug_mode}
        />
      </.card_widget>
      
      <.card_widget span={3}>
        <:header>Conversion Rate</:header>
        <.stat_widget 
          value={"#{@conversion_rate}%"}
          change="+0.5%"
          change_label="vs last month"
          trend="up"
          data_source={@data_source}
          debug_mode={@debug_mode}
        />
      </.card_widget>
      
      <!-- Activity List -->
      <.card_widget span={8} class="h-full flex flex-col">
        <:header>Recent Activity</:header>
        <div class="flex-1 overflow-hidden">
          <div class="space-y-3 max-h-[400px] overflow-y-auto pr-2">
            <div :for={activity <- @activities} class="flex items-center justify-between p-4 bg-base-200 rounded-lg hover:bg-base-300 transition-colors">
              <div class="flex-1">
                <div class="font-medium text-base">{activity.user}</div>
                <div class="text-sm text-base-content/70 mt-1">{activity.action}</div>
              </div>
              <div class="flex items-center gap-3">
                <.badge_widget variant={status_variant(activity.status)}>
                  {activity.status}
                </.badge_widget>
                <span class="text-sm text-base-content/60 whitespace-nowrap">{activity.time}</span>
              </div>
            </div>
          </div>
        </div>
      </.card_widget>
      
      <.card_widget span={4} class="h-full flex flex-col">
        <:header>Quick Stats</:header>
        <div class="flex-1 space-y-4">
          <.stat_widget 
            label="Pending Orders"
            value="23"
            size="sm"
            data_source={@data_source}
            debug_mode={@debug_mode}
          />
          <.stat_widget 
            label="Support Tickets"
            value="7"
            size="sm"
            data_source={@data_source}
            debug_mode={@debug_mode}
          />
          <.stat_widget 
            label="Average Response Time"
            value="1.2h"
            size="sm"
            data_source={@data_source}
            debug_mode={@debug_mode}
          />
        </div>
        <:actions>
          <.button_widget variant="primary" size="sm">
            View All Stats
          </.button_widget>
        </:actions>
      </.card_widget>
      </.grid_layout>
    </div>
    """
  end
  
  # Static data for dumb UI
  defp assign_static_data(socket) do
    socket
    |> assign(:revenue, "125,340")
    |> assign(:user_count, "2,847")
    |> assign(:order_count, "439")
    |> assign(:conversion_rate, "3.2")
    |> assign(:activities, [
      %{
        user: "john.doe@example.com",
        action: "Created new order",
        status: "completed",
        time: "2 mins ago"
      },
      %{
        user: "jane.smith@example.com",
        action: "Updated profile",
        status: "completed",
        time: "5 mins ago"
      },
      %{
        user: "bob.wilson@example.com",
        action: "Payment processing",
        status: "pending",
        time: "8 mins ago"
      },
      %{
        user: "alice.brown@example.com",
        action: "Submitted support ticket",
        status: "in_progress",
        time: "12 mins ago"
      },
      %{
        user: "charlie.davis@example.com",
        action: "Account verification",
        status: "failed",
        time: "15 mins ago"
      },
      %{
        user: "emma.wilson@example.com",
        action: "Downloaded report",
        status: "completed",
        time: "18 mins ago"
      },
      %{
        user: "frank.jones@example.com",
        action: "Updated billing info",
        status: "completed",
        time: "22 mins ago"
      },
      %{
        user: "grace.lee@example.com",
        action: "Cancelled subscription",
        status: "completed",
        time: "25 mins ago"
      }
    ])
  end
  
  defp status_variant("completed"), do: "success"
  defp status_variant("pending"), do: "warning"
  defp status_variant("in_progress"), do: "info"
  defp status_variant("failed"), do: "error"
  defp status_variant(_), do: "neutral"
end