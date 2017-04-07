defmodule HelperCore.Server.ClientSupervisor do
  use Supervisor
  alias HelperCore.Server.Client

  def start_link(name: name) do
    Supervisor.start_link(__MODULE__, [], name: name)
  end

  def init([]) do
    children = [
      worker(Client, [], restart: :temporary)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

  def handle_client(client_socket, opts \\ []) do
    supervisor = Keyword.get(opts, :supervisor, __MODULE__)
    {:ok, pid} = Supervisor.start_child(supervisor, [client_socket])
    :ok = :gen_tcp.controlling_process(client_socket, pid)
    {:ok, pid}
  end
end
