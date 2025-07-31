defmodule Foundation.Dashboard do
  use Ash.Domain,
    otp_app: :foundation,
    extensions: [AshPhoenix]

  resources do
    resource Foundation.Dashboard.KpiSummary
    resource Foundation.Dashboard.Activity
  end
end