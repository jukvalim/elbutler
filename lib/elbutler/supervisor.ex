defmodule ElButler.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      {
        ElButler.Scheduler,
        # run the tasks every 30 minutes
        {1000 * 60 * 30,
         [
           &ElButler.Tasks.check_worth_the_candle/0,
           &ElButler.Tasks.check_pod/0,
           &ElButler.Tasks.check_fod/0,
           &ElButler.Tasks.check_hwfm/0,
           &ElButler.Tasks.check_rm/0
         ]}
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
