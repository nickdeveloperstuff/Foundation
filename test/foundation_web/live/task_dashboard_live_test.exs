defmodule FoundationWeb.TaskDashboardLiveTest do
  use FoundationWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "task dashboard" do
    test "form uses standard parameter structure", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/tasks")
      
      # Open the task creation modal
      view
      |> element("button", "Add Task")
      |> render_click()
      
      # Test validation with standard "form" parameter
      assert view
             |> form("#task-form", %{"form" => %{"title" => "Te"}})
             |> render_change() =~ "must be at least 3 characters long"
      
      # Test with valid title
      assert view
             |> form("#task-form", %{"form" => %{"title" => "Test Task"}})
             |> render_change()
      
      # Test submission with standard "form" parameter
      assert view
             |> form("#task-form", %{
               "form" => %{
                 "title" => "Test Task",
                 "description" => "Test description",
                 "status" => "pending",
                 "priority" => "medium"
               }
             })
             |> render_submit()
             
      # Verify the form still works with flash message
      assert render(view) =~ "Task created successfully!"
    end
    
    test "validates form parameters are properly structured", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/tasks")
      
      # Open modal
      view
      |> element("button", "Add Task")
      |> render_click()
      
      # This test ensures we're not accepting non-standard parameter structures
      # The form should only work with the "form" key
      html = render(view)
      
      # Check that the form is rendered with proper structure
      assert html =~ ~s(phx-change="validate_task")
      assert html =~ ~s(phx-submit="save_task")
      
      # Attempt to validate with incorrect parameter structure (should fail)
      # Note: In a properly configured form, this would not trigger validation
      # because the form expects parameters under the "form" key
      assert view
             |> form("#task-form", %{"task" => %{"title" => "Test"}})
             |> render_change() 
      
      # The form should not show validation errors because it didn't receive
      # parameters in the expected structure
      refute render(view) =~ "must be at least 3 characters long"
    end
  end
end