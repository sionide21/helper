defmodule CacheCommands.PeriodicCommand do
  use GenServer
  require Logger
  alias CacheCommands.CommandRegistry

  def start_link(command) do
    GenServer.start_link(__MODULE__, [command], name: name(command))
  end

  defp name(command) do
    {:via, Registry, {CommandRegistry, command}}
  end

  def init([command]) do
    {:ok, %{command: command}}
  end

  def get(pid, refresh: refresh) do
    GenServer.call(pid, {:get, refresh: refresh})
  end

  def handle_call({:get, refresh: refresh}, _from, state) do
    with {:ok, result} <- execute(state.command, refresh: refresh)
    do
      {:reply, {:ok, result}, state}
    else
      e -> {:reply, e, state}
    end
  end

  defp execute(cmd, refresh: _) do
    with [cmd | args] <- OptionParser.split(cmd),
         {results, 0} <- System.cmd(cmd, args)
    do
      {:ok, results}
    else
      {error, status} -> {status, error}
    end
  rescue
    e in ErlangError ->
      case e.original do
        :enoent -> {1, "#{cmd}: command not found"}
        error -> {1, error}
      end
    e ->
      {1, Exception.message(e)}
  end
end
