# ref. https://github.com/ex-aws/ex_aws_route53/blob/master/lib/ex_aws/route53/parsers.ex

if Code.ensure_loaded?(SweetXml) do
  defmodule CfWait.CloudFront.Parsers do
    use ExAws.Operation.Query.Parser
    import SweetXml, only: [sigil_x: 2]

    def parse({:ok, resp}, :list_distributions) do
      resp |> parse_xml(~x"//DistributionList",
        is_truncated: ~x"./IsTruncated/text()"s |> to_boolean,
        marker: ~x"./Marker/text()"s,
        max_items: ~x"./MaxItems/text()"i,
        next_marker: ~x"./NextMarker/text()"s,
        quantity: ~x"./Quantity/text()"i,
        items: [
          ~x"./Items/DistributionSummary"l,
          id: ~x"./Id/text()"s,
          status: ~x"./Status/text()"s,
          domain_name: ~x"./DomainName/text()"s,
          comment: ~x"./Comment/text()"s,
          aliases: [
            ~x"./Aliases"l,
            items: [
              ~x"./Items"l,
              cname: ~x"./CNAME/text()"s
            ],
          ],
        ]
      )
    end

    def parse({:ok, resp}, :get_distribution) do
      resp |> parse_xml(~x"//Distribution",
        id:  ~x"./Id/text()"s,
        status:  ~x"./Status/text()"s,
        domain_name:  ~x"./DomainName/text()"s
      )
    end

    def parse(val, _), do: val

    defp to_boolean(xpath) do
      xpath |> SweetXml.transform_by(&(&1 == "true"))
    end

    defp parse_xml(%{body: xml} = resp, xpath, elements) do
      # IO.puts "resp: #{inspect resp}"
      parsed_body = xml |> SweetXml.xpath(xpath, elements)
      {:ok, Map.put(resp, :body, parsed_body)}
    end
  end
else
  defmodule CfWait.CloudFront.Parsers do
    def parse(val, _), do: val
  end
end
