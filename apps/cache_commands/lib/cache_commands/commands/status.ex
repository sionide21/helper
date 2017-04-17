defmodule CacheCommands.Commands.Status do
  use HelperCore.Command
  alias CacheCommands.{CommandSupervisor, PeriodicCommand}

  def handle_command(command) do
    CommandSupervisor.list_commands()
    |> PeriodicCommand.Info.display(headers: true)
    |> apply_fn(fn display ->
      command
      |> echo(display)
      |> quit()
    end)
  end

  defp apply_fn(arg, fun) do
    fun.(arg)
  end
end
