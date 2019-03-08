defmodule SqsService.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex_sqs_service,
      version: "0.2.1",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      preferred_cli_env: [
        espec: :test
      ],
      deps: deps()
    ]
  end

  def application do
    [applications: [:logger, :sweet_xml, :poison]]
  end

  defp deps do
    [
      {:ex_aws, "~> 2.1",   optional: true},
      {:ex_aws_sqs, "~> 2.0", optional: true},
      {:sweet_xml, "~> 0.6.5"},
      {:poison, "~> 3.1.0", override: true},
      {:espec, "~> 1.4.6",  only: :test, app: false},
      {:dogma, "~> 0.1.14", only: [:dev, :test]},
      {:credo, "~> 0.8.10", only: [:dev, :test]}
    ]
  end
end
