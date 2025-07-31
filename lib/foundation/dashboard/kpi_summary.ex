defmodule Foundation.Dashboard.KpiSummary do
  use Ash.Resource,
    otp_app: :foundation,
    domain: Foundation.Dashboard,
    data_layer: :embedded

  attributes do
    attribute :revenue, :string, allow_nil?: false, public?: true
    attribute :revenue_growth, :integer, allow_nil?: false, public?: true
    attribute :active_users, :string, allow_nil?: false, public?: true  
    attribute :user_growth, :integer, allow_nil?: false, public?: true
    attribute :new_signups, :integer, allow_nil?: false, public?: true
    attribute :signup_rate, :integer, allow_nil?: false, public?: true
    attribute :churn_rate, :float, allow_nil?: false, public?: true
    attribute :churn_change, :float, allow_nil?: false, public?: true
  end

  actions do
    defaults [:read]
    
    create :create do
      accept :*
    end
  end
end