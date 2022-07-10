defmodule ExFinder.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :ex_finder,
      version: @version,
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      description: "A File Picker for Phoenix",
      deps: deps(),
      aliases: aliases(),
      package: package(),
      docs: docs()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "cmd npm install --prefix assets"],
      dev: "run --no-halt dev.exs"
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Actual deps
      {:jason, "~> 1.0"},
      {:phoenix_live_view, "~> 0.17.7"},

      # Dev and test
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:plug_cowboy, "~> 2.0", only: :dev},
      {:ex_doc, "~> 0.21", only: :docs}
    ]
  end

  defp docs do
    [
      main: "ExFinder",
      source_ref: "v#{@version}",
      source_url: "https://github.com/luisgabrielroldan/ex_finder"
    ]
  end

  defp package do
    [
      maintainers: ["Gabriel Roldán"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/luisgabrielroldan/ex_finder"},
      files: ~w(priv/*.js priv/*.css priv/*.ttf priv/*.woff2 lib mix.exs LICENSE.md README.md)
    ]
  end
end
