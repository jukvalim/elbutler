defmodule ElButler.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # This is the new line
      ElButler.Scheduler
    ]
    opts = [strategy: :one_for_one, name: ElButler.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
