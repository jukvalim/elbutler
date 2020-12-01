defmodule ElButler.Scheduler do
  @moduledoc """
  Scheduler that runs the tasks it's given on regular basis. The tasks
  and the frequency they are ran are set when starting the
  scheduler with start_link
  """
  use GenServer

  # Client

  def start_link({frequency, tasks}) when is_integer(frequency) and is_list(tasks) do
    GenServer.start_link(__MODULE__, {frequency, tasks})
  end

  # Server (callbacks)

  @impl true
  def init({frequency, tasks}) do
    schedule(0)
    {:ok, {frequency, tasks}}
  end

  @impl true
  def handle_info(:run_tasks, {frequency, tasks}) do
    schedule(frequency)
    awaitables = for t <- tasks, do: Task.async(t)
    for a <- awaitables, do: Task.await(a)

    {:noreply, {frequency, tasks}}
  end

  defp schedule(frequency) do
    Process.send_after(self(), :run_tasks, frequency)
  end
end
