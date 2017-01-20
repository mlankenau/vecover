defmodule Vecover.Mixfile do
  use Mix.Project

  def project do
    [app: :vecover,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     test_coverage: [tool: Vecover],
     spec_paths: ["spec"],
     spec_pattern: "*_spec.exs",
     preferred_cli_env: [espec: :test],
     deps: deps()]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [ {:espec, "~> 0.8.21", only: :test}]
  end
end
