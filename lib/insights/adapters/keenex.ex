defmodule Insights.Adapters.Keenex do
  @moduledoc """
  Adapter module for Keen.io.
  It uses `keenex` for communicating to the service

  ### Compile time options
  Those options should be set in the config file and require
  recompilation in order to make an effect.
    * `:adapter` - The adapter name, in this case, `Insights.Adapters.Keen`
    * `:credentials` - Credentials to connect with Keen.io. [More info](https://keen.io/docs/api/#api-keys)
      * `:project_id` - Project ID in Keen.io
      * `:write_key` - The write key is an API key specifically for writing data
      * `:read_key` - The read key is an API key for querying and extracting data

  Info about the contents can be found [keen.io api reference](https://keen.io/docs/api/reference/)
  """
  @adapter :keenex
  @conn __MODULE__.Connection

  # Inherit all behaviour from Insights.Adapters.Base
  use Insights.Adapters.Base, @adapter

  @doc false
  def start_link(_server, opts) do
    unless Code.ensure_loaded?(@conn) do
      raise """
      could not find #{inspect @conn}.
      Please verify you have added #{inspect @adapter} as a dependency:
          {#{inspect @adapter}, ">= 0.0.0"}
      And remember to recompile Insights afterwards by cleaning the current build:
          mix deps.clean @adapter
      """
    end

    @conn.connect(opts[:credentials])
  end

end
