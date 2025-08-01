defmodule Foundation.TaskManager.Changes.SetCompletedAt do
  @moduledoc """
  Sets the completed_at timestamp when task status changes to completed.
  Supports both atomic and non-atomic operations.
  """
  use Ash.Resource.Change
  import Ash.Expr

  @impl true
  def change(changeset, _opts, _context) do
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

  @impl true
  def atomic(_changeset, _opts, _context) do
    # Use Ash expressions for atomic operations
    {:atomic, %{
      completed_at: expr(
        if ^atomic_ref(:status) == :completed do
          now()
        else
          nil
        end
      )
    }}
  end
end