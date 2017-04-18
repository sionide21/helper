defmodule CacheCommands do
  alias CacheCommands.{CommandSupervisor, DB, PeriodicCommand}

  def get(cmd, refresh: refresh) do
    cmd
    |> CommandSupervisor.get_command()
    |> PeriodicCommand.get(refresh: refresh)
  end

  def restore_commands() do
    Enum.each(DB.values(), fn command_state ->
      CommandSupervisor.get_command(command_state)
    end)
  end
end
