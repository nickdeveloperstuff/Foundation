defmodule FoundationWeb.TesterDemoLive do
  use FoundationWeb, :live_view
  
  import FoundationWeb.Components.Widgets.Button
  import FoundationWeb.Components.Widgets.Card
  import FoundationWeb.Components.Widgets.Input
  import FoundationWeb.Components.Widgets.Form
  import FoundationWeb.Components.Widgets.List
  import FoundationWeb.Components.Widgets.Table
  import FoundationWeb.Components.Widgets.Modal
  import FoundationWeb.Components.Widgets.Navigation
  import FoundationWeb.Components.LayoutWidgets
  
  def mount(_params, _session, socket) do
    socket = 
      socket
      |> assign(:active_page, "dashboard")
      |> assign(:kpi_data, generate_kpi_data())
      |> assign(:recent_activities, generate_activities())
      |> assign(:user_stats, generate_user_stats())
    
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
        <div class="span-12 mb-8">
          <h1 class="text-3xl font-bold">Dashboard Overview</h1>
          <p class="text-base-content/70 mt-2">Welcome back! Here's what's happening with your business.</p>
        </div>
        
        <.card_widget span={3}>
          <:header>Total Revenue</:header>
          <div class="text-3xl font-bold">$<%= @kpi_data.revenue %></div>
          <div class="text-sm text-success">+<%= @kpi_data.revenue_growth %>% this month</div>
        </.card_widget>
        
        <.card_widget span={3}>
          <:header>Active Users</:header>
          <div class="text-3xl font-bold"><%= @kpi_data.active_users %></div>
          <div class="text-sm text-success">+<%= @kpi_data.user_growth %>% this month</div>
        </.card_widget>
        
        <.card_widget span={3}>
          <:header>New Signups</:header>
          <div class="text-3xl font-bold"><%= @kpi_data.new_signups %></div>
          <div class="text-sm text-base-content/70"><%= @kpi_data.signup_rate %> per day avg</div>
        </.card_widget>
        
        <.card_widget span={3}>
          <:header>Churn Rate</:header>
          <div class="text-3xl font-bold"><%= @kpi_data.churn_rate %>%</div>
          <div class="text-sm text-error">-<%= @kpi_data.churn_change %>% vs last month</div>
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
              <span class={[
                "badge",
                row.status == "success" && "badge-success",
                row.status == "pending" && "badge-warning",
                row.status == "failed" && "badge-error"
              ]}>
                <%= row.status %>
              </span>
            </:col>
          </.table_widget>
        </.card_widget>
        
        <.card_widget span={4}>
          <:header>User Statistics</:header>
          <.list_widget spacing={4} direction="vertical">
            <:item>
              <div class="flex justify-between items-center">
                <span class="text-sm">Free Tier</span>
                <span class="font-bold"><%= @user_stats.free %></span>
              </div>
            </:item>
            <:item>
              <div class="flex justify-between items-center">
                <span class="text-sm">Basic Plan</span>
                <span class="font-bold"><%= @user_stats.basic %></span>
              </div>
            </:item>
            <:item>
              <div class="flex justify-between items-center">
                <span class="text-sm">Pro Plan</span>
                <span class="font-bold"><%= @user_stats.pro %></span>
              </div>
            </:item>
            <:item>
              <div class="flex justify-between items-center">
                <span class="text-sm">Enterprise</span>
                <span class="font-bold"><%= @user_stats.enterprise %></span>
              </div>
            </:item>
          </.list_widget>
          <:actions>
            <.button_widget size="sm" variant="primary">View Details</.button_widget>
          </:actions>
        </.card_widget>
        
        <.card_widget span={12}>
          <:header>Revenue Chart (Placeholder)</:header>
          <div class="h-64 bg-base-200 rounded-lg flex items-center justify-center">
            <p class="text-base-content/50">Chart visualization would go here</p>
          </div>
        </.card_widget>
        
        <.card_widget span={6}>
          <:header>Quick Actions</:header>
          <div class="grid grid-cols-2 gap-4">
            <.button_widget variant="primary" class="w-full">
              <.icon name="hero-plus" class="size-4 mr-2" />
              Add Customer
            </.button_widget>
            <.button_widget variant="secondary" class="w-full">
              <.icon name="hero-document-text" class="size-4 mr-2" />
              Generate Report
            </.button_widget>
            <.button_widget variant="secondary" class="w-full">
              <.icon name="hero-credit-card" class="size-4 mr-2" />
              Process Payment
            </.button_widget>
            <.button_widget variant="secondary" class="w-full">
              <.icon name="hero-envelope" class="size-4 mr-2" />
              Send Newsletter
            </.button_widget>
          </div>
        </.card_widget>
        
        <.card_widget span={6}>
          <:header>System Health</:header>
          <.list_widget spacing={3} direction="vertical">
            <:item>
              <div class="flex justify-between items-center">
                <span>API Response Time</span>
                <span class="badge badge-success">45ms</span>
              </div>
            </:item>
            <:item>
              <div class="flex justify-between items-center">
                <span>Database Load</span>
                <span class="badge badge-warning">67%</span>
              </div>
            </:item>
            <:item>
              <div class="flex justify-between items-center">
                <span>Server Uptime</span>
                <span class="badge badge-success">99.9%</span>
              </div>
            </:item>
            <:item>
              <div class="flex justify-between items-center">
                <span>Error Rate</span>
                <span class="badge badge-success">0.02%</span>
              </div>
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
end