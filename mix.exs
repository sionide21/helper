defmodule HelperUmbrella.Mixfile do
  use Mix.Project

  def project do
    [app: :helper_umbrella,
     apps_path: "apps",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  defp deps do
    []
  end
end
