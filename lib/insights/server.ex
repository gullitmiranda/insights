defmodule Insights.Server do
  @moduledoc """
  Defines a adapter.
  A adapter maps to an underlying data store, controlled by the
  adapter. For example, Insights ships with a Keen adapter that
  stores data into a PostgreSQL database.
  When used, the adapter expects the `:otp_app` as option.
  The `:otp_app` should point to an OTP application that has
  the adapter configuration. For example, the adapter:
      defmodule Insight do
        use Insights.Server, otp_app: :my_app
      end
  Could be configured with:
      config :my_app, Insight,
        adapter: Insights.Adapters.Keenex,
        credentials: %{
          project_id: System.get_env("KEEN_PROJECT_ID"),
          write_key:  System.get_env("KEEN_WRITE_KEY"),
          read_key:   System.get_env("KEEN_READ_KEY"),
        }
  """

  use Behaviour
  @type t :: module

  @doc false
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour Insights.Server

      {otp_app, adapter, config} = Insights.Server.Config.parse(__MODULE__, opts)
      @otp_app otp_app
      @adapter adapter
      @config  config
      @before_compile adapter

      require Logger
      @log_level config[:log_level] || :debug

      def config do
        Insights.Server.Config.config(@otp_app, __MODULE__)
      end

      def start_link(custom_config \\ []) do
        config = Keyword.merge(config(), custom_config)
        @adapter.start_link(__MODULE__, config)
      end

      def all(queryable \\ nil, params \\ []) do
        @adapter.all(__MODULE__, queryable, params)
      end

      def count(queryable \\ nil, params \\ [], options \\ []) do
        @adapter.count(__MODULE__, queryable, params)
      end

      def get(queryable, id, params \\ [], options \\ []) do
        @adapter.get(__MODULE__, queryable, id, params)
      end

      def get!(queryable, id, params \\ [], options \\ []) do
        @adapter.get!(__MODULE__, queryable, id, params)
      end

      def insert(model, params \\ [], options \\ []) do
        @adapter.insert(__MODULE__, @adapter, model, params)
      end

      def update(model, params \\ [], options \\ []) do
        @adapter.update(__MODULE__, @adapter, model, params)
      end

      def delete(model, params \\ [], options \\ []) do
        @adapter.delete(__MODULE__, @adapter, model, params)
      end

      def insert!(model, params \\ [], options \\ []) do
        @adapter.insert!(__MODULE__, @adapter, model, params)
      end

      def update!(model, params \\ [], options \\ []) do
        @adapter.update!(__MODULE__, @adapter, model, params)
      end

      def delete!(model, params \\ [], options \\ []) do
        @adapter.delete!(__MODULE__, @adapter, model, params)
      end

      def __adapter__ do
        @adapter
      end

      def __insight__ do
        true
      end

    end
  end

  @doc """
  Returns the adapter tied to the adapter.
  """
  defcallback __adapter__ :: Insights.Adapter.t

  @doc """
  Simply returns true to mark this module as a adapter.
  """
  defcallback __insight__ :: true

  @doc """
  Returns the adapter configuration stored in the `:otp_app` environment.
  """
  defcallback config() :: Keyword.t

  @doc """
  Starts any connection pooling or supervision and return `{:ok, pid}`
  or just `:ok` if nothing needs to be done.
  Returns `{:error, {:already_started, pid}}` if the insight already
  started or `{:error, term}` in case anything else goes wrong.
  """
  defcallback start_link() :: {:ok, pid} | :ok |
                              {:error, {:already_started, pid}} |
                              {:error, term}

  @doc """
  Fetches a single model from the data store where the primary key matches the
  given id.
  Returns `nil` if no result was found. If the model in the queryable
  has no primary key `Insights.NoPrimaryKeyError` will be raised.
  ## Options
    * `:timeout` - The time in milliseconds to wait for the call to finish,
      `:infinity` will wait indefinitely (default: 5000)
  """
  defcallback get(term, Keyword.t) :: Insights.Model.t | nil | no_return

  @doc """
  Similar to `get/3` but raises `Insights.NoResultsError` if no record was found.
  ## Options
    * `:timeout` - The time in milliseconds to wait for the call to finish,
      `:infinity` will wait indefinitely (default: 5000);
    * `:log` - When false, does not log the query
  """
  defcallback get!(term, Keyword.t) :: Insights.Model.t | nil | no_return

  @doc """
  Fetches all entries from the data store matching the given query.
  May raise `Insights.QueryError` if query validation fails.
  ## Options
    * `:timeout` - The time in milliseconds to wait for the call to finish,
      `:infinity` will wait indefinitely (default: 5000);
    * `:log` - When false, does not log the query
  ## Example
      # Fetch all post titles
      query = from p in Post,
           select: p.title
      MyInsight.all(query)
  """
  defcallback all(term, Keyword.t) :: [Insights.Model.t] | no_return

  defcallback count(term, Keyword.t, Keyword.t) :: term | no_return

  @doc """
  Inserts a model or a changeset.
  In case a model is given, the model is converted into a changeset
  with all model non-virtual fields as part of the changeset.
  In case a changeset is given, the changes in the changeset are
  merged with the model fields, and all of them are sent to the
  database.
  If any `before_insert` or `after_insert` callback is registered
  in the given model, they will be invoked with the changeset.
  ## Options
    * `:timeout` - The time in milliseconds to wait for the call to finish,
      `:infinity` will wait indefinitely (default: 5000);
    * `:log` - When false, does not log the query
  ## Example
      post = MyInsight.insert! %Post{title: "Insights is great"}
  """
  defcallback insert!(Insights.Model.t, Keyword.t) :: Insights.Model.t | no_return

  @doc """
  Updates a model or changeset using its primary key.
  In case a model is given, the model is converted into a changeset
  with all model non-virtual fields as part of the changeset. For this
  reason, it is preferred to use changesets as they perform dirty
  tracking and avoid sending data that did not change to the database
  over and over. In case there are no changes in the changeset, no
  data is sent to the database at all.
  In case a changeset is given, only the changes in the changeset
  will be updated, leaving all the other model fields intact.
  If any `before_update` or `after_update` callback are registered
  in the given model, they will be invoked with the changeset.
  If the model has no primary key, `Insights.NoPrimaryKeyError` will be raised.
  ## Options
    * `:force` - By default, if there are no changes in the changeset,
      `update!/2` is a no-op. By setting this option to true, update
      callbacks will always be executed, even if there are no changes
      (including timestamps).
    * `:timeout` - The time in milliseconds to wait for the call to finish,
      `:infinity` will wait indefinitely (default: 5000);
    * `:log` - When false, does not log the query
  ## Example
      post = MyInsight.get!(Post, 42)
      post = %{post | title: "New title"}
      MyInsight.update!(post)
  """
  defcallback update!(Insights.Model.t, Keyword.t) :: Insights.Model.t | no_return

  @doc """
  Deletes a model using its primary key.
  If any `before_delete` or `after_delete` callback are registered
  in the given model, they will be invoked with the changeset.
  If the model has no primary key, `Insights.NoPrimaryKeyError` will be raised.
  ## Options
    * `:timeout` - The time in milliseconds to wait for the call to finish,
      `:infinity` will wait indefinitely (default: 5000);
    * `:log` - When false, does not log the query
  ## Example
      [post] = MyInsight.all(from(p in Post, where: p.id == 42))
      MyInsight.delete!(post)
  """
  defcallback delete!(Insights.Model.t, Keyword.t) :: Insights.Model.t | no_return

end
