defmodule DataFetching.MixProject do
  use Mix.Project

  def project do
    [
      app: :data_fetching,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {DataFetching.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:eventsource_ex, "~> 0.0.2"},
      {:sweet_xml, "~> 0.6.5"},
      {:poison, "~> 3.1"}
    ]
  end
end
