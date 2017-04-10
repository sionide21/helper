defmodule HelperCore.Commands.Test do
  use HelperCore.Command

  def handle_command(command) do
    command
    |> IO.inspect
    |> execute(:echo, "CMD  #{command.name}")
    |> execute(:echo, "ARGS #{command.args}")
    |> IO.inspect

    {:ok, files} = command
    |> query("ls -l")
    |> IO.inspect

    command
    |> execute(:print, files)

    command
    |> execute(:exit, 21)

    command
  end
end
