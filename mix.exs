defmodule ElButler.MixProject do
  use Mix.Project

  def project do
    [
      app: :elbutler,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ElButler.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:quantum, "~> 2.3"},
      {:timex, "~> 3.0"},
      {:telegram, git: "https://github.com/visciang/telegram.git"}
    ]
  end
end
