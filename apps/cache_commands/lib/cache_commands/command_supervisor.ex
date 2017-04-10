defmodule CacheCommands.CommandSupervisor do
  use Supervisor
  alias CacheCommands.PeriodicCommand

  def start_link(name: name) do
    Supervisor.start_link(__MODULE__, [], name: name)
  end

  def init([]) do
    children = [
      worker(PeriodicCommand, [], restart: :permanent)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

  def get_command(cmd) do
    __MODULE__
    |> Supervisor.start_child([cmd])
    |> case do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end
end
