# Foundation UI System Guide

## Table of Contents
- [Overview](#overview)
- [Technology Stack](#technology-stack)
- [Core Concepts](#core-concepts)
- [Technical Architecture](#technical-architecture)
- [Widget System](#widget-system)
- [Layout System](#layout-system)
- [Building UIs](#building-uis)
- [Best Practices](#best-practices)
- [Quick Reference](#quick-reference)

## Overview

The Foundation UI System is a custom-built component library that wraps DaisyUI components with consistent spacing, layout rules, and responsive behavior. It's designed to create pixel-perfect, full-screen applications with a focus on desktop-first responsive design.

### Key Features
- **Consistent Spacing**: 4px atomic spacing scale throughout
- **Full-Screen Layouts**: CSS Grid-based, screen-filling designs
- **Widget Pattern**: Wrapped DaisyUI components with layout awareness
- **12-Column Grid**: Flexible, responsive grid system
- **Desktop-First**: Optimized for desktop with graceful mobile degradation
- **Container Queries**: Modern responsive design using Tailwind v4

## Technology Stack

### Core Technologies
- **Phoenix LiveView**: Real-time server-rendered views
- **Tailwind CSS v4**: Utility-first CSS framework with container queries
- **DaisyUI**: Component library providing base styling
- **CSS Grid**: Modern layout system for complex designs

### Architecture Principles
1. **Atomic Spacing**: All spacing uses multiples of 4px
2. **Component Wrapping**: DaisyUI components wrapped with layout containers
3. **Consistent Naming**: All custom components use `_widget` suffix
4. **Full-Width Layouts**: Containers fill the entire viewport
5. **Responsive by Default**: Container queries for adaptive layouts

## Core Concepts

### CRITICAL: Widget-Only Development Philosophy

**The #1 Rule: If you're writing HTML with classes, you're doing it wrong.**

Every visual element in the Foundation UI system should be a pre-wrapped widget. This ensures:
- Consistent styling across the entire application
- Design system enforcement without thinking
- Zero need to know Tailwind classes
- Changes can be made in one place
- True "lego brick" development

Examples:
```elixir
# ❌ WRONG - Raw HTML with classes
<div class="text-3xl font-bold">$89,432</div>
<div class="text-sm text-success">+12% this month</div>

# ✅ RIGHT - Using a widget
<.stat_widget value="$89,432" change="+12%" change_label="this month" trend="up" />
```

### 1. The 4px Atomic Spacing Scale

All spacing in the system is based on a 4px unit. This creates visual harmony and consistency.

```
1  = 4px    (tight spacing)
2  = 8px    (compact spacing)
3  = 12px   (comfortable spacing)
4  = 16px   (default spacing)
5  = 20px   (relaxed spacing)
6  = 24px   (spacious)
8  = 32px   (section spacing)
10 = 40px   (large spacing)
12 = 48px   (extra large)
16 = 64px   (huge spacing)
20 = 80px   (massive spacing)
24 = 96px   (maximum spacing)
```

### 2. The Widget Pattern

Widgets are wrapped DaisyUI components that:
- Enforce consistent spacing rules
- Provide grid-aware layouts
- Handle responsive behavior
- Maintain visual consistency

Example:
```elixir
# Instead of a raw DaisyUI button:
<button class="btn btn-primary">Click me</button>

# Use a widget:
<.button_widget span={3} align="center">Click me</.button_widget>
```

### 3. The 12-Column Grid System

All layouts use a 12-column grid:
- Components can span 1-12 columns
- Gaps between columns use the spacing scale
- Responsive gaps adjust at breakpoints
- Nested grids maintain consistency

### 4. Full-Screen Layouts

Layouts always fill the viewport:
- `min-height: 100vh` on containers
- No unnecessary scrollbars
- Content expands to fill space
- Proper overflow handling

## Technical Architecture

### CSS File Structure

```
assets/css/
├── app.css           # Main CSS file with imports
├── spacing.css       # CSS custom properties for spacing
├── layouts.css       # Grid and layout utilities
└── theme-overrides.css # DaisyUI customizations
```

### Component Structure

```
lib/foundation_web/components/
├── core_components.ex    # Legacy components (deprecated)
├── widgets.ex           # Base widget module
├── layout_widgets.ex    # Layout components
├── layout_helpers.ex    # Utility functions
└── widgets/
    ├── button.ex        # Button widget
    ├── card.ex          # Card widget
    ├── input.ex         # Input widget
    ├── form.ex          # Form widget
    ├── list.ex          # List widget
    ├── table.ex         # Table widget
    ├── modal.ex         # Modal widget
    └── navigation.ex    # Navigation widget
```

### Import Structure

All widgets are imported in `core_components.ex`:
```elixir
import FoundationWeb.Components.Widgets
import FoundationWeb.Components.Widgets.{Button, Card, Input, Form, List, Table, Modal, Navigation}
import FoundationWeb.Components.Widgets.{Heading, Stat, Badge, Placeholder, StatRow}
import FoundationWeb.Components.LayoutWidgets
```

## Widget System

### Available Widgets

#### 1. Button Widget (`button_widget`)
Wrapped button with optional grid awareness and alignment.

**Attributes:**
- `variant`: "primary" | "secondary" | "accent" | "ghost" | "link"
- `size`: "sm" | "md" | "lg"
- `span`: 1-12 (optional - when omitted, no wrapper div is created)
- `align`: "start" | "center" | "end" (only applies when span is set)
- `class`: Additional CSS classes (e.g., "w-full" for full width)

**Examples:**
```elixir
# With grid span
<.button_widget span={4} align="center" variant="primary">
  Save Changes
</.button_widget>

# Without span (no wrapper div)
<.button_widget variant="secondary" class="w-full">
  Cancel
</.button_widget>
```

#### 2. Card Widget (`card_widget`)
Container with optional header and actions.

**Attributes:**
- `span`: 1-12 (default: 4)
- `padding`: spacing scale value (default: 6)
- Slots: `:header`, `:inner_block`, `:actions`

**Example:**
```elixir
<.card_widget span={6}>
  <:header>User Statistics</:header>
  <p>Total users: 1,234</p>
  <:actions>
    <.button_widget size="sm">View Details</.button_widget>
  </:actions>
</.card_widget>
```

#### 3. Input Widget (`input_widget`)
Form input with label and error handling.

**Attributes:**
- `span`: 1-12 (default: 12)
- `label`: Input label text
- `name`: Input name attribute
- `type`: Input type (default: "text")
- `error`: Error message

**Example:**
```elixir
<.input_widget 
  span={6} 
  label="Email Address" 
  name="email" 
  type="email"
  error={@errors[:email]}
/>
```

#### 4. Form Widget (`form_widget`)
Form container with grid layout.

**Attributes:**
- `for`: Phoenix form struct
- `columns`: Number of columns (default: 1)
- `gap`: Spacing between fields (default: 6)

**Example:**
```elixir
<.form_widget for={@form} columns={2} gap={4}>
  <.input_widget label="First Name" name="first_name" />
  <.input_widget label="Last Name" name="last_name" />
  <.input_widget span={12} label="Email" name="email" type="email" />
</.form_widget>
```

#### 5. List Widget (`list_widget`)
Flexible list container.

**Attributes:**
- `span`: 1-12 (default: 12)
- `spacing`: Gap between items (default: 3)
- `direction`: "vertical" | "horizontal"

**Example:**
```elixir
<.list_widget spacing={4} direction="vertical">
  <:item>First item</:item>
  <:item>Second item</:item>
  <:item>Third item</:item>
</.list_widget>
```

#### 6. Table Widget (`table_widget`)
Responsive table with consistent spacing.

**Attributes:**
- `span`: 1-12 (default: 12)
- `id`: Table ID
- `rows`: List of row data
- Slot `:col` with `label` and optional `width`

**Example:**
```elixir
<.table_widget id="users-table" rows={@users} span={12}>
  <:col label="Name" width="w-1/3">
    <%= row.name %>
  </:col>
  <:col label="Email" width="w-1/3">
    <%= row.email %>
  </:col>
  <:col label="Status" width="w-1/3">
    <%= row.status %>
  </:col>
</.table_widget>
```

#### 7. Modal Widget (`modal_widget`)
Dialog modal with backdrop.

**Attributes:**
- `id`: Modal ID for JavaScript control
- `title`: Modal title
- `max_width`: Maximum width (default: "max-w-2xl")
- `padding`: Internal padding (default: 6)

**Example:**
```elixir
<.modal_widget id="edit-modal" title="Edit User">
  <.form_widget for={@form}>
    <.input_widget label="Name" name="name" />
  </.form_widget>
  <:actions>
    <.button_widget variant="primary">Save</.button_widget>
  </:actions>
</.modal_widget>
```

#### 8. Navigation Widget (`navigation_widget`)
Vertical sidebar navigation (optimized for dashboard layouts).

**Attributes:**
- `brand`: Brand/logo text
- Slot `:nav_item` with `path` and `active` attributes
- Slot `:actions` for bottom actions

**Example:**
```elixir
<.navigation_widget brand="My Dashboard">
  <:nav_item path="/dashboard" active>Dashboard</:nav_item>
  <:nav_item path="/users">Users</:nav_item>
  <:nav_item path="/settings">Settings</:nav_item>
  <:actions>
    <.button_widget size="sm" variant="ghost">Profile</.button_widget>
  </:actions>
</.navigation_widget>
```

#### 9. Heading Widget (`heading_widget`)
Consistent page and section headings with automatic spacing.

**Attributes:**
- `variant`: "page" | "section" | "subsection" (default: "page")
- `span`: 1-12 (default: 12)
- Slot `:description` for optional subtitle

**Example:**
```elixir
<.heading_widget variant="page">
  Dashboard Overview
  <:description>
    Welcome back! Here's what's happening with your business.
  </:description>
</.heading_widget>
```

#### 10. Stat Widget (`stat_widget`)
KPI and metric displays with automatic formatting.

**Attributes:**
- `value`: Main value to display (required)
- `label`: Optional label above value
- `change`: Change indicator (e.g., "+12%")
- `change_label`: Label for change (e.g., "this month")
- `trend`: "up" | "down" | "neutral" (affects color)
- `size`: "sm" | "md" | "lg" (default: "md")
- `span`: Grid columns to span (optional)

**Example:**
```elixir
<.stat_widget 
  value="$89,432"
  label="Total Revenue"
  change="+12%"
  change_label="this month"
  trend="up"
/>
```

#### 11. Badge Widget (`badge_widget`)
Status indicators and labels with consistent styling.

**Attributes:**
- `variant`: "success" | "error" | "warning" | "info" | "primary" | "secondary" | "accent" | "neutral" (default: "neutral")
- `size`: "xs" | "sm" | "md" | "lg" (default: "md")
- `outline`: Boolean for outline style (default: false)

**Example:**
```elixir
<.badge_widget variant="success">Active</.badge_widget>
<.badge_widget variant="warning" outline>Pending</.badge_widget>
```

#### 12. Placeholder Widget (`placeholder_widget`)
Content placeholders for empty states or loading.

**Attributes:**
- `height`: "sm" | "md" | "lg" | "xl" (default: "md")
- `span`: 1-12 (default: 12)
- `icon`: Optional Heroicon name

**Example:**
```elixir
<.placeholder_widget height="lg" icon="hero-chart-bar">
  Chart visualization would go here
</.placeholder_widget>
```

#### 13. Stat Row Widget (`stat_row_widget`)
Label/value pairs for lists and tables.

**Attributes:**
- `label`: Left-aligned label (required)
- `value`: Right-aligned value (required)
- `size`: "sm" | "md" | "lg" (default: "md")

**Example:**
```elixir
<.list_widget>
  <:item>
    <.stat_row_widget label="Free Tier" value="892" />
  </:item>
  <:item>
    <.stat_row_widget label="Pro Plan" value="387" />
  </:item>
</.list_widget>
```

## Layout System

### Layout Components

#### 1. Grid Layout (`grid_layout`)
Full-screen 12-column grid container.

**Usage:**
```elixir
<.grid_layout>
  <.card_widget span={4}>Card 1</.card_widget>
  <.card_widget span={4}>Card 2</.card_widget>
  <.card_widget span={4}>Card 3</.card_widget>
</.grid_layout>
```

#### 2. Dashboard Layout (`dashboard_layout`)
Fixed sidebar (280px) + main content layout using CSS Grid.

**Features:**
- Fixed 280px sidebar width
- Sidebar has `bg-base-200` background
- Main content area is scrollable
- Uses `grid-cols-[280px_1fr]` for proper layout

**Usage:**
```elixir
<.dashboard_layout>
  <:sidebar>
    <.navigation_widget brand="Dashboard">
      <:nav_item path="/dashboard" active>Dashboard</:nav_item>
      <:nav_item path="/users">Users</:nav_item>
    </.navigation_widget>
  </:sidebar>
  
  <.grid_layout>
    <!-- main content with 12-column grid -->
  </.grid_layout>
</.dashboard_layout>
```

#### 3. Centered Layout (`centered_layout`)
Centers content with max width.

**Usage:**
```elixir
<.centered_layout max_width="max-w-2xl">
  <.card_widget span={12}>
    <:header>Welcome</:header>
    <p>Centered content here</p>
  </.card_widget>
</.centered_layout>
```

### Responsive Behavior

The system uses container queries for responsive design:

```css
@container (min-width: 768px)  /* Tablet */
@container (min-width: 1024px) /* Desktop */
@container (min-width: 1440px) /* Wide desktop */
```

Grid gaps automatically adjust:
- Mobile: `gap: var(--space-6)` (24px)
- Tablet: `gap: var(--space-8)` (32px)
- Desktop: `gap: var(--space-10)` (40px)

## Building UIs

### Widget-Only Development Example

Here's a complete dashboard built using ONLY widgets - no raw HTML:

```elixir
<.dashboard_layout>
  <:sidebar>
    <.navigation_widget brand="SaaSy Dashboard">
      <:nav_item path="/dashboard" active>Dashboard</:nav_item>
      <:nav_item path="/customers">Customers</:nav_item>
      <:nav_item path="/analytics">Analytics</:nav_item>
      <:actions>
        <.button_widget size="sm" variant="ghost">Profile</.button_widget>
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
    
    <!-- KPI Cards Row -->
    <.card_widget span={3}>
      <:header>Total Revenue</:header>
      <.stat_widget 
        value="$89,432"
        change="+12%"
        change_label="this month"
        trend="up"
      />
    </.card_widget>
    
    <.card_widget span={3}>
      <:header>Active Users</:header>
      <.stat_widget 
        value="1,892"
        change="+8%"
        change_label="this month"
        trend="up"
      />
    </.card_widget>
    
    <!-- Activity Table -->
    <.card_widget span={8}>
      <:header>Recent Activity</:header>
      <.table_widget id="activity" rows={@activities}>
        <:col label="Time"><%= row.time %></:col>
        <:col label="User"><%= row.user %></:col>
        <:col label="Status">
          <.badge_widget variant={badge_variant(row.status)}>
            <%= row.status %>
          </.badge_widget>
        </:col>
      </.table_widget>
    </.card_widget>
    
    <!-- User Stats -->
    <.card_widget span={4}>
      <:header>User Statistics</:header>
      <.list_widget spacing={2}>
        <:item>
          <.stat_row_widget label="Free Tier" value="892" />
        </:item>
        <:item>
          <.stat_row_widget label="Pro Plan" value="387" />
        </:item>
      </.list_widget>
      <:actions>
        <.button_widget size="sm" variant="primary">View Details</.button_widget>
      </:actions>
    </.card_widget>
  </.grid_layout>
</.dashboard_layout>
```

Notice: **Zero raw HTML elements**. Everything is a widget!

### Basic Page Structure

```elixir
defmodule MyAppWeb.PageLive do
  use MyAppWeb, :live_view
  
  def render(assigns) do
    ~H"""
    <.grid_layout>
      <!-- Header -->
      <div class="span-12 mb-8">
        <h1 class="text-3xl font-bold">Page Title</h1>
      </div>
      
      <!-- Content cards -->
      <.card_widget span={4}>
        <:header>Section 1</:header>
        <p>Content here</p>
      </.card_widget>
      
      <.card_widget span={8}>
        <:header>Main Content</:header>
        <p>More content</p>
      </.card_widget>
    </.grid_layout>
    """
  end
end
```

### Form Page Example

```elixir
<.centered_layout>
  <.card_widget span={12}>
    <:header>User Registration</:header>
    
    <.form_widget for={@form} columns={2} gap={4}>
      <.input_widget label="First Name" name="first_name" />
      <.input_widget label="Last Name" name="last_name" />
      <.input_widget span={12} label="Email" name="email" type="email" />
      <.input_widget span={12} label="Password" name="password" type="password" />
      
      <div class="span-12 flex justify-end gap-4 mt-6">
        <.button_widget variant="ghost">Cancel</.button_widget>
        <.button_widget variant="primary">Register</.button_widget>
      </div>
    </.form_widget>
  </.card_widget>
</.centered_layout>
```

### Dashboard Example

```elixir
<.dashboard_layout>
  <:sidebar>
    <.navigation_widget brand="Analytics">
      <:nav_item path="/dashboard" active>Overview</:nav_item>
      <:nav_item path="/users">Users</:nav_item>
      <:nav_item path="/reports">Reports</:nav_item>
    </.navigation_widget>
  </:sidebar>
  
  <.grid_layout>
    <!-- KPI Cards -->
    <.card_widget span={3}>
      <:header>Total Users</:header>
      <div class="text-3xl font-bold">1,234</div>
      <div class="text-sm text-base-content/70">+12% this month</div>
    </.card_widget>
    
    <.card_widget span={3}>
      <:header>Revenue</:header>
      <div class="text-3xl font-bold">$45,678</div>
      <div class="text-sm text-base-content/70">+8% this month</div>
    </.card_widget>
    
    <!-- Main content -->
    <.card_widget span={12}>
      <:header>Recent Activity</:header>
      <.table_widget id="activity" rows={@activities}>
        <!-- table columns -->
      </.table_widget>
    </.card_widget>
  </.grid_layout>
</.dashboard_layout>
```

## Best Practices

### 1. Use Widgets for Everything
```elixir
# ❌ NEVER write raw HTML
<h1 class="text-3xl font-bold">Page Title</h1>
<div class="text-sm text-success">+12% growth</div>
<span class="badge badge-success">Active</span>

# ✅ ALWAYS use widgets
<.heading_widget variant="page">Page Title</.heading_widget>
<.stat_widget value="156" change="+12%" trend="up" />
<.badge_widget variant="success">Active</.badge_widget>
```

### 2. Common Widget Patterns
```elixir
# Buttons in grids - use class="w-full" instead of span
<div class="grid grid-cols-2 gap-4">
  <.button_widget variant="primary" class="w-full">Save</.button_widget>
  <.button_widget variant="secondary" class="w-full">Cancel</.button_widget>
</div>

# Status badges in tables
<.table_widget rows={@users}>
  <:col label="Status" :let={row}>
    <.badge_widget variant={status_variant(row.status)}>
      <%= row.status %>
    </.badge_widget>
  </:col>
</.table_widget>

# KPI cards with stats
<.card_widget span={3}>
  <:header>Revenue</:header>
  <.stat_widget value="$45,678" change="+8%" trend="up" />
</.card_widget>
```

### 3. Always Use the Spacing Scale
```elixir
# ❌ Don't use arbitrary values
<div class="p-7">Content</div>

# ✅ Use spacing scale values  
<.card_widget padding={8}>Content</.card_widget>  <!-- 32px -->
```

### 2. Specify Grid Spans
```elixir
# ❌ Don't rely on default spans
<.card_widget>Content</.card_widget>

# ✅ Be explicit about layout
<.card_widget span={4}>Content</.card_widget>
```

### 3. Use Semantic Widgets
```elixir
# ❌ Don't use raw DaisyUI components
<button class="btn btn-primary">Save</button>

# ✅ Use widget wrappers
<.button_widget variant="primary">Save</.button_widget>
```

### 4. Maintain Visual Hierarchy
- Use consistent spacing between sections
- Group related content in cards
- Maintain alignment across grid columns
- Use appropriate heading sizes

### 5. Handle Responsive Design
- Design for desktop first
- Test at container query breakpoints
- Ensure content remains readable on mobile
- Use appropriate span values for different sizes

### 6. Form Best Practices
- Group related fields
- Use appropriate input types
- Provide clear labels
- Show validation errors inline
- Use consistent button placement

## Quick Reference

### Spacing Scale Cheat Sheet
```
p-1  = 4px     p-5  = 20px    p-12 = 48px
p-2  = 8px     p-6  = 24px    p-16 = 64px
p-3  = 12px    p-8  = 32px    p-20 = 80px
p-4  = 16px    p-10 = 40px    p-24 = 96px
```

### Grid Spans
```
span-1  = 8.33%    span-6  = 50%
span-2  = 16.66%   span-8  = 66.66%
span-3  = 25%      span-12 = 100%
span-4  = 33.33%
```

### Common Patterns
```elixir
# Three-column layout
<.card_widget span={4}>...</.card_widget>
<.card_widget span={4}>...</.card_widget>
<.card_widget span={4}>...</.card_widget>

# Two-column with sidebar
<.card_widget span={3}>Sidebar</.card_widget>
<.card_widget span={9}>Main content</.card_widget>

# Full-width section
<.card_widget span={12}>...</.card_widget>

# Centered form
<.centered_layout max_width="max-w-xl">
  <.form_widget>...</.form_widget>
</.centered_layout>
```

### Widget Import
Add to your LiveView or component:
```elixir
use MyAppWeb, :live_view
# All widgets are automatically imported via core_components
```

## Migration Guide

### From core_components to Widgets

```elixir
# Old approach
<.button type="submit" phx-disable-with="Saving...">
  Save
</.button>

# New approach
<.button_widget 
  type="submit" 
  phx-disable-with="Saving..."
  span={3}
  align="end"
>
  Save
</.button_widget>
```

### Creating New Widgets

1. Create file in `lib/foundation_web/components/widgets/`
2. Define module with `use Phoenix.Component`
3. Include standard attributes: `span`, `class`, `rest`
4. Wrap content in a grid-aware container
5. Add to widgets.ex imports
6. Document with examples

Example new widget:
```elixir
defmodule FoundationWeb.Components.Widgets.Alert do
  use Phoenix.Component
  
  attr :variant, :string, default: "info"
  attr :span, :integer, default: 12
  attr :dismissible, :boolean, default: false
  attr :class, :string, default: ""
  slot :inner_block, required: true
  
  def alert_widget(assigns) do
    ~H"""
    <div class={[
      "span-#{@span}",
      "alert",
      "alert-#{@variant}",
      @class
    ]}>
      {render_slot(@inner_block)}
      <button :if={@dismissible} class="btn btn-sm btn-circle btn-ghost">
        ✕
      </button>
    </div>
    """
  end
end
```

## Troubleshooting

### Common Issues

1. **Widgets not available**
   - Ensure imports are in `core_components.ex`
   - Check module naming matches convention

2. **Spacing looks wrong**
   - Verify using spacing scale values
   - Check CSS imports in app.css
   - Ensure no conflicting styles

3. **Layout breaking**
   - Check total span doesn't exceed 12
   - Verify grid container is present
   - Test at different screen sizes

4. **Responsive issues**
   - Use container queries, not media queries
   - Test at defined breakpoints
   - Consider mobile span adjustments

## Summary

The Foundation UI System provides a consistent, maintainable way to build Phoenix LiveView applications. By following the widget pattern and spacing scale, developers can create pixel-perfect layouts that work across all screen sizes. The system's opinions about spacing, layout, and component structure ensure visual consistency while remaining flexible enough for diverse use cases.

Remember: When in doubt, refer to the spacing scale, use the appropriate widget, and maintain the 12-column grid structure. Happy building!