defmodule CacheCommands.CommandSupervisor do
  use Supervisor
  alias CacheCommands.PeriodicCommand

  def start_link(name: name) do
    Supervisor.start_link(__MODULE__, [], name: name)
  end

  def init([]) do
    children = [
      worker(PeriodicCommand, [], restart: :transient)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

  def list_commands(opts \\ []) do
    get_supervisor(opts)
    |> Supervisor.which_children()
    |> lookup_commands()
    |> Enum.sort
  end

  def get_command(cmd, opts \\ []) do
    get_supervisor(opts)
    |> Supervisor.start_child([cmd])
    |> case do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  defp get_supervisor(supervisor: sup), do: sup
  defp get_supervisor(_), do: __MODULE__

  defp lookup_commands(child_specs) do
    lookup_commands([], child_specs)
  end
  defp lookup_commands(acc, [child_spec | rest]) do
    [lookup_command(child_spec) | acc]
    |> lookup_commands(rest)
  end
  defp lookup_commands(acc, []) do
    acc
  end

  defp lookup_command({_, pid, _, _}) do
    PeriodicCommand.info(pid)
  end
end
