defmodule Insights.Adapters.Keenex.Api do
  alias Keenex.Base

  def get(endpoint, params \\ []) do
    Base.url(endpoint, params)
    |> Keenex.Http.get
    |> Base.to_response
  end

  def post(endpoint, params, options \\ []) do
    Base.post(endpoint, params, options)
  end
end
