defmodule CfWait.CLI do
  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [help: :boolean], aliases: [h: :help])
    case parse do
      { [ help: true ], _, _ } -> :help
      # { _, [ user, project, count ], _ } -> { user, project, String.to_integer(count) }
      _ -> :list_distributions
      # _ -> :help
    end
  end

  def process(:help) do
    IO.puts """
    usage: cf-wait
    """
    System.halt(0)
  end
  def process(:run) do
    # list_distributions
    # |> select_distribution
    # |> wait_deployed
    # |> notify_deployed
  end
  def process(:list_distributions) do
    CfWait.CloudFront.list_distributions
    |> ExAws.request!
  end
end
