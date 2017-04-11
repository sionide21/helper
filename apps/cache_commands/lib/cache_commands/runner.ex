defmodule CacheCommands.Runner do
  use GenServer
  require Logger
  alias CacheCommands.CommandRegistry

  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  def init([]) do
    {:ok, []}
  end

  def execute(pid, cmd) do
    Logger.debug("Run #{inspect cmd}")
    val = GenServer.call(pid, {:execute, cmd})
    Logger.debug("Result #{inspect val}")
    val
  end

  def execute_async(pid, cmd) do
    GenServer.cast(pid, {:execute, cmd, self()})
  end

  def handle_call({:execute, cmd}, _from, state) do
    {:reply, execute(cmd), state}
  end

  def handle_cast({:execute, cmd, from}, state) do
    result = execute(cmd)
    send(from, {:result, result})

    {:noreply, state}
  end

  defp execute(cmd) do
    with [cmd | args] <- cmd,
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
