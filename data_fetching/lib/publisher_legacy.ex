defmodule PublisherLegacy do
  use GenServer, restart: :permanent

  def start_link(port) do
    GenServer.start_link(__MODULE__, port, name: __MODULE__)
  end

  @impl true
  def init(port) do
    opts = [:binary, active: false]
    
    socket = case :gen_udp.open(port, opts) do
      {:ok, socket} -> socket
      {:error, _reason} ->
        Process.exit(self(), :normal)
    end

    {:ok, socket}
  end

  @impl true
  def handle_cast({:data, data}, socket) do
    case :gen_udp.send(socket, {127, 0, 0, 1}, 2307, data) do
      :ok -> IO.inspect(data)
    end
    {:noreply, socket}
  end         
end