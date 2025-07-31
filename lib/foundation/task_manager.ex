# This domain groups all task-related resources
defmodule Foundation.TaskManager do
  use Ash.Domain,
    otp_app: :foundation,
    extensions: [AshPhoenix]

  resources do
    # Register our Task resource
    resource Foundation.TaskManager.Task
  end
end