defmodule CacheCommands.Runner do
  use GenServer
  require Logger

  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  def init([]) do
    {:ok, []}
  end

  def execute(pid, cmd, timeout) do
    GenServer.call(pid, {:execute, cmd}, timeout)
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

  defp do_execute([cmd | args]) do
    cmd
    |> Porcelain.exec(args, err: :string)
    |> case do
      %{out: out, status: 0} -> {:ok, out}
      %{err: err, status: s} -> {s, err}
      {:error, error}        -> {1, error}
    end
  end

  defp log_value(val, msg) do
    Logger.debug("#{msg} #{inspect val}")
    val
  end
end
