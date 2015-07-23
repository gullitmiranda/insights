defmodule Insights.Adapter do
  @moduledoc """
  This module specifies the adapter API that an adapter is required to
  implement.
  """

  use Behaviour

  @type t :: module
  @type source :: {table :: binary, model :: atom}

  @typep adapter :: Insights.Server.t
  @typep query :: String.t
  @typep options :: Keyword.t

  @doc """
  The callback invoked in case the adapter needs to inject code.
  """
  defmacrocallback __before_compile__(Macro.Env.t) :: Macro.t

  @doc """
  Starts any connection pooling or supervision and return `{:ok, pid}`
  or just `:ok` if nothing needs to be done.
  Returns `{:error, {:already_started, pid}}` if the adapter already
  started or `{:error, term}` in case anything else goes wrong.
  ## Adapter start
  Because some Insights tasks like migration may run without starting
  the parent application, it is recommended that start_link in
  adapters make sure the adapter application is started by calling
  `Application.ensure_all_started/1`.
  """
  defcallback start_link(adapter, options) ::
              {:ok, pid} | :ok | {:error, {:already_started, pid}} | {:error, term}

  @doc """
  Fetches all results from the data store based on the given query.
  It receives a preprocess function responsible that should be
  invoked for each selected field in the query result in order
  to convert them to the expected Insights type.
  """
  defcallback all(adapter, query, options) :: [[term]] | no_return

  @doc """
  Count all results from the data store based on the given query.
  It receives a preprocess function responsible that should be
  invoked for each selected field in the query result in order
  to convert them to the expected Insights type.
  """
  defcallback count(adapter, query, options) :: {:ok, term} | {:error, term} | no_return

  @doc """
  Inserts a single new model in the data store.
  """
  defcallback insert(adapter, query, source, options) ::
                    {:ok, Keyword.t} | no_return

  @doc """
  Updates a single model with the given filters.
  While `filters` can be any record column, it is expected that
  at least the primary key (or any other key that uniquely
  identifies an existing record) to be given as filter. Therefore,
  in case there is no record matching the given filters,
  `{:error, :stale}` is returned.
  """
  defcallback update(adapter, query, source, options) ::
                    {:ok, Keyword.t} | {:error, :stale} | no_return

  @doc """
  Deletes a sigle model with the given filters.
  While `filters` can be any record column, it is expected that
  at least the primary key (or any other key that uniquely
  identifies an existing record) to be given as filter. Therefore,
  in case there is no record matching the given filters,
  `{:error, :stale}` is returned.
  """
  defcallback delete(adapter, query, options) ::
                     {:ok, Keyword.t} | {:error, :stale} | no_return

end
