defmodule CacheCommands.Runner do
  use GenServer
  require Logger

  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  def init([]) do
    {:ok, []}
  end

  def execute(pid, cmd) do
    GenServer.call(pid, {:execute, cmd})
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
    cmd
    |> log_value("Run")
    |> do_execute()
    |> log_value("Result")
  end

  defp do_execute(cmd) do
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

  defp log_value(val, msg) do
    Logger.debug("#{msg} #{inspect val}")
    val
  end
end
