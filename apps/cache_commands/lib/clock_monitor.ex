defmodule ClockMonitor do
  @moduledoc """
  Detects changes to the system clock and notifies subscribers.

  A `timer` - such as Process.send_after - uses erlangs [monotonic_time][1] to
  detect when it should fire. This works very well in most cases because we
  generally don't want external factors affecting our timers. In some cases
  however, we're actually more interested in the system time.

  For example, if you set a timer for 1 day, you expect it to fire
  24 hours later. If the computer hibernates for 8 hours, the monotonic clock
  will pick back up where it left off and instead, your timer will fire after 30
  hours. The computer itself will know 30 hours have passed, because it will
  correct it's own clock on wakeup.

  In order to fire after 24 hours, we can monitor the clock offset. If it changes,
  we can simply reschedule the timer based on either: how much it changed by, or
  the original time we wanted 24 hours from.

  *NOTE* This module only works if you are running erlang in [Multi-Time Warp Mode][2].

  1: http://erlang.org/doc/man/erlang.html#monotonic_time-0 Erlang `monotonic_time` funciton
  2: http://erlang.org/doc/apps/erts/time_correction.html#Multi_Time_Warp_Mode Multi-Time Warp Mode
  """
  defdelegate start_link(opts), to: ClockMonitor.Supervisor

  def subscribe do
    {:ok, _} = Registry.register(ClockMonitor.Registry, ClockMonitor.Monitor, nil)
    :ok
  end

  def notify(change) do
    Registry.dispatch(ClockMonitor.Registry, ClockMonitor.Monitor, fn entries ->
      for {pid, _} <- entries, do: send(pid, {:clock_changed, change})
    end)
  end
end
