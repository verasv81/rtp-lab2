defmodule Forecast do
  def calculate_forecast (data) do
    temperature = data["temperature"]
    light = data["light"]
    wind = data["wind"]
    pressure = data["pressure"]
    humidity = data["humidity"]

    forecast =
    cond do
      temperature < -2 && light < 128 && pressure < 720 -> "SNOW"
      temperature < -2 && light > 128 && pressure < 680 -> "WET_SNOW"
      temperature < -8 -> "SNOW"
      temperature < -15 && wind > 45 -> "BLIZZARD"
      temperature > 0 && pressure < 710 && humidity > 70 && wind < 20 -> "SLIGHT_RAIN"
      temperature > 0 && pressure < 690 && humidity > 70 && wind > 20 -> "HEAVY_RAIN"
      temperature > 30 && pressure < 770 && humidity > 80 && light > 192 -> "HOT"
      temperature > 30 && pressure < 770 && humidity > 50 && light > 192 && wind > 35 -> "CONVECTION_OVEN"
      temperature > 25 && pressure < 750 && humidity > 70 && light < 192 && wind < 10 -> "WARM"
      temperature > 25 && pressure < 750 && humidity > 70 && light < 192 && wind > 10 -> "SLIGHT_BREEZE"
      light < 128 -> "CLOUDY"
      temperature > 30 && pressure < 660 && humidity > 85 && wind > 45 -> "MONSOON"
      true -> "JUST_A_NORMAL_DAY"
    end

    {forecast, data}
  end

  def calculate_avg_data(sensor_list_data) do
    pressure = sum_data(sensor_list_data, "pressure") / length(sensor_list_data)
    humidity = sum_data(sensor_list_data, "humidity") / length(sensor_list_data)
    light = sum_data(sensor_list_data, "light") / length(sensor_list_data)
    wind_speed = sum_data(sensor_list_data, "wind") / length(sensor_list_data)
    temperature = sum_data(sensor_list_data, "temperature") / length(sensor_list_data)
    timestamp = last_element(sensor_list_data, "unix_timestamp_100us")

    result = %{
      humidity: humidity,
      light: light,
      pressure: pressure,
      temperature: temperature,
      wind: wind_speed,
      timestamp: timestamp
    }
    result
  end

  def sort_map(map)do
    Enum.map(map, fn elem -> hd(elem) end) |>
    Enum.frequencies|>
    Map.to_list |>
    Enum.sort_by(&(elem(&1, 1)), :desc)
  end

  def get_first(list)do
    hd(list)|> elem(0)
  end

  def get_sensor_from_list(list, condition)do
    Enum.filter(list, fn elem -> hd(elem) === condition end) |>
    Enum.map(fn list -> List.to_tuple(list) end) |>
    Enum.map(fn tuple -> elem(tuple, 1) end) |> List.to_tuple
  end

  def sum_data(list, key)do
    Enum.map(list, fn (x) -> x[key] end)|>
    Enum.sum
  end

  def last_element(list, key)do
    Enum.map(list, fn (x) -> x[key] end)|>
    Enum.max()
  end

end