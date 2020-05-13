defmodule Worker do
  use GenServer, restart: :transient

  def start_link(msg) do
    GenServer.start_link(__MODULE__, msg)
  end

  @impl true
  def init(msg) do
    {:ok, msg}
  end

  @impl true
  def handle_cast({:compute, msg}, _states) do
    data = Poison.decode!(msg.data)["message"]
    data = calc_avg(data)
    GenServer.cast(Publisher, {:data, data})

    {:noreply, []}
  end

  @impl true
  def terminate(_reason, _state) do
    DynamicSupervisor.terminate_child(DynSupervisor, self())
  end

  defp calc_avg(data) do
    light_sensor_1 = data["light_sensor_1"]
    light_sensor_2 = data["light_sensor_2"]
    light_sensor = avg(light_sensor_1, light_sensor_2)
    unix_timestamp_100us = data["unix_timestamp_100us"]

    map = %{
      :light_sensor => light_sensor,
      :unix_timestamp_100us => unix_timestamp_100us,
      :topic => "sensors"
    }

    {:ok, json} = Poison.encode(map)
    json
  end

  defp avg(a, b) do
    (a + b) / 2
  end
end
