defmodule Calculator do
  @spec get_appropiate_sensor_data(any, any) :: nil | %{optional(<<_::40>>) => float}
  def get_appropiate_sensor_data(sensor_data, timestamp) do
    sensor_avg = if sensor_data != nil do
      sensor_appropriate_list = Enum.filter(sensor_data, fn data ->
        sensor_timestamp = data["unix_timestamp_100us"]
        ((timestamp - sensor_timestamp) <= 100) &&
        ((timestamp - sensor_timestamp) >= -100)
      end)

      sensor_avg =
      if Enum.empty?(sensor_appropriate_list) do
        nil
      else
        get_avg_apropriate_sensor_data(sensor_appropriate_list)
      end
      sensor_avg
    else
      nil
    end
    sensor_avg
  end

  def get_appropriate_legacy_sensor_data(legacy_data, timestamp) do
    legacy_avg = if legacy_data != nil do
      legacy_sensors_appropriate_list = Enum.filter(legacy_data, fn data ->
        legeacy_sensors_timestamp = data["unix_timestamp_100us"]
        ((timestamp - legeacy_sensors_timestamp) <= 100) &&
        ((timestamp - legeacy_sensors_timestamp) >= -100)
      end)

      legacy_avg =
      if Enum.empty?(legacy_sensors_appropriate_list) do
        nil
      else
        get_avg_apropriate_legacy_data(legacy_sensors_appropriate_list)
      end
      legacy_avg
    else
      nil
    end
    legacy_avg
  end

  def get_avg_apropriate_sensor_data(sensor_data_list) do
    avg = sum_data(sensor_data_list, "light") / Enum.count(sensor_data_list)
    map = Map.put(%{}, "light", avg)
    map
  end

  def get_avg_apropriate_legacy_data(sensor_data_list) do
    hum_avg = sum_data(sensor_data_list, "humidity") / Enum.count(sensor_data_list)
    temp_avg = sum_data(sensor_data_list, "temperature") / Enum.count(sensor_data_list)
    map = Map.put(%{}, "humidity", hum_avg)
    map = Map.put(map, "temperature", temp_avg)
    map
  end

  @spec sum_data(any, any) :: number
  def sum_data(list, key)do
    Enum.map(list, fn (x) -> x[key] end)|>
    Enum.sum
  end
end