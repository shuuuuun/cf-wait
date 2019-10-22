defmodule CfWait.CLI do
  @wait_interval 60 * 1000

  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  def parse_args(argv) do
    # TODO: wait_interval option
    # TODO: aws-profile option
    parse =
      OptionParser.parse(argv, switches: [help: :boolean, debug: :boolean], aliases: [h: :help])

    # IO.puts "parsed args: #{inspect parse}"
    case parse do
      {[help: true], _, _} ->
        :help

      {opts, ["list-distributions"], _} ->
        {:list_distributions, opts}

      {opts, _, _} ->
        {:run, opts}

      _ ->
        {:run, []}
        # _ -> :help
    end
  end

  def process(:help) do
    IO.puts("""
    usage: cf-wait
    """)

    System.halt(0)
  end

  def process({:run, opts}) do
    # TODO: check aws configuration
    list_distributions(opts)
    |> select_distribution(opts)
    |> wait_deployed(opts)
    |> notify_deployed

    # |> IO.inspect
  end

  def process({:list_distributions, opts}) do
    list_distributions(opts)
    |> IO.inspect()
  end

  defp list_distributions(opts) do
    is_debug = Keyword.get(opts, :debug, false)

    res =
      CfWait.CloudFront.list_distributions()
      |> ExAws.request!(debug_requests: is_debug)

    # IO.puts "res: #{inspect res}"
    res.body.items
  end

  defp select_distribution(distributions, _opts) do
    distributions
    |> Enum.with_index()
    |> Enum.each(fn {dist, index} ->
      # TODO: beautify outputs. table format?
      IO.puts("#{index}: #{inspect(dist)}")
    end)

    index_list = 0..(Enum.count(distributions) - 1) |> Enum.join("/")
    selected = IO.gets("which distribution? (#{index_list}) ") |> String.trim()

    selected_num =
      case Integer.parse(selected) do
        {num, _} -> num
        :error -> 0
      end

    selected_dist = Enum.at(distributions, selected_num)
    # TODO: beautify outputs.
    IO.puts("#{selected_num}: #{inspect(selected_dist)}")
    selected_dist
  end

  defp wait_deployed(distribution, opts) do
    # ref. https://docs.aws.amazon.com/cli/latest/reference/cloudfront/wait/distribution-deployed.html
    is_debug = Keyword.get(opts, :debug, false)
    id = distribution.id

    res =
      CfWait.CloudFront.get_distribution(id)
      |> ExAws.request!(debug_requests: is_debug)

    case res.body do
      %{id: ^id, status: "Deployed"} -> :ok
      %{id: ^id, status: _} = body -> _wait_deployed(body, opts)
    end
  end

  defp _wait_deployed(distribution, opts) do
    # TODO: max iteration count
    IO.puts("status: #{distribution.status}")
    :timer.sleep(@wait_interval)
    wait_deployed(distribution, opts)
  end

  defp notify_deployed(:ok) do
    # TODO: optimize notification for each OS.
    IO.puts("Deployed!!!")
  end

  defp notify_deployed(result) do
    IO.puts("result: #{result}")
  end
end
