defmodule CacheCommands.Commands.Maintain do
  use HelperCore.Command

  def handle_command(command) do
    command
    |> parse()
    |> execute()
    |> reply(command)
  end

  defp parse(command) do
    with {opts, cmd, _} <- parse_head(command, strict: [refresh: :string]),
         {:ok, refresh} <- get_refresh(opts),
    do: {:ok, cmd, refresh}
  end

  defp execute({:ok, cmd, refresh}) do
    CacheCommands.get(cmd, refresh: refresh)
  end
  defp execute(error), do: error

  defp reply({:ok, value}, command) do
    command
    |> print(value)
    |> quit()
  end
  defp reply({status, error}, command) do
    die(command, error, status)
  end

  defp get_refresh(opts) do
    opts
    |> Keyword.get(:refresh, "10m")
    |> parse_refresh()
  end

  defp parse_refresh(str) when is_binary(str) do
    str
    |> Integer.parse
    |> parse_refresh()
  end
  defp parse_refresh({n, ""}),   do: {:ok, n}
  defp parse_refresh({n, "s"}),  do: {:ok, n}
  defp parse_refresh({n, "m"}),  do: {:ok, n * 60}
  defp parse_refresh({n, "h"}),  do: {:ok, n * 60 * 60}
  defp parse_refresh({n, "d"}),  do: {:ok, n * 24 * 60 * 60}
  defp parse_refresh({_, unit}), do: {1, "Unknown time unit: #{inspect unit}"}
end
