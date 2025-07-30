defmodule Foundation.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FoundationWeb.Telemetry,
      Foundation.Repo,
      {DNSCluster, query: Application.get_env(:foundation, :dns_cluster_query) || :ignore},
      {Oban,
       AshOban.config(
         Application.fetch_env!(:foundation, :ash_domains),
         Application.fetch_env!(:foundation, Oban)
       )},
      {Phoenix.PubSub, name: Foundation.PubSub},
      # Start a worker by calling: Foundation.Worker.start_link(arg)
      # {Foundation.Worker, arg},
      # Start to serve requests, typically the last entry
      FoundationWeb.Endpoint,
      {AshAuthentication.Supervisor, [otp_app: :foundation]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Foundation.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FoundationWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
