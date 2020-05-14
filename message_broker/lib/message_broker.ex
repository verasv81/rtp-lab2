defmodule MessageBroker.Application do
  use Application

  def start(_, _) do
    children = [
      %{
        id: Queue,
        start: {Queue, :start_link, []}
      },
      %{
        id: Server,
        start: {Server, :start_link, [2307]}
      }
    ]

    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)

    IO.puts("Server started!")

    receive do
    end
  end
end