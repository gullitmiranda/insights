defmodule Helpers do
  def project_id do
    Application.get_env(:insights, :keen_project_id, System.get_env("KEEN_PROJECT_ID"))
  end

  def write_key do
    Application.get_env(:insights, :keen_write_key, System.get_env("KEEN_WRITE_KEY"))
  end

  def read_key do
    Application.get_env(:insights, :keen_read_key, System.get_env("KEEN_READ_KEY"))
  end
end

defmodule Insights.Adapters.KeenexTest do
  use ExUnit.Case, async: false
  # use ExVCR.Mock

  # Start Keenex
  Application.put_env(:insights, __MODULE__.Server,
    adapter: Insights.Adapters.Keenex,
    credentials: %{
      project_id: Helpers.project_id,
      write_key:  Helpers.write_key,
      read_key:   Helpers.read_key,
    })

  # alias Insights.Adapters.Keenex.Connection, as: Keen

  defmodule Server do
    use Insights.Server, otp_app: :insights
  end

  setup_all do
    Server.start_link
    :ok
  end

  test "server start and credentials" do
    # {status, keen} = Server.start_link
    # IO.inspect {status, keen}

    # assert status == :ok
    assert Server.__adapter__ == Insights.Adapters.Keenex
    assert Keenex.project_id == Helpers.project_id
    assert Keenex.write_key == Helpers.write_key
    assert Keenex.read_key == Helpers.read_key
  end

  test "start extraction start" do
    {status, _} = Server.all("start")

    assert status == :ok
  end

  test "start count" do
    {status, _} = Server.count("start")

    assert status == :ok
  end

  test "start count with filter" do
    # Keenex.Events.post(%{start: [
    #   %{url: "https://github.com/azukiapp/feedbin"},
    #   %{url: "https://github.com/azukiapp/azk"},
    #   %{url: "https://github.com/azukiapp/feedbin"},
    # ]})

    {status, _} = Server.count("start", filters: ["url=https://github.com/azukiapp/feedbin"])
    |> IO.inspect

    assert status == :ok
  end

  test "post new start event" do
    data = %{
      url:           "https://github.com/azukiapp/azk",
      host:          "github.com",
      repo_user:     "azukiapp",
      repo_basename: "azk"
    }
    {status, _} = Server.insert("start", data)

    assert status == :ok
  end
end
