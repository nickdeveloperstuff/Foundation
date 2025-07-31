# Task Manager Validation Test - Ash-UI Implementation Guide Verification

> **PURPOSE**: This document validates whether the claims and instructions in `LATEST_ASH_AND_UI_IMPLEMENTATION_GUIDE.md` actually work in practice. This is NOT a tutorial - it's a validation test that documents what works, what doesn't, and what needs correction in the guide.

> **CRITICAL INSTRUCTIONS FOR TESTERS**:
> - ✅ **DOCUMENT AS YOU GO** - Don't wait until the end to write down issues
> - ✅ **CHECK OFF ITEMS** - Mark completed items with ✓ and failed items with ✗
> - ✅ **RECORD ALL ISSUES** - Even minor discrepancies should be noted
> - ✅ **TRY WORKAROUNDS** - If something fails, try minor fixes but DON'T restructure the approach
> - ✅ **CONTINUE TESTING** - If one section fails, still test the others as much as possible
> - ✅ **BE SPECIFIC** - Write exact error messages and what you tried to fix them

> **SCREENSHOT TOOL**: When taking screenshots, use ONLY Puppeteer MCP (NOT Playwright MCP). Command: `mcp__puppeteer__puppeteer_screenshot`

## Validation Tracking Summary
<!-- Fill this in as you go -->
| Section | Guide Reference | Status | Issues Found |
|---------|----------------|--------|--------------|
| Ash Resources | Section "Creating New Widgets" | [ ] | |
| Route Creation | Section "Building Scaffold/Dumb UIs" | [ ] | |
| Static UI | Section "Common Layout Patterns" | [ ] | |
| Ash Connection | Section "Connecting UIs to Ash" | [ ] | |
| Real-time Updates | Section "Enable Real-time Updates" | [ ] | |
| Form Validation | Section "Form Pattern" | [ ] | |

## Table of Contents
1. [Overview](#overview)
2. [Before You Start](#before-you-start)
3. [File Structure Preview](#file-structure-preview)
4. [Phase 1: Create Ash Resources](#phase-1-create-ash-resources)
5. [Phase 2: Create Route and Page](#phase-2-create-route-and-page)
6. [Phase 3: Build Static UI](#phase-3-build-static-ui)
7. [Phase 4: Create Task Form](#phase-4-create-task-form)
8. [Phase 5: Connect to Ash](#phase-5-connect-to-ash)
9. [Phase 6: Real-time Updates](#phase-6-real-time-updates)
10. [Phase 7: Form Validation](#phase-7-form-validation)
11. [Testing Guide](#testing-guide)
12. [Troubleshooting](#troubleshooting)
13. [Complete Code Reference](#complete-code-reference)

## 🚨 CRITICAL REMINDER: Document As You Go! 🚨

**DO NOT WAIT** until the end to fill in the validation results. As you complete each step:

1. ✓ Check off completed items immediately
2. ✗ Mark failures as soon as they happen
3. 📝 Write down exact error messages
4. 🔧 Document any workarounds you try
5. 📊 Fill in the validation results boxes after each section

**The value of this test is in the real-time documentation of issues, not in completing the app!**

---

## Overview

### What We're Validating
This test validates the following claims from `LATEST_ASH_AND_UI_IMPLEMENTATION_GUIDE.md`:
- ❓ "Dual Mode Widgets: Same widget works with both static and live data"
- ❓ "Real-time Updates: Automatic UI updates when data changes"
- ❓ "Clean Separation: UI components remain dumb"
- ❓ "Developer Friendly: Debug mode shows data sources visually"
- ❓ "Rapid Prototyping: Start with static data, switch to Ash when ready"

### Validation Methodology
1. Follow the guide's approach exactly as described
2. Document any deviations from expected behavior
3. Note missing instructions or unclear steps
4. Record workarounds needed to make things work
5. Continue testing even if earlier steps fail

### Prerequisites Validation
Before starting, verify these prerequisites work:
- [ ] Foundation project cloned successfully
- [ ] PostgreSQL is running (command: `pg_ctl status` or check system services)
- [ ] `mix phx.server` runs without errors
- [ ] Can access http://localhost:4000
- [ ] All mix dependencies installed (`mix deps.get`)

**❌ PREREQUISITE ISSUES:** 
<!-- Document any prerequisite problems here -->

### When Things Go Wrong - Important Instructions

**If you encounter errors:**
1. **Document First**: Write down the exact error message and context
2. **Try Minor Fixes**: 
   - Check for typos
   - Missing imports
   - Compilation errors
   - Restart the server
3. **Don't Restructure**: Keep following the guide's paradigm
4. **Mark and Continue**: Note what failed and try to test remaining sections
5. **Track Dependencies**: Note if failure X prevents testing Y

**Use These Documentation Markers:**
- ✅ **CONFIRMED**: Works exactly as the guide describes
- ❌ **ISSUE**: Something doesn't work as described
- ⚠️ **WORKAROUND**: Had to do something different
- 🔍 **INVESTIGATION**: Debugging attempts made
- ⏭️ **SKIPPED**: Couldn't test due to earlier failure

## Before You Start

### Check Your Environment

**1. Verify you're in the right directory:**
```bash
pwd
```
Should output something like: `/Users/yourname/Documents/DEVELOPMENT/SCRATCH/saasy/foundation`

**2. Check the project runs:**
```bash
mix phx.server
```
- Visit http://localhost:4000
- You should see the application
- Press `Ctrl+C` twice to stop the server

**3. Check database connection:**
```bash
mix ecto.create
```
Should say "The database for Foundation.Repo has already been created" or create it.

### Basic Commands You'll Need

| Command | What it does | When to use it |
|---------|--------------|----------------|
| `mix compile` | Compiles your Elixir code | After creating/editing files |
| `mix phx.server` | Starts the web server | To run the application |
| `iex -S mix` | Starts interactive Elixir shell | To test code interactively |
| `recompile()` | Recompiles code (in IEx) | After file changes while in IEx |
| `Ctrl+C` twice | Exits IEx or stops server | When you need to exit |

## File Structure Preview

This is what we'll create (★ = new file, ✏️ = modify existing):

```
foundation/
├── lib/
│   ├── foundation/
│   │   ├── task_manager.ex                    ★ Phase 1
│   │   └── task_manager/
│   │       └── task.ex                        ★ Phase 1
│   └── foundation_web/
│       ├── router.ex                          ✏️ Phase 2
│       ├── live/
│       │   └── task_dashboard_live.ex         ★ Phase 2
│       ├── components/
│       │   └── widgets/
│       │       └── task_form.ex               ★ Phase 4
│       └── widget_data.ex                     ✏️ Phase 5
├── priv/
│   └── repo/
│       └── migrations/
│           └── [timestamp]_create_tasks.exs   ★ Phase 1
└── config/
    └── config.exs                             ✏️ Phase 1
```

## Phase 1: Create Ash Resources

> **Validating Guide Section**: "Step 1: Create an Ash Resource" (Lines 341-409)
> 
> **Guide Claims to Verify**:
> - Resources can be created with attributes, actions, and calculations
> - PostgreSQL integration works seamlessly
> - Automatic timestamp handling

### Phase 1 Validation Checklist
- [ ] Guide provides clear Ash resource structure
- [ ] Database migration generation works as described
- [ ] Resource actions (create, read, update) function properly
- [ ] Calculations work as shown in guide

### Step 1.1: Create the Task Resource

**🔍 VALIDATION POINT**: The guide shows creating a Metric resource. We'll create a Task resource following the same pattern to verify the approach works.

**Guide Reference**: Lines 343-409 show the resource structure

**Pre-check**:
```bash
pwd
# Should show: .../foundation
ls lib/foundation/
# Should show existing files like accounts.ex, application.ex, etc.
```

**Create the directory structure:**
```bash
mkdir -p lib/foundation/task_manager
```

**Verify it was created:**
```bash
ls lib/foundation/
# Should now include: task_manager/
```

**Create the Task resource file:**

File: `lib/foundation/task_manager/task.ex`

```elixir
# This file defines our Task resource - think of it as our data model
defmodule Foundation.TaskManager.Task do
  use Ash.Resource,
    otp_app: :foundation,
    domain: Foundation.TaskManager,
    data_layer: AshPostgres.DataLayer

  # This tells Ash to use PostgreSQL and which table
  postgres do
    table "tasks"
    repo Foundation.Repo
  end

  # These are the fields our tasks will have
  attributes do
    # Every task gets a unique ID automatically
    uuid_primary_key :id
    
    # The task title - required field
    attribute :title, :string, allow_nil?: false, public?: true
    
    # Longer description - optional
    attribute :description, :text, public?: true
    
    # Status can only be one of these values
    attribute :status, :atom do
      constraints [one_of: [:pending, :in_progress, :completed]]
      default :pending
      public? true
    end
    
    # Priority levels
    attribute :priority, :atom do
      constraints [one_of: [:low, :medium, :high, :urgent]]
      default :medium
      public? true
    end
    
    # When the task was completed (if completed)
    attribute :completed_at, :utc_datetime_usec, public?: true
    
    # Automatic timestamps
    timestamps()
  end

  # These are the operations we can perform on tasks
  actions do
    # Basic CRUD operations
    defaults [:read, :destroy]
    
    # Custom create action with specific fields
    create :create do
      accept [:title, :description, :status, :priority]
    end
    
    # Custom update action
    update :update do
      accept [:title, :description, :status, :priority]
      
      # When status changes to completed, set completed_at
      change fn changeset, _context ->
        if Ash.Changeset.changing_attribute?(changeset, :status) do
          case Ash.Changeset.get_attribute(changeset, :status) do
            :completed -> 
              Ash.Changeset.change_attribute(changeset, :completed_at, DateTime.utc_now())
            _ -> 
              Ash.Changeset.change_attribute(changeset, :completed_at, nil)
          end
        else
          changeset
        end
      end
    end
  end
  
  # Calculated fields (computed on the fly)
  calculations do
    # Is this task completed?
    calculate :is_completed, :boolean do
      expr(status == :completed)
    end
  end
end
```

**Quick Test 1.1:**
```bash
mix compile
```

**Expected output:**
```
Compiling 1 file (.ex)
warning: struct Foundation.TaskManager has not been defined yet
  lib/foundation/task_manager/task.ex:5: Foundation.TaskManager.Task (module)
```

> **NOTE**: This warning is EXPECTED! We'll fix it in the next step.

**Common Issues:**
- **"** (SyntaxError) syntax error before: ..." - You have a typo. Check for missing commas, brackets, or `end` statements
- **"undefined function expr/1"** - Make sure you have `use Ash.Resource` at the top

### Step 1.1 Validation Results
┌────────────────────────────────────────────────┐
│ **WORKS AS DESCRIBED:** [ ] Yes [ ] No        │
│ **Guide Accuracy:** [ ] Complete [ ] Partial  │
│                                                │
│ **Issues Found:**                              │
│ _____________________________________________  │
│ _____________________________________________  │
│                                                │
│ **Workarounds Used:**                          │
│ _____________________________________________  │
│ _____________________________________________  │
└────────────────────────────────────────────────┘

---

### Step 1.2: Create the TaskManager Domain

**🔍 VALIDATION POINT**: Guide section "Step 2: Create the Domain" (Lines 412-425)

**Guide Says**: "Create a domain that groups related resources"
**Testing**: Whether domain creation follows the pattern shown

**Create the domain file:**

File: `lib/foundation/task_manager.ex`

```elixir
# This domain groups all task-related resources
defmodule Foundation.TaskManager do
  use Ash.Domain,
    otp_app: :foundation,
    extensions: [AshPhoenix]

  resources do
    # Register our Task resource
    resource Foundation.TaskManager.Task
  end
end
```

**Quick Test 1.2:**
```bash
mix compile
```

**Expected output:**
```
Compiling 2 files (.ex)
Generated foundation app
```

> **Success!** No warnings this time.

---

### Step 1.3: Register Domain in Config

**What we're doing**: Telling our application about the new domain.

**Edit the config file:**

File: `config/config.exs`

Find the section that looks like this (around line 70-80):
```elixir
config :foundation,
  ash_domains: [
    Foundation.Accounts,
    Foundation.Dashboard,
    Foundation.Ledger
  ]
```

Add our new domain to the list:
```elixir
config :foundation,
  ash_domains: [
    Foundation.Accounts,
    Foundation.Dashboard,
    Foundation.Ledger,
    Foundation.TaskManager  # <-- Add this line
  ]
```

**Quick Test 1.3:**
```bash
mix compile
```

Should compile without errors.

---

### Step 1.4: Create Database Migration

**What we're doing**: Creating the database table for tasks.

**Generate the migration:**
```bash
mix ash.codegen create_tasks
```

**Expected output:**
```
* creating priv/repo/migrations/20240731123456_create_tasks.exs
```

> **Note**: Your timestamp will be different!

**Review the generated migration:**
```bash
cat priv/repo/migrations/*_create_tasks.exs
```

You should see a migration that creates a tasks table with all our fields.

**Run the migration:**
```bash
mix ecto.migrate
```

**Expected output:**
```
[info] == Running 20240731123456 Foundation.Repo.Migrations.CreateTasks.up/0 forward
[info] create table tasks
[info] == Migrated 20240731123456 in 0.0s
```

---

### Step 1.5: Test the Resource Works

**What we're doing**: Making sure we can create and query tasks.

**Start IEx:**
```bash
iex -S mix
```

**Create a test task:**
```elixir
# Create a task
task = Foundation.TaskManager.Task.create!(%{
  title: "Test the Ash resource",
  description: "Make sure our Task resource works",
  status: :pending,
  priority: :high
})
```

**Expected output:**
```elixir
#Foundation.TaskManager.Task<
  id: "0189abc...",
  title: "Test the Ash resource",
  description: "Make sure our Task resource works",
  status: :pending,
  priority: :high,
  completed_at: nil,
  inserted_at: ~U[2024-07-31 12:34:56Z],
  updated_at: ~U[2024-07-31 12:34:56Z],
  ...
>
```

**Query all tasks:**
```elixir
Foundation.TaskManager.Task.read!()
```

**Expected output:**
```elixir
[
  #Foundation.TaskManager.Task<
    id: "0189abc...",
    title: "Test the Ash resource",
    ...
  >
]
```

**Exit IEx:**
Press `Ctrl+C` twice

### ✅ Phase 1 Complete!

You now have:
- A working Task resource
- A TaskManager domain
- A database table for tasks
- The ability to create and query tasks

**Before moving on, verify:**
- [ ] You can create tasks in IEx
- [ ] Tasks are saved to the database
- [ ] You can query tasks back

---

## Phase 2: Create Route and Page

> **Validating Guide Section**: "Manual Scaffold Creation" (Lines 185-289)
>
> **Guide Claims to Verify**:
> - Generator creates working LiveView with structure shown
> - Basic layout includes widget imports
> - Static/Ash data switching works
> - Real-time update handlers are included

### Phase 2 Validation Checklist
- [ ] Can create route as guide suggests
- [ ] LiveView structure matches template (Lines 188-289)
- [ ] Widget imports work as shown
- [ ] mount/render pattern follows guide

### Step 2.1: Add Route to Router

**🔍 VALIDATION POINT**: Guide assumes we know how to add routes but doesn't explicitly show this step

**❌ MISSING FROM GUIDE**: 
<!-- Document if route creation instructions are missing -->

**Open the router file:**

File: `lib/foundation_web/router.ex`

**Find the right location** (around line 42-50):
```elixir
  scope "/", FoundationWeb do
    pipe_through :browser

    get "/", PageController, :home
    live "/tester-demo", TesterDemoLive
    live "/newest-try", NewestTryLive
    # <-- We'll add our route here
    auth_routes AuthController, Foundation.Accounts.User, path: "/auth"
```

**Add this line** (after the other `live` routes):
```elixir
    live "/task-dashboard", TaskDashboardLive
```

The section should now look like:
```elixir
  scope "/", FoundationWeb do
    pipe_through :browser

    get "/", PageController, :home
    live "/tester-demo", TesterDemoLive
    live "/newest-try", NewestTryLive
    live "/task-dashboard", TaskDashboardLive  # <-- Added this
    auth_routes AuthController, Foundation.Accounts.User, path: "/auth"
```

**Quick Test 2.1:**
```bash
mix compile
```

**Expected error:**
```
error: module FoundationWeb.TaskDashboardLive is not available
```

> **This error is EXPECTED!** We haven't created the module yet.

---

### Step 2.2: Create the LiveView Module

**What we're doing**: Creating the LiveView module that our route points to.

**Create the LiveView file:**

File: `lib/foundation_web/live/task_dashboard_live.ex`

```elixir
defmodule FoundationWeb.TaskDashboardLive do
  use FoundationWeb, :live_view
  
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
  
  def render(assigns) do
    ~H"""
    <div class="p-8">
      <h1 class="text-2xl font-bold">Task Dashboard</h1>
      <p class="mt-4">This is a placeholder page. We'll add the actual UI next!</p>
    </div>
    """
  end
end
```

**Quick Test 2.2:**
```bash
mix compile
```

**Expected output:**
```
Compiling 1 file (.ex)
Generated foundation app
```

**Start the server:**
```bash
mix phx.server
```

**Browser Test:**
1. Open http://localhost:4000/task-dashboard
2. You should see "Task Dashboard" with the placeholder text

**Take a screenshot:**
```
mcp__puppeteer__puppeteer_navigate url: "http://localhost:4000/task-dashboard"
mcp__puppeteer__puppeteer_screenshot name: "task-dashboard-placeholder"
```

### ✅ Phase 2 Complete!

You now have:
- A working route at `/task-dashboard`
- A basic LiveView module
- A page that loads successfully

---

## Phase 3: Build Static UI

> **Validating Guide Section**: "Common Layout Patterns" (Lines 293-334) and Widget examples throughout
>
> **Guide Claims to Verify**:
> - Widgets can be imported and used as shown
> - Grid layout system works with span values
> - Debug mode shows data source indicators
> - Static data assignment works before Ash integration

### Phase 3 Validation Checklist
- [ ] All widget imports resolve correctly
- [ ] Grid layout with span={n} works as described
- [ ] Debug mode indicators appear on widgets
- [ ] Static data can be assigned and displayed

### Step 3.1: Import Required Widgets

**🔍 VALIDATION POINT**: Guide shows various widget imports throughout. Testing if they all exist and work.

**Guide References**: 
- Card widget usage (Lines 296-312)
- Stat widget example (Lines 567-574)
- Table widget (Lines 698-715)

### Step 3.1 Validation Results
┌────────────────────────────────────────────────┐
│ **All widgets imported successfully?** [ ]    │
│ **Missing widgets:**                           │
│ _____________________________________________  │
│ **Import errors:**                             │
│ _____________________________________________  │
└────────────────────────────────────────────────┘

**Update the LiveView file:**

File: `lib/foundation_web/live/task_dashboard_live.ex`

Replace the entire file with:

```elixir
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
  import FoundationWeb.Components.LayoutWidgets
  
  def mount(_params, _session, socket) do
    # Start with static data
    data_source = :static
    
    socket = 
      socket
      |> assign(:data_source, data_source)
      |> assign(:debug_mode, true)  # Shows data source on widgets
      |> assign_static_data()
      
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
    <div class="p-8">
      <h1 class="text-2xl font-bold">Task Dashboard</h1>
      <p class="mt-4">Static data loaded - ready for UI!</p>
    </div>
    """
  end
end
```

**Quick Test 3.1:**
```bash
mix compile
```

Should compile without errors.

**Browser Test:**
- Refresh http://localhost:4000/task-dashboard
- Page should still load (no change visible yet)

---

### Step 3.2: Build the Dashboard Layout

**What we're doing**: Creating the full dashboard UI with stats and table.

**Update the render function:**

Replace the `render` function in the same file with:

```elixir
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
          <.button_widget variant="primary">
            <Heroicons.plus class="w-4 h-4 mr-2" />
            Add Task
          </.button_widget>
        </div>
        
        <!-- Task Table -->
        <.card_widget span={12}>
          <.table_widget rows={@tasks}>
            <:col label="Title" field={:title}>
              <div>
                <div class="font-medium">{@row.title}</div>
                <div class="text-sm text-base-content/60">{@row.description}</div>
              </div>
            </:col>
            
            <:col label="Status" field={:status}>
              <.badge_widget variant={status_color(@row.status)}>
                {format_status(@row.status)}
              </.badge_widget>
            </:col>
            
            <:col label="Priority" field={:priority}>
              <.badge_widget variant={priority_color(@row.priority)}>
                {format_priority(@row.priority)}
              </.badge_widget>
            </:col>
            
            <:col label="Created" field={:inserted_at}>
              {@row.inserted_at}
            </:col>
          </.table_widget>
        </.card_widget>
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
```

**Quick Test 3.2:**
```bash
mix compile
```

**Browser Test:**
1. Refresh http://localhost:4000/task-dashboard
2. You should now see:
   - Task Manager Dashboard header
   - 4 statistics cards showing numbers
   - A table with 4 sample tasks
   - Each widget should show "static" in the corner (debug mode)

**Take a screenshot:**
```
mcp__puppeteer__puppeteer_navigate url: "http://localhost:4000/task-dashboard"
mcp__puppeteer__puppeteer_screenshot name: "task-dashboard-static-ui"
```

**Common Issues:**
- **"undefined function badge_widget/1"** - Make sure you imported Badge
- **Page looks broken** - Check for missing `</.widget>` closing tags
- **No debug indicators** - Verify `debug_mode={@debug_mode}` is on each stat widget

### ✅ Phase 3 Complete!

You now have:
- A complete dashboard UI with statistics
- A table showing task data
- Visual indicators showing data source (static)
- Styled status and priority badges

---

## Phase 4: Create Task Form

> **Goal**: Add a form widget for creating new tasks

### Step 4.1: Add Modal State

**What we're doing**: Adding the ability to show/hide a modal with our form.

**Update the mount function:**

In `lib/foundation_web/live/task_dashboard_live.ex`, update the mount function:

```elixir
  def mount(_params, _session, socket) do
    # Start with static data
    data_source = :static
    
    socket = 
      socket
      |> assign(:data_source, data_source)
      |> assign(:debug_mode, true)
      |> assign(:show_task_modal, false)  # <-- Add this line
      |> assign_static_data()
      
    {:ok, socket}
  end
```

---

### Step 4.2: Import Modal Widget

**Add to the imports section** (at the top with other imports):

```elixir
  import FoundationWeb.Components.Widgets.Modal
```

---

### Step 4.3: Create Task Form Widget

**What we're doing**: Creating a reusable form widget for tasks.

**Create new file:**

File: `lib/foundation_web/components/widgets/task_form.ex`

```elixir
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
            field={@form[:title]}
            label="Task Title"
            placeholder="Enter task title"
            required={true}
          />
        </div>
        
        <!-- Description Field -->
        <div>
          <.input_widget
            field={@form[:description]}
            label="Description"
            type="textarea"
            placeholder="Describe the task (optional)"
            rows="3"
          />
        </div>
        
        <!-- Status Field -->
        <div>
          <.input_widget
            field={@form[:status]}
            label="Status"
            type="select"
            options={[
              {"Pending", :pending},
              {"In Progress", :in_progress},
              {"Completed", :completed}
            ]}
          />
        </div>
        
        <!-- Priority Field -->
        <div>
          <.input_widget
            field={@form[:priority]}
            label="Priority"
            type="select"
            options={[
              {"Low", :low},
              {"Medium", :medium},
              {"High", :high},
              {"Urgent", :urgent}
            ]}
          />
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
```

**Quick Test 4.3:**
```bash
mix compile
```

---

### Step 4.4: Add Form and Modal to Dashboard

**What we're doing**: Integrating the form into our dashboard with a modal.

**Update the LiveView file:**

1. **Add import** at the top with other imports:
```elixir
  import FoundationWeb.Components.Widgets.TaskForm
```

2. **Create a simple form** - Add this function after `assign_static_data`:
```elixir
  defp create_task_form() do
    # Create a simple form with default values
    %{
      "title" => "",
      "description" => "",
      "status" => "pending",
      "priority" => "medium"
    }
  end
```

3. **Add event handlers** - Add these after the render function:
```elixir
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
  def handle_event("validate_task", %{"task" => params}, socket) do
    {:noreply, assign(socket, :task_form, params)}
  end
  
  # Handle form submission
  def handle_event("save_task", %{"task" => params}, socket) do
    # For now, just close the modal
    # We'll implement actual saving in Phase 5
    IO.puts("Task would be saved: #{inspect(params)}")
    
    {:noreply, assign(socket, :show_task_modal, false)}
  end
```

4. **Update the Add Task button** - Find this button in the render function:
```elixir
<.button_widget variant="primary">
  <Heroicons.plus class="w-4 h-4 mr-2" />
  Add Task
</.button_widget>
```

Replace it with:
```elixir
<.button_widget variant="primary" phx-click="open_task_modal">
  <Heroicons.plus class="w-4 h-4 mr-2" />
  Add Task
</.button_widget>
```

5. **Add the modal** - Add this right before the closing `</div>` in the render function:
```elixir
        <!-- Task Creation Modal -->
        <.modal_widget 
          :if={@show_task_modal} 
          id="task-modal"
          on_close="close_modal"
          title="Create New Task"
        >
          <.task_form_widget 
            form={to_form(@task_form || create_task_form(), as: :task)}
            data_source={@data_source}
            debug_mode={@debug_mode}
          />
        </.modal_widget>
      </.grid_layout>
    </div>
    """
  end
```

**Quick Test 4.4:**
```bash
mix compile
```

**Browser Test:**
1. Refresh http://localhost:4000/task-dashboard
2. Click the "Add Task" button
3. A modal should appear with:
   - Form fields for title, description, status, priority
   - Cancel and Create Task buttons
   - Debug indicator showing "Form: static"
4. Fill in some values
5. Click Cancel - modal should close
6. Click Add Task again, click outside modal - should close

**Take a screenshot:**
```
mcp__puppeteer__puppeteer_navigate url: "http://localhost:4000/task-dashboard"
# Click Add Task button first
mcp__puppeteer__puppeteer_click selector: "button:has-text('Add Task')"
# Then screenshot
mcp__puppeteer__puppeteer_screenshot name: "task-form-modal"
```

### ✅ Phase 4 Complete!

You now have:
- A working modal system
- A complete task form with all fields
- Form opens and closes properly
- Static form data handling

---

## Phase 5: Connect to Ash

> **Goal**: Switch from static data to real Ash resources

### Step 5.1: Update WidgetData Module

**What we're doing**: Adding functions to fetch task data from Ash.

**Update the file:**

File: `lib/foundation_web/widget_data.ex`

Add these functions at the end of the module (before the final `end`):

```elixir
  @doc """
  Fetch task statistics from the database
  """
  def fetch_task_statistics do
    tasks = Foundation.TaskManager.Task.read!()
    
    %{
      total_tasks: length(tasks),
      completed_tasks: Enum.count(tasks, & &1.status == :completed),
      in_progress_tasks: Enum.count(tasks, & &1.status == :in_progress),
      urgent_tasks: Enum.count(tasks, & &1.priority == :urgent)
    }
  end
  
  @doc """
  Fetch recent tasks from the database
  """
  def fetch_recent_tasks do
    Foundation.TaskManager.Task
    |> Ash.Query.sort(inserted_at: :desc)
    |> Ash.Query.limit(20)
    |> Ash.read!()
  end
  
  @doc """
  Assign task data to socket
  """
  def assign_task_data(socket, :static) do
    # Return socket unchanged for static data
    socket
  end
  
  def assign_task_data(socket, :ash) do
    stats = fetch_task_statistics()
    tasks = fetch_recent_tasks()
    
    socket
    |> Phoenix.Component.assign(:tasks, tasks)
    |> Phoenix.Component.assign(:total_tasks, stats.total_tasks)
    |> Phoenix.Component.assign(:completed_tasks, stats.completed_tasks)
    |> Phoenix.Component.assign(:in_progress_tasks, stats.in_progress_tasks)
    |> Phoenix.Component.assign(:urgent_tasks, stats.urgent_tasks)
  end
```

**Quick Test 5.1:**
```bash
# In IEx
iex -S mix
FoundationWeb.WidgetData.fetch_task_statistics()
```

**Expected output:**
```elixir
%{
  total_tasks: 1,
  completed_tasks: 0,
  in_progress_tasks: 0,
  urgent_tasks: 0
}
```

Exit IEx with `Ctrl+C` twice.

---

### Step 5.2: Create Ash Form

**What we're doing**: Using AshPhoenix.Form for proper form handling.

**Update the LiveView file:**

File: `lib/foundation_web/live/task_dashboard_live.ex`

1. **Replace the create_task_form function:**
```elixir
  defp create_task_form() do
    Foundation.TaskManager.Task
    |> AshPhoenix.Form.for_create(:create)
  end
```

2. **Update the mount function** to use Ash data:
```elixir
  def mount(_params, _session, socket) do
    # Switch to Ash data
    data_source = :ash  # <-- Changed from :static
    
    socket = 
      socket
      |> assign(:data_source, data_source)
      |> assign(:debug_mode, true)
      |> assign(:show_task_modal, false)
      |> load_task_data(data_source)  # <-- Changed this line
      
    {:ok, socket}
  end
```

3. **Replace assign_static_data** with load_task_data:
```elixir
  defp load_task_data(socket, :static) do
    assign_static_data(socket)
  end
  
  defp load_task_data(socket, :ash) do
    WidgetData.assign_task_data(socket, :ash)
  end
```

4. **Update the validate_task handler:**
```elixir
  def handle_event("validate_task", %{"task" => params}, socket) do
    form = 
      socket.assigns.task_form
      |> AshPhoenix.Form.validate(params)
    
    {:noreply, assign(socket, :task_form, form)}
  end
```

5. **Update the save_task handler:**
```elixir
  def handle_event("save_task", %{"task" => params}, socket) do
    form = 
      socket.assigns.task_form
      |> AshPhoenix.Form.validate(params)
    
    case AshPhoenix.Form.submit(form) do
      {:ok, _task} ->
        # Reload the data to show the new task
        socket = 
          socket
          |> load_task_data(socket.assigns.data_source)
          |> assign(:show_task_modal, false)
          |> put_flash(:info, "Task created successfully!")
        
        {:noreply, socket}
        
      {:error, form} ->
        {:noreply, assign(socket, :task_form, form)}
    end
  end
```

6. **Fix the form formatting** in the render function:

Find this line in the modal:
```elixir
form={to_form(@task_form || create_task_form(), as: :task)}
```

Replace with:
```elixir
form={@task_form || create_task_form()}
```

**Quick Test 5.2:**
```bash
mix compile
```

**Browser Test:**
1. Refresh http://localhost:4000/task-dashboard
2. You should see:
   - Real task data (the test task we created earlier)
   - Statistics reflecting actual database counts
   - Debug indicators now show "ash" instead of "static"

---

### Step 5.3: Test Creating Tasks

**Browser Test:**
1. Click "Add Task"
2. Fill in:
   - Title: "My first UI task"
   - Description: "Created from the dashboard"
   - Status: Pending
   - Priority: High
3. Click "Create Task"
4. The modal should close
5. The new task should appear in the table
6. Statistics should update

**Take a screenshot:**
```
mcp__puppeteer__puppeteer_navigate url: "http://localhost:4000/task-dashboard"
mcp__puppeteer__puppeteer_screenshot name: "task-dashboard-with-ash-data"
```

**Verify in IEx:**
```bash
iex -S mix
Foundation.TaskManager.Task.read!() |> length()
# Should show 2 or more tasks
```

### Phase 5 Overall Validation Results
┌────────────────────────────────────────────────┐
│ **ASH INTEGRATION WORKS?** [ ] Yes [ ] No     │
│                                                │
│ **Key Findings:**                              │
│ [ ] WidgetData module extensible as shown     │
│ [ ] Form creation matches guide pattern       │
│ [ ] Data persistence works                    │
│ [ ] UI updates after operations               │
│                                                │
│ **Guide Gaps Found:**                         │
│ _____________________________________________  │
│ _____________________________________________  │
│                                                │
│ **If this phase failed, could you continue?** │
│ [ ] Yes, with workarounds                     │
│ [ ] No, blocking issue                        │
└────────────────────────────────────────────────┘

### ✅ Phase 5 Complete!

You now have:
- Dashboard showing real data from database
- Working form that creates tasks in database
- Statistics that update after creating tasks
- Proper Ash form validation

---

## Phase 6: Real-time Updates

> **Goal**: Make the UI update automatically across all connected browsers

### Step 6.1: Add PubSub Subscription

**What we're doing**: Setting up the LiveView to listen for updates.

**Update the mount function:**

File: `lib/foundation_web/live/task_dashboard_live.ex`

```elixir
  def mount(_params, _session, socket) do
    # Switch to Ash data
    data_source = :ash
    
    # Subscribe to updates if connected
    if connected?(socket) && data_source == :ash do
      WidgetData.subscribe_to_updates([:task_updates])
    end
    
    socket = 
      socket
      |> assign(:data_source, data_source)
      |> assign(:debug_mode, true)
      |> assign(:show_task_modal, false)
      |> load_task_data(data_source)
      
    {:ok, socket}
  end
```

---

### Step 6.2: Add Broadcast Function

**What we're doing**: Adding ability to notify all connected clients.

**Update WidgetData module:**

File: `lib/foundation_web/widget_data.ex`

Add this function:

```elixir
  @doc """
  Broadcast task updates to all connected clients
  """
  def broadcast_task_update(action) when action in [:created, :updated, :deleted] do
    stats = fetch_task_statistics()
    tasks = fetch_recent_tasks()
    
    data = %{
      tasks: tasks,
      total_tasks: stats.total_tasks,
      completed_tasks: stats.completed_tasks,
      in_progress_tasks: stats.in_progress_tasks,
      urgent_tasks: stats.urgent_tasks,
      action: action
    }
    
    broadcast_update(:task_updates, data)
  end
```

**Quick Test 6.2:**
```bash
mix compile
```

---

### Step 6.3: Add Update Handler

**What we're doing**: Handling incoming updates in the LiveView.

**Add to LiveView file** (after the other handle_event functions):

```elixir
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
```

---

### Step 6.4: Broadcast After Task Creation

**What we're doing**: Triggering updates when tasks are created.

**Update the save_task handler** in LiveView:

```elixir
  def handle_event("save_task", %{"task" => params}, socket) do
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
```

**Quick Test 6.4:**
```bash
mix compile
mix phx.server
```

**Multi-Browser Test:**
1. Open http://localhost:4000/task-dashboard in TWO browser windows
2. Arrange them side by side
3. In Browser 1: Click "Add Task"
4. Fill in:
   - Title: "Real-time test task"
   - Description: "This should appear in both browsers"
5. Click "Create Task"
6. **Both browsers should update immediately!**
7. Browser 2 should show "New task added" notification

**Take screenshots:**
```
# Arrange browsers side by side first
mcp__puppeteer__puppeteer_screenshot name: "real-time-updates-demo"
```

### ✅ Phase 6 Complete!

You now have:
- Real-time updates across all connected browsers
- PubSub broadcasting of changes
- Notifications when tasks are added
- No page refresh needed!

---

## Phase 7: Form Validation

> **Goal**: Add proper validation with user-friendly error messages

### Step 7.1: Add Ash Validations

**What we're doing**: Adding validation rules to the Task resource.

**Update the Task resource:**

File: `lib/foundation/task_manager/task.ex`

Update the create action with validations:

```elixir
    # Custom create action with validations
    create :create do
      accept [:title, :description, :status, :priority]
      
      # Title is required and must be at least 3 characters
      validate length(:title, min: 3) do
        message "must be at least 3 characters long"
      end
      
      # If status is urgent, priority must be high or urgent
      validate fn changeset, _context ->
        status = Ash.Changeset.get_attribute(changeset, :status)
        priority = Ash.Changeset.get_attribute(changeset, :priority)
        
        if status == :urgent && priority not in [:high, :urgent] do
          {:error, field: :priority, message: "must be high or urgent for urgent tasks"}
        else
          :ok
        end
      end
    end
```

**Also update the update action:**

```elixir
    update :update do
      accept [:title, :description, :status, :priority]
      
      # Same validation for title
      validate length(:title, min: 3) do
        message "must be at least 3 characters long"
      end
```

**Quick Test 7.1:**
```bash
mix compile
```

---

### Step 7.2: Display Validation Errors

**What we're doing**: Showing errors in the UI nicely.

**Update the task form widget:**

File: `lib/foundation_web/components/widgets/task_form.ex`

The form fields already handle errors from AshPhoenix.Form! The Input widget component automatically displays validation errors.

**Browser Test:**
1. Refresh http://localhost:4000/task-dashboard
2. Click "Add Task"
3. Try to submit with:
   - Empty title → Should show "is required"
   - Title "Hi" → Should show "must be at least 3 characters long"
   - Valid title → Should save successfully

**Take a screenshot of validation:**
```
mcp__puppeteer__puppeteer_navigate url: "http://localhost:4000/task-dashboard"
mcp__puppeteer__puppeteer_click selector: "button:has-text('Add Task')"
# Try to submit empty form
mcp__puppeteer__puppeteer_click selector: "button:has-text('Create Task')"
mcp__puppeteer__puppeteer_screenshot name: "form-validation-errors"
```

### ✅ Phase 7 Complete!

You now have:
- Server-side validation rules
- User-friendly error messages
- Validation that prevents invalid data
- Clean error display in the form

---

## Testing Guide

### Complete Test Checklist

Run through this entire sequence to verify everything works:

**1. Database Test:**
```bash
iex -S mix
```
```elixir
# Create test task
Foundation.TaskManager.Task.create!(%{
  title: "Database test",
  status: :pending,
  priority: :low
})

# Query tasks
Foundation.TaskManager.Task.read!() |> length()
# Should return the number of tasks
```

**2. Single Browser Test:**
- [ ] Navigate to http://localhost:4000/task-dashboard
- [ ] Verify statistics show correct counts
- [ ] Click "Add Task"
- [ ] Try submitting empty form (should show errors)
- [ ] Fill valid data and submit
- [ ] Verify task appears in table
- [ ] Verify statistics update

**3. Multi-Browser Test:**
- [ ] Open dashboard in two browsers
- [ ] Create task in Browser 1
- [ ] Verify it appears instantly in Browser 2
- [ ] Check notification appears in Browser 2

**4. Validation Test:**
- [ ] Try title with 2 characters (should fail)
- [ ] Try title with 3+ characters (should pass)
- [ ] Leave title empty (should fail)

### Performance Test

Create multiple tasks quickly:
```elixir
# In IEx
for i <- 1..10 do
  Foundation.TaskManager.Task.create!(%{
    title: "Performance test #{i}",
    status: Enum.random([:pending, :in_progress, :completed]),
    priority: Enum.random([:low, :medium, :high, :urgent])
  })
end

# Broadcast update
FoundationWeb.WidgetData.broadcast_task_update(:created)
```

Both browsers should update smoothly.

---

## Troubleshooting

### Common Issues and Solutions

**Issue: "undefined function" errors**
```bash
mix deps.get
mix compile --force
```

**Issue: "module WidgetData is not available"**
- Make sure you saved all file changes
- Run `recompile()` in IEx
- Restart the Phoenix server

**Issue: Real-time updates not working**
- Check browser console for WebSocket errors
- Verify you're using `connected?(socket)` check
- Make sure PubSub is configured in your app

**Issue: Form won't submit**
- Check browser console for JavaScript errors
- Verify form has all required fields
- Check validation errors in the form

**Issue: Database connection errors**
- Verify PostgreSQL is running
- Check database credentials in `config/dev.exs`
- Run `mix ecto.create`

---

## Complete Code Reference

### Final Task Resource
`lib/foundation/task_manager/task.ex`:
[Full code provided in Phase 1 and Phase 7]

### Final LiveView
`lib/foundation_web/live/task_dashboard_live.ex`:
[Complete working code with all phases integrated]

### Final WidgetData additions
`lib/foundation_web/widget_data.ex`:
[All task-related functions added]

---

## Documentation Updates for Main Guide

After completing this proof of concept, add these clarifications to the main guide:

1. **In "Creating Ash Resources" section:**
   - Add note about registering domains in config.exs
   - Include validation examples
   - Show how to use calculations

2. **In "Real-time Updates" section:**
   - Clarify the connected?(socket) check is essential
   - Add example of broadcasting from outside LiveView
   - Show notification handling pattern

3. **In "Form Validation" section:**
   - Add examples of common validations
   - Show how AshPhoenix.Form handles errors automatically
   - Include custom validation example

4. **In "Testing" section:**
   - Add multi-browser testing instructions
   - Include IEx testing commands
   - Add performance testing notes

---

## Final Validation Summary

### Overall Guide Accuracy Assessment

**Guide Title**: LATEST_ASH_AND_UI_IMPLEMENTATION_GUIDE.md

**Test Completion Date**: _________________

**Tester**: _________________

### Executive Summary
┌────────────────────────────────────────────────┐
│ **OVERALL RESULT:** [ ] PASS [ ] FAIL         │
│                                                │
│ **Sections Tested:** _____ / 6                │
│ **Sections Passed:** _____ / 6                │
│ **Critical Blockers:** _____                  │
│ **Minor Issues:** _____                       │
└────────────────────────────────────────────────┘

### Detailed Results by Section

| Section | Works? | Major Issues | Minor Issues | Guide Needs Update? |
|---------|--------|--------------|--------------|---------------------|
| Ash Resources | [ ] | | | [ ] |
| Route Creation | [ ] | | | [ ] |
| Static UI | [ ] | | | [ ] |
| Ash Connection | [ ] | | | [ ] |
| Real-time Updates | [ ] | | | [ ] |
| Form Validation | [ ] | | | [ ] |

### Critical Issues That Block Progress
1. _________________________________________________
2. _________________________________________________
3. _________________________________________________

### Guide Sections That Need Clarification
1. _________________________________________________
2. _________________________________________________
3. _________________________________________________

### Missing Instructions in Guide
1. _________________________________________________
2. _________________________________________________
3. _________________________________________________

### Sections That Worked Perfectly
1. _________________________________________________
2. _________________________________________________
3. _________________________________________________

### Recommended Guide Updates

**High Priority** (Blocking issues):
- [ ] _____________________________________________
- [ ] _____________________________________________

**Medium Priority** (Confusing but workable):
- [ ] _____________________________________________
- [ ] _____________________________________________

**Low Priority** (Nice to have):
- [ ] _____________________________________________
- [ ] _____________________________________________

### Test Environment Details
- Elixir Version: ________________
- Phoenix Version: _______________
- Ash Version: __________________
- PostgreSQL Version: ____________
- OS: ___________________________

### Additional Notes
_____________________________________________________
_____________________________________________________
_____________________________________________________

---

## Validation Completed ✓

**Remember**: The goal was to validate the guide, not build a perfect app. If you found issues, you've succeeded in improving the documentation for future developers!