defmodule NeonTodo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Logger.add_backend(NeonTodo.LoggerBackend)

    children = [
      NeonTodoWeb.Telemetry,
      NeonTodo.Repo,
      {DNSCluster, query: Application.get_env(:neon_todo, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: NeonTodo.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: NeonTodo.Finch},
      # Start a worker by calling: NeonTodo.Worker.start_link(arg)
      # {NeonTodo.Worker, arg},
      # Start to serve requests, typically the last entry
      NeonTodoWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NeonTodo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    NeonTodoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
