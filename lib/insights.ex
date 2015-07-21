defmodule Insights do
  @moduledoc ~S"""
  Wrapper for sending and data capture for keen.io or others adapters

  ## Adapters
    `Insights` is a wrapper around the service or database. We can define a
    adapter as follows:
        defmodule Insight do
          use Insights.Insight, otp_app: :my_app
        end

    Where the configuration for the Adapter must be in your application
    environment, usually defined in your `config/config.exs`:
        config :my_app, Insight,
          adapter: Insights.Adapters.Keenex,
          credentials: %{
            project_id: System.get_env("KEEN_PROJECT_ID"),
            write_key:  System.get_env("KEEN_WRITE_KEY"),
            read_key:   System.get_env("KEEN_READ_KEY"),
          }

  Each adapter in Insights defines a `start_link/0` function that needs to be invoked
  before using the adapter. In general, this function is not called directly,
  but used as part of your application supervision tree.
  If your application was generated with a supervisor (by passing `--sup` to `mix new`)
  you will have a `lib/my_app.ex` file containing the application start callback that
  defines and starts your supervisor. You just need to edit the `start/2` function to
  start the repo as a worker on the supervisor:
      def start(_type, _args) do
        import Supervisor.Spec
        children = [
          worker(Insight, [])
        ]
        opts = [strategy: :one_for_one, name: MyApp.Supervisor]
        Supervisor.start_link(children, opts)
      end
  """
end
