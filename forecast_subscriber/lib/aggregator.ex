defmodule Aggregator do
  use GenServer

  def start_link(socket) do
    GenServer.start_link(__MODULE__, socket, name: __MODULE__)
  end

  def send_forecast(forecast_sensor_tuple) do
    GenServer.cast(__MODULE__, {:collect_forecast, forecast_sensor_tuple})
  end

  def init(socket) do
    Process.send_after(self(), :send_forecast, 1000)

    {:ok, {[], socket}}
  end

  def handle_cast({:collect_forecast, forecast_sensor_tuple}, aggregator_state) do
    socket = elem(aggregator_state, 1)
    forecast_map = elem(aggregator_state, 0)
    new_aggregator_state = forecast_map ++ [forecast_sensor_tuple]

    {:noreply, {new_aggregator_state, socket}}
  end

  def handle_info(:send_forecast, aggregator_state)do
    socket = elem(aggregator_state, 1)
    forecast_map = elem(aggregator_state, 0)


    if !Enum.empty?(forecast_map) do
      forecast =
      Forecast.sort_map(forecast_map) |>
      Forecast.get_first()

      sensors_data = Forecast.get_sensor_from_list(forecast_map, forecast)
      avg_data = Forecast.calculate_avg_data(Tuple.to_list(sensors_data))

      send_to_broker(socket, forecast, avg_data)
    end

    Process.send_after(self(), :send_forecast, 1000)
    aggregator_new_state = Enum.drop(forecast_map, length(forecast_map))

    {:noreply, {aggregator_new_state, socket}}
  end

  defp send_to_broker(socket, forecast, data) do
    package = %{
      :topic => "printer",
      :type => "message",
      :forecast => forecast
    }
    
    encoded_package = Poison.encode!(package)
    case :gen_udp.send(socket, {127,0,0,1}, 2307, encoded_package) do
      :ok -> IO.inspect(encoded_package)
    end
  end


end
