defmodule CfWait.CLI do
  @wait_interval 60 * 1000

  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [help: :boolean], aliases: [h: :help])
    # IO.puts "parsed args: #{inspect parse}"
    case parse do
      { [ help: true ], _, _ } -> :help
      { _, [ "list-distributions" ], _ } -> :list_distributions
      _ -> :run
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
    list_distributions()
    |> select_distribution
    |> wait_deployed
    |> IO.inspect
    # |> notify_deployed
  end
  def process(:list_distributions) do
    list_distributions()
    |> IO.inspect
  end

  defp list_distributions do
    res =
      CfWait.CloudFront.list_distributions
      # |> ExAws.request!
      |> ExAws.request!(debug_requests: true)
    # TODO: debug mode
    # IO.puts "res: #{inspect res}"
    res.body.items
  end

  defp select_distribution(distributions) do
    distributions
    |> Enum.with_index
    |> Enum.each(fn {dist, index} ->
      IO.puts "#{index}: #{inspect dist}"
    end)
    index_list = 0..(Enum.count(distributions)-1) |> Enum.join("/")
    selected = IO.gets("which distribution? (#{index_list}) ") |> String.trim
    selected_num =
      case Integer.parse(selected) do
        {num, _} -> num
        :error -> 0
      end
    Enum.at distributions, selected_num
  end

  defp wait_deployed(distribution) do
    # ref. https://docs.aws.amazon.com/cli/latest/reference/cloudfront/wait/distribution-deployed.html
    # CfWait.CloudFront.wait_distribution_deployed
    # |> ExAws.request!
    id = distribution.id
    IO.puts "id: #{id}"
    res =
      CfWait.CloudFront.get_distribution(id)
      # |> (fn arg -> IO.puts(inspect(arg)); arg end).()
      |> ExAws.request!(debug_requests: true)
    case res.body do
      %{ id: ^id, status: "Deployed" } -> :ok
      %{ id: ^id, status: _ } = body -> _wait_deployed(body)
    end
  end

  defp _wait_deployed(distribution) do
    # TODO: max iteration count
    IO.puts "status: #{distribution.status}"
    :timer.sleep(@wait_interval)
    wait_deployed(distribution)
  end
end
