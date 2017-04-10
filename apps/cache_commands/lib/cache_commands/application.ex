defmodule CacheCommands.Application do
  @moduledoc false
  use Application
  alias CacheCommands.{CommandRegistry, CommandSupervisor}

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(CommandSupervisor, [[name: CommandSupervisor]]),
      supervisor(Registry, [:unique, CommandRegistry]),
    ]

    opts = [strategy: :one_for_one, name: CacheCommands.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
