defmodule CacheCommands.Commands.Maintain do
  use HelperCore.Command

  def handle_command(command) do
    case parse(command) do
      {:ok, cmd, refresh} ->
        cmd
        |> CacheCommands.get(refresh: refresh)
        |> case do
          {:ok, value} ->
            command
            |> print(value)
            |> quit()
          {status, error} ->
            die(command, error, status)
        end
      {:error, error} ->
        die(command, error)
    end
  end

  defp parse(command) do
    with {opts, cmd, _} <- parse_head(command, strict: [refresh: :string]),
         {:ok, refresh} <- opts |> Keyword.get(:refresh, "10m") |> parse_refresh(),
    do: {:ok, cmd, refresh}
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
  defp parse_refresh({_, unit}), do: {:error, "Unknown time unit: #{inspect unit}"}
end
