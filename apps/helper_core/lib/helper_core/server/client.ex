defmodule HelperCore.Server.Client do
  use GenServer

  def start_link(socket) do
    GenServer.start_link(__MODULE__, socket: socket)
  end

  def init(socket: socket) do
    accept_line(socket)
    {:ok, socket}
  end

  def handle_info({:tcp, _, packet}, socket) do
    IO.puts("Client sent: #{inspect(packet)}")
    :ok = :gen_tcp.send(socket, "I HEAR YOU\n")
    :gen_tcp.close(socket)
    {:noreply, socket}
  end
  def handle_info({:tcp_closed, _}, socket) do
    {:stop, {:shutdown, :client_disconnect}, socket}
  end

  defp accept_line(socket) do
    :inet.setopts(socket, active: :once)
  end
end
