defmodule Timestamp do
  use GenServer

  def start_link(socket) do
    GenServer.start_link(__MODULE__, socket, name: __MODULE__)
  end

  def add(package) do
    GenServer.cast(__MODULE__, {:add_message, package})
  end

  def init(socket) do
    registry = Map.new()
    Process.send_after(self(), :time_stream, 1000)

    {:ok, {registry, socket}}
  end

  def handle_cast({:add_message, package}, streamer_state) do
    state = elem(streamer_state, 0)
    socket = elem(streamer_state, 1)

    topic = package["topic"]
    message = Map.delete(package, "topic")

    if Map.has_key?(state, topic) do
      messages = Map.get(state, topic)
      messages = messages ++ [message]
      new_state = Map.put(state, topic, messages)

      {:noreply, {new_state, socket}}
    else
      new_state = Map.put(state, topic, [message])

      {:noreply, {new_state, socket}}
    end
  end

  def handle_info(:time_stream, streamer_state) do
    state = elem(streamer_state, 0)
    socket = elem(streamer_state, 1)

    iot_messages = Map.get(state, "iot")
    sensors_messages = Map.get(state, "sensors")
    legacy_sensors_messages = Map.get(state, "legacy_sensors")

    streamed_message =
      if iot_messages != nil do
        Enum.map(iot_messages, fn iot_message ->
        iot_timestamp = iot_message["unix_timestamp_100us"]
        sensor_message = Calculator.get_appropiate_sensor_data(sensors_messages, iot_timestamp)
        legacy_message = Calculator.get_appropriate_legacy_sensor_data(legacy_sensors_messages, iot_timestamp)

        if (sensor_message != nil) && (legacy_message != nil) do
          %{
            pressure: iot_message["atmo_pressure"],
            wind: iot_message["wind_speed"],
            light: sensor_message["light"],
            humidity: legacy_message["humidity"],
            temperature: legacy_message["temperature"],
            unix_timestamp_100us: iot_message["unix_timestamp_100us"],
            topic: "aggregator",
            type: "message"
          }
        else
          nil
        end
      end)
    else
      nil
    end

    if streamed_message != nil do
      final_message_list = Enum.filter(streamed_message, fn message ->
        message != nil
      end)

      if !Enum.empty?(final_message_list) do
        Enum.each(final_message_list, fn message ->
            case :gen_udp.send(socket, '127.0.0.1', 6161, Poison.encode!(message)) do
              :ok -> IO.inspect(Poison.encode!(message))
            end
        end)
      end
    end


    Process.send_after(self(), :time_stream, 1000)
    {:noreply, {%{}, socket}}
  end
end
