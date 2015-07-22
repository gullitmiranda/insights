defmodule Insights.Adapters.Keenex.Api do
  alias Keenex.Base

  @doc """
  Implementation for `Keenex.Base.get/2`
  """
  def get(endpoint, params \\ []) do
    try do
      Base.get(endpoint, params)
    rescue
      err in HTTPotion.HTTPError -> {:error, err}
    end
  end

  @doc """
  Implementation for `Keenex.Base.post/3`
  """
  def post(endpoint, params, options \\ []) do
    try do
      Base.post(endpoint, params, options)
    rescue
      err in HTTPotion.HTTPError -> {:error, err}
    end
  end
end
