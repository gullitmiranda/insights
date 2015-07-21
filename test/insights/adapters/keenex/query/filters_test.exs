defmodule Insights.Adapters.Keenex.Query.FiltersTest do
  use ExUnit.Case, async: true

  alias Insights.Adapters.Keenex.Query
  alias Insights.Adapters.Keenex.Query.Filters

  test "map = to eq filter" do
    filter = "url=https://github.com/azukiapp/feedbin"

    assert Filters.parse(filter) == %{
      property_name:  "url",
      operator:       "eq",
      property_value: "https://github.com/azukiapp/feedbin",
    }
  end

  test "map >= to gte filter" do
    filter = "count>=2"

    assert Filters.parse(filter) == %{
      property_name:  "count",
      operator:       "gte",
      property_value: "2",
    }
  end

  test "map multiple filters" do
    filter = ["count<=2", "runs>10", "repo!=azukiapp/azk"]

    assert Filters.parse(filter) == [
      %{
        property_name:  "count",
        operator:       "lte",
        property_value: "2",
      },
      %{
        property_name:  "runs",
        operator:       "gt",
        property_value: "10",
      },
      %{
        property_name:  "repo",
        operator:       "ne",
        property_value: "azukiapp/azk",
      },
    ]
  end

  test "process params" do
    query = Query.params("start", filters: ["url=https://github.com/azukiapp/feedbin"])
    |> Enum.sort

    assert query == [
      event_collection: "start",
      filters: [
        %{operator: "eq", property_name: "url", property_value: "https://github.com/azukiapp/feedbin"}
      ],
    ]
  end
end
