defmodule Foundation.Dashboard do
  use Ash.Domain,
    otp_app: :foundation,
    extensions: [AshPhoenix]

  resources do
    # Empty for now - embedded resources removed
  end
end