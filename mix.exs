defmodule NervesBackdoor.MixProject do
  use Mix.Project

  @github_organization "samuelventura"
  @app :nerves_backdoor
  @source_url "https://github.com/#{@github_organization}/#{@app}"
  @version Path.join(__DIR__, "VERSION")
           |> File.read!()
           |> String.trim()

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      docs: docs(),
      aliases: aliases(),
      description: description()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :plug, :jason, :plug_cowboy, :mac_address, :circuits_gpio],
      mod: {NervesBackdoor.Application, []},
      env: [
        port: 31680,
        name: "nerves",
        home: "/data/backdoor",
        version: @version,
        ifname: "eth0",
        io_push: 47,
        io_red: 66,
        io_green: 69,
        io_blue: 45,
        blink_ms: 200,
        blink_color: :blue,
        reset_color: :red,
        reset_ms: 3000
      ]
    ]
  end

  defp aliases do
    [
      test: "test --no-start"
    ]
  end

  defp deps do
    [
      {:plug, "~> 1.7"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      {:mac_address, "~> 0.0.1"},
      {:circuits_gpio, "~> 0.4"},
      {:cors_plug, "~> 2.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      extras: ["README.md"],
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end

  defp package do
    [
      files: ["lib", "test", "mix.*", "*.exs", "*.md", ".gitignore", "LICENSE", "VERSION"],
      maintainers: ["Samuel Ventura"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp description do
    """
    Setup and Maintenance Tools with RESTish API
    """
  end
end
