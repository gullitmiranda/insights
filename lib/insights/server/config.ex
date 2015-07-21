defmodule Insights.Server.Config do
  @moduledoc false

  @doc """
  Loads otp app and adapter configuration from options.
  """
  def parse(module, opts) do
    otp_app = Keyword.fetch!(opts, :otp_app)
    config  = Application.get_env(otp_app, module, [])
    adapter = opts[:adapter] || config[:adapter]

    unless adapter do
      raise ArgumentError, "missing :adapter configuration in " <>
                           "config #{inspect otp_app}, #{inspect module}"
    end

    unless Code.ensure_loaded?(adapter) do
      raise ArgumentError, "adapter #{inspect adapter} was not compiled, " <>
                           "ensure it is correct and it is included as a project dependency"
    end

    {otp_app, adapter, config}
  end

  @doc """
  Retrieves and normalizes the configuration for `server` in `otp_app`.
  """
  def config(otp_app, module) do
    if config = Application.get_env(otp_app, module) do
      [otp_app: otp_app, server: module] ++ config
    else
      raise ArgumentError,
        "configuration for #{inspect module} not specified in #{inspect otp_app} environment"
    end
  end
end
