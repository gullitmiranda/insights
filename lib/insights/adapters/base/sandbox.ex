defmodule Insights.Adapters.Base.Sandbox do
  @moduledoc """
  Start a pool with a single sandboxed Base connection.

  ### Options

  * `:shutdown` - The shutdown method for the connections (default: 5000) (see Supervisor.Spec)

  """

  # alias Insights.Adapters.Connection

  @spec start_link(module, Keyword.t) :: {:ok, pid} | {:error, any}
  def start_link(conn_mod, opts) do
    {name, opts} = Keyword.pop(opts, :name)
    GenServer.start_link(__MODULE__, {conn_mod, opts}, [name: name])
  end

end
