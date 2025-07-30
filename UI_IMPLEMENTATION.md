# Custom UI System Implementation Plan for Phoenix/LiveView with Tailwind v4 & DaisyUI

## Overview
This plan implements a custom UI system based on your requirements:
- Full-width, screen-filling layouts using CSS Grid
- Consistent spacing with atomic units (4px scale)
- Wrapped DaisyUI components called "widgets"
- Desktop-first responsive design using Tailwind v4
- Pixel-perfect, proportional layouts
- Testing checkpoints at each implementation step

## Step-by-Step Implementation Plan

### Phase 1: Foundation Setup (Spacing & Layout Constants)

#### 1. Create spacing configuration file
- **Path**: `assets/css/spacing.css`
- **Implementation**:
  ```css
  :root {
    /* 4px atomic spacing scale */
    --space-1: 4px;
    --space-2: 8px;
    --space-3: 12px;
    --space-4: 16px;
    --space-5: 20px;
    --space-6: 24px;
    --space-8: 32px;
    --space-10: 40px;
    --space-12: 48px;
    --space-16: 64px;
    --space-20: 80px;
    --space-24: 96px;
  }
  ```
- **Test**: Create a simple HTML file with divs using these spacing variables and verify measurements in browser DevTools

#### 2. Create base layout system
- **Path**: `assets/css/layouts.css`
- **Implementation**:
  ```css
  /* Full-screen grid container */
  .layout-full {
    display: grid;
    min-height: 100vh;
    width: 100%;
  }

  /* 12-column grid system */
  .grid-12 {
    display: grid;
    grid-template-columns: repeat(12, 1fr);
    gap: var(--space-6);
  }

  /* Container queries */
  @container (min-width: 768px) {
    .grid-12 { gap: var(--space-8); }
  }

  @container (min-width: 1024px) {
    .grid-12 { gap: var(--space-10); }
  }

  /* Grid span utilities */
  .span-1 { grid-column: span 1; }
  .span-2 { grid-column: span 2; }
  .span-3 { grid-column: span 3; }
  .span-4 { grid-column: span 4; }
  .span-6 { grid-column: span 6; }
  .span-8 { grid-column: span 8; }
  .span-12 { grid-column: span 12; }
  ```
- **Test**: Create a test page with a full-screen grid layout, verify it fills viewport without scrollbars

#### 3. Update app.css imports
- **Path**: `assets/css/app.css`
- **Add after Tailwind imports**:
  ```css
  @import "./spacing.css";
  @import "./layouts.css";
  ```
- **Test**: Run `mix phx.server` and check browser console for CSS errors, verify spacing variables are accessible

### Phase 2: Widget System (Component Wrappers)

#### 4. Create base widget module
- **Path**: `lib/foundation_web/components/widgets.ex`
- **Implementation**:
  ```elixir
  defmodule FoundationWeb.Components.Widgets do
    use Phoenix.Component

    @doc """
    Base widget wrapper that enforces layout rules
    """
    attr :span, :integer, default: 12, doc: "Grid columns to span (1-12)"
    attr :padding, :integer, default: 4, doc: "Padding using spacing scale"
    attr :gap, :integer, default: 4, doc: "Gap between child elements"
    attr :class, :string, default: ""
    slot :inner_block, required: true

    def widget_wrapper(assigns) do
      ~H"""
      <div class={[
        "span-#{@span}",
        "p-#{@padding}",
        "gap-#{@gap}",
        @class
      ]}>
        {render_slot(@inner_block)}
      </div>
      """
    end
  end
  ```
- **Test**: Create a simple widget that wraps a div, render it in a LiveView page, verify it applies spacing correctly

#### 5. Create Button Widget
- **Path**: `lib/foundation_web/components/widgets/button.ex`
- **Implementation**:
  ```elixir
  defmodule FoundationWeb.Components.Widgets.Button do
    use Phoenix.Component
    
    attr :variant, :string, default: "primary"
    attr :size, :string, default: "md"
    attr :span, :integer, default: nil
    attr :align, :string, default: "start"
    attr :class, :string, default: ""
    attr :rest, :global
    slot :inner_block, required: true

    def button_widget(assigns) do
      ~H"""
      <div class={[
        @span && "span-#{@span}",
        "flex",
        align_class(@align)
      ]}>
        <button class={[
          "btn",
          "btn-#{@variant}",
          "btn-#{@size}",
          spacing_class(@size),
          @class
        ]} {@rest}>
          {render_slot(@inner_block)}
        </button>
      </div>
      """
    end

    defp align_class("start"), do: "justify-start"
    defp align_class("center"), do: "justify-center"
    defp align_class("end"), do: "justify-end"
    
    defp spacing_class("sm"), do: "px-3 py-2"
    defp spacing_class("md"), do: "px-4 py-3"
    defp spacing_class("lg"), do: "px-6 py-4"
  end
  ```
- **Test**: Add button widget to a test page with different spacing props, verify visual spacing matches specification

#### 6. Create Card Widget
- **Path**: `lib/foundation_web/components/widgets/card.ex`
- **Implementation**:
  ```elixir
  defmodule FoundationWeb.Components.Widgets.Card do
    use Phoenix.Component
    
    attr :span, :integer, default: 4
    attr :padding, :integer, default: 6
    attr :class, :string, default: ""
    slot :header
    slot :inner_block, required: true
    slot :actions

    def card_widget(assigns) do
      ~H"""
      <div class={[
        "span-#{@span}",
        "card",
        "bg-base-100",
        "shadow-xl",
        @class
      ]}>
        <div class="card-body p-#{@padding}">
          <h2 :if={@header != []} class="card-title mb-4">
            {render_slot(@header)}
          </h2>
          <div class="flex-grow">
            {render_slot(@inner_block)}
          </div>
          <div :if={@actions != []} class="card-actions justify-end mt-6">
            {render_slot(@actions)}
          </div>
        </div>
      </div>
      """
    end
  end
  ```
- **Test**: Create card with content, verify it respects grid columns and internal spacing

#### 7. Create Input Widget
- **Path**: `lib/foundation_web/components/widgets/input.ex`
- **Implementation**:
  ```elixir
  defmodule FoundationWeb.Components.Widgets.Input do
    use Phoenix.Component
    
    attr :span, :integer, default: 12
    attr :label, :string, required: true
    attr :name, :string, required: true
    attr :type, :string, default: "text"
    attr :error, :string, default: nil
    attr :class, :string, default: ""
    attr :rest, :global

    def input_widget(assigns) do
      ~H"""
      <div class={["span-#{@span}", "form-control"]}>
        <label class="label pb-2">
          <span class="label-text">{@label}</span>
        </label>
        <input 
          type={@type}
          name={@name}
          class={[
            "input",
            "input-bordered",
            "w-full",
            @error && "input-error",
            @class
          ]}
          {@rest}
        />
        <label :if={@error} class="label pt-2">
          <span class="label-text-alt text-error">{@error}</span>
        </label>
      </div>
      """
    end
  end
  ```
- **Test**: Create form with input widget, verify label and error spacing follows 4px scale

#### 8. Create Form Widget
- **Path**: `lib/foundation_web/components/widgets/form.ex`
- **Implementation**:
  ```elixir
  defmodule FoundationWeb.Components.Widgets.Form do
    use Phoenix.Component
    
    attr :for, :any, required: true
    attr :action, :string, default: "#"
    attr :columns, :integer, default: 1
    attr :gap, :integer, default: 6
    attr :class, :string, default: ""
    attr :rest, :global
    slot :inner_block, required: true

    def form_widget(assigns) do
      ~H"""
      <.form for={@for} action={@action} class={@class} {@rest}>
        <div class={[
          "grid",
          "grid-cols-#{@columns}",
          "gap-#{@gap}",
          "@container"
        ]}>
          {render_slot(@inner_block)}
        </div>
      </.form>
      """
    end
  end
  ```
- **Test**: Build form with multiple fields, verify vertical rhythm and field alignment

#### 9. Create List Widget
- **Path**: `lib/foundation_web/components/widgets/list.ex`
- **Implementation**:
  ```elixir
  defmodule FoundationWeb.Components.Widgets.List do
    use Phoenix.Component
    
    attr :span, :integer, default: 12
    attr :spacing, :integer, default: 3
    attr :direction, :string, default: "vertical"
    attr :class, :string, default: ""
    slot :item, required: true

    def list_widget(assigns) do
      ~H"""
      <ul class={[
        "span-#{@span}",
        @direction == "horizontal" && "flex flex-row",
        @direction == "vertical" && "flex flex-col",
        "gap-#{@spacing}",
        @class
      ]}>
        <li :for={item <- @item} class="list-item">
          {render_slot(item)}
        </li>
      </ul>
      """
    end
  end
  ```
- **Test**: Create list with items, measure spacing between items equals specified scale value

#### 10. Create Table Widget
- **Path**: `lib/foundation_web/components/widgets/table.ex`
- **Implementation**:
  ```elixir
  defmodule FoundationWeb.Components.Widgets.Table do
    use Phoenix.Component
    
    attr :span, :integer, default: 12
    attr :id, :string, required: true
    attr :rows, :list, required: true
    attr :class, :string, default: ""
    slot :col, required: true do
      attr :label, :string
      attr :width, :string
    end

    def table_widget(assigns) do
      ~H"""
      <div class={["span-#{@span}", "overflow-x-auto", @class]}>
        <table class="table w-full">
          <thead>
            <tr>
              <th :for={col <- @col} class={[
                "px-6 py-4",
                col[:width]
              ]}>
                {col[:label]}
              </th>
            </tr>
          </thead>
          <tbody>
            <tr :for={row <- @rows}>
              <td :for={col <- @col} class="px-6 py-4">
                {render_slot(col, row)}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      """
    end
  end
  ```
- **Test**: Create table with data, verify cell padding and responsive behavior at different widths

#### 11. Create Modal Widget
- **Path**: `lib/foundation_web/components/widgets/modal.ex`
- **Implementation**:
  ```elixir
  defmodule FoundationWeb.Components.Widgets.Modal do
    use Phoenix.Component
    
    attr :id, :string, required: true
    attr :title, :string, required: true
    attr :max_width, :string, default: "max-w-2xl"
    attr :padding, :integer, default: 6
    attr :class, :string, default: ""
    slot :inner_block, required: true
    slot :actions

    def modal_widget(assigns) do
      ~H"""
      <dialog id={@id} class={["modal", @class]}>
        <div class={["modal-box", @max_width, "p-#{@padding}"]}>
          <h3 class="font-bold text-lg mb-4">{@title}</h3>
          <div class="py-4">
            {render_slot(@inner_block)}
          </div>
          <div :if={@actions != []} class="modal-action mt-6">
            {render_slot(@actions)}
          </div>
        </div>
        <form method="dialog" class="modal-backdrop">
          <button>close</button>
        </form>
      </dialog>
      """
    end
  end
  ```
- **Test**: Trigger modal display, verify padding and centering behavior

#### 12. Create Navigation Widget
- **Path**: `lib/foundation_web/components/widgets/navigation.ex`
- **Implementation**:
  ```elixir
  defmodule FoundationWeb.Components.Widgets.Navigation do
    use Phoenix.Component
    
    attr :brand, :string, required: true
    attr :class, :string, default: ""
    slot :nav_item, required: true do
      attr :path, :string
      attr :active, :boolean
    end
    slot :actions

    def navigation_widget(assigns) do
      ~H"""
      <div class={["navbar bg-base-100 px-6", @class]}>
        <div class="navbar-start">
          <div class="text-xl font-bold">{@brand}</div>
        </div>
        <div class="navbar-center hidden lg:flex">
          <ul class="menu menu-horizontal gap-2">
            <li :for={item <- @nav_item}>
              <.link 
                navigate={item[:path]} 
                class={item[:active] && "active"}
              >
                {render_slot(item)}
              </.link>
            </li>
          </ul>
        </div>
        <div :if={@actions != []} class="navbar-end gap-4">
          {render_slot(@actions)}
        </div>
      </div>
      """
    end
  end
  ```
- **Test**: Create nav with items, verify spacing and responsive behavior

### Phase 3: Layout Components

#### 13. Create layout widget module
- **Path**: `lib/foundation_web/components/layout_widgets.ex`
- **Implementation**:
  ```elixir
  defmodule FoundationWeb.Components.LayoutWidgets do
    use Phoenix.Component

    @doc "Full-screen grid layout"
    attr :class, :string, default: ""
    slot :inner_block, required: true

    def grid_layout(assigns) do
      ~H"""
      <div class={["layout-full grid-12 p-6 @container", @class]}>
        {render_slot(@inner_block)}
      </div>
      """
    end

    @doc "Dashboard layout with sidebar"
    attr :class, :string, default: ""
    slot :sidebar, required: true
    slot :inner_block, required: true

    def dashboard_layout(assigns) do
      ~H"""
      <div class={["layout-full grid grid-cols-12 @container", @class]}>
        <aside class="col-span-3 bg-base-200 p-6">
          {render_slot(@sidebar)}
        </aside>
        <main class="col-span-9 p-6">
          {render_slot(@inner_block)}
        </main>
      </div>
      """
    end

    @doc "Centered content layout"
    attr :max_width, :string, default: "max-w-4xl"
    attr :class, :string, default: ""
    slot :inner_block, required: true

    def centered_layout(assigns) do
      ~H"""
      <div class={["layout-full flex items-center justify-center p-6", @class]}>
        <div class={[@max_width, "w-full"]}>
          {render_slot(@inner_block)}
        </div>
      </div>
      """
    end
  end
  ```
- **Test**: Create page using grid layout widget, verify 12-column grid renders correctly

#### 14. Create layout utilities
- **Path**: `lib/foundation_web/components/layout_helpers.ex`
- **Implementation**:
  ```elixir
  defmodule FoundationWeb.Components.LayoutHelpers do
    @spacing_scale %{
      1 => "4px",
      2 => "8px", 
      3 => "12px",
      4 => "16px",
      5 => "20px",
      6 => "24px",
      8 => "32px",
      10 => "40px",
      12 => "48px",
      16 => "64px",
      20 => "80px",
      24 => "96px"
    }

    def spacing_value(scale) when is_integer(scale) do
      Map.get(@spacing_scale, scale, "#{scale * 4}px")
    end

    def grid_span_class(span) when span in 1..12 do
      "span-#{span}"
    end

    def responsive_columns(base, tablet, desktop) do
      [
        "grid-cols-#{base}",
        "@md:grid-cols-#{tablet}",
        "@lg:grid-cols-#{desktop}"
      ]
    end
  end
  ```
- **Test**: Use helper functions in console/IEx, verify calculations return expected values

### Phase 4: Integration & Configuration

#### 15. Update core_components.ex
- **Path**: `lib/foundation_web/components/core_components.ex`
- **Changes**:
  ```elixir
  # Add at top of file
  import FoundationWeb.Components.Widgets
  import FoundationWeb.Components.Widgets.{Button, Card, Input, Form, List, Table, Modal, Navigation}
  import FoundationWeb.Components.LayoutWidgets
  
  # Add deprecation notice to existing components
  @deprecated "Use button_widget/1 instead"
  def button(assigns) do
    # existing implementation
  end
  ```
- **Test**: Existing pages should still render, new widget versions should be available

#### 16. Create theme configuration
- **Path**: `assets/css/theme-overrides.css`
- **Implementation**:
  ```css
  :root {
    /* Override DaisyUI sizing to match our scale */
    --size-field: var(--space-10);
    --size-selector: var(--space-6);
    --border: 1px;
    --radius-box: var(--space-2);
    --radius-field: var(--space-2);
    --radius-selector: var(--space-1);
    
    /* Consistent component heights */
    --h-sm: var(--space-8);
    --h-md: var(--space-10);
    --h-lg: var(--space-12);
  }
  ```
- **Test**: Verify DaisyUI components use new sizing values

#### 17. Create Tailwind configuration
- **Path**: `assets/tailwind.config.js`
- **Implementation**:
  ```javascript
  module.exports = {
    content: [
      "./js/**/*.js",
      "../lib/foundation_web/**/*.*ex"
    ],
    theme: {
      extend: {
        spacing: {
          '1': '4px',
          '2': '8px',
          '3': '12px',
          '4': '16px',
          '5': '20px',
          '6': '24px',
          '8': '32px',
          '10': '40px',
          '12': '48px',
          '16': '64px',
          '20': '80px',
          '24': '96px'
        },
        gridTemplateColumns: {
          '12': 'repeat(12, minmax(0, 1fr))'
        }
      }
    },
    plugins: [
      require("@tailwindcss/container-queries")
    ]
  }
  ```
- **Test**: Use new spacing utilities in a test component, verify they compile correctly

### Phase 5: Documentation

#### 18. Create implementation guide
- **Path**: `WIDGET_IMPLEMENTATION.md`
- **Content**:
  ```markdown
  # Widget Implementation Guide

  ## Overview
  Widgets are our wrapped DaisyUI components that enforce consistent spacing and layout rules.

  ## Naming Convention
  - Module: `FoundationWeb.Components.Widgets.{ComponentName}`
  - Function: `{component}_widget`
  - Usage: `<.button_widget>Click me</.button_widget>`

  ## Spacing Scale
  Always use our 4px-based scale:
  - 1 = 4px
  - 2 = 8px
  - 3 = 12px
  - 4 = 16px
  - 5 = 20px
  - 6 = 24px
  - 8 = 32px
  - 10 = 40px
  - 12 = 48px
  - 16 = 64px
  - 20 = 80px
  - 24 = 96px

  ## Creating New Widgets
  1. Create module in `lib/foundation_web/components/widgets/`
  2. Include span, padding, and gap attributes
  3. Wrap DaisyUI component with layout div
  4. Add to widgets.ex imports
  5. Document with examples

  ## Migration from core_components
  Replace:
  ```elixir
  <.button>Save</.button>
  ```
  
  With:
  ```elixir
  <.button_widget span={3} align="center">Save</.button_widget>
  ```
  ```
- **Test**: Follow guide to create a new widget, verify process works as documented

## File Structure Overview

```
foundation/
├── assets/
│   ├── css/
│   │   ├── app.css (updated)
│   │   ├── spacing.css (new)
│   │   ├── layouts.css (new)
│   │   └── theme-overrides.css (new)
│   └── tailwind.config.js (new)
├── lib/
│   └── foundation_web/
│       ├── components/
│       │   ├── core_components.ex (updated)
│       │   ├── widgets.ex (new)
│       │   ├── layout_widgets.ex (new)
│       │   ├── layout_helpers.ex (new)
│       │   └── widgets/
│       │       ├── button.ex (new)
│       │       ├── card.ex (new)
│       │       ├── input.ex (new)
│       │       ├── form.ex (new)
│       │       ├── list.ex (new)
│       │       ├── table.ex (new)
│       │       ├── modal.ex (new)
│       │       └── navigation.ex (new)
├── UI_IMPLEMENTATION.md (this file)
└── WIDGET_IMPLEMENTATION.md (new)
```

## Key Implementation Details

### Atomic Spacing Scale (4px base)
```css
--space-1: 4px;
--space-2: 8px;
--space-3: 12px;
--space-4: 16px;
--space-5: 20px;
--space-6: 24px;
--space-8: 32px;
--space-10: 40px;
--space-12: 48px;
--space-16: 64px;
--space-20: 80px;
--space-24: 96px;
```

### Widget Naming Convention
- All custom wrapped components use "widget" terminology
- Module names: `Widgets.Button`, `Widgets.Card`, etc.
- Component usage: `<.button_widget>`, `<.card_widget>`
- Clear distinction from DaisyUI base components

### Grid System
- 12-column base grid
- Full-width containers
- Gap values use spacing scale
- Nested grids for complex layouts

### Testing Strategy
- Each step includes minimal verification
- Use browser DevTools for spacing verification
- Visual confirmation of layout behavior
- Console checks for errors
- IEx testing for helper functions

### Responsive Breakpoints
```css
@container (min-width: 768px) /* Tablet */
@container (min-width: 1024px) /* Desktop */
@container (min-width: 1440px) /* Wide desktop */
@container (min-width: 1920px) /* Ultra-wide */
```

This implementation ensures pixel-perfect layouts with consistent 4px-based spacing, proper proportions, and desktop-first responsive design while leveraging DaisyUI components wrapped in layout-aware widget containers.