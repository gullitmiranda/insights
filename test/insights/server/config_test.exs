defmodule Insights.Server.ConfigTest do
  use ExUnit.Case, async: true

  import Insights.Server.Config

  defp put_env(env) do
    Application.put_env(:insights, __MODULE__, env)
  end

  test "reads otp app configuration" do
    put_env(database: "hello")
    assert config(:insights, __MODULE__) == [otp_app: :insights, server: __MODULE__, database: "hello"]
  end
end
