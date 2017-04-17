defmodule CacheCommands.PeriodicCommand.Info do
  defstruct [:command, :interval, :last_refreshed, :next_refresh]

  def new(values) do
    struct(__MODULE__, values)
  end

  def display(info_or_infos, opts \\ [])
  def display(info=%__MODULE__{}, opts) do
    display([info], opts)
  end
  def display(infos, opts) do
    headers = Keyword.get(opts, :headers, false)
    rows = Enum.map(infos, &columns/1)
    rows = if headers do
      [Enum.map(headers(), &elem(&1, 0)) | rows]
    else
      rows
    end
    padding = compute_padding(rows)

    rows
    |> Enum.map(&render_row(&1, padding))
    |> Enum.join("\n")
  end

  defp render_row(row, opts) do
    row
    |> apply_padding(opts)
    |> Enum.join("\t")
  end

  defp columns(info) do
    headers()
    |> Enum.map(fn {_, f} -> f.(info) end)
  end

  def apply_padding(row, padding) do
    row
    |> Enum.with_index()
    |> Enum.map(fn {val, i} ->
      String.pad_trailing(val, Enum.at(padding, i) || 0)
    end)
  end

  defp compute_padding(rows) do
    Enum.zip(rows)
    |> Enum.map(fn col ->
      Tuple.to_list(col)
      |> Enum.map(&byte_size/1)
      |> Enum.reduce(&max/2)
    end)
  end

  def id(%__MODULE__{command: command}) do
    ARGV.to_identifier(command)
  end

  def display_next_refresh(%{next_refresh: next_refresh}) when is_integer(next_refresh) and next_refresh > 0 do
    humanize(next_refresh)
  end
  def display_next_refresh(_), do: "now"

  def display_interval(%{interval: interval}) when is_integer(interval) do
    humanize(interval)
  end
  def display_interval(_), do: ""

  def display_last_refreshed(%{last_refreshed: last_refreshed}) when is_integer(last_refreshed) do
    last_refreshed
    |> Timex.from_unix()
    |> Timex.Timezone.convert(Timex.Timezone.Local.lookup())
    |> Timex.format!("{ANSIC}")
  end
  def display_last_refreshed(_), do: "never"

  defp headers do
    [
      {"ID",           &id/1},
      {"CMD",          &to_string/1},
      {"INTERVAL",     &display_interval/1},
      {"LAST REFRESH", &display_last_refreshed/1},
      {"NEXT REFRESH", &display_next_refresh/1},
    ]
  end

  defp humanize(seconds) do
    seconds
    |> Timex.Duration.from_seconds()
    |> Timex.format_duration(:humanized)
  end

  defimpl String.Chars, for: __MODULE__ do
    def to_string(%{command: command}) do
      ARGV.to_string(command)
    end
  end
end
