defmodule Sender do
  def start_link(socket) do
    pid = spawn(__MODULE__, :broadcast, [socket])
    {:ok, pid}
  end

  def broadcast(socket) do
    SubscriberServer.broadcast_messages(socket)
    Process.sleep(10)
    broadcast(socket)
  end
end
