defmodule Insights.Adapters.Keenex.Query do
  alias Insights.Adapters.Keenex.Query.Filters

  def params(collection, params) when is_bitstring(collection) do
    params([ event_collection: collection] ++ params)
  end

  def params(query) do
    if filters = query[:filters] do
      query = Keyword.put(query, :filters, Filters.parse(filters))
    end

    query
  end
end
