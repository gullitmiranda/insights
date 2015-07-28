if Code.ensure_loaded?(Keenex) do

  alias Insights.Adapters.Keenex.Api
  alias Insights.Adapters.Keenex.Query

  defmodule Insights.Adapters.Keenex.Connection do
    @moduledoc false

    ## Connection
    @behaviour Insights.Adapters.Connection

    def connect(%{project_id: project_id, write_key: write_key, read_key: read_key}) do
      Keenex.start_link(project_id, write_key, read_key)
    end

    # Queries

    def query(collection, query, params \\ [], _options \\ []) do
      params = Query.params(collection, params)

      case Api.post(query, params, key: :read) do
        {:ok   , reponse} -> {:ok, reponse["result"]}
        {:error, reponse} -> {:error, reponse}
      end
    end

    def all(collection, params \\ []) do
      params = Query.params(params)
      Api.get([~s(queries/extraction), %{event_collection: collection}], params)
    end

    def count(collection, params \\ []) do
      params = Query.params(collection, params)

      case Api.post(~s(queries/count), params, key: :read) do
        {:ok   , reponse} -> {:ok, reponse["result"]}
        {:error, reponse} -> {:error, reponse}
      end
    end

    # TODO
    def insert(collection, params \\ [], _options \\ []) do
      params = Query.params(params)

      try do
        Keenex.EventCollections.post(collection, params)
      rescue
        err in HTTPotion.HTTPError -> {:error, err}
      end
    end

    # TODO
    def update(_query, _source, _opts) do
      {:ok, nil}
    end

    # TODO
    def delete(_query, _source, _opts) do
      {:ok, nil}
    end

  end
end
