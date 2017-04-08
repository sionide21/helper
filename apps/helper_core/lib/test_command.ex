defmodule HelperCore.TestCommand do
  use HelperCore.Command
  alias HelperCore.Context

  def handle_command(command) do
    command
    |> IO.inspect
    |> Context.execute(:echo, "CMD  #{command.name}")
    |> Context.execute(:echo, "ARGS #{command.args}")
    |> IO.inspect

    {:ok, files} = command
    |> Context.query("lss -l")
    |> IO.inspect

    command
    |> Context.execute(:print, String.reverse(files))

    command
    |> Context.execute(:exit, 21)

    command
  end
end
