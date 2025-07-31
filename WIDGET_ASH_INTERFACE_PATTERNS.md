# Widget-to-Ash Interface Connection Patterns

## Table of Contents
- [Executive Summary](#executive-summary)
- [Quick Decision Guide](#quick-decision-guide)
- [Pattern Recommendations](#pattern-recommendations)
  - [1. Data Assigns Pattern (MOST RECOMMENDED)](#1-data-assigns-pattern-most-recommended)
  - [2. Action Props Pattern](#2-action-props-pattern)
  - [3. Form Integration Pattern](#3-form-integration-pattern)
  - [4. Smart Widget Wrapper Pattern](#4-smart-widget-wrapper-pattern)
  - [5. Context Injection Pattern](#5-context-injection-pattern)
- [Implementation Workflows](#implementation-workflows)
- [Widget Enhancement Guide](#widget-enhancement-guide)
- [Real-World Examples](#real-world-examples)
- [Migration Strategy](#migration-strategy)

## Executive Summary

This guide provides practical patterns for connecting your UI widgets to Ash interfaces while maintaining the principle of "dumb" widgets. The patterns are ranked by simplicity, maintainability, and how little manual work they require.

**Core Philosophy**: Your widgets should remain presentation-only components that know nothing about business logic or data fetching. All Ash integration happens at the LiveView level.

## Quick Decision Guide

```
What are you building?
├── Display-only data (tables, cards, stats)
│   └── Use: Data Assigns Pattern (#1)
├── Interactive elements (buttons, actions)
│   └── Use: Action Props Pattern (#2)
├── Forms with validation
│   └── Use: Form Integration Pattern (#3)
├── Complex nested components
│   └── Use: Smart Widget Wrapper Pattern (#4)
└── Highly dynamic/configurable UIs
    └── Use: Context Injection Pattern (#5)
```

## Pattern Recommendations

### 1. Data Assigns Pattern (MOST RECOMMENDED)

**Philosophy**: Widgets receive fully-prepared data through assigns. LiveView handles all Ash interactions.

**Why This Is Best**:
- Zero changes to existing widgets
- Clear data flow
- Easy to test
- Works with your current patterns
- Most idiot-proof approach

#### How It Works

```elixir
# In your LiveView
def mount(_params, _session, socket) do
  # Call Ash interfaces to get data
  users = MyApp.Accounts.list_users!(load: [:profile])
  stats = MyApp.Analytics.get_dashboard_stats!()
  
  socket = 
    socket
    |> assign(:users, users)
    |> assign(:stats, stats)
    
  {:ok, socket}
end

# In your template - widgets just display data
~H"""
<.stat_widget 
  value={@stats.total_revenue}
  change={@stats.revenue_change}
  trend={@stats.revenue_trend}
/>

<.table_widget rows={@users} id="users-table">
  <:col label="Name"><%= row.name %></:col>
  <:col label="Email"><%= row.email %></:col>
</.table_widget>
"""
```

#### Implementation Steps

1. **Define your Ash interfaces**:
```elixir
# In your domain
resources do
  resource User do
    define :list_users, action: :read
    define :get_user_stats, action: :stats
  end
end
```

2. **Call interfaces in LiveView**:
```elixir
def mount(_params, _session, socket) do
  users = MyApp.Accounts.list_users!()
  {:ok, assign(socket, :users, users)}
end
```

3. **Pass data to widgets** - No widget changes needed!

#### Handling Updates

```elixir
def handle_event("refresh", _params, socket) do
  # Re-fetch data from Ash
  users = MyApp.Accounts.list_users!()
  {:noreply, assign(socket, :users, users)}
end
```

**Pros**:
- Simplest approach
- No widget modifications
- Clear separation of concerns
- Easy to understand data flow
- Works with existing widgets

**Cons**:
- LiveView can become large with many assigns
- Need to manually refresh data

**Best For**: 90% of use cases - dashboards, reports, data displays

---

### 2. Action Props Pattern

**Philosophy**: Widgets emit standardized events, LiveView handles them by calling Ash interfaces.

#### How It Works

```elixir
# Widget emits predictable events
<.button_widget 
  phx-click="action"
  phx-value-action="create_user"
  phx-value-resource="user"
>
  Add User
</.button_widget>

# LiveView handles all actions
def handle_event("action", %{"action" => action, "resource" => resource} = params, socket) do
  case {resource, action} do
    {"user", "create"} ->
      MyApp.Accounts.create_user!(params["data"])
      
    {"user", "delete"} ->
      MyApp.Accounts.delete_user!(params["id"])
      
    {"post", "publish"} ->
      MyApp.Blog.publish_post!(params["id"])
  end
  
  # Refresh relevant data
  {:noreply, refresh_data(socket)}
end
```

#### Enhanced Button Widget (Minimal Change)

```elixir
# Add these optional attrs to button_widget.ex
attr :action, :string, default: nil
attr :resource, :string, default: nil
attr :action_data, :map, default: %{}

def button_widget(assigns) do
  assigns = 
    assigns
    |> assign(:action_attrs, build_action_attrs(assigns))
    
  ~H"""
  <button class={...} {@action_attrs} {@rest}>
    <%= render_slot(@inner_block) %>
  </button>
  """
end

defp build_action_attrs(%{action: nil}), do: %{}
defp build_action_attrs(%{action: action, resource: resource, action_data: data}) do
  %{
    "phx-click" => "action",
    "phx-value-action" => action,
    "phx-value-resource" => resource,
    "phx-value-data" => Jason.encode!(data)
  }
end
```

#### Usage Example

```elixir
# In your template
<.card_widget span={6}>
  <:header>Quick Actions</:header>
  
  <.button_widget 
    action="create"
    resource="user"
    variant="primary"
  >
    Add User
  </.button_widget>
  
  <.button_widget
    action="generate_report"
    resource="analytics"
    action_data={%{type: "monthly"}}
  >
    Generate Monthly Report
  </.button_widget>
</.card_widget>
```

**Pros**:
- Minimal widget changes
- Centralized action handling
- Predictable patterns
- Easy to add new actions

**Cons**:
- Requires small widget updates
- All actions go through one handler

**Best For**: Interactive elements, action buttons, toolbars

---

### 3. Form Integration Pattern

**Philosophy**: Leverage AshPhoenix.Form for form widgets while keeping widgets dumb.

#### How It Works

```elixir
# In LiveView
def mount(_params, _session, socket) do
  # Use generated form function
  form = MyApp.Accounts.form_to_create_user()
  
  {:ok, assign(socket, :form, form)}
end

def handle_event("validate", %{"form" => params}, socket) do
  form = AshPhoenix.Form.validate(socket.assigns.form, params)
  {:noreply, assign(socket, :form, form)}
end

def handle_event("submit", %{"form" => params}, socket) do
  case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
    {:ok, user} ->
      {:noreply, 
        socket
        |> put_flash(:info, "User created!")
        |> push_navigate(to: ~p"/users/#{user.id}")}
        
    {:error, form} ->
      {:noreply, assign(socket, :form, form)}
  end
end
```

#### Enhanced Form Widget

Your existing form_widget already works! Just ensure it accepts Phoenix.HTML.Form:

```elixir
# In template
<.form_widget for={@form} phx-change="validate" phx-submit="submit">
  <.input_widget 
    field={@form[:email]} 
    label="Email"
    span={6}
  />
  <.input_widget 
    field={@form[:name]} 
    label="Name"
    span={6}
  />
  
  <.button_widget variant="primary" type="submit">
    Save User
  </.button_widget>
</.form_widget>
```

#### Handling Nested Forms

```elixir
# Ash action with relationship
create :create do
  accept [:name, :email]
  argument :locations, {:array, :map}
  change manage_relationship(:locations, type: :create)
end

# In template - works automatically!
<.form_widget for={@form}>
  <.input_widget field={@form[:name]} />
  
  <.inputs_for :let={location} field={@form[:locations]}>
    <.input_widget field={location[:address]} />
    <.input_widget field={location[:city]} />
  </.inputs_for>
  
  <.button_widget phx-click="add-location">
    Add Location
  </.button_widget>
</.form_widget>

# Handle adding nested forms
def handle_event("add-location", _, socket) do
  form = AshPhoenix.Form.add_form(socket.assigns.form, :locations)
  {:noreply, assign(socket, :form, form)}
end
```

**Pros**:
- Automatic validation
- Error handling built-in
- Works with relationships
- No widget changes needed

**Cons**:
- Only for forms
- Need to understand AshPhoenix.Form

**Best For**: All forms, especially complex ones with relationships

---

### 4. Smart Widget Wrapper Pattern

**Philosophy**: Create thin wrapper components that handle Ash integration, keeping base widgets pure.

#### How It Works

```elixir
# Create a smart wrapper
defmodule FoundationWeb.Components.SmartWidgets do
  use Phoenix.Component
  import FoundationWeb.Components.Widgets.Table
  
  attr :resource, :atom, required: true
  attr :action, :atom, default: :read
  attr :filters, :map, default: %{}
  attr :load, :list, default: []
  attr :columns, :list, required: true
  
  def smart_table(assigns) do
    # Fetch data using Ash
    data = fetch_resource_data(assigns)
    assigns = assign(assigns, :rows, data)
    
    ~H"""
    <.table_widget rows={@rows} id="#{@resource}-table">
      <%= for col <- @columns do %>
        <:col label={col.label} width={col[:width]}>
          <%= render_column(col, row) %>
        </:col>
      <% end %>
    </.table_widget>
    """
  end
  
  defp fetch_resource_data(%{resource: resource, action: action, filters: filters, load: load}) do
    # Call the appropriate Ash interface
    apply(resource.__domain__, action, [filters: filters, load: load])
  end
  
  defp render_column(%{field: field, type: :badge}, row) do
    ~H"""
    <.badge_widget variant={badge_variant(Map.get(row, field))}>
      <%= Map.get(row, field) %>
    </.badge_widget>
    """
  end
  
  defp render_column(%{field: field}, row) do
    Map.get(row, field)
  end
end
```

#### Usage

```elixir
# Before - manual data fetching
def mount(_, _, socket) do
  users = MyApp.Accounts.list_users!(load: [:profile])
  {:ok, assign(socket, :users, users)}
end

~H"""
<.table_widget rows={@users}>
  <:col label="Name"><%= row.name %></:col>
</.table_widget>
"""

# After - smart widget handles everything
~H"""
<.smart_table
  resource={MyApp.Accounts.User}
  action={:list_users}
  load={[:profile]}
  columns={[
    %{label: "Name", field: :name},
    %{label: "Status", field: :status, type: :badge}
  ]}
/>
"""
```

**Pros**:
- Original widgets unchanged
- Reusable patterns
- Can gradually adopt
- Type-safe with resources

**Cons**:
- Additional wrapper layer
- Need to maintain wrappers
- Can hide complexity

**Best For**: Common patterns like CRUD tables, resource cards

---

### 5. Context Injection Pattern

**Philosophy**: Use assigns to inject capabilities rather than data.

#### How It Works

```elixir
# In LiveView
def mount(_params, _session, socket) do
  socket = 
    socket
    |> assign(:api, %{
      users: &MyApp.Accounts.list_users!/1,
      create_user: &MyApp.Accounts.create_user!/1,
      stats: &MyApp.Analytics.get_stats!/1
    })
    
  {:ok, socket}
end

# Create a data fetching component
def data_provider(assigns) do
  data = assigns.api[assigns.resource].(assigns.opts || [])
  assigns = assign(assigns, :data, data)
  
  ~H"""
  <%= render_slot(@inner_block, @data) %>
  """
end

# Usage
~H"""
<.data_provider resource={:users} opts={[load: [:profile]]} :let={users}>
  <.table_widget rows={users}>
    <!-- columns -->
  </.table_widget>
</.data_provider>
"""
```

**Pros**:
- Very flexible
- Lazy data loading
- Composable

**Cons**:
- More complex
- Can be confusing
- Indirect data flow

**Best For**: Highly dynamic UIs, admin panels, configurable dashboards

---

## Implementation Workflows

### Workflow for Data Assigns Pattern

1. **Define Ash interfaces** in your domain:
```elixir
resources do
  resource User do
    define :list_users, action: :read
    define :get_user_by_id, action: :read, get_by: [:id]
    define :create_user, action: :create
  end
end
```

2. **Create LiveView** with data fetching:
```elixir
defmodule MyAppWeb.UsersLive do
  use MyAppWeb, :live_view
  
  def mount(_params, _session, socket) do
    {:ok, socket |> assign_users() |> assign_stats()}
  end
  
  defp assign_users(socket) do
    users = MyApp.Accounts.list_users!(
      load: [:profile, :subscription],
      sort: [inserted_at: :desc]
    )
    assign(socket, :users, users)
  end
  
  defp assign_stats(socket) do
    stats = %{
      total: length(socket.assigns.users),
      active: Enum.count(socket.assigns.users, & &1.status == :active),
      growth: calculate_growth(socket.assigns.users)
    }
    assign(socket, :stats, stats)
  end
end
```

3. **Use widgets** in template - no changes needed:
```elixir
~H"""
<.grid_layout>
  <.heading_widget>
    Users Overview
    <:description>Manage your application users</:description>
  </.heading_widget>
  
  <.stat_widget 
    value={@stats.total}
    label="Total Users"
    change={"+#{@stats.growth}%"}
    trend="up"
  />
  
  <.table_widget rows={@users} id="users">
    <:col label="Name"><%= row.name %></:col>
    <:col label="Email"><%= row.email %></:col>
    <:col label="Status">
      <.badge_widget variant={status_variant(row.status)}>
        <%= row.status %>
      </.badge_widget>
    </:col>
  </.table_widget>
</.grid_layout>
"""
```

### Workflow for Form Pattern

1. **Define action** with AshPhoenix extension:
```elixir
use Ash.Domain, extensions: [AshPhoenix]

resources do
  resource User do
    define :register_user, args: [:email, :name]
  end
end
```

2. **Setup form** in LiveView:
```elixir
def mount(_params, _session, socket) do
  form = MyApp.Accounts.form_to_register_user()
  {:ok, assign(socket, :form, form)}
end
```

3. **Handle events**:
```elixir
def handle_event("validate", %{"form" => params}, socket) do
  form = AshPhoenix.Form.validate(socket.assigns.form, params)
  {:noreply, assign(socket, :form, form)}
end

def handle_event("submit", %{"form" => params}, socket) do
  case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
    {:ok, user} ->
      {:noreply, 
        socket
        |> put_flash(:info, "User registered!")
        |> redirect(to: ~p"/users/#{user.id}")}
        
    {:error, form} ->
      {:noreply, assign(socket, :form, form)}
  end
end
```

## Widget Enhancement Guide

### Making Widgets "Interface-Ready"

Most widgets need ZERO changes! But here are optional enhancements:

#### 1. Standard Event Props

Add to interactive widgets:
```elixir
# In button_widget.ex
attr :event, :string, default: nil
attr :event_data, :map, default: %{}

# Automatically set phx-click and phx-value-*
```

#### 2. Loading States

Add to data widgets:
```elixir
# In table_widget.ex
attr :loading, :boolean, default: false

def table_widget(assigns) do
  ~H"""
  <div class={["span-#{@span}", @class]}>
    <div :if={@loading} class="flex justify-center p-8">
      <span class="loading loading-spinner loading-lg"></span>
    </div>
    <table :if={!@loading} class="table">
      <!-- existing table code -->
    </table>
  </div>
  """
end
```

#### 3. Empty States

Add to list/table widgets:
```elixir
slot :empty_state

~H"""
<div :if={Enum.empty?(@rows)} class="text-center p-8">
  <%= render_slot(@empty_state) || "No data available" %>
</div>
"""
```

## Real-World Examples

### Complete User Management Dashboard

```elixir
defmodule MyAppWeb.Admin.UsersLive do
  use MyAppWeb, :live_view
  
  # Mount with all necessary data
  def mount(_params, _session, socket) do
    socket = 
      socket
      |> assign(:users, list_users())
      |> assign(:stats, get_user_stats())
      |> assign(:form, MyApp.Accounts.form_to_create_user())
      |> assign(:show_modal, false)
      
    {:ok, socket}
  end
  
  # Define helper functions for Ash calls
  defp list_users(opts \\ []) do
    MyApp.Accounts.list_users!(
      load: [:subscription, :last_login],
      sort: [inserted_at: :desc],
      limit: opts[:limit] || 50
    )
  end
  
  defp get_user_stats do
    %{
      total: MyApp.Accounts.count_users!(),
      active: MyApp.Accounts.count_users!(filter: [status: :active]),
      new_this_month: MyApp.Accounts.count_users!(
        filter: [inserted_at: [greater_than: DateTime.utc_now() |> DateTime.add(-30, :day)]]
      )
    }
  end
  
  # Handle all events
  def handle_event("open_create_modal", _, socket) do
    {:noreply, assign(socket, :show_modal, true)}
  end
  
  def handle_event("close_modal", _, socket) do
    {:noreply, 
      socket
      |> assign(:show_modal, false)
      |> assign(:form, MyApp.Accounts.form_to_create_user())}
  end
  
  def handle_event("validate", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, :form, form)}
  end
  
  def handle_event("submit", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, _user} ->
        {:noreply,
          socket
          |> put_flash(:info, "User created successfully!")
          |> assign(:users, list_users())
          |> assign(:stats, get_user_stats())
          |> assign(:show_modal, false)
          |> assign(:form, MyApp.Accounts.form_to_create_user())}
          
      {:error, form} ->
        {:noreply, assign(socket, :form, form)}
    end
  end
  
  def handle_event("delete_user", %{"id" => id}, socket) do
    case MyApp.Accounts.delete_user!(id) do
      :ok ->
        {:noreply,
          socket
          |> put_flash(:info, "User deleted")
          |> assign(:users, list_users())
          |> assign(:stats, get_user_stats())}
          
      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not delete user")}
    end
  end
  
  def handle_event("toggle_status", %{"id" => id}, socket) do
    user = MyApp.Accounts.get_user_by_id!(id)
    new_status = if user.status == :active, do: :inactive, else: :active
    
    case MyApp.Accounts.update_user!(user, %{status: new_status}) do
      {:ok, _} ->
        {:noreply, assign(socket, :users, list_users())}
        
      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not update user")}
    end
  end
  
  # The template - using only dumb widgets!
  def render(assigns) do
    ~H"""
    <.dashboard_layout>
      <:sidebar>
        <.navigation_widget brand="Admin Panel">
          <:nav_item path="/admin/users" active>Users</:nav_item>
          <:nav_item path="/admin/billing">Billing</:nav_item>
          <:nav_item path="/admin/settings">Settings</:nav_item>
        </.navigation_widget>
      </:sidebar>
      
      <.grid_layout>
        <!-- Header with action -->
        <div class="span-12 flex justify-between items-center">
          <.heading_widget>
            User Management
            <:description>
              Manage your application users and permissions
            </:description>
          </.heading_widget>
          
          <.button_widget 
            variant="primary" 
            phx-click="open_create_modal"
          >
            <.icon name="hero-plus" class="w-4 h-4 mr-2" />
            Add User
          </.button_widget>
        </div>
        
        <!-- Stats Cards -->
        <.card_widget span={4}>
          <:header>Total Users</:header>
          <.stat_widget value={@stats.total} />
        </.card_widget>
        
        <.card_widget span={4}>
          <:header>Active Users</:header>
          <.stat_widget 
            value={@stats.active}
            change={percentage_of(@stats.active, @stats.total)}
            change_label="of total"
          />
        </.card_widget>
        
        <.card_widget span={4}>
          <:header>New This Month</:header>
          <.stat_widget value={@stats.new_this_month} />
        </.card_widget>
        
        <!-- Users Table -->
        <.card_widget span={12}>
          <:header>All Users</:header>
          
          <.table_widget rows={@users} id="users-table">
            <:col label="Name" width="w-1/4">
              <%= row.name %>
            </:col>
            
            <:col label="Email" width="w-1/4">
              <%= row.email %>
            </:col>
            
            <:col label="Status" width="w-1/6">
              <.badge_widget variant={status_variant(row.status)}>
                <%= row.status %>
              </.badge_widget>
            </:col>
            
            <:col label="Plan" width="w-1/6">
              <%= row.subscription && row.subscription.plan || "Free" %>
            </:col>
            
            <:col label="Actions" width="w-1/6">
              <div class="flex gap-2">
                <.button_widget 
                  size="sm"
                  variant="ghost"
                  phx-click="toggle_status"
                  phx-value-id={row.id}
                >
                  <%= if row.status == :active, do: "Deactivate", else: "Activate" %>
                </.button_widget>
                
                <.button_widget
                  size="sm"
                  variant="ghost"
                  phx-click="delete_user"
                  phx-value-id={row.id}
                  data-confirm="Are you sure?"
                >
                  Delete
                </.button_widget>
              </div>
            </:col>
          </.table_widget>
        </.card_widget>
      </.grid_layout>
    </.dashboard_layout>
    
    <!-- Create User Modal -->
    <.modal_widget :if={@show_modal} id="create-user-modal" title="Create New User">
      <.form_widget 
        for={@form} 
        phx-change="validate" 
        phx-submit="submit"
      >
        <.input_widget 
          field={@form[:name]}
          label="Full Name"
          span={12}
        />
        
        <.input_widget
          field={@form[:email]}
          label="Email Address"
          type="email"
          span={12}
        />
        
        <.input_widget
          field={@form[:role]}
          label="Role"
          type="select"
          options={[
            {"User", "user"},
            {"Admin", "admin"},
            {"Manager", "manager"}
          ]}
          span={12}
        />
      </.form_widget>
      
      <:actions>
        <.button_widget variant="ghost" phx-click="close_modal">
          Cancel
        </.button_widget>
        <.button_widget variant="primary" form="create-user-form" type="submit">
          Create User
        </.button_widget>
      </:actions>
    </.modal_widget>
    """
  end
  
  # Helper functions
  defp status_variant(:active), do: "success"
  defp status_variant(:inactive), do: "neutral"
  defp status_variant(:suspended), do: "error"
  defp status_variant(_), do: "neutral"
  
  defp percentage_of(partial, total) when total > 0 do
    "#{round(partial / total * 100)}%"
  end
  defp percentage_of(_, _), do: "0%"
end
```

### Complex Form with Relationships

```elixir
defmodule MyAppWeb.ProjectLive.New do
  use MyAppWeb, :live_view
  
  def mount(_params, _session, socket) do
    # Form with nested relationships
    form = MyApp.Projects.form_to_create_project()
    
    {:ok, 
      socket
      |> assign(:form, form)
      |> assign(:available_users, MyApp.Accounts.list_users!())}
  end
  
  def handle_event("validate", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, :form, form)}
  end
  
  def handle_event("add_milestone", _, socket) do
    form = AshPhoenix.Form.add_form(socket.assigns.form, :milestones)
    {:noreply, assign(socket, :form, form)}
  end
  
  def handle_event("remove_milestone", %{"index" => index}, socket) do
    form = AshPhoenix.Form.remove_form(
      socket.assigns.form, 
      "form[milestones][#{index}]"
    )
    {:noreply, assign(socket, :form, form)}
  end
  
  def handle_event("submit", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, project} ->
        {:noreply,
          socket
          |> put_flash(:info, "Project created!")
          |> push_navigate(to: ~p"/projects/#{project.id}")}
          
      {:error, form} ->
        {:noreply, assign(socket, :form, form)}
    end
  end
  
  def render(assigns) do
    ~H"""
    <.centered_layout max_width="max-w-4xl">
      <.card_widget span={12}>
        <:header>Create New Project</:header>
        
        <.form_widget 
          for={@form} 
          phx-change="validate" 
          phx-submit="submit"
          columns={2}
          gap={6}
        >
          <!-- Basic Info -->
          <.input_widget
            field={@form[:name]}
            label="Project Name"
            span={12}
          />
          
          <.input_widget
            field={@form[:description]}
            label="Description"
            type="textarea"
            span={12}
          />
          
          <.input_widget
            field={@form[:start_date]}
            label="Start Date"
            type="date"
            span={6}
          />
          
          <.input_widget
            field={@form[:end_date]}
            label="End Date"
            type="date"
            span={6}
          />
          
          <!-- Team Members -->
          <div class="span-12">
            <h3 class="text-lg font-semibold mb-4">Team Members</h3>
            
            <.input_widget
              field={@form[:team_member_ids]}
              label="Select Team Members"
              type="select"
              multiple={true}
              options={Enum.map(@available_users, &{&1.name, &1.id})}
              span={12}
            />
          </div>
          
          <!-- Milestones -->
          <div class="span-12">
            <div class="flex justify-between items-center mb-4">
              <h3 class="text-lg font-semibold">Milestones</h3>
              <.button_widget 
                type="button"
                size="sm"
                variant="secondary"
                phx-click="add_milestone"
              >
                Add Milestone
              </.button_widget>
            </div>
            
            <.inputs_for :let={milestone} field={@form[:milestones]}>
              <.card_widget span={12} padding={4}>
                <div class="grid grid-cols-12 gap-4">
                  <.input_widget
                    field={milestone[:name]}
                    label="Milestone Name"
                    span={8}
                  />
                  
                  <.input_widget
                    field={milestone[:due_date]}
                    label="Due Date"
                    type="date"
                    span={4}
                  />
                  
                  <.input_widget
                    field={milestone[:description]}
                    label="Description"
                    type="textarea"
                    span={11}
                  />
                  
                  <div class="span-1 flex items-end pb-2">
                    <.button_widget
                      type="button"
                      size="sm"
                      variant="ghost"
                      phx-click="remove_milestone"
                      phx-value-index={milestone.index}
                    >
                      <.icon name="hero-trash" class="w-4 h-4" />
                    </.button_widget>
                  </div>
                </div>
              </.card_widget>
            </.inputs_for>
          </div>
          
          <!-- Submit -->
          <div class="span-12 flex justify-end gap-4 mt-6">
            <.button_widget variant="ghost" type="button" navigate={~p"/projects"}>
              Cancel
            </.button_widget>
            <.button_widget variant="primary" type="submit">
              Create Project
            </.button_widget>
          </div>
        </.form_widget>
      </.card_widget>
    </.centered_layout>
    """
  end
end
```

## Migration Strategy

### Phase 1: Keep Everything As-Is
- Your widgets work perfectly already!
- Start using Data Assigns Pattern immediately
- No widget changes needed

### Phase 2: Gradual Enhancement (Optional)
1. Add loading states to data widgets
2. Add action props to interactive widgets
3. Create smart wrappers for common patterns

### Phase 3: Standardization
1. Document your patterns
2. Create LiveView templates/generators
3. Build a pattern library

### Testing Approach

```elixir
# Test widgets remain simple - just HTML
describe "stat_widget/1" do
  test "renders value and label" do
    assigns = %{
      value: "$1,234",
      label: "Revenue",
      change: "+10%",
      trend: "up"
    }
    
    html = render_component(&stat_widget/1, assigns)
    
    assert html =~ "$1,234"
    assert html =~ "Revenue"
    assert html =~ "+10%"
  end
end

# Test LiveView handles Ash integration
describe "UsersLive" do
  test "loads users on mount", %{conn: conn} do
    # Create test users via Ash
    user1 = MyApp.Accounts.create_user!(%{name: "Test User 1"})
    user2 = MyApp.Accounts.create_user!(%{name: "Test User 2"})
    
    {:ok, view, html} = live(conn, "/users")
    
    assert html =~ "Test User 1"
    assert html =~ "Test User 2"
    assert has_element?(view, "[data-role=user-row][data-id=#{user1.id}]")
  end
  
  test "creates user through form", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/users")
    
    # Open modal
    view |> element("button", "Add User") |> render_click()
    
    # Fill form
    view
    |> form("#user-form", %{
      "form" => %{
        "name" => "New User",
        "email" => "new@example.com"
      }
    })
    |> render_submit()
    
    # Verify user was created
    assert MyApp.Accounts.get_user_by_email!("new@example.com")
    assert render(view) =~ "User created successfully!"
  end
end
```

## Summary

The **Data Assigns Pattern** is your best friend:
1. Widgets stay completely dumb
2. LiveView handles all Ash calls
3. Zero changes to existing code
4. Clear, simple data flow

For forms, use **AshPhoenix.Form** - it just works with your existing form widgets.

For repeated patterns, consider **Smart Widget Wrappers** - but only after you've proven the pattern multiple times.

Remember: The best interface is no interface. Your widgets shouldn't know Ash exists.