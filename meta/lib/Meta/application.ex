defmodule Meta.Application do
  use Application

  def start(_type, _args) do
    children = [
      Meta.Repo
      # otros procesos...
    ]

    opts = [strategy: :one_for_one, name: Meta.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
