# Latest Ash and UI Implementation Guide

## Executive Summary

This guide provides a comprehensive walkthrough of the Ash-Widget integration system implemented in Foundation. The system enables you to create reusable UI widgets that can seamlessly switch between static (hardcoded) data and dynamic (Ash-backed) data with real-time updates.

### Key Benefits:
- **Dual Mode Widgets**: Same widget works with both static and live data
- **Real-time Updates**: Automatic UI updates when data changes
- **Clean Separation**: UI components remain "dumb" - data logic lives elsewhere
- **Developer Friendly**: Debug mode shows data sources visually
- **Rapid Prototyping**: Start with static data, switch to Ash when ready

### System Components:
1. **Widgets**: Reusable UI components (stat, table, card, etc.)
2. **WidgetData**: Central data management module
3. **Ash Resources**: Data models and business logic
4. **LiveView**: Orchestrates widgets and handles real-time events

---

## Architecture Overview

### Data Flow Diagram
```
                    ┌──────────────┐
                    │ Ash Resource │
                    │   (Data)     │
                    └──────┬───────┘
                           │ 
                           │ read/query
                           ▼
                    ┌──────────────┐
                    │  WidgetData  │
                    │  (Data Hub)  │
                    └──────┬───────┘
                           │
                           │ fetch & transform
                           ▼
┌─────────────┐     ┌──────────────┐     ┌────────────────┐
│   Widget    │ ◄── │   LiveView   │ ──► │     PubSub     │
│  (Dumb UI)  │     │(Orchestrator)│     │  (Real-time)   │
└─────────────┘     └──────┬───────┘     └────────┬───────┘
    receives               │                       │
    props/data             │ subscribes           │ broadcasts
                           └───────────────────────┘
                               handle_info

Data Flow Summary:
1. LiveView calls WidgetData.assign_widget_data()
2. WidgetData fetches from Ash Resources
3. LiveView passes data as props to Widgets
4. LiveView subscribes to PubSub topics
5. External updates trigger WidgetData.broadcast_update()
6. PubSub notifies LiveView via handle_info
7. LiveView updates state and re-renders Widgets
```

### Key Concepts:

1. **Data Sources**:
   - `:static` - Hardcoded data for prototyping
   - `:ash` - Live data from Ash resources

2. **Real-time Updates**:
   - PubSub broadcasts changes to all connected clients
   - LiveView handles updates automatically

3. **Debug Mode**:
   - Visual indicators show which data source is active
   - Helps during development and testing

---

## Creating New Widgets

### Widget Anatomy

Every widget follows this structure:

```elixir
defmodule FoundationWeb.Components.Widgets.MyWidget do
  use Phoenix.Component
  
  # Define widget attributes
  attr :value, :string, required: true
  attr :label, :string, default: nil
  attr :data_source, :atom, default: :static
  attr :resource_id, :string, default: nil
  attr :refresh_interval, :integer, default: nil
  attr :debug_mode, :boolean, default: false
  
  def my_widget(assigns) do
    ~H"""
    <div class="relative">
      <!-- Debug indicator -->
      <div :if={@debug_mode} class="absolute top-1 right-1 text-xs px-1 bg-base-300 rounded">
        {@data_source}
      </div>
      
      <!-- Widget content -->
      <div class="widget-content">
        <span :if={@label}>{@label}</span>
        <div>{@value}</div>
      </div>
    </div>
    """
  end
end
```

### Step-by-Step: Create a Metric Widget

Let's create a new metric widget that displays a single metric with an icon:

**Step 1: Create the widget file**

```elixir
# lib/foundation_web/components/widgets/metric.ex
defmodule FoundationWeb.Components.Widgets.Metric do
  use Phoenix.Component
  
  attr :value, :string, required: true
  attr :label, :string, required: true
  attr :icon, :string, default: "hero-chart-bar"
  attr :color, :string, default: "primary"
  attr :data_source, :atom, default: :static
  attr :resource_id, :string, default: nil
  attr :refresh_interval, :integer, default: nil
  attr :debug_mode, :boolean, default: false
  
  def metric_widget(assigns) do
    ~H"""
    <div class="relative p-4 rounded-lg bg-base-100">
      <div :if={@debug_mode} class="absolute top-1 right-1 text-xs px-1 bg-base-300 rounded">
        {@data_source}
      </div>
      
      <div class="flex items-center gap-4">
        <div class={"p-3 rounded-full bg-#{@color}/10"}>
          <.icon name={@icon} class={"size-6 text-#{@color}"} />
        </div>
        
        <div>
          <div class="text-sm text-base-content/70">{@label}</div>
          <div class="text-2xl font-bold">{@value}</div>
        </div>
      </div>
    </div>
    """
  end
end
```

**Step 2: Use the widget in a LiveView**

```elixir
# In your LiveView render function
<.metric_widget 
  label="Total Orders"
  value={@order_count}
  icon="hero-shopping-cart"
  color="success"
  data_source={@data_source}
  debug_mode={@debug_mode}
/>
```

### Widget Best Practices

1. **Keep widgets dumb**: No business logic, just display
2. **Use consistent attributes**: Always include data_source and debug_mode
3. **Follow naming conventions**: Use `_widget` suffix
4. **Document attributes**: Add @doc strings for complex widgets
5. **Use Tailwind classes**: Leverage the design system

---

## Building Scaffold/Dumb UIs

### Using the Generator

The fastest way to create a new dashboard:

```bash
mix foundation.gen.live_dashboard SalesDashboard
```

This creates `lib/foundation_web/live/sales_dashboard_live.ex` with:
- Basic layout structure
- Widget imports
- Static/Ash data switching
- Real-time update handlers

### Manual Scaffold Creation

Here's a complete scaffold LiveView template:

```elixir
defmodule FoundationWeb.MyDashboardLive do
  use FoundationWeb, :live_view
  
  alias FoundationWeb.WidgetData
  
  # Import all widgets you need
  import FoundationWeb.Components.Widgets.Card
  import FoundationWeb.Components.Widgets.Stat
  import FoundationWeb.Components.Widgets.Table
  import FoundationWeb.Components.Widgets.Heading
  import FoundationWeb.Components.LayoutWidgets
  
  def mount(_params, _session, socket) do
    # Start with static data for development
    data_source = :static  # Change to :ash when ready
    
    # Subscribe to real-time updates if using Ash
    if data_source == :ash do
      WidgetData.subscribe_to_updates([:my_topic])
    end
    
    socket = 
      socket
      |> assign(:data_source, data_source)
      |> assign(:debug_mode, true)
      |> assign_initial_data(data_source)
      
    {:ok, socket}
  end
  
  def render(assigns) do
    ~H"""
    <.grid_layout>
      <!-- Page Header -->
      <.heading_widget variant="page">
        My Dashboard
        <:description>
          Monitor your key metrics and activities
        </:description>
      </.heading_widget>
      
      <!-- Metrics Row -->
      <.card_widget span={3}>
        <:header>Revenue</:header>
        <.stat_widget 
          value={"$#{@revenue}"}
          change="+12%"
          change_label="vs last month"
          trend="up"
          data_source={@data_source}
          debug_mode={@debug_mode}
        />
      </.card_widget>
      
      <.card_widget span={3}>
        <:header>Users</:header>
        <.stat_widget 
          value={@user_count}
          change="+5%"
          change_label="vs last month"
          trend="up"
          data_source={@data_source}
          debug_mode={@debug_mode}
        />
      </.card_widget>
      
      <!-- Activity Table -->
      <.card_widget span={6}>
        <:header>Recent Activity</:header>
        <.table_widget rows={@activities}>
          <:col label="User" field={:user} />
          <:col label="Action" field={:action} />
          <:col label="Time" field={:time} />
        </.table_widget>
      </.card_widget>
    </.grid_layout>
    """
  end
  
  # Static data for development
  defp assign_initial_data(socket, :static) do
    socket
    |> assign(:revenue, "45,231")
    |> assign(:user_count, "1,234")
    |> assign(:activities, [
      %{user: "john@example.com", action: "Logged in", time: "2 mins ago"},
      %{user: "jane@example.com", action: "Created project", time: "5 mins ago"}
    ])
  end
  
  # Ash data (implemented later)
  defp assign_initial_data(socket, :ash) do
    WidgetData.assign_widget_data(socket, :ash)
  end
  
  # Handle real-time updates
  def handle_info({:widget_data_updated, :my_topic, data}, socket) do
    {:noreply, assign(socket, data)}
  end
end
```

### Common Layout Patterns

**1. Dashboard Grid (12-column)**
```elixir
<.grid_layout>
  <!-- Full width -->
  <.card_widget span={12}>...</.card_widget>
  
  <!-- Half width -->
  <.card_widget span={6}>...</.card_widget>
  <.card_widget span={6}>...</.card_widget>
  
  <!-- Thirds -->
  <.card_widget span={4}>...</.card_widget>
  <.card_widget span={4}>...</.card_widget>
  <.card_widget span={4}>...</.card_widget>
  
  <!-- Quarters -->
  <.card_widget span={3}>...</.card_widget>
  <.card_widget span={3}>...</.card_widget>
  <.card_widget span={3}>...</.card_widget>
  <.card_widget span={3}>...</.card_widget>
</.grid_layout>
```

**2. Sidebar Layout**
```elixir
<.dashboard_layout>
  <:sidebar>
    <.navigation_widget brand="My App">
      <:nav_item path="/dashboard" active={true}>
        Dashboard
      </:nav_item>
      <:nav_item path="/users">
        Users
      </:nav_item>
    </.navigation_widget>
  </:sidebar>
  
  <.grid_layout>
    <!-- Main content -->
  </.grid_layout>
</.dashboard_layout>
```

---

## Connecting UIs to Ash

### Step 1: Create an Ash Resource

```elixir
# lib/foundation/analytics/metric.ex
defmodule Foundation.Analytics.Metric do
  use Ash.Resource,
    otp_app: :foundation,
    domain: Foundation.Analytics,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "metrics"
    repo Foundation.Repo
  end

  attributes do
    uuid_primary_key :id
    
    attribute :name, :string, allow_nil?: false, public?: true
    attribute :value, :decimal, allow_nil?: false, public?: true
    attribute :previous_value, :decimal, public?: true
    attribute :unit, :string, default: "count", public?: true
    
    timestamps()
  end

  actions do
    defaults [:read, :destroy]
    
    create :create do
      accept [:name, :value, :previous_value, :unit]
    end
    
    update :update do
      accept [:value, :previous_value]
    end
    
    read :by_name do
      argument :name, :string, allow_nil?: false
      filter expr(name == ^arg(:name))
    end
  end
  
  calculations do
    calculate :change_percentage, :float do
      calculation fn records, _opts ->
        Enum.map(records, fn record ->
          if record.previous_value && record.previous_value != 0 do
            ((record.value - record.previous_value) / record.previous_value * 100)
            |> Float.round(1)
          else
            0.0
          end
        end)
      end
    end
    
    calculate :formatted_value, :string do
      calculation fn records, _opts ->
        Enum.map(records, fn record ->
          case record.unit do
            "currency" -> "$#{Number.Currency.number_to_currency(record.value)}"
            "percentage" -> "#{record.value}%"
            _ -> to_string(record.value)
          end
        end)
      end
    end
  end
end
```

### Step 2: Create the Domain

```elixir
# lib/foundation/analytics.ex
defmodule Foundation.Analytics do
  use Ash.Domain,
    otp_app: :foundation,
    extensions: [AshPhoenix]

  resources do
    resource Foundation.Analytics.Metric
  end
end
```

### Step 3: Update WidgetData Module

```elixir
# In lib/foundation_web/widget_data.ex, update the assign_widget_data function:

def assign_widget_data(socket, :ash) do
  # Fetch real data from Ash
  metrics = Foundation.Analytics.Metric
  |> Ash.Query.load([:change_percentage, :formatted_value])
  |> Ash.read!()
  
  # Transform into widget-friendly format
  revenue_metric = Enum.find(metrics, &(&1.name == "revenue"))
  users_metric = Enum.find(metrics, &(&1.name == "active_users"))
  
  socket
  |> assign(:revenue, revenue_metric.formatted_value || "$0")
  |> assign(:revenue_change, revenue_metric.change_percentage || 0)
  |> assign(:user_count, users_metric.formatted_value || "0")
  |> assign(:user_change, users_metric.change_percentage || 0)
end

# Add specific data fetching functions
def fetch_dashboard_metrics do
  %{
    revenue: get_metric_value("revenue"),
    users: get_metric_value("active_users"),
    orders: get_metric_value("total_orders"),
    churn: get_metric_value("churn_rate")
  }
end

defp get_metric_value(name) do
  Foundation.Analytics.Metric
  |> Ash.Query.filter(name == ^name)
  |> Ash.Query.load([:formatted_value, :change_percentage])
  |> Ash.read_one!()
end
```

### Step 4: Enable Real-time Updates

**Add a GenServer for periodic updates:**

```elixir
# lib/foundation_web/metric_updater.ex
defmodule FoundationWeb.MetricUpdater do
  use GenServer
  alias FoundationWeb.WidgetData
  
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end
  
  def init(state) do
    # Update every 30 seconds
    :timer.send_interval(30_000, :update_metrics)
    {:ok, state}
  end
  
  def handle_info(:update_metrics, state) do
    # Fetch fresh data
    metrics = WidgetData.fetch_dashboard_metrics()
    
    # Broadcast to all subscribers
    WidgetData.broadcast_update(:dashboard_metrics, metrics)
    
    {:noreply, state}
  end
end
```

**Add to supervision tree:**

```elixir
# In lib/foundation/application.ex
children = [
  # ... other children
  FoundationWeb.MetricUpdater
]
```

### Step 5: Complete LiveView Integration

```elixir
defmodule FoundationWeb.AnalyticsDashboardLive do
  use FoundationWeb, :live_view
  
  alias FoundationWeb.WidgetData
  alias Foundation.Analytics
  
  def mount(_params, _session, socket) do
    data_source = :ash
    
    if connected?(socket) && data_source == :ash do
      WidgetData.subscribe_to_updates([:dashboard_metrics])
    end
    
    socket = 
      socket
      |> assign(:data_source, data_source)
      |> assign(:debug_mode, false)
      |> load_dashboard_data()
      
    {:ok, socket}
  end
  
  defp load_dashboard_data(socket) do
    metrics = WidgetData.fetch_dashboard_metrics()
    
    socket
    |> assign(:revenue, metrics.revenue.formatted_value)
    |> assign(:revenue_change, metrics.revenue.change_percentage)
    |> assign(:users, metrics.users.formatted_value)
    |> assign(:users_change, metrics.users.change_percentage)
  end
  
  def handle_info({:widget_data_updated, :dashboard_metrics, metrics}, socket) do
    {:noreply, load_dashboard_data(socket)}
  end
end
```

---

## Common Implementation Patterns

### 1. Dashboard Pattern

**Use Case**: Executive dashboards, analytics views

```elixir
defmodule FoundationWeb.ExecutiveDashboardLive do
  use FoundationWeb, :live_view
  
  def render(assigns) do
    ~H"""
    <.grid_layout>
      <!-- KPI Row -->
      <div class="col-span-12 grid grid-cols-4 gap-4">
        <.stat_widget 
          label="Revenue"
          value={@revenue}
          change={@revenue_change}
          trend={trend_direction(@revenue_change)}
        />
        <!-- More KPIs... -->
      </div>
      
      <!-- Charts Row -->
      <.card_widget span={8}>
        <:header>Revenue Trend</:header>
        <div id="revenue-chart" phx-hook="Chart">
          <!-- Chart implementation -->
        </div>
      </.card_widget>
      
      <.card_widget span={4}>
        <:header>Top Products</:header>
        <.list_widget items={@top_products}>
          <:item :let={product}>
            <div class="flex justify-between">
              <span>{product.name}</span>
              <span class="font-semibold">${product.revenue}</span>
            </div>
          </:item>
        </.list_widget>
      </.card_widget>
    </.grid_layout>
    """
  end
  
  defp trend_direction(change) when change > 0, do: "up"
  defp trend_direction(change) when change < 0, do: "down"
  defp trend_direction(_), do: "neutral"
end
```

### 2. Form Pattern

**Use Case**: Settings, data entry, configuration

```elixir
defmodule FoundationWeb.UserSettingsLive do
  use FoundationWeb, :live_view
  
  def render(assigns) do
    ~H"""
    <.grid_layout>
      <.card_widget span={8}>
        <:header>User Settings</:header>
        
        <.form_widget for={@form} phx-submit="save" phx-change="validate">
          <.input_widget 
            field={@form[:name]} 
            label="Full Name" 
            icon="hero-user"
          />
          
          <.input_widget 
            field={@form[:email]} 
            label="Email Address" 
            type="email"
            icon="hero-envelope"
          />
          
          <.input_widget 
            field={@form[:role]} 
            label="Role" 
            type="select"
            options={["Admin", "User", "Guest"]}
          />
          
          <:actions>
            <.button_widget type="submit" variant="primary">
              Save Changes
            </.button_widget>
          </:actions>
        </.form_widget>
      </.card_widget>
      
      <.card_widget span={4}>
        <:header>Quick Stats</:header>
        <.stat_widget 
          label="Last Login"
          value={@last_login}
          size="sm"
        />
        <.stat_widget 
          label="Total Sessions"
          value={@session_count}
          size="sm"
        />
      </.card_widget>
    </.grid_layout>
    """
  end
end
```

### 3. Table/List Pattern

**Use Case**: Data management, CRUD interfaces

```elixir
defmodule FoundationWeb.UserManagementLive do
  use FoundationWeb, :live_view
  
  def render(assigns) do
    ~H"""
    <.grid_layout>
      <!-- Filters -->
      <.card_widget span={12}>
        <div class="flex gap-4">
          <.input_widget 
            name="search"
            placeholder="Search users..."
            icon="hero-magnifying-glass"
            phx-debounce="300"
            phx-change="search"
          />
          
          <.button_widget phx-click="new_user">
            <.icon name="hero-plus" class="size-4" />
            Add User
          </.button_widget>
        </div>
      </.card_widget>
      
      <!-- User Table -->
      <.card_widget span={12}>
        <.table_widget rows={@users} row_click="edit_user">
          <:col label="Name" field={:name}>
            <span class="font-medium">{@row.name}</span>
          </:col>
          
          <:col label="Email" field={:email} />
          
          <:col label="Status" field={:status}>
            <.badge_widget variant={status_variant(@row.status)}>
              {@row.status}
            </.badge_widget>
          </:col>
          
          <:col label="Actions">
            <.button_widget size="xs" phx-click="edit" phx-value-id={@row.id}>
              Edit
            </.button_widget>
          </:col>
        </.table_widget>
      </.card_widget>
    </.grid_layout>
    """
  end
  
  defp status_variant("active"), do: "success"
  defp status_variant("inactive"), do: "warning"
  defp status_variant(_), do: "neutral"
end
```

### 4. Mixed Data Source Pattern

**Use Case**: Gradual migration, A/B testing

```elixir
defmodule FoundationWeb.HybridDashboardLive do
  use FoundationWeb, :live_view
  
  def mount(_params, _session, socket) do
    socket = 
      socket
      # Some widgets use Ash
      |> assign(:revenue_source, :ash)
      |> assign(:activity_source, :static)
      |> load_revenue_data(:ash)
      |> load_activity_data(:static)
      
    {:ok, socket}
  end
  
  def render(assigns) do
    ~H"""
    <.grid_layout>
      <!-- This widget uses Ash data -->
      <.stat_widget 
        value={@revenue}
        label="Revenue"
        data_source={@revenue_source}
        debug_mode={true}
      />
      
      <!-- This widget uses static data -->
      <.table_widget 
        rows={@activities}
        data_source={@activity_source}
        debug_mode={true}
      >
        <:col label="Activity" field={:name} />
      </.table_widget>
    </.grid_layout>
    """
  end
end
```

---

## Testing and Debugging

### Using Debug Mode

Debug mode adds visual indicators to show data sources:

```elixir
# In mount function
socket = assign(socket, :debug_mode, true)

# In render function - indicators appear automatically
<.stat_widget 
  value={@value}
  debug_mode={@debug_mode}  # Shows "static" or "ash"
/>
```

### Testing Real-time Updates

**In IEx console:**

```elixir
# Test broadcasting
FoundationWeb.WidgetData.broadcast_update(:kpi, %{
  revenue: "125,000",
  revenue_growth: 15
})

# Test specific topic
FoundationWeb.WidgetData.broadcast_update(:activities, [
  %{id: 1, user: "test@example.com", action: "Test action", time: "now"}
])
```

### Common Troubleshooting

**Issue: Widgets not updating in real-time**

Check:
1. PubSub subscription in mount: `WidgetData.subscribe_to_updates([:topic])`
2. Handle_info function exists: `def handle_info({:widget_data_updated, :topic, data}, socket)`
3. Socket is connected: `if connected?(socket) do`

**Issue: "Undefined function" errors**

Solution:
```elixir
# In IEx
recompile()

# Or restart server
mix phx.server
```

**Issue: Data not showing from Ash**

Debug steps:
```elixir
# Check resource directly
Foundation.Dashboard.KpiSummary |> Ash.read!()

# Check domain registration
Application.get_env(:foundation, :ash_domains)

# Test WidgetData function
FoundationWeb.WidgetData.test_module()
```

---

## Quick Reference

### Commands Cheatsheet

```bash
# Generate new dashboard
mix foundation.gen.live_dashboard MyDashboard

# Create Ash resource
mix ash.gen.resource MyDomain MyResource \
  attributes:string:required \
  count:integer:required

# Start server
mix phx.server

# Interactive console
iex -S mix

# Recompile in IEx
recompile()
```

### Essential Code Snippets

**Basic Widget Usage:**
```elixir
<.stat_widget 
  value={@metric}
  label="Metric Name"
  change="+5%"
  trend="up"
  data_source={@data_source}
  debug_mode={@debug_mode}
/>
```

**Subscribe to Updates:**
```elixir
if connected?(socket) do
  WidgetData.subscribe_to_updates([:topic1, :topic2])
end
```

**Handle Updates:**
```elixir
def handle_info({:widget_data_updated, topic, data}, socket) do
  {:noreply, assign(socket, data)}
end
```

**Broadcast Changes:**
```elixir
WidgetData.broadcast_update(:topic, %{key: "value"})
```

### Widget Attribute Reference

**Common attributes all widgets should support:**
- `data_source` - :static or :ash
- `debug_mode` - true/false
- `resource_id` - Ash resource identifier (future use)
- `refresh_interval` - Auto-refresh in ms (future use)

**StatWidget specific:**
- `value` - Main metric value (required)
- `label` - Metric label
- `change` - Change amount (+5%, -2%, etc)
- `change_label` - Context for change (vs last month)
- `trend` - "up", "down", or "neutral"
- `size` - "sm", "md", or "lg"

**TableWidget specific:**
- `rows` - List of data (required)
- `row_click` - Event handler for row clicks
- `:col` slot with `label` and `field`

**CardWidget specific:**
- `span` - Grid columns (1-12)
- `:header` slot for title
- `:footer` slot for actions

---

## Next Steps

1. **Start Simple**: Use the generator to create your first dashboard
2. **Prototype with Static**: Get the UI right with hardcoded data
3. **Create Ash Resources**: Model your domain properly
4. **Connect to Ash**: Update WidgetData and switch data_source
5. **Add Real-time**: Implement broadcasting where needed
6. **Optimize**: Add caching, pagination, and error handling

Remember: The beauty of this system is that you can start simple and evolve. Your widgets don't need to know where their data comes from - they just display what they're given.

Happy building! 🚀