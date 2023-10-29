defmodule Homeassistant.MixProject do
  use Mix.Project

  def project do
    [
      app: :homeassistant,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Homeassistant.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:emqtt, github: "emqx/emqtt", tag: "1.9.1", system_env: [{"BUILD_WITHOUT_QUIC", "1"}]},
      {:jason, "~> 1.0"}
    ]
  end
end