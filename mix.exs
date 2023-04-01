defmodule CfWait.MixProject do
  use Mix.Project

  def project do
    [
      app: :cf_wait,
      version: "0.1.0",
      elixir: "~> 1.9",
      escript: escript(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:configparser_ex, "~> 4.0"},
      {:ex_aws, "~> 2.4"},
      {:hackney, "~> 1.15"},
      {:poison, "~> 3.1"},
      # TODO: check https://nvd.nist.gov/vuln/detail/CVE-2019-15160?cpeVersion=2.2 and https://github.com/kbrw/sweet_xml/issues/71
      {:sweet_xml, "~> 0.6"}
    ]
  end

  defp escript do
    [
      name: "cf-wait",
      main_module: CfWait.CLI
    ]
  end
end
