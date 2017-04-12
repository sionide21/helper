use Mix.Config

goon_path = __ENV__.file |> Path.dirname |> Path.join("../bin/goon") |> Path.expand
config :porcelain, :goon_driver_path, goon_path

config :cache_commands, timeout: 60_000
