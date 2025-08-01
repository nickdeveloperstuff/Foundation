# Foundation Custom Conventions

This document describes patterns that differ from standard Ash/Phoenix.

## 1. Connection-Aware Subscriptions

Use `FoundationWeb.Live.Subscriptions.safe_subscribe/2` in all LiveViews.

**Why**: Prevents subscription errors during mount lifecycle.

**Example**:
```elixir
def mount(_params, _session, socket) do
  socket = FoundationWeb.Live.Subscriptions.safe_subscribe(socket, "updates")
  {:ok, socket}
end
```

**Note**: Currently, most LiveViews use the WidgetData abstraction instead of direct PubSub subscriptions, but the utility is available for future use.

## 2. Module-based Atomic Changes

For changes that need atomic support, create a module implementing the atomic callback.

**Why**: Inline functions cannot implement the atomic callback required by Ash 3.0+.

**Example**: See `Foundation.TaskManager.Changes.SetCompletedAt`

---

Everything else follows standard Ash Framework patterns.