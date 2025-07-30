# Creating New Routes and Pages - RULES

## ⚠️ IMPORTANT: SCOPE OF THIS DOCUMENT

**This document is ONLY for creating a new route with a new placeholder page.**

- ✅ Creating a new route in the router
- ✅ Creating a new LiveView module with placeholder content
- ✅ Setting up proper authentication (public/private)
- ❌ NO business logic
- ❌ NO fancy UI  
- ❌ NO additional features

**If the user wants anything beyond a basic route + page, that's a SEPARATE task to be done AFTER following these rules.**

## Quick Start

1. **Check current docs**: Use Context7 to look up `/ash-project/ash` and `/phoenixframework/phoenix_live_view` for patterns matching your project versions
2. **Add route**: Edit `lib/foundation_web/router.ex`
3. **Create LiveView**: Add new file in `lib/foundation_web/live/`
4. **Test**: Visit the new route

## Naming Convention

**Route to Module Name Pattern:**
- Route: `/demo-ui-dashboard` → Module: `DemoUiDashboardLive`  
- Route: `/user-settings` → Module: `UserSettingsLive`
- Route: `/admin/reports` → Module: `AdminReportsLive`

**Rules:**
- Convert kebab-case route segments to PascalCase
- Add "Live" suffix
- Remove slashes and join segments
- File path: `lib/foundation_web/live/demo_ui_dashboard_live.ex`

## Step 1: Check Existing Code Patterns

Before creating anything, examine the current project structure:
- Check `lib/foundation_web/router.ex` for routing patterns
- Look at existing LiveView files in `lib/foundation_web/live/` (may need to create this directory)
- Note the authentication setup and scope organization

If you need additional examples beyond what's in the project, use Context7:
- Search `/phoenixframework/phoenix_live_view` for "routing" 
- Search `/ash-project/ash` for "authentication routing"

## Step 2: Add Route to Router

Edit `lib/foundation_web/router.ex`:

### For PRIVATE routes (requires login):
Add inside the `ash_authentication_live_session :authenticated_routes` block:
```elixir
live "/your-path", YourLive
```

### For PUBLIC routes:
Add inside a regular `scope` block:
```elixir
live "/your-path", YourLive
```

## Step 3: Create LiveView Module

Create new file in `lib/foundation_web/live/` directory (create directory if it doesn't exist):

### For PUBLIC pages (no login required):
```elixir
defmodule FoundationWeb.YourLive do
  use FoundationWeb, :live_view
  
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
  
  def render(assigns) do
    ~H"""
    <div class="p-8">
      <h1>Placeholder Page</h1>
      <p>Replace this with actual content later.</p>
    </div>
    """
  end
end
```

### For PRIVATE pages (login required):
```elixir
defmodule FoundationWeb.YourLive do
  use FoundationWeb, :live_view
  
  on_mount {FoundationWeb.LiveUserAuth, :live_user_required}
  
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
  
  def render(assigns) do
    ~H"""
    <div class="p-8">
      <h1>Placeholder Page</h1>
      <p>Replace this with actual content later.</p>
    </div>
    """
  end
end
```

## Directory Structure

Place LiveView files here:
- `lib/foundation_web/live/` - Main LiveView modules  
- `lib/foundation_web/live/your_feature/` - Feature-specific subdirectories

## Authentication Options

Add one of these `on_mount` declarations to your LiveView:

- **Required login**: `on_mount {FoundationWeb.LiveUserAuth, :live_user_required}`
- **Optional login**: `on_mount {FoundationWeb.LiveUserAuth, :live_user_optional}`
- **No user allowed**: `on_mount {FoundationWeb.LiveUserAuth, :live_no_user}`

## Layout Inheritance (Automatic)

DO NOT CHANGE ANY APP.CSS OR ANY OTHER STYLING.

All pages automatically inherit:
- ✅ No horizontal scrolling (even with 3000px content)
- ✅ Responsive design (flex/grid auto-wrap)
- ✅ Consistent background colors
- ✅ Smooth vertical scrolling

This happens automatically via `root.html.heex` and APP.CSS - no setup needed, AND DO NOT MODIFY EITHER OF THOSE.

## Testing Your Route

1. **Compile**: Run `mix compile` to check for syntax errors
2. **Start server**: `mix phx.server` (usually already running at localhost:4000)
3. **Visit route**: `http://localhost:4000/your-path`
4. **Verify**: 
   - Page loads successfully
   - Shows your placeholder content
   - Authentication works as expected (redirects for private routes)
   - No browser console errors

## Troubleshooting & Tips

### Common Issues:
- **`live/` directory doesn't exist**: Create it with `mkdir -p lib/foundation_web/live`
- **Module name mismatch**: Ensure your module name matches the pattern: `FoundationWeb.YourLive` (not `DemostarterWeb`)

### File Naming Examples:
- Route: `/tester-demo` → File: `tester_demo_live.ex` → Module: `TesterDemoLive`
- Route: `/user-profile` → File: `user_profile_live.ex` → Module: `UserProfileLive`  
- Route: `/admin/dashboard` → File: `admin_dashboard_live.ex` → Module: `AdminDashboardLive`

### Router Location:
The route should be added in the **second** `scope "/" FoundationWeb` block (around line 45), NOT in the `ash_authentication_live_session` block unless it requires authentication.

## Remember

This document is ONLY for creating the route + placeholder page. Any additional features, business logic, or UI enhancements are separate tasks to be done AFTER the basic route is working.