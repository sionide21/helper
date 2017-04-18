defmodule CacheCommands.Application do
  @moduledoc false
  use Application
  alias CacheCommands.{CommandRegistry, CommandSupervisor, DB}

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(CommandSupervisor, [[name: CommandSupervisor]]),
      supervisor(Registry, [:unique, CommandRegistry]),
      worker(DB, [[name: DB]]),
      worker(Task, [&CacheCommands.restore_commands/0], restart: :transient),
    ]

    opts = [strategy: :one_for_one, name: CacheCommands.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
