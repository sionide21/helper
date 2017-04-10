defmodule HelperCore.Commands.NotFound do
  use HelperCore.Command

  def handle_command(command) do
    die(command, "H.E.L.P.eR.: #{command.name}: command not found")
  end
end
