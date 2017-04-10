defmodule HelperCore.Server.Client do
  use GenServer
  require Logger
  alias HelperCore.Server.Authentication
  @command Application.get_env(:helper_core, :command)

  defmodule State do
    defstruct [:socket, authenticated: false]
  end

  def start_link(socket) do
    GenServer.start_link(__MODULE__, socket: socket)
  end

  def init(socket: socket) do
    Logger.info("Client connected")
    accept_line(socket)
    {:ok, %State{socket: socket}}
  end

  def handle_info({:tcp, _, "auth " <> code}, %{socket: socket}=state) do
    String.trim(code)
    |> Authentication.verify()
    |> case do
      :ok ->
        accept_line(socket)
        {:noreply, %State{state | authenticated: true}}
      {:error, err} ->
        Logger.error("Authentication error: #{err}")
        {:stop, {:shutdown, err}, state}
      end
  end
  def handle_info({:tcp, _, packet}, %{socket: socket, authenticated: true}=state) do
    context = HelperCore.Context.new(packet, socket)
    Logger.info("Command: #{context}")
    @command.handle_command(context)

    accept_line(socket)
    {:noreply, state}
  end
  def handle_info({:tcp, _, packet}, %{authenticated: false}=state) do
    Logger.error("Unauthenticated request: #{inspect packet}")
    {:stop, {:shutdown, :unauthorized}, state}
  end
  def handle_info({:tcp_closed, _}, state) do
    Logger.info("Client disconnected")
    {:stop, {:shutdown, :client_disconnect}, state}
  end

  defp accept_line(socket) do
    :inet.setopts(socket, active: :once)
  end
end
