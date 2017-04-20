defmodule ClockMonitor.Monitor do
  use GenServer
  require Logger

  def start_link(name: name) do
    GenServer.start_link(__MODULE__, [], name: name)
  end

  def init([]) do
    monitor = :erlang.monitor(:time_offset, :clock_service)
    {:ok, %{monitor: monitor, offset: System.time_offset}}
  end

  # TODO We may want a threshold below which we don't trigger, I see a ton of 2ms changes
  # This may be the time correction kicking in, it speeds up the monotonic clock a bit to
  # try and catch up w/ system time
  def handle_info({:CHANGE, _, :time_offset, :clock_service, new_offset}, state) do
    change = change_millis(state, new_offset)
    Logger.debug("System time changed by #{change} ms!")
    ClockMonitor.notify({change, :millisecond})
    {:noreply, %{state | offset: new_offset}}
  end

  defp change_millis(%{offset: old}, new) do
    new - old
    |> :erlang.convert_time_unit(:native, :millisecond)
  end
end
