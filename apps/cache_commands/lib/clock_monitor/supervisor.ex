defmodule ClockMonitor.Supervisor do
  use Supervisor
  alias ClockMonitor.Monitor

  def start_link(name: name) do
    Supervisor.start_link(__MODULE__, [], name: name)
  end

  def init([]) do
    children = [
      worker(Monitor, [[name: Monitor]]),
      supervisor(Registry, [:duplicate, ClockMonitor.Registry]),
    ]

    supervise(children, strategy: :one_for_one)
  end
end
