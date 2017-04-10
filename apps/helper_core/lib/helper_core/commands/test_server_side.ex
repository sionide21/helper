defmodule HelperCore.Commands.TestServerSide do
  require Logger
  use HelperCore.Command

  def handle_command(command) do
    {:ok, dir} = query(command, "pwd")
    execute(command, :echo, "PWD #{String.trim(dir)}")

    {files, 0} = System.cmd("ls", ["-l"], cd: String.trim(dir))
    command
    |> execute(:print, files)
    |> execute(:exit, 0)
  end
end
