defmodule Insights.Adapters.BaseTest do
  use ExUnit.Case, async: true

  defmodule Adapter do
    use Insights.Adapters.Base
  end

  Application.put_env(:insights, __MODULE__.Server, adapter: Adapter)

  defmodule Server do
    use Insights.Server, otp_app: :insights
  end

  test "server adapter" do
    assert Server.__adapter__ == Adapter
  end
end
