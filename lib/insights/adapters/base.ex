defmodule Insights.Adapters.Base do
  @moduledoc """
  Behaviour and implementation for adapters.
  """

  @doc false
  defmacro __using__(adapter) do
    quote do
      @behaviour Insights.Adapter

      @conn __MODULE__.Connection
      @adapter unquote(adapter)

      ## Worker

      @doc false
      defmacro __before_compile__(_env) do
        :ok
      end

      @doc false
      def start_link(server, options) do
        {:ok, _} = Application.ensure_all_started(@conn, @adapter)
        Insights.Adapters.Base.start_link(@conn, @adapter, server, options)
      end

      ## Query

      @doc false
      def query(server, collection, query, params, options) do
        Insights.Adapters.Base.query(server, @conn.query(collection, query, params, options), options)
      end

      @doc false
      def all(server, query, options) do
        Insights.Adapters.Base.all(server, @conn.all(query, options), options)
      end

      @doc false
      def count(server, query, options) do
        Insights.Adapters.Base.count(server, @conn.count(query, options), options)
      end

      @doc false
      def insert(server, query, source, options) do
        Insights.Adapters.Base.model(server, @conn.insert(query, source), options)
      end

      @doc false
      def update(server, query, source, options) do
        Insights.Adapters.Base.model(server, @conn.update(query, source, options), options)
      end

      @doc false
      def delete(server, query, options) do
        Insights.Adapters.Base.model(server, @conn.delete(query, options), options)
      end

      defoverridable [start_link: 2, query: 5, all: 3, insert: 4, update: 4, delete: 3]
    end
  end

  ## Worker
  # alias Insights.Adapters.Base.Sandbox

  @doc false
  def start_link(connection, adapter, _server, options) do
    unless Code.ensure_loaded?(connection) do
      raise """
      could not find #{inspect connection}.
      Please verify you have added #{inspect adapter} as a dependency:
          {#{inspect adapter}, ">= 0.0.0"}
      And remember to recompile Insights afterwards by cleaning the current build:
          mix deps.clean insights
      """
    end

    connection.start_link(connection, options)
  end

  ## Query

  @doc false
  def query(_server, data, _options) do
    data
  end

  @doc false
  def all(_server, data, _options) do
    data
  end

  @doc false
  def count(_server, data, _options) do
    data
  end

  @doc false
  def model(_server, data, _options) do
    data
  end
end
