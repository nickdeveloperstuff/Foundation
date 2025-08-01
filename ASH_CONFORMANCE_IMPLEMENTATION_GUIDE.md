# Ash Framework Conformance Implementation Guide

This guide provides step-by-step instructions for implementing architectural changes to align the Foundation project with Ash Framework v3.5.33 best practices. Each section includes implementation, testing, and documentation steps.

## Phase 1: Form Parameter Standardization

### Step 1: Find All Non-Standard Form Parameter Usage

1. Open your terminal in the project root directory
2. Run these search commands to find problematic patterns:

```bash
# Search for direct parameter access patterns
grep -r "params\[\"form\"\]" lib/foundation_web/live/
grep -r "params\[\"task\"\]" lib/foundation_web/live/
grep -r "get_in(params, \[\"form\"\])" lib/foundation_web/live/
grep -r "get_in(params, \[\"task\"\])" lib/foundation_web/live/

# Search for conditional parameter checking
grep -r "params\[\"form\"\] || params\[\"task\"\]" lib/foundation_web/live/
grep -r "Map.get(params, \"form\"" lib/foundation_web/live/
```

3. Create a file called `form_refactoring_tracker.md` and list every file that shows up in the search results

### Step 2: Understand the Pattern We're Fixing

The WRONG way (what we're fixing):
```elixir
def handle_event("validate", params, socket) do
  # WRONG: Checking multiple parameter keys
  form_params = params["form"] || params["task"] || params
  form = AshPhoenix.Form.validate(socket.assigns.form, form_params)
  {:noreply, assign(socket, form: form)}
end
```

The RIGHT way (Ash standard pattern):
```elixir
def handle_event("validate", %{"form" => params}, socket) do
  # RIGHT: Always expecting "form" key
  form = AshPhoenix.Form.validate(socket.assigns.form, params)
  {:noreply, assign(socket, form: form)}
end
```

### Step 3: Fix Form Initialization in Each LiveView

For each LiveView file in your tracker:

1. Find the `mount/3` function or wherever forms are initialized
2. Look for form creation like this:
   ```elixir
   form = AshPhoenix.Form.for_create(MyApp.Resource, :create)
   ```

3. Change it to explicitly use "form" as the parameter name:
   ```elixir
   form = AshPhoenix.Form.for_create(MyApp.Resource, :create, as: "form")
   ```

4. If using `for_update`, do the same:
   ```elixir
   form = AshPhoenix.Form.for_update(resource, :update, as: "form")
   ```

### Step 4: Fix Event Handlers

For each LiveView file:

1. Find all `handle_event` functions that deal with forms
2. Look for these event names: "validate", "submit", "save", "create", "update"
3. Change the parameter pattern matching:

   **Before:**
   ```elixir
   def handle_event("validate", params, socket) do
     form_params = params["form"] || params["task"] || params
     # ...
   end
   ```

   **After:**
   ```elixir
   def handle_event("validate", %{"form" => params}, socket) do
     # Use params directly, no need to check multiple keys
     # ...
   end
   ```

### Step 5: Test Each Form Immediately

**DO NOT MOVE TO THE NEXT LIVEVIEW UNTIL THIS ONE IS TESTED!**

For the LiveView you just modified:

1. Start the Phoenix server: `mix phx.server`
2. Navigate to the page with the form
3. Test these actions:
   - Fill out the form fields
   - Check that validation messages appear as you type
   - Submit the form
   - Verify the data saves correctly
4. Check the browser console for any JavaScript errors
5. Check the terminal for any Elixir errors

If the form doesn't work:
- Check that your template uses `<.form for={@form}>` not a custom name
- Verify the form `id` matches what you expect
- Use `IO.inspect(params)` in your event handler to see the structure

### Step 6: Create/Update Tests for This Form

Before moving to the next LiveView, add tests:

```elixir
test "form uses standard parameter structure", %{conn: conn} do
  {:ok, view, _html} = live(conn, ~p"/your-path-here")
  
  # Test validation with standard "form" parameter
  assert view
         |> form("#your-form-id", %{"form" => %{"field" => "value"}})
         |> render_change() =~ "expected content"
  
  # Test submission with standard "form" parameter
  assert view
         |> form("#your-form-id", %{"form" => %{"field" => "value"}})
         |> render_submit()
         
  # Verify the form still works
  assert_redirect(view, ~p"/success-path")
end
```

Run the test: `mix test test/foundation_web/live/your_live_view_test.exs`

### Step 7: Document What Changed

In your tracker file, add notes for this LiveView:

```markdown
## LiveView: TaskLive.Index

**What Changed**: 
- Removed multi-parameter checking (was checking "form", "task", and direct params)
- Now uses standard AshPhoenix pattern with consistent "form" parameter

**Ash Conformance**: 
- ✅ NOW FOLLOWS ASH STANDARD - AshPhoenix.Form expects consistent parameter keys
- This is not a custom convention, we're returning to Ash defaults

**Testing Status**: ✅ Tested on [date]
```

## Phase 2: Atomic Validation Migration

### Step 1: Find All Non-Atomic Validations

1. Search for all uses of `require_atomic? false`:

```bash
grep -r "require_atomic? false" lib/foundation/
```

2. Create `atomic_validation_tracker.md` and list each occurrence with:
   - File path
   - Resource name
   - Action name
   - Current validations/changes

### Step 2: Analyze Each Non-Atomic Action

For each action with `require_atomic? false`:

1. Open the resource file
2. Find the action definition
3. List all validations and changes in the action
4. For each validation/change, determine:
   - Is it a custom validation module?
   - Is it using a built-in validation?
   - Is it a custom change module?
   - What attributes does it access?

Document your findings:
```markdown
## Resource: Foundation.Accounts.User
### Action: :update_profile
- require_atomic? false
- Validations:
  - validate {CustomEmailValidator, field: :email} - CUSTOM
  - validate present(:name) - BUILTIN
- Changes:
  - change {SlugifyName, field: :name} - CUSTOM
```

### Step 3: Implement Atomic Callbacks for Custom Validations

For each custom validation module:

1. Open the validation module file
2. Add the `atomic/3` callback after the `validate/3` function:

```elixir
defmodule MyApp.Validations.MyCustomValidation do
  use Ash.Resource.Validation
  
  # Existing validate function
  @impl true
  def validate(changeset, opts, _context) do
    value = Ash.Changeset.get_attribute(changeset, opts[:attribute])
    if valid?(value) do
      :ok
    else
      {:error, field: opts[:attribute], message: "is invalid"}
    end
  end
  
  # ADD THIS NEW FUNCTION
  @impl true
  def atomic(changeset, opts, context) do
    {:atomic,
     # List attributes this validation uses
     [opts[:attribute]],
     # Expression for when validation should FAIL
     expr(not valid?(^atomic_ref(opts[:attribute]))),
     # Error to return when validation fails
     expr(
       error(^InvalidAttribute, %{
         field: ^opts[:attribute],
         value: ^atomic_ref(opts[:attribute]),
         message: ^(context.message || "is invalid"),
         vars: %{field: ^opts[:attribute]}
       })
     )}
  end
  
  # Helper function used by both callbacks
  defp valid?(value) do
    # Your validation logic here
  end
end
```

### Step 4: Test the Atomic Implementation Immediately

Create a test specifically for the atomic behavior:

```elixir
defmodule MyApp.Validations.MyCustomValidationTest do
  use ExUnit.Case
  import Ash.Expr
  
  describe "atomic validation" do
    test "works with bulk operations" do
      # Test valid data in bulk
      assert {:ok, results} = 
        MyResource
        |> Ash.bulk_create([
          %{field: "valid_value_1"},
          %{field: "valid_value_2"}
        ], :create)
      
      assert length(results) == 2
    end
    
    test "rejects invalid data atomically" do
      # Test invalid data is caught
      assert {:error, %Ash.BulkResult{errors: errors}} = 
        MyResource
        |> Ash.bulk_create([
          %{field: "invalid_value"}
        ], :create)
        
      assert [%{field: :field, message: "is invalid"}] = errors
    end
    
    test "matches non-atomic behavior" do
      # Ensure atomic and non-atomic give same results
      changeset = Ash.Changeset.for_create(MyResource, :create, %{field: "test_value"})
      
      # Test non-atomic
      non_atomic_result = MyCustomValidation.validate(changeset, [attribute: :field], %{})
      
      # Test atomic (you'll need to simulate this based on your logic)
      # Assert both give same result
    end
  end
end
```

### Step 5: Implement Atomic Callbacks for Custom Changes

For each custom change module:

```elixir
defmodule MyApp.Changes.SlugifyName do
  use Ash.Resource.Change
  import Ash.Expr  # Important for expr() macro
  
  @impl true
  def change(changeset, opts, _context) do
    case Ash.Changeset.get_attribute(changeset, :name) do
      nil -> changeset
      name -> 
        slug = slugify(name)
        Ash.Changeset.change_attribute(changeset, :slug, slug)
    end
  end
  
  # ADD THIS NEW FUNCTION
  @impl true
  def atomic(changeset, _opts, _context) do
    # For simple attribute transformations
    {:atomic, %{
      slug: expr(fragment("slugify(?)", ^atomic_ref(:name)))
    }}
  end
  
  defp slugify(name) do
    name
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9\s-]/, "")
    |> String.replace(~r/\s+/, "-")
  end
end
```

### Step 6: Test Atomic Changes

```elixir
test "slugify works atomically" do
  assert {:ok, %{slug: "john-doe"}} = 
    User
    |> Ash.Changeset.for_create(:create, %{name: "John Doe"})
    |> Ash.create!()
    
  # Test bulk operations use atomic path
  assert {:ok, results} = 
    User
    |> Ash.bulk_create([
      %{name: "Jane Smith"},
      %{name: "Bob Johnson"}
    ], :create)
    
  assert Enum.map(results, & &1.slug) == ["jane-smith", "bob-johnson"]
end
```

### Step 7: Remove require_atomic? false

Only after ALL validations and changes for an action have atomic implementations:

1. Remove `require_atomic? false` from the action
2. Run ALL tests for that resource: `mix test test/foundation/accounts/user_test.exs`
3. If tests fail, DO NOT PROCEED - fix the atomic implementation first

### Step 8: Document the Atomic Migration

In your tracker, document each resource:

```markdown
## Resource: Foundation.Accounts.User

**What Changed**:
- Removed `require_atomic? false` from :update_profile action
- Added atomic callbacks to CustomEmailValidator
- Added atomic callbacks to SlugifyName change

**Ash Conformance**:
- ✅ NOW FOLLOWS ASH STANDARD - Atomic validations are the default in Ash 3.0+
- This improves performance and data consistency
- No custom conventions added

**Caveats**:
- SlugifyName requires a custom postgres function `slugify()` to work atomically
- If the database doesn't have this function, the atomic path will fail

**Testing Status**: ✅ All atomic tests passing [date]
```

## Phase 3: Type System and Validation Standardization

### Step 1: Find and Fix :text Type Usage

1. Search for `:text` type usage:

```bash
grep -r "attribute.*:text" lib/foundation/
grep -r "argument.*:text" lib/foundation/
```

2. For each occurrence, change `:text` to `:string`:

```elixir
# WRONG - :text doesn't exist in Ash
attribute :description, :text

# RIGHT - Use :string
attribute :description, :string
```

3. If you need to support very long text, add constraints:

```elixir
attribute :description, :string do
  constraints max_length: 10_000  # or whatever limit makes sense
end
```

### Step 2: Test Type Changes

After changing each attribute type:

1. Run the resource's tests
2. Try to create/update a record with a long string in that field
3. Verify the database can store it properly

```elixir
test "description accepts long strings" do
  long_text = String.duplicate("Lorem ipsum ", 1000)
  
  assert {:ok, resource} = 
    MyResource
    |> Ash.Changeset.for_create(:create, %{description: long_text})
    |> Ash.create()
    
  assert String.length(resource.description) > 10_000
end
```

### Step 3: Create Custom Text Type (Optional - Only if Needed)

**⚠️ THIS IS A CUSTOM CONVENTION - DOCUMENT IT!**

If you have many long text fields and want semantic consistency:

1. Create `lib/foundation/types/text.ex`:

```elixir
defmodule Foundation.Types.Text do
  @moduledoc """
  A custom type for long text fields.
  
  ⚠️ CUSTOM CONVENTION ⚠️
  This is NOT a standard Ash type. We created this for semantic clarity
  when dealing with long-form text fields like descriptions, blog posts, etc.
  
  In standard Ash, you would use:
    attribute :description, :string, constraints: [max_length: nil]
  
  We use:
    attribute :description, Foundation.Types.Text
    
  This type has no length limit and is intended for user-generated content.
  """
  
  use Ash.Type.NewType, 
    subtype_of: :string, 
    constraints: [
      max_length: :infinity
    ]
end
```

2. Test the custom type thoroughly:

```elixir
defmodule Foundation.Types.TextTest do
  use ExUnit.Case
  
  test "accepts very long strings" do
    long_string = String.duplicate("a", 100_000)
    assert {:ok, ^long_string} = 
      Ash.Type.cast_input(Foundation.Types.Text, long_string, %{})
  end
  
  test "handles nil" do
    assert {:ok, nil} = Ash.Type.cast_input(Foundation.Types.Text, nil, %{})
  end
  
  test "rejects non-string input" do
    assert :error = Ash.Type.cast_input(Foundation.Types.Text, 123, %{})
  end
end
```

3. Document this custom convention:

```markdown
## Custom Type: Foundation.Types.Text

**What It Is**:
- A semantic wrapper around :string with no length limit
- Used for long-form text fields

**Why We Created It**:
- Provides consistent handling of long text across the codebase
- Makes intent clear when reading resource definitions

**How It Differs from Ash**:
- Ash doesn't have a :text type
- Standard Ash would use :string with constraints
- This is purely for developer convenience

**When to Use**:
- User-generated content (posts, comments, descriptions)
- Any field that might contain more than 255 characters
- DO NOT use for short strings like names or titles
```

### Step 4: Fix Validation Function Names

1. Search for incorrect validation names:

```bash
grep -r "validate string_length" lib/foundation/
grep -r "validate length(" lib/foundation/
```

2. Fix to use correct built-in names:

```elixir
# WRONG - incorrect function name
validate length(:name, min: 3)

# RIGHT - correct built-in
validate string_length(:name, min: 3)
```

### Step 5: Test Validation Changes

For each validation you fix:

```elixir
test "name validation works correctly" do
  # Test too short
  assert {:error, %{errors: errors}} = 
    MyResource
    |> Ash.Changeset.for_create(:create, %{name: "ab"})
    |> Ash.create()
    
  assert [%{field: :name, message: message}] = errors
  assert message =~ "at least 3"
  
  # Test valid length
  assert {:ok, _} = 
    MyResource
    |> Ash.Changeset.for_create(:create, %{name: "abc"})
    |> Ash.create()
end
```

### Step 6: Document Validation Standardization

```markdown
## Validation Standardization

**What Changed**:
- Fixed incorrect validation function names
- Moved duplicated validations to global validations block
- Added proper conditional validations with `where` clauses

**Ash Conformance**:
- ✅ NOW FOLLOWS ASH STANDARD - Using correct built-in validation names
- ✅ Global validations reduce duplication (Ash best practice)
- No custom conventions added

**Common Patterns Fixed**:
- `validate length()` → `validate string_length()`
- Multiple identical validations → Single global validation with `on: [actions]`
```

## Phase 4: Connection-Aware Patterns

### Step 1: Create Subscription Utility Module

**⚠️ THIS IS A CUSTOM CONVENTION - DOCUMENT IT!**

1. Create `lib/foundation_web/live/subscriptions.ex`:

```elixir
defmodule FoundationWeb.Live.Subscriptions do
  @moduledoc """
  ⚠️ CUSTOM CONVENTION ⚠️
  
  Utilities for safe Phoenix.PubSub subscriptions in LiveViews.
  
  WHY THIS EXISTS:
  - Standard Phoenix.PubSub.subscribe/2 can error during LiveView mount
  - The socket isn't connected during the first mount/3 call
  - This causes subscription errors in the logs
  
  STANDARD PHOENIX WAY:
    def mount(_, _, socket) do
      Phoenix.PubSub.subscribe(MyApp.PubSub, "topic")  # Can error!
      {:ok, socket}
    end
  
  OUR WAY:
    def mount(_, _, socket) do
      socket = Subscriptions.safe_subscribe(socket, "topic")
      {:ok, socket}
    end
  
  This ensures subscriptions only happen when the socket is connected.
  """
  
  require Logger
  
  def safe_subscribe(socket, topic) when is_binary(topic) do
    if Phoenix.LiveView.connected?(socket) do
      Phoenix.PubSub.subscribe(Foundation.PubSub, topic)
      Logger.debug("Subscribed to #{topic}")
    end
    socket
  end
  
  def safe_subscribe_many(socket, topics) when is_list(topics) do
    Enum.reduce(topics, socket, &safe_subscribe(&2, &1))
  end
end
```

### Step 2: Test the Subscription Module

```elixir
defmodule FoundationWeb.Live.SubscriptionsTest do
  use FoundationWeb.ConnCase
  import Phoenix.LiveViewTest
  
  defmodule TestLive do
    use FoundationWeb, :live_view
    alias FoundationWeb.Live.Subscriptions
    
    def mount(_params, _session, socket) do
      socket = Subscriptions.safe_subscribe(socket, "test_topic")
      {:ok, assign(socket, :messages, [])}
    end
    
    def render(assigns) do
      ~H"<div>Test</div>"
    end
  end
  
  test "safe_subscribe only subscribes when connected", %{conn: conn} do
    # First mount (disconnected) should not error
    {:ok, view, _html} = live(conn, "/test")
    
    # After connected mount, messages should arrive
    Phoenix.PubSub.broadcast(Foundation.PubSub, "test_topic", {:test, "message"})
    
    # Give it time to receive
    Process.sleep(50)
    
    # Should have received the message
    assert render(view) =~ "Test"
  end
end
```

### Step 3: Update LiveViews to Use Safe Subscriptions

1. Find all direct subscriptions:

```bash
grep -r "Phoenix.PubSub.subscribe" lib/foundation_web/live/
```

2. Update each one:

```elixir
# BEFORE - Standard Phoenix way
def mount(_params, _session, socket) do
  Phoenix.PubSub.subscribe(Foundation.PubSub, "updates")
  {:ok, socket}
end

# AFTER - Our safe way
def mount(_params, _session, socket) do
  socket = FoundationWeb.Live.Subscriptions.safe_subscribe(socket, "updates")
  {:ok, socket}
end
```

3. Add the alias:

```elixir
alias FoundationWeb.Live.Subscriptions
```

### Step 4: Test Each Updated LiveView

1. Start the server and load the page
2. Check server logs - should see "Subscribed to [topic]" ONLY ONCE
3. Verify real-time features still work
4. Check for no subscription errors in logs

### Step 5: Document the Convention

```markdown
## Connection-Aware Subscriptions

**What Changed**:
- Created FoundationWeb.Live.Subscriptions module
- All LiveViews now use safe_subscribe instead of direct PubSub.subscribe

**Why This Is Different from Standard Phoenix**:
- Standard Phoenix allows subscribing during disconnected mount
- This can cause errors that clutter logs
- Our approach prevents these errors

**When to Use**:
- ALWAYS use Subscriptions.safe_subscribe() in LiveView mount
- NEVER use Phoenix.PubSub.subscribe() directly in LiveViews
- Regular Elixir processes can still use direct subscriptions

**Testing Requirements**:
- Test that pages load without subscription errors
- Verify real-time updates still work
- Check logs for clean subscription messages
```

## Final Testing Checklist

Run through this checklist after completing all phases:

1. **Full Test Suite**
   ```bash
   mix test
   ```
   All tests should pass.

2. **Check for Removed Anti-Patterns**
   ```bash
   # Should return nothing:
   grep -r "params\[\"form\"\] || params\[\"task\"\]" lib/
   
   # Should be significantly reduced:
   grep -r "require_atomic? false" lib/foundation/
   
   # Should return nothing:
   grep -r "attribute.*:text" lib/foundation/
   ```

3. **Manual Testing**
   - Test every form in the application
   - Verify real-time features work
   - Check for console errors
   - Review server logs for cleanliness

4. **Performance Testing**
   ```elixir
   # Before changes, benchmark bulk operations
   # After changes, they should be faster
   Benchee.run(%{
     "bulk_create" => fn ->
       Ash.bulk_create!(Resource, Enum.map(1..100, &%{field: "value#{&1}"}), :create)
     end
   })
   ```

## Documentation Summary

Create `FOUNDATION_CONVENTIONS.md` with ONLY these custom patterns:

```markdown
# Foundation Custom Conventions

This document describes patterns that differ from standard Ash/Phoenix.

## 1. Connection-Aware Subscriptions

Use `FoundationWeb.Live.Subscriptions.safe_subscribe/2` in all LiveViews.

**Why**: Prevents subscription errors during mount lifecycle.

## 2. Foundation.Types.Text (if implemented)

Use for long-form text fields instead of `:string` with constraints.

**Why**: Semantic clarity for unbounded text fields.

---

Everything else follows standard Ash Framework patterns.
```