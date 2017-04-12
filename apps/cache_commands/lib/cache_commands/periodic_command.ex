defmodule CacheCommands.PeriodicCommand do
  use GenServer
  require Logger
  alias CacheCommands.{CommandRegistry, Runner}
  @timeout Application.get_env(:cache_commands, :timeout)

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
    GenServer.call(pid, {:get, refresh: 1000 * refresh}, @timeout)
  end

  def handle_call({:get, refresh: refresh}, _from, state=%{result: nil}) do
    Runner.execute(state.runner, state.command, @timeout)
    |> case do
      {:ok, result} ->
        state
        |> schedule_refresh(refresh)
        |> set_interval(refresh)
        |> cache_result(result)
        |> send_result()
      error ->
        {:stop, {:shutdown, error}, error, state}
    end
  end
  def handle_call({:get, refresh: refresh}, _from, state=%{refresh: refresh}) do
    send_result(state)
  end
  def handle_call({:get, refresh: refresh}, _from, state) do
    state
    |> change_interval(refresh)
    |> send_result()
  end

  def handle_info(:refresh, state) do
    Logger.debug("Refreshing #{inspect state.command}")
    Runner.execute_async(state.runner, state.command)
    {:noreply, state}
  end
  def handle_info({:result, {:ok, result}}, state) do
    state = state
    |> schedule_refresh(state.refresh)
    |> cache_result(result)

    {:noreply, state}
  end
  def handle_info({:result, {status, error}}, state) do
    Logger.warn("Error refreshing #{inspect state.command} (#{status}): #{inspect error}")
    {:stop, {:shutdown, error}, state}
  end

  defp schedule_refresh(state, wait) do
    timer = Process.send_after(self(), :refresh, wait)
    %{state | timer: timer}
  end

  defp change_interval(state, refresh) do
    state.timer
    |> Process.cancel_timer()
    |> case do
      remaining when is_integer(remaining) ->
        reschedule(state, refresh, remaining)
      false ->
        set_interval(state, refresh)
    end
  end

  defp reschedule(state, refresh, remaining) do
    new_time = max(0, refresh - (state.refresh - remaining))
    Logger.debug("Refresh changed from #{state.refresh} to #{refresh}. Updating timer from #{remaining} to #{new_time}")

    state
    |> schedule_refresh(new_time)
    |> set_interval(refresh)
  end

  defp cache_result(state, result) do
    %{state | result: result}
  end

  defp set_interval(state, interval) do
    %{state | refresh: interval}
  end

  defp send_result(state) do
    {:reply, {:ok, state.result}, state}
  end
end
