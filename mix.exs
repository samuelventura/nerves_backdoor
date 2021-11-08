defmodule NervesBackdoor.MixProject do
  use Mix.Project

  def project do
    [
      app: :nerves_backdoor,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {NervesBackdoor.Application, []},
      env: [port: port()]
    ]
  end

  defp port do
    case Mix.env() do
      :prod -> 80
      _ -> 4000
    end
  end

  defp deps do
    [
      {:plug, "~> 1.7"},
      {:poison, "~> 5.0"},
      {:plug_cowboy, "~> 2.5"}
    ]
  end
end
