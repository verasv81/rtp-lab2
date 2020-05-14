defmodule Server do
  require Logger

  def start_link(port) do
    opts = [:binary, active: false]
    server_pid = case :gen_udp.open(port, opts) do
      {:ok, socket} ->
        Sender.start_link(socket)
        spawn_link(__MODULE__, :recieve_messages, [socket])
      {:error, reason} ->
        Logger.info("Could not start server! Reason: #{reason}")
        Process.exit(self(), :normal)
    end
    {:ok, server_pid}
  end

  def recieve_messages(socket) do
    case :gen_udp.recv(socket, 0) do
      {:ok, data} ->
        package = elem(data, 2)
        decoded_package = Poison.decode!(package)
        type = decoded_package["type"]
        
        if type == nil do
          Queue.push(decoded_package)
        else
          case type do
            "subscribe" -> SubscriberServer.subscribe(data, decoded_package)
          end
        end
    end
    recieve_messages(socket)
  end
end
