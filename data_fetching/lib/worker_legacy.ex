defmodule WorkerLegacy do
  use GenServer, restart: :transient
  import SweetXml

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
    data = xml_parse(data)
    GenServer.cast(PublisherLegacy, {:data, data})
    {:noreply, []}
  end

  @impl true
  def terminate(_reason, _state) do
    DynamicSupervisor.terminate_child(DynSupervisorLegacy, self())
  end

  def xml_parse(data) do
    humidity_sensor_values =
      data
      |> xpath(~x"//humidity_percent/value"l, value: ~x"text()")
      |> Enum.map(fn %{value: value} ->
        value
      end)

    temperature_sensor_values =
      data
      |> xpath(~x"//temperature_celsius/value"l, value: ~x"text()")
      |> Enum.map(fn %{value: value} ->
        value
      end)

    unix_timestamp_100us = get_xml_timestamp(data)

    [humidity_sensor_1 | humidity_sensor_2] = humidity_sensor_values
    [temperature_sensor_1 | temperature_sensor_2] = temperature_sensor_values

    humidity_sensor_1 = single_quotes_to_float(humidity_sensor_1)
    humidity_sensor_2 = single_quotes_to_float(humidity_sensor_2)
    temperature_sensor_1 = single_quotes_to_float(temperature_sensor_1)
    temperature_sensor_2 = single_quotes_to_float(temperature_sensor_2)
    unix_timestamp_100us = single_quotes_to_integer(unix_timestamp_100us)

    humidity_sensor = avg(humidity_sensor_1, humidity_sensor_2)
    temperature_sensor = avg(temperature_sensor_1, temperature_sensor_2)

    map = %{
      :humidity_sensor => humidity_sensor,
      :temperature_sensor => temperature_sensor,
      :unix_timestamp_100us => unix_timestamp_100us,
      :topic => "legacy_sensors"
    }

    {:ok, json} = Poison.encode(map)
    json
  end

  defp single_quotes_to_float(num) do
    num = to_string(num)
    num = String.to_float(num)
    num
  end

  defp single_quotes_to_integer(num) do
    num = to_string(num)
    num = String.to_integer(num)
    num
  end

  defp get_xml_timestamp(xml) do
    xml = parse(xml) |> xmlElement()
    xml = Enum.at(xml, 6)
    xml = Tuple.to_list(xml)
    xml = List.last(xml)
    xml = List.first(xml)
    xml = Tuple.to_list(xml)
    xml = Enum.at(xml, 8)
    xml
  end

  defp avg(a, b) do
    (a + b) / 2
  end
end