defmodule WorkerLegacy do
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
    data = json_parse(msg)
    data = calc_avg(data)
    PublisherLegacy.publish(PublisherLegacy, data)

    {:noreply, []}
  end

  @impl true
  def terminate(_reason, _state) do
    DynamicSupervisor.terminate_child(DynSupervisorLegacy, self())
  end

  def json_parse(msg) do
    msg_data = Poison.decode!(msg.data)
    msg_data["message"]
  end

  defp calc_avg(data) do
    atmo_pressure_sensor_1 = data["atmo_pressure_sensor_1"]
    atmo_pressure_sensor_2 = data["atmo_pressure_sensor_2"]
    atmo_pressure_sensor = avg(atmo_pressure_sensor_1, atmo_pressure_sensor_2)
    humidity_sensor_1 = data["humidity_sensor_1"]
    humidity_sensor_2 = data["humidity_sensor_2"]
    humidity_sensor = avg(humidity_sensor_1, humidity_sensor_2)
    light_sensor_1 = data["light_sensor_1"]
    light_sensor_2 = data["light_sensor_2"]
    light_sensor = avg(light_sensor_1, light_sensor_2)
    temperature_sensor_1 = data["temperature_sensor_1"]
    temperature_sensor_2 = data["temperature_sensor_2"]
    temperature_sensor = avg(temperature_sensor_1, temperature_sensor_2)
    wind_speed_sensor_1 = data["wind_speed_sensor_1"]
    wind_speed_sensor_2 = data["wind_speed_sensor_2"]
    wind_speed_sensor = avg(wind_speed_sensor_1, wind_speed_sensor_2)
    unix_timestamp_us = data["unix_timestamp_us"]

    map = %{
      :atmo_pressure_sensor => atmo_pressure_sensor,
      :humidity_sensor => humidity_sensor,
      :light_sensor => light_sensor,
      :temperature_sensor => temperature_sensor,
      :wind_speed_sensor => wind_speed_sensor,
      :unix_timestamp_us => unix_timestamp_us
    }

    map
  end

  defp avg(a, b) do
    (a + b) / 2
  end
end
