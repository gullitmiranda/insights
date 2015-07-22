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
      def start_link(server, opts) do
        {:ok, _} = Application.ensure_all_started(@conn, @adapter)
        Insights.Adapters.Base.start_link(@conn, @adapter, server, opts)
      end

      ## Query

      @doc false
      def all(server, query, opts) do
        Insights.Adapters.Base.all(server, @conn.all(query, opts), opts)
      end

      @doc false
      def count(server, query, opts) do
        Insights.Adapters.Base.count(server, @conn.count(query, opts), opts)
      end

      @doc false
      def insert(server, source, opts) do
        Insights.Adapters.Base.model(server, @conn.insert(server, source, opts), opts)
      end

      @doc false
      def update(server, query, source, opts) do
        Insights.Adapters.Base.model(server, @conn.update(server, query, source, opts), opts)
      end

      @doc false
      def delete(server, query, opts) do
        Insights.Adapters.Base.model(server, @conn.delete(server, query, opts), opts)
      end

      defoverridable [all: 3, insert: 3, update: 4, delete: 3, start_link: 2]
    end
  end

  ## Worker
  # alias Insights.Adapters.Base.Sandbox

  @doc false
  def start_link(connection, adapter, _server, opts) do
    unless Code.ensure_loaded?(connection) do
      raise """
      could not find #{inspect connection}.
      Please verify you have added #{inspect adapter} as a dependency:
          {#{inspect adapter}, ">= 0.0.0"}
      And remember to recompile Insights afterwards by cleaning the current build:
          mix deps.clean insights
      """
    end

    connection.start_link(connection, opts)
  end

  ## Query

  @doc false
  def all(_server, data, _opts) do
    data
  end

  @doc false
  def count(_server, data, _opts) do
    data
  end

  @doc false
  def model(_server, data, _opts) do
    data
  end
end
