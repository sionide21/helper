defmodule HelperCore.Commands.NotFound do
  use HelperCore.Command

  def handle_command(command) do
    command
    |> execute(:error, "H.E.L.P.eR.: #{command.name}: command not found")
    |> execute(:exit, 1)

    command
  end
end
