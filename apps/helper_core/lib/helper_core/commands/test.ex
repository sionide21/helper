defmodule HelperCore.Commands.Test do
  require Logger
  use HelperCore.Command

  def handle_command(command) do
    command
    |> debug_inspect
    |> execute(:echo, "CMD  #{command.name}")
    |> execute(:echo, "ARGS #{command.args}")
    |> debug_inspect

    {:ok, files} = command
    |> query("ls -l")
    |> debug_inspect

    command
    |> execute(:print, files)

    command
    |> execute(:exit, 21)

    command
  end

  defp debug_inspect(value) do
    value
    |> inspect()
    |> Logger.debug()

    value
  end
end
