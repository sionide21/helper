defmodule HelperCore.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(HelperCore.Server, []),
    ]

    opts = [strategy: :one_for_one, name: HelperCore.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
