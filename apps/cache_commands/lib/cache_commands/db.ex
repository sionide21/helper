defmodule CacheCommands.DB do
  use GenServer

  def start_link(name: name) do
    GenServer.start_link(__MODULE__, [], name: name)
  end

  def init([]) do
    {:ok, file} = HelperCore.Config.file("commands.db")
    {:ok, table} = :dets.open_file(__MODULE__, file: to_charlist(file))
    {:ok, %{table: table}}
  end

  def write(key, value, opts \\ []) do
    get_server(opts)
    |> GenServer.cast({:write, key, value})
  end

  def values(opts \\ []) do
    get_server(opts)
    |> GenServer.call(:values)
  end

  def handle_cast({:write, key, value}, state) do
    :ok = :dets.insert(state.table, {key, value})
    {:noreply, state}
  end

  def handle_call(:values, _from, state) do
    values = :dets.foldr(fn {_, value}, acc -> [value | acc] end, [], state.table)
    {:reply, values, state}
  end

  defp get_server([]), do: __MODULE__
  defp get_server(pid: pid), do: pid
end
