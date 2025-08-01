defmodule Foundation.TaskManager.Changes.SetCompletedAtTest do
  use Foundation.DataCase
  
  alias Foundation.TaskManager.Task
  
  describe "atomic change for completed_at" do
    test "sets completed_at atomically when status changes to completed" do
      # Create a task
      assert {:ok, task} = 
        Task
        |> Ash.Changeset.for_create(:create, %{
          title: "Test Task",
          status: :pending
        })
        |> Ash.create()
      
      assert is_nil(task.completed_at)
      
      # Update to completed status
      assert {:ok, updated_task} = 
        task
        |> Ash.Changeset.for_update(:update, %{status: :completed})
        |> Ash.update()
      
      # Should have a completed_at timestamp
      assert not is_nil(updated_task.completed_at)
      assert %DateTime{} = updated_task.completed_at
    end
    
    test "clears completed_at when status changes from completed" do
      # Create a completed task with timestamp
      assert {:ok, task} = 
        Task
        |> Ash.Changeset.for_create(:create, %{
          title: "Test Task",
          status: :pending
        })
        |> Ash.create()
      
      # First complete it
      assert {:ok, completed_task} = 
        task
        |> Ash.Changeset.for_update(:update, %{status: :completed})
        |> Ash.update()
      
      assert not is_nil(completed_task.completed_at)
      
      # Then change status back to pending
      assert {:ok, pending_task} = 
        completed_task
        |> Ash.Changeset.for_update(:update, %{status: :pending})
        |> Ash.update()
      
      # Should clear the completed_at
      assert is_nil(pending_task.completed_at)
    end
    
    test "works with bulk operations (tests atomic path)" do
      # Create multiple tasks
      tasks_attrs = for i <- 1..3 do
        %{title: "Task #{i}", status: :pending}
      end
      
      assert {:ok, tasks} = 
        Task
        |> Ash.bulk_create(tasks_attrs, :create, return_records?: true, domain: Foundation.TaskManager)
      
      _task_ids = Enum.map(tasks.records, & &1.id)
      
      # Bulk update to completed
      assert {:ok, %Ash.BulkResult{}} = 
        Task
        |> Ash.bulk_update(:update, %{status: :completed})
      
      # Verify all have completed_at
      updated_tasks = 
        Task
        |> Ash.read!()
      
      assert Enum.all?(updated_tasks, fn task -> 
        task.status == :completed and not is_nil(task.completed_at)
      end)
    end
    
    test "matches non-atomic behavior" do
      # Create a task and get changeset
      task_attrs = %{title: "Test Task", status: :pending}
      
      assert {:ok, task} = 
        Task
        |> Ash.Changeset.for_create(:create, task_attrs)
        |> Ash.create()
      
      # Test updating to completed
      changeset = Ash.Changeset.for_update(task, :update, %{status: :completed})
      
      # The change should work the same way whether atomic or not
      assert {:ok, updated} = Ash.update(changeset)
      assert not is_nil(updated.completed_at)
    end
  end
end