defmodule HelperCore.Server do
  use Supervisor
  alias __MODULE__.{Listener, ClientSupervisor}

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      worker(Listener, [[port: 1221, name: Listener]]),
      supervisor(ClientSupervisor, [[name: ClientSupervisor]])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
