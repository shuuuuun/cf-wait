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
      # _ -> :list_distributions
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
    |> IO.inspect
    # |> wait_deployed
    # |> notify_deployed
  end
  def process(:list_distributions) do
    list_distributions()
  end

  defp list_distributions do
    res =
      CfWait.CloudFront.list_distributions
      |> ExAws.request!
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
    # selected = IO.gets("which distribution? (#{index_list}) ") |> String.trim |> String.to_integer
    selected = IO.gets("which distribution? (#{index_list}) ") |> String.trim
    selected_num =
      case Integer.parse(selected) do
        {num, _} -> num
        :error -> 0
      end
    Enum.at distributions, selected_num
  end
end
