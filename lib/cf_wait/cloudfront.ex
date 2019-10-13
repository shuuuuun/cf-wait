defmodule CfWait.CloudFront do
  use ExAws.Utils,
    format_type: :xml,
    non_standard_keys: %{}

  @version "2019-03-26"

  def list_distributions(opts \\ []) do
    # opts
    # # |> request(:list_distributions)
    # |> request(:distribution)
    request(:get, :distribution, params: opts)
    |> (fn arg -> IO.puts(inspect(arg)); arg end).()
    |> ExAws.request(debug_requests: true)
  end

  defp request(params, action) do
    action_string = action |> Atom.to_string |> Macro.camelize

    %ExAws.Operation.Query{
      # path: "/",
      path: "/#{@version}/#{action}",
      # params: params |> filter_nil_params |> Map.put("Action", action_string) |> Map.put("Version", @version),
      service: :cloudfront,
      action: action,
      # parser: &ExAws.Cloudformation.Parsers.parse/3
    }
  end

  defp request(http_method, action, opts) do
    path = Keyword.get(opts, :path, "")
    params = opts |> Keyword.get(:params, []) |> rename_keys(max_items: :maxitems) |> Map.new
    %ExAws.Operation.RestQuery{
      http_method: http_method,
      path: "/#{@version}/#{action}#{path}",
      params: params,
      body: Keyword.get(opts, :body, ""),
      service: :cloudfront,
      action: action,
      # parser: &ExAws.Route53.Parsers.parse/2
    }
  end
end
