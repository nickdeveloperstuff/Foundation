defmodule FoundationWeb.TesterDemoLive do
  use FoundationWeb, :live_view
  
  alias FoundationWeb.WidgetData
  
  import FoundationWeb.Components.Widgets.Button
  import FoundationWeb.Components.Widgets.Card
  import FoundationWeb.Components.Widgets.Input
  import FoundationWeb.Components.Widgets.Form
  import FoundationWeb.Components.Widgets.List
  import FoundationWeb.Components.Widgets.Table
  import FoundationWeb.Components.Widgets.Modal
  import FoundationWeb.Components.Widgets.Navigation
  import FoundationWeb.Components.Widgets.Heading
  import FoundationWeb.Components.Widgets.Stat
  import FoundationWeb.Components.Widgets.Badge
  import FoundationWeb.Components.Widgets.Placeholder
  import FoundationWeb.Components.Widgets.StatRow
  import FoundationWeb.Components.LayoutWidgets
  
  def mount(_params, _session, socket) do
    # Start with static data to ensure compatibility
    data_source = :ash  # Change this to :static to use hardcoded data
    
    # Subscribe to updates if using Ash
    if data_source == :ash do
      WidgetData.subscribe_to_updates([:kpi, :activities])
    end
    
    socket = 
      socket
      |> assign(:active_page, "dashboard")
      |> assign(:data_source, data_source)
      |> assign(:debug_mode, true)  # Set to false to hide debug info
    
    socket = 
      if data_source == :ash do
        socket
        |> WidgetData.assign_widget_data(:ash)
        |> assign(:user_stats, generate_user_stats())
      else
        socket
        |> assign(:kpi_data, generate_kpi_data())
        |> assign(:recent_activities, generate_activities())
        |> assign(:user_stats, generate_user_stats())
      end
      
    {:ok, socket}
  end
  
  def render(assigns) do
    ~H"""
    <.dashboard_layout>
      <:sidebar>
        <.navigation_widget brand="SaaSy Dashboard">
          <:nav_item path="/tester-demo" active={@active_page == "dashboard"}>
            Dashboard
          </:nav_item>
          <:nav_item path="/tester-demo/customers" active={@active_page == "customers"}>
            Customers
          </:nav_item>
          <:nav_item path="/tester-demo/analytics" active={@active_page == "analytics"}>
            Analytics
          </:nav_item>
          <:nav_item path="/tester-demo/reports" active={@active_page == "reports"}>
            Reports
          </:nav_item>
          <:nav_item path="/tester-demo/billing" active={@active_page == "billing"}>
            Billing
          </:nav_item>
          <:nav_item path="/tester-demo/settings" active={@active_page == "settings"}>
            Settings
          </:nav_item>
          <:actions>
            <.button_widget size="sm" variant="ghost">
              <.icon name="hero-user-circle" class="size-5" />
              Profile
            </.button_widget>
          </:actions>
        </.navigation_widget>
      </:sidebar>
      
      <.grid_layout>
        <.heading_widget variant="page">
          Dashboard Overview
          <:description>
            Welcome back! Here's what's happening with your business.
          </:description>
        </.heading_widget>
        
        <.card_widget span={3}>
          <:header>Total Revenue</:header>
          <.stat_widget 
            value={"$#{@kpi_data.revenue}"}
            change={"+#{@kpi_data.revenue_growth}%"}
            change_label="this month"
            trend="up"
            data_source={@data_source}
            debug_mode={@debug_mode}
          />
        </.card_widget>
        
        <.card_widget span={3}>
          <:header>Active Users</:header>
          <.stat_widget 
            value={to_string(@kpi_data.active_users)}
            change={"+#{@kpi_data.user_growth}%"}
            change_label="this month"
            trend="up"
            data_source={@data_source}
            debug_mode={@debug_mode}
          />
        </.card_widget>
        
        <.card_widget span={3}>
          <:header>New Signups</:header>
          <.stat_widget 
            value={to_string(@kpi_data.new_signups)}
            change={to_string(@kpi_data.signup_rate)}
            change_label="per day avg"
            trend="neutral"
            data_source={@data_source}
            debug_mode={@debug_mode}
          />
        </.card_widget>
        
        <.card_widget span={3}>
          <:header>Churn Rate</:header>
          <.stat_widget 
            value={"#{@kpi_data.churn_rate}%"}
            change={"-#{@kpi_data.churn_change}%"}
            change_label="vs last month"
            trend="down"
            data_source={@data_source}
            debug_mode={@debug_mode}
          />
        </.card_widget>
        
        <.card_widget span={8}>
          <:header>Recent Activity</:header>
          <.table_widget id="activity-table" rows={@recent_activities} span={12}>
            <:col label="Time" width="w-1/5" :let={row}>
              <%= row.time %>
            </:col>
            <:col label="User" width="w-1/4" :let={row}>
              <%= row.user %>
            </:col>
            <:col label="Action" width="w-2/5" :let={row}>
              <%= row.action %>
            </:col>
            <:col label="Status" width="w-1/5" :let={row}>
              <.badge_widget variant={badge_variant(row.status)}>
                <%= row.status %>
              </.badge_widget>
            </:col>
          </.table_widget>
        </.card_widget>
        
        <.card_widget span={4}>
          <:header>User Statistics</:header>
          <.list_widget spacing={2} direction="vertical">
            <:item>
              <.stat_row_widget label="Free Tier" value={to_string(@user_stats.free)} />
            </:item>
            <:item>
              <.stat_row_widget label="Basic Plan" value={to_string(@user_stats.basic)} />
            </:item>
            <:item>
              <.stat_row_widget label="Pro Plan" value={to_string(@user_stats.pro)} />
            </:item>
            <:item>
              <.stat_row_widget label="Enterprise" value={to_string(@user_stats.enterprise)} />
            </:item>
          </.list_widget>
          <:actions>
            <.button_widget size="sm" variant="primary">View Details</.button_widget>
          </:actions>
        </.card_widget>
        
        <.card_widget span={12}>
          <:header>Revenue Chart (Placeholder)</:header>
          <.placeholder_widget height="lg" icon="hero-chart-bar">
            Chart visualization would go here
          </.placeholder_widget>
        </.card_widget>
        
        <.card_widget span={6}>
          <:header>Quick Actions</:header>
          <.list_widget spacing={4} direction="vertical">
            <:item>
              <.button_widget variant="primary" class="w-full">
                <.icon name="hero-plus" class="size-4 mr-2" />
                Add Customer
              </.button_widget>
            </:item>
            <:item>
              <.button_widget variant="secondary" class="w-full">
                <.icon name="hero-document-text" class="size-4 mr-2" />
                Generate Report
              </.button_widget>
            </:item>
            <:item>
              <.button_widget variant="secondary" class="w-full">
                <.icon name="hero-credit-card" class="size-4 mr-2" />
                Process Payment
              </.button_widget>
            </:item>
            <:item>
              <.button_widget variant="secondary" class="w-full">
                <.icon name="hero-envelope" class="size-4 mr-2" />
                Send Newsletter
              </.button_widget>
            </:item>
          </.list_widget>
        </.card_widget>
        
        <.card_widget span={6}>
          <:header>System Health</:header>
          <.list_widget spacing={2} direction="vertical">
            <:item>
              <.stat_row_widget label="API Response Time" value="45ms" />
            </:item>
            <:item>
              <.stat_row_widget label="Database Load" value="67%" />
            </:item>
            <:item>
              <.stat_row_widget label="Server Uptime" value="99.9%" />
            </:item>
            <:item>
              <.stat_row_widget label="Error Rate" value="0.02%" />
            </:item>
          </.list_widget>
        </.card_widget>
      </.grid_layout>
    </.dashboard_layout>
    """
  end
  
  defp generate_kpi_data do
    %{
      revenue: "89,432",
      revenue_growth: 12,
      active_users: "1,892",
      user_growth: 8,
      new_signups: 156,
      signup_rate: 22,
      churn_rate: 2.3,
      churn_change: 0.5
    }
  end
  
  defp generate_activities do
    [
      %{id: 1, time: "2 mins ago", user: "john.doe@example.com", action: "Upgraded to Pro plan", status: "success"},
      %{id: 2, time: "15 mins ago", user: "sarah.smith@example.com", action: "Created new project", status: "success"},
      %{id: 3, time: "1 hour ago", user: "mike.jones@example.com", action: "Payment failed", status: "failed"},
      %{id: 4, time: "2 hours ago", user: "emma.wilson@example.com", action: "Exported data report", status: "success"},
      %{id: 5, time: "3 hours ago", user: "david.brown@example.com", action: "Subscription renewal", status: "pending"},
      %{id: 6, time: "5 hours ago", user: "lisa.taylor@example.com", action: "Added team member", status: "success"}
    ]
  end
  
  defp generate_user_stats do
    %{
      free: 892,
      basic: 543,
      pro: 387,
      enterprise: 70
    }
  end
  
  def handle_info({:widget_data_updated, :kpi, data}, socket) do
    {:noreply, assign(socket, :kpi_data, data)}
  end

  def handle_info({:widget_data_updated, :activities, data}, socket) do
    {:noreply, assign(socket, :recent_activities, data)}
  end
  
  defp badge_variant("success"), do: "success"
  defp badge_variant("pending"), do: "warning"
  defp badge_variant("failed"), do: "error"
  defp badge_variant(_), do: "neutral"
end