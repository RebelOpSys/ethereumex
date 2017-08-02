defmodule Ethereumex.Mixfile do
  use Mix.Project

  def project do
    [app: :ethereumex,
     version: "0.1.1",
     elixir: "~> 1.4",
     description: "Elixir JSON-RPC client for the Ethereum blockchain",
     package: [
       maintainers: ["Ayrat Badykov"],
       licenses: ["MIT"],
       links: %{"GitHub" => "https://github.com/ayrat555/ethereumex"}
     ],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     elixirc_paths: elixirc_paths(Mix.env)]
  end

  def application do
    [extra_applications: [:logger],
     mod: {Ethereumex, []}]
  end

  defp deps do
    [{:httpoison, "~> 0.11.1"},
     {:poison, "~> 3.1.0"},
     {:exvcr, "~> 0.8", only: :test},
     {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
     {:ex_doc, "~> 0.14", only: :dev, runtime: false},
     {:uuid, "~> 1.1"},
     {:poison, ">=0.0.0"}]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
