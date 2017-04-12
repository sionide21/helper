defmodule CacheCommands.PeriodicCommand do
  use GenServer
  require Logger
  alias CacheCommands.{CommandRegistry, Runner}

  defmodule State do
    defstruct [command: nil, runner: nil, timer: nil, refresh: nil, result: nil]
  end

  def start_link(command) do
    GenServer.start_link(__MODULE__, [command], name: name(command))
  end

  defp name(command) do
    {:via, Registry, {CommandRegistry, command}}
  end

  def init([command]) do
    {:ok, runner} = Runner.start_link()
    {:ok, %State{command: command, runner: runner}}
  end

  def get(pid, refresh: refresh) do
    GenServer.call(pid, {:get, refresh: 1000 * refresh})
  end

  def handle_call({:get, refresh: refresh}, _from, state=%{result: nil}) do
    with {:ok, result} <- Runner.execute(state.runner, state.command),
         timer <- Process.send_after(self(), :refresh, refresh),
         state <- %{state | result: result, timer: timer, refresh: refresh}
    do
      {:reply, {:ok, result}, state}
    else
      e -> {:reply, e, state}
    end
  end
  def handle_call({:get, refresh: refresh}, _from, state=%{result: result, refresh: refresh}) do
    {:reply, {:ok, result}, state}
  end
  def handle_call({:get, refresh: refresh}, _from, state=%{result: result, refresh: old_refresh}) do
    Process.cancel_timer(state.timer)
    |> case do
      false ->
        {:reply, {:ok, result}, %{state | refresh: refresh}}
      remaining ->
        new_time = max(0, refresh - (old_refresh - remaining))
        Logger.debug("Refresh changed from #{old_refresh} to #{refresh}. Updating timer from #{remaining} to #{new_time}")
        timer = Process.send_after(self(), :refresh, new_time)
        {:reply, {:ok, result}, %{state | timer: timer, refresh: refresh}}
    end
  end

  def handle_info(:refresh, state) do
    Logger.debug("Refreshing \"#{state.command}\"")
    Runner.execute_async(state.runner, state.command)
    {:noreply, state}
  end
  def handle_info({:result, {:ok, result}}, state) do
    timer = Process.send_after(self(), :refresh, state.refresh)
    {:noreply, %{state | result: result, timer: timer}}
  end
  def handle_info({:result, {:error, error}}, state) do
    Logger.warn("Error refreshing \"#{state.command}\": #{inspect error}")
    {:stop, error, state}
  end
end
