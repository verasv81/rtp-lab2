defmodule Server do
  
  def start_link(socket) do
    pid = spawn_link(__MODULE__, :subscribe_data, [socket])

    {:ok, pid}
  end

  def subscribe_data (socket) do
    package = %{
      :type => "subscribe",
      :topic => "iot/sensors/legacy_sensors"
    }
    encoded_package = Poison.encode!(package)
    case :gen_udp.send(socket, {127, 0, 0, 1}, 2307, encoded_package) do
      :ok -> receive_data(socket)
    end
  end

  def receive_data (socket) do
    case :gen_udp.recv(socket, 0) do
      {:ok, data} ->
        packet = elem(data, 2) |> Poison.decode!()
        Timestamp.add(packet)
    end

      receive_data(socket)
    end
end
