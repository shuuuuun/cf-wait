defmodule CfWait.CloudFront do
  def list_distributions do
    action = :list_distributions
    action_string = action |> Atom.to_string |> Macro.camelize

    operation =
      %ExAws.Operation.Query{
        path: "/",
        params: %{"Action" => action_string},
        service: :cloudfront,
        action: action
      }

    ExAws.request(operation)
  end
end
