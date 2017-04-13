defmodule CacheCommands.Commands.Status do
  use HelperCore.Command
  alias CacheCommands.CommandSupervisor

  def handle_command(command) do
    CommandSupervisor.list_commands()
    |> Enum.map(&ARGV.to_string/1)
    |> Enum.join("\t\n")
    |> apply_fn(fn cmds ->
      command
      |> echo("Commands Being Maintained:\n#{cmds}")
      |> quit
    end)
  end

  defp apply_fn(arg, fun) do
    fun.(arg)
  end
end
