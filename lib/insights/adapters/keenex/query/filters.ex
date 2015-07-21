defmodule Insights.Adapters.Keenex.Query.Filters do

  # eq, ne, lt, gt, exists, in, contains, not_contains
  @binary_ops [
    <=: "lte",
    >=: "gte",
    !=: "ne",
    ==: "eq",
    =: "eq",
    <: "lt",
    >:  "gt",
    # "!=nil": "exists", or: "OR",
    # ilike: "ILIKE", like: "LIKE"
  ]

  def parse(filter) when is_bitstring(filter) do
    split_operator(filter)
  end

  def parse(filters) do
    parse(filters, [])
  end

  def parse(filter, acc) when is_nil(filter), do: acc

  def parse([], acc), do: acc

  def parse([head|tail], acc) do
    parse(tail, acc ++ [parse(head)])
  end

  def split_operator(query) do
    split_operator(query, Keyword.keys(@binary_ops))
  end

  def split_operator(query, [op|next]) do
    case String.split(query, Atom.to_string(op)) do
      [key, value] -> filter_to_map(key, op, value)
      _ -> split_operator(query, next)
    end
  end

  def filter_to_map(key, op, value) do
    %{
      property_name:  key,
      operator:       Keyword.get(@binary_ops, op),
      property_value: value,
    }
  end
end
