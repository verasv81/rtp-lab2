defmodule Server do
  use GenServer
  require Logger

  def start_link(port) do
    GenServer.start_link(__MODULE__, port, name: __MODULE__)
  end

  @impl true
  def init(port) do
    opts = [:binary, active: true]
    socket = case :gen_udp.open(port, opts) do
      {:ok, socket} -> IO.inspect(socket)
      {:error, reason} ->
        Logger.error("Error, reason #{reason}")
        Process.exit(self(), :normal)
    end
    package = %{
      :topic => "aggregator",
      :type => "subscribe"
    }

    {:ok, encoded_package} = Poison.encode(package)
    case :gen_udp.send(socket, {127, 0, 0, 1}, 2307, encoded_package) do
      :ok -> get_data(socket)
    end

    {:ok, socket}
  end

  def get_data (socket) do
    case :gen_udp.recv(socket, 0) do
      {:ok, data} ->
        package = elem(data, 2) |> Poison.decode!()
        {forecast, data} = Forecast.calculate_forecast(package)
        Aggregator.send_forecast([forecast, data])
      end

      get_data(socket)
    end
end
