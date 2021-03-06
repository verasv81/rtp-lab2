defmodule WorkerIot do
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

    GenServer.cast(PublisherIot, {:data, data})
    {:noreply, []}
  end

  @impl true
  def terminate(_reason, _state) do
    DynamicSupervisor.terminate_child(DynSupervisorIot, self())
  end

  defp calc_avg(data) do
    atmo_pressure_sensor_1 = data["atmo_pressure_sensor_1"]
    atmo_pressure_sensor_2 = data["atmo_pressure_sensor_2"]
    atmo_pressure_sensor = avg(atmo_pressure_sensor_1, atmo_pressure_sensor_2)
    wind_speed_sensor_1 = data["wind_speed_sensor_1"]
    wind_speed_sensor_2 = data["wind_speed_sensor_2"]
    wind_speed_sensor = avg(wind_speed_sensor_1, wind_speed_sensor_2)
    unix_timestamp_100us = data["unix_timestamp_100us"]

    map = %{
      :atmo_pressure_sensor => atmo_pressure_sensor,
      :wind_speed_sensor => wind_speed_sensor,
      :unix_timestamp_100us => unix_timestamp_100us,
      :topic => "iot"
    }

    {:ok, json} = Poison.encode(map)
    json
  end

  defp avg(a, b) do
    (a + b) / 2
  end
end
