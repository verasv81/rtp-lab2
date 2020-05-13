defmodule Server do
  
  def start_link(socket) do
    pid = spawn_link(__MODULE__, :subscribe_data, [socket])

    {:ok, pid}
  end

  def subscribe_data (socket) do
    package = %{
      :type => "subscribe",
      :topic => "printer"
    }
    encoded_package = Poison.encode!(package)
    case :gen_udp.send(socket, {127, 0, 0, 1}, 2307, encoded_package) do
      :ok -> receive_data(socket)
    end
  end

  def receive_data (socket) do
    case :gen_udp.recv(socket, 0) do
      {:ok, data} ->
        package = elem(data, 2) |> Poison.decode!()
        Printer.info(package)
    end
      receive_data(socket)
    end
end
