defmodule ElButler.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      ElButler.Supervisor,
      {Plug.Cowboy, scheme: :http, plug: ElButler.HelloWorldPlug, options: [port: 4000]}
    ]

    opts = [strategy: :one_for_one, name: ElButler.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
