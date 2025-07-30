defmodule Foundation.Ledger do
  use Ash.Domain,
    otp_app: :foundation

  resources do
    resource Foundation.Ledger.Account
    resource Foundation.Ledger.Balance
    resource Foundation.Ledger.Transfer
  end
end
