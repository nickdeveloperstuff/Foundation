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