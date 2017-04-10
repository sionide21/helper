defmodule HelperCore.Commands.TestServerSide do
  require Logger
  use HelperCore.Command

  def handle_command(command) do
    {:ok, dir} = query(command, "pwd")
    echo(command, "PWD #{String.trim(dir)}")

    {files, 0} = System.cmd("ls", ["-l"], cd: String.trim(dir))
    command
    |> print(files)
    |> quit()
  end
end
