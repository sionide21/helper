use Mix.Config

config :helper_core, command: HelperCore.Commands.Dispatch

config :logger, :console,
  level: :debug,
  format: "$time [$level]$levelpad [ $metadata] $message\n",
  metadata: [:pid, :module]
