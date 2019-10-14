# ref. https://docs.aws.amazon.com/ja_jp/cloudfront/latest/APIReference/API_Operations.html
defmodule CfWait.CloudFront do
  use ExAws.Utils,
    format_type: :xml,
    non_standard_keys: %{}

  @version "2019-03-26"

  def list_distributions(opts \\ []) do
    request(:get, :list_distributions, path: "/distribution", params: opts)
    # |> (fn arg -> IO.puts(inspect(arg)); arg end).()
    # |> ExAws.request(debug_requests: true)
  end

  def get_distribution(id, opts \\ []) do
    request(:get, :get_distribution, path: "/distribution/#{id}", params: opts)
  end

  defp request(http_method, action, opts) do
    path = Keyword.get(opts, :path, "")
    params = opts |> Keyword.get(:params, []) |> rename_keys(max_items: :maxitems) |> Map.new

    %ExAws.Operation.RestQuery{
      http_method: http_method,
      path: "/#{@version}/#{path}",
      params: params,
      body: Keyword.get(opts, :body, ""),
      service: :cloudfront,
      action: action,
      parser: &CfWait.CloudFront.Parsers.parse/2
    }
  end
end
