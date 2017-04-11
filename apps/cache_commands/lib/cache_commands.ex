defmodule CacheCommands do
  alias CacheCommands.{CommandSupervisor, PeriodicCommand}
  def get(cmd, refresh: refresh) do
    cmd
    |> CommandSupervisor.get_command()
    |> PeriodicCommand.get(refresh: refresh)
  end
end
