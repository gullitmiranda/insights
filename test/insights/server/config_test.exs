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

  test "reads credentails from otp app configuration" do
    credentials = %{
      project_id: System.get_env("KEEN_PROJECT_ID"),
      write_key:  System.get_env("KEEN_WRITE_KEY"),
      read_key:   System.get_env("KEEN_READ_KEY"),
    }
    put_env(credentials: credentials)

    assert config(:insights, __MODULE__) == [
      otp_app: :insights,
      server: __MODULE__,
      credentials: credentials
    ]
  end
end
