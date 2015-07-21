defmodule Insights.TestAdapter do
  # @behaviour Insights.Adapter

  defmacro __before_compile__(_opts), do: :ok
  def start_link(_repo, _opts), do: :ok
end

Application.put_env(:insights, Insights.TestServer, [])

defmodule Insights.TestServer do
  use Insights.Server, otp_app: :insights, adapter: Insights.TestAdapter
end
