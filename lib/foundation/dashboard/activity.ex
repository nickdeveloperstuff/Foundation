defmodule Foundation.Dashboard.Activity do
  use Ash.Resource,
    otp_app: :foundation,
    domain: Foundation.Dashboard,
    data_layer: :embedded

  attributes do
    attribute :id, :integer, allow_nil?: false, public?: true
    attribute :time, :string, allow_nil?: false, public?: true
    attribute :user, :string, allow_nil?: false, public?: true
    attribute :action, :string, allow_nil?: false, public?: true
    attribute :status, :string, allow_nil?: false, public?: true
  end

  actions do
    defaults [:read, :create]
  end
end