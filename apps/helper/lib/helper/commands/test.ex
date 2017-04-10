defmodule Helper.Commands.Test do
  require Logger
  use HelperCore.Command

  def handle_command(command) do
    command
    |> debug_inspect
    |> echo("CMD  #{command.name}")
    |> echo("ARGS #{command.args}")
    |> debug_inspect

    {:ok, files} = command
    |> query("ls -l")
    |> debug_inspect

    command
    |> print(files)
    |> quit(21)
  end

  defp debug_inspect(value) do
    value
    |> inspect()
    |> Logger.debug()

    value
  end
end
