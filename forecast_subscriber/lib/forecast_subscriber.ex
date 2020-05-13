defmodule ForecastSubscriber.Application do
  use Application

  def start(_type, _args) do

    children = [
      %{
        id: Server,
        start: {Server, :start_link, [2005]}
      },
    ]

    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)

      receive do
      end
    end
  end
