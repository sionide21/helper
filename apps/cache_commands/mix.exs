defmodule CacheCommands.Mixfile do
  use Mix.Project

  def project do
    [app: :cache_commands,
     version: "0.1.0",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger],
     mod: {CacheCommands.Application, []}]
  end

  defp deps do
    [
      {:helper_core, in_umbrella: true},
      {:porcelain, "~> 2.0"},
      {:timex, "~> 3.1"},
    ]
  end

  defp aliases do
    [
      test: "test --no-start",
    ]
  end
end
