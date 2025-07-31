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
    attribute :description, :string, public?: true
    
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
      require_atomic? false
      
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
    calculate :is_completed, :boolean, expr(status == :completed)
  end
end