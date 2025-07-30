defmodule Foundation.Secrets do
  use AshAuthentication.Secret

  def secret_for(
        [:authentication, :tokens, :signing_secret],
        Foundation.Accounts.User,
        _opts,
        _context
      ) do
    Application.fetch_env(:foundation, :token_signing_secret)
  end
end
