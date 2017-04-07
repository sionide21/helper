defmodule HelperCore.Server.Listener do
  use GenServer
  alias HelperCore.Server.ClientSupervisor

  def start_link(port: port, name: name) do
    GenServer.start_link(__MODULE__, [port: port], name: name)
  end

  def init(port: port) do
    {:ok, socket} = :gen_tcp.listen(port, [
      :binary,
      active: false,
      backlog: 2048,
      ip: {127,0,0,1},
      nodelay: true,
      packet: :line,
      reuseaddr: true,
    ])
    send(self(), :accept)
    {:ok, socket}
  end

  def handle_info(:accept, socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    ClientSupervisor.handle_client(client)
    send(self(), :accept)
    {:noreply, socket}
  end
end
