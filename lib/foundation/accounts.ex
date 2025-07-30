defmodule Foundation.Accounts do
  use Ash.Domain, otp_app: :foundation, extensions: [AshAdmin.Domain]

  admin do
    show? true
  end

  resources do
    resource Foundation.Accounts.Token
    resource Foundation.Accounts.User
  end
end
