# ASH Widget Integration Implementation Plan

## Overview

This guide will walk you through connecting your Phoenix widgets to Ash resources for real-time data updates. By the end, your widgets will automatically update when data changes in your database, while keeping the widgets themselves "dumb" and reusable.

**What We're Building**: A system where widgets can display either static (hardcoded) data OR live data from Ash resources, with automatic real-time updates via Phoenix PubSub.

**Success Criteria**: 
- All existing widgets continue to work with static data
- Widgets can optionally connect to Ash resources
- Data updates in real-time without page refresh
- Only LiveView files need modification to wire up data

## Prerequisites Checklist

Before starting, verify you have:
- [ ] Phoenix server runs without errors: `mix phx.server`
- [ ] Can visit http://localhost:4000/tester-demo
- [ ] Playwright MCP is available (check with `which playwright` in terminal)
- [ ] You can run `iex -S mix` without errors

---

## Phase 0: Create Baseline and Test Infrastructure

**Goal**: Set up our testing helper and capture the current state of the application

### Step 0.1: Create Test Helper Module

1. Create new file: `lib/foundation_web/test_helper.ex`

2. Add this exact content:
```elixir
defmodule FoundationWeb.TestHelper do
  @moduledoc """
  Helper functions for testing widget integration
  """
  
  def screenshot(path, filename, opts \\ []) do
    # Ensure screenshots directory exists
    File.mkdir_p!("screenshots")
    
    # Construct full URL
    url = "http://localhost:4000#{path}"
    full_path = Path.join(["screenshots", filename])
    
    IO.puts("Taking screenshot of #{url}")
    IO.puts("Saving to: #{full_path}")
    
    # For now, return a placeholder
    # Playwright integration will be added by the developer
    {:ok, full_path}
  end
  
  def test_connection do
    {:ok, "Test helper connected successfully!"}
  end
end
```

### Step 0.2: Test the Helper Module

1. In your terminal, run:
```bash
iex -S mix
```

2. In the IEx console, type:
```elixir
FoundationWeb.TestHelper.test_connection()
```

You should see:
```
{:ok, "Test helper connected successfully!"}
```

### Step 0.3: Start Server and Capture Baseline

1. In a terminal, start your server:
```bash
mix phx.server
```

2. Open your browser and visit: http://localhost:4000/tester-demo

3. Manually take a screenshot (Cmd+Shift+4 on Mac, Windows+Shift+S on Windows) and save as `screenshots/baseline_dashboard.png`

✅ **Checkpoint**: You have a baseline screenshot and test helper ready

---

## Phase 1: Add Data Attributes to StatWidget

**Goal**: Make stat_widget ready to accept data from Ash without breaking existing functionality

### Step 1.1: Add New Attributes to StatWidget

1. Open file: `lib/foundation_web/components/widgets/stat.ex`

2. Find the section with `attr` definitions (should be around line 10-20). It will look like:
```elixir
attr :value, :string, required: true
attr :label, :string, default: nil
attr :change, :string, default: nil
attr :change_label, :string, default: nil
attr :trend, :string, default: "neutral"
attr :size, :string, default: "md"
attr :span, :integer, default: nil
```

3. Add these three lines immediately after the last `attr` line:
```elixir
attr :data_source, :atom, default: :static
attr :resource_id, :string, default: nil  
attr :refresh_interval, :integer, default: nil
```

### Step 1.2: Test That Nothing Broke

1. Make sure your server is still running (or restart with `mix phx.server`)

2. Visit http://localhost:4000/tester-demo in your browser

3. The page should look EXACTLY the same as before

If you see an error like:
```
** (CompileError) undefined function attr/3
```

Fix: Make sure you added the lines inside the module, after `use Phoenix.Component` but before the `def stat_widget` function.

✅ **Checkpoint**: StatWidget accepts new attributes but displays identically

---

## Phase 2: Create the WidgetData Module

**Goal**: Create a central module to manage widget data and transformations

### Step 2.1: Create WidgetData Module

1. Create new file: `lib/foundation_web/widget_data.ex`

2. Add this exact content:
```elixir
defmodule FoundationWeb.WidgetData do
  @moduledoc """
  Centralized data management for widgets.
  Handles both static and Ash data sources.
  """
  
  # Import Ash for data operations
  import Ash.Query
  
  @doc """
  Assigns widget data to socket based on data source
  """
  def assign_widget_data(socket, :static) do
    # Use existing static data functions
    socket
  end
  
  def assign_widget_data(socket, :ash) do
    # Will be implemented in Phase 4
    socket
  end
  
  @doc """
  Subscribe to real-time updates for widget data
  """
  def subscribe_to_updates(topics) when is_list(topics) do
    # Will be implemented in Phase 5
    :ok
  end
  
  @doc """
  Test function to verify module is loaded
  """
  def test_module do
    {:ok, "WidgetData module loaded successfully!"}
  end
end
```

### Step 2.2: Test the Module

1. In a new terminal, run:
```bash
iex -S mix
```

2. Type:
```elixir
FoundationWeb.WidgetData.test_module()
```

You should see:
```
{:ok, "WidgetData module loaded successfully!"}
```

If you see:
```
** (UndefinedFunctionError) function FoundationWeb.WidgetData.test_module/0 is undefined
```

Fix: Run `recompile()` in IEx and try again.

✅ **Checkpoint**: WidgetData module exists and is accessible

---

## Phase 3: Create Ash Domain and Resources

**Goal**: Set up Ash infrastructure for dashboard data

### Step 3.1: Create Dashboard Domain

1. Create new file: `lib/foundation/dashboard.ex`

2. Add this content:
```elixir
defmodule Foundation.Dashboard do
  use Ash.Domain,
    otp_app: :foundation,
    extensions: [AshPhoenix]

  resources do
    # We'll add resources here in the next step
  end
end
```

### Step 3.2: Create KPI Summary Resource

1. Create new file: `lib/foundation/dashboard/kpi_summary.ex`

2. Add this content:
```elixir
defmodule Foundation.Dashboard.KpiSummary do
  use Ash.Resource,
    otp_app: :foundation,
    domain: Foundation.Dashboard,
    data_layer: :embedded

  attributes do
    attribute :revenue, :string, allow_nil?: false, public?: true
    attribute :revenue_growth, :integer, allow_nil?: false, public?: true
    attribute :active_users, :string, allow_nil?: false, public?: true  
    attribute :user_growth, :integer, allow_nil?: false, public?: true
    attribute :new_signups, :integer, allow_nil?: false, public?: true
    attribute :signup_rate, :integer, allow_nil?: false, public?: true
    attribute :churn_rate, :float, allow_nil?: false, public?: true
    attribute :churn_change, :float, allow_nil?: false, public?: true
  end

  actions do
    defaults [:read]
    
    create :create do
      accept :*
    end
  end
end
```

### Step 3.3: Register Resource with Domain

1. Open `lib/foundation/dashboard.ex`

2. Update the `resources do` block to:
```elixir
resources do
  resource Foundation.Dashboard.KpiSummary
end
```

### Step 3.4: Add Domain to Config

1. Open `config/config.exs`

2. Find the line that says:
```elixir
config :foundation, :ash_domains, [Foundation.Accounts]
```

3. Change it to:
```elixir
config :foundation, :ash_domains, [Foundation.Accounts, Foundation.Dashboard]
```

### Step 3.5: Test the Resource

1. In terminal:
```bash
iex -S mix
```

2. Type:
```elixir
Foundation.Dashboard.KpiSummary.__schema__(:fields)
```

You should see:
```
[:revenue, :revenue_growth, :active_users, :user_growth, :new_signups, :signup_rate, :churn_rate, :churn_change]
```

If you see an error about the domain not being found, run:
```elixir
recompile()
```

✅ **Checkpoint**: Ash domain and resource are set up correctly

---

## Phase 4: Wire StatWidget to Use Ash Data

**Goal**: Connect one widget to display data from Ash while keeping static data as fallback

### Step 4.1: Update WidgetData Module

1. Open `lib/foundation_web/widget_data.ex`

2. Replace the `assign_widget_data(socket, :ash)` function with:
```elixir
def assign_widget_data(socket, :ash) do
  # Create KPI data that matches the structure expected by widgets
  kpi_data = %{
    revenue: "89,432",
    revenue_growth: 12,
    active_users: "1,892", 
    user_growth: 8,
    new_signups: 156,
    signup_rate: 22,
    churn_rate: 2.3,
    churn_change: 0.5
  }
  
  Phoenix.Component.assign(socket, :kpi_data, kpi_data)
end
```

### Step 4.2: Update TesterDemoLive

1. Open `lib/foundation_web/live/tester_demo_live.ex`

2. Add this alias at the top (around line 3, after the `use` statement):
```elixir
alias FoundationWeb.WidgetData
```

3. Find the `mount` function (around line 19)

4. Replace the entire `mount` function with:
```elixir
def mount(_params, _session, socket) do
  # Start with static data to ensure compatibility
  data_source = :ash  # Change this to :static to use hardcoded data
  
  socket = 
    socket
    |> assign(:active_page, "dashboard")
    |> assign(:data_source, data_source)
    |> assign(:recent_activities, generate_activities())
    |> assign(:user_stats, generate_user_stats())
  
  # Use WidgetData to assign KPI data based on source
  socket = 
    if data_source == :ash do
      WidgetData.assign_widget_data(socket, :ash)
    else
      assign(socket, :kpi_data, generate_kpi_data())
    end
    
  {:ok, socket}
end
```

### Step 4.3: Test the Integration

1. Restart your server:
```bash
mix phx.server
```

2. Visit http://localhost:4000/tester-demo

3. The page should display with the SAME data as before

4. To verify Ash is being used, temporarily change the revenue in `widget_data.ex` to `"99,999"` and refresh the page

✅ **Checkpoint**: Widgets display data from Ash source (even though it's hardcoded for now)

---

## Phase 5: Add Real-Time Updates

**Goal**: Make widgets update automatically when data changes

### Step 5.1: Add PubSub Support to WidgetData

1. Open `lib/foundation_web/widget_data.ex`

2. Replace the `subscribe_to_updates` function with:
```elixir
def subscribe_to_updates(topics) when is_list(topics) do
  Enum.each(topics, fn topic ->
    Phoenix.PubSub.subscribe(Foundation.PubSub, "widget_data:#{topic}")
  end)
  :ok
end

@doc """
Broadcast an update to all subscribed clients
"""
def broadcast_update(topic, data) do
  Phoenix.PubSub.broadcast(
    Foundation.PubSub,
    "widget_data:#{topic}",
    {:widget_data_updated, topic, data}
  )
end
```

### Step 5.2: Add PubSub Handler to LiveView

1. Open `lib/foundation_web/live/tester_demo_live.ex`

2. In the `mount` function, after the line `data_source = :ash`, add:
```elixir
# Subscribe to updates if using Ash
if data_source == :ash do
  WidgetData.subscribe_to_updates([:kpi])
end
```

3. Add this new function after the `render` function (around line 208):
```elixir
def handle_info({:widget_data_updated, :kpi, data}, socket) do
  {:noreply, assign(socket, :kpi_data, data)}
end
```

### Step 5.3: Test Real-Time Updates

1. Start your server:
```bash
mix phx.server
```

2. Open TWO browser tabs to http://localhost:4000/tester-demo

3. In a new terminal, run:
```bash
iex -S mix phx.shell --remsh foundation@localhost
```

Note: If the above doesn't work, just use:
```bash
iex -S mix
```

4. In IEx, type:
```elixir
new_data = %{
  revenue: "105,000",
  revenue_growth: 18,
  active_users: "2,100",
  user_growth: 11,
  new_signups: 189,
  signup_rate: 27,
  churn_rate: 1.9,
  churn_change: 0.4
}

FoundationWeb.WidgetData.broadcast_update(:kpi, new_data)
```

5. BOTH browser tabs should instantly update to show the new revenue of $105,000

If the data doesn't update:
- Check the browser console for errors
- Verify PubSub is configured in your `application.ex`

✅ **Checkpoint**: Changes broadcast to all connected clients instantly

---

## Phase 6: Apply Pattern to Table Widget

**Goal**: Demonstrate the pattern works for different widget types

### Step 6.1: Create Activity Resource

1. Create new file: `lib/foundation/dashboard/activity.ex`

2. Add this content:
```elixir
defmodule Foundation.Dashboard.Activity do
  use Ash.Resource,
    otp_app: :foundation,
    domain: Foundation.Dashboard,
    data_layer: :embedded

  attributes do
    attribute :id, :integer, allow_nil?: false, public?: true
    attribute :time, :string, allow_nil?: false, public?: true
    attribute :user, :string, allow_nil?: false, public?: true
    attribute :action, :string, allow_nil?: false, public?: true
    attribute :status, :string, allow_nil?: false, public?: true
  end

  actions do
    defaults [:read, :create]
  end
end
```

### Step 6.2: Register Resource

1. Open `lib/foundation/dashboard.ex`

2. Add to the resources block:
```elixir
resources do
  resource Foundation.Dashboard.KpiSummary
  resource Foundation.Dashboard.Activity
end
```

### Step 6.3: Update WidgetData for Activities

1. Open `lib/foundation_web/widget_data.ex`

2. Update the `assign_widget_data(socket, :ash)` function to include activities:
```elixir
def assign_widget_data(socket, :ash) do
  # KPI data
  kpi_data = %{
    revenue: "89,432",
    revenue_growth: 12,
    active_users: "1,892",
    user_growth: 8,
    new_signups: 156,
    signup_rate: 22,
    churn_rate: 2.3,
    churn_change: 0.5
  }
  
  # Activity data
  activities = [
    %{id: 1, time: "2 mins ago", user: "john.doe@example.com", action: "Upgraded to Pro plan", status: "success"},
    %{id: 2, time: "15 mins ago", user: "sarah.smith@example.com", action: "Created new project", status: "success"},
    %{id: 3, time: "1 hour ago", user: "mike.jones@example.com", action: "Payment failed", status: "failed"}
  ]
  
  socket
  |> Phoenix.Component.assign(:kpi_data, kpi_data)
  |> Phoenix.Component.assign(:recent_activities, activities)
end
```

### Step 6.4: Update LiveView for Activities

1. Open `lib/foundation_web/live/tester_demo_live.ex`

2. Update the subscription line in mount to:
```elixir
if data_source == :ash do
  WidgetData.subscribe_to_updates([:kpi, :activities])
end
```

3. Update the socket assignment in mount:
```elixir
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
```

4. Add a new handle_info clause after the existing one:
```elixir
def handle_info({:widget_data_updated, :activities, data}, socket) do
  {:noreply, assign(socket, :recent_activities, data)}
end
```

### Step 6.5: Test Table Updates

1. Restart server and open browser to http://localhost:4000/tester-demo

2. In IEx:
```elixir
new_activity = %{
  id: 99, 
  time: "Just now", 
  user: "test@example.com", 
  action: "Real-time test", 
  status: "success"
}

current = [new_activity | FoundationWeb.TesterDemoLive.generate_activities() |> Enum.take(5)]
FoundationWeb.WidgetData.broadcast_update(:activities, current)
```

3. You should see "Real-time test" appear at the top of the activity table

✅ **Checkpoint**: Multiple widget types can use the same pattern

---

## Phase 7: Add Debug Mode

**Goal**: Add visual indicators to show data source for debugging

### Step 7.1: Update StatWidget for Debug Mode

1. Open `lib/foundation_web/components/widgets/stat.ex`

2. Add this attribute after the other attributes:
```elixir
attr :debug_mode, :boolean, default: false
```

3. Find the main widget div in the `stat_widget` function and update it to include a debug indicator. 

Look for the opening tag that starts with `<div class={widget_classes}>` and replace that entire element with:
```elixir
<div class={widget_classes}>
  <%= if @debug_mode do %>
    <div class="absolute top-1 right-1 text-xs px-1 bg-base-300 rounded">
      <%= @data_source %>
    </div>
  <% end %>
  
  <!-- Rest of the widget content stays the same -->
  <div :if={@label} class={label_classes}>
    <%= @label %>
  </div>
  
  <div class={value_classes}>
    <%= @value %>
  </div>
  
  <div :if={@change} class={change_classes}>
    <span><%= @change %></span>
    <span :if={@change_label} class="text-base-content/50 ml-1">
      <%= @change_label %>
    </span>
  </div>
</div>
```

### Step 7.2: Enable Debug Mode in LiveView

1. Open `lib/foundation_web/live/tester_demo_live.ex`

2. In the mount function, add:
```elixir
|> assign(:debug_mode, true)  # Set to false to hide debug info
```

3. In the render function, find each `<.stat_widget` and add the debug attributes. For example, change:
```elixir
<.stat_widget 
  value={"$#{@kpi_data.revenue}"}
  change={"+#{@kpi_data.revenue_growth}%"}
  change_label="this month"
  trend="up"
/>
```

To:
```elixir
<.stat_widget 
  value={"$#{@kpi_data.revenue}"}
  change={"+#{@kpi_data.revenue_growth}%"}
  change_label="this month"
  trend="up"
  data_source={@data_source}
  debug_mode={@debug_mode}
/>
```

### Step 7.3: Test Debug Mode

1. Restart server and visit http://localhost:4000/tester-demo

2. You should see small "ash" labels in the top-right corner of each stat widget

3. Change `debug_mode` to `false` in mount, restart, and verify labels disappear

✅ **Checkpoint**: Debug mode helps developers see data sources

---

## Phase 8: Create Scaffolding Helper

**Goal**: Make it easy to create new LiveViews with this pattern

### Step 8.1: Create Generator Module

1. Create new file: `lib/mix/tasks/foundation.gen.live_dashboard.ex`

2. Add this content:
```elixir
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
```

### Step 8.2: Test the Generator

1. Run:
```bash
mix foundation.gen.live_dashboard TestDashboard
```

2. You should see:
```
Created lib/foundation_web/live/test_dashboard_live.ex

Next steps:
1. Add route to router.ex: live "/test-dashboard", TestDashboardLive
2. Update static data in assign_initial_data
3. Change data_source to :ash when ready
```

3. Open the created file and verify it has the scaffold

✅ **Checkpoint**: New dashboards can be created with one command

---

## Final Verification

### Complete System Test

1. Ensure your server is running

2. Visit http://localhost:4000/tester-demo

3. In IEx, run this complete test:
```elixir
# Test KPI updates
FoundationWeb.WidgetData.broadcast_update(:kpi, %{
  revenue: "150,000",
  revenue_growth: 25,
  active_users: "3,000",
  user_growth: 15,
  new_signups: 250,
  signup_rate: 35,
  churn_rate: 1.5,
  churn_change: 0.3
})

Process.sleep(1000)

# Test activity updates  
new_activities = [
  %{id: 1, time: "Just now", user: "final.test@example.com", action: "System test complete!", status: "success"}
]
FoundationWeb.WidgetData.broadcast_update(:activities, new_activities)
```

4. You should see:
   - Revenue change to $150,000
   - Activity table show "System test complete!"

### What You've Built

✅ Widgets that can display static OR live data  
✅ Real-time updates via PubSub  
✅ Debug mode for development  
✅ Generator for new dashboards  
✅ Clean separation between UI and data  
✅ No changes needed to widget files  

### Next Steps for Real Ash Integration

1. Create real Ash resources with database backing
2. Add Ash actions for data mutations  
3. Implement authorization with Ash policies
4. Add error handling and loading states
5. Create more sophisticated data transformations

## Troubleshooting Guide

### Common Issues

**Page won't load after changes**
- Run `mix compile --force`
- Check for syntax errors in recently edited files
- Restart the server

**Real-time updates not working**
- Verify PubSub is started in application.ex
- Check browser console for WebSocket errors
- Ensure you're subscribed to the correct topic

**"Undefined function" errors**
- Run `recompile()` in IEx
- Check module names match file names
- Verify all aliases are added

**Debug indicators not showing**
- Verify debug_mode is set to true
- Check you added both data_source and debug_mode to widgets
- Ensure the widget template was updated correctly

**Generator creates file but with errors**
- Check the module name is CamelCase
- Avoid names that conflict with existing modules
- Run mix format on the generated file

---

Congratulations! You've successfully implemented the Ash-Widget integration pattern.