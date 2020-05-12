defmodule Request do
  def start_link(url) do
    {:ok, _pid} = EventsourceEx.new(url, stream_to: self())

    recv()
  end

  def recv do
    receive do
      msg -> msg_operations(msg)
    end
  end

  def msg_operations(msg) do
    GenServer.cast(DataFlowIot, :send_flow)
    GenServer.cast(DistributorIot, {:distributor, msg})
    recv()
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent
    }
  end
end
