defmodule Insights.Mixfile do
  use Mix.Project

  @version "0.0.1"
  @github_repository "https://github.com/gullitmiranda/insights"
  @adapters [:keenex]

  def project do
    [app: :insights,
     version: @version,
     elixir: "~> 1.0",
     deps: deps,

     # Hex
     description: description,
     package: package,

     # Docs
     name: "Insights",
     docs: [source_ref: "v#{@version}",
            source_url: @github_repository]]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    []
  end

  defp description do
    """
    Insights is a wrapper for sending and data capture for keen.io or others adapters
    """
  end

  defp package do
    [ # These are the default files included in the package
      contributors: ["Gullit Miranda"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => @github_repository},
      files: ~w(mix.exs README* LICENSE* CHANGELOG.md lib test)]
  end
end
