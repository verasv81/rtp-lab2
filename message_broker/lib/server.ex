defmodule Server do
  require Logger

  def start_link(port) do
    opts = [:binary, active: false]
    server_pid = case :gen_udp.open(port, opts) do
      {:ok, socket} ->
        Sender.start_link(socket)
        spawn_link(__MODULE__, :loop_acceptor, [socket])
      {:error, reason} ->
        Logger.info("Could not start server! Reason: #{reason}")
        Process.exit(self(), :normal)
    end
    {:ok, server_pid}
  end

  def loop_acceptor(socket) do
    case :gen_udp.recv(socket, 0) do
      {:ok, data} ->
        encoded_package = elem(data, 2)
        decoded_package = Poison.decode!(encoded_package)
        type = decoded_package["type"]
        package = Map.delete(decoded_package, "type")

        case type do
          "message" -> Queue.add(package)
          "subscribe" -> SubscriberServer.subscribe(data, package)
          "unsubscribe" -> SubscriberServer.unsubscribe(data, package)
        end
    end
    loop_acceptor(socket)
  end
end
