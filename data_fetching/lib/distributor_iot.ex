defmodule DistributorIot do
  use GenServer, restart: :permanent

  def start_link(msg) do
    GenServer.start_link(__MODULE__, msg, name: __MODULE__)
  end

  @impl true
  def init(_msg) do
    counter = 0
    {:ok, counter}
  end

  @impl true
  def handle_cast({:distributor, msg}, states) do
    counter = states
    recommend_max_workers = GenServer.call(DataFlowIot, :recommend_max_workers)
    pids_list = DynSupervisorIot.pid_children()

    if DynSupervisorIot.count_children()[:active] < recommend_max_workers do
      create_worker(msg)
    else
      if DynSupervisorIot.count_children()[:active] > recommend_max_workers do
        [head | _tail] = pids_list
        remove_worker(head)
      end
    end

    if counter < length(pids_list) do
      counter = counter + 1
      compute_forecast(pids_list, counter, msg)
      {:noreply, counter}
    else
      counter = 0
      compute_forecast(pids_list, counter, msg)
      {:noreply, counter}
    end
  end

  defp compute_forecast(pids_list, counter, msg) do
    DynSupervisorIot.calculate_and_send_forecast(Enum.at(pids_list, counter), msg)
  end

  defp create_worker(msg) do
    DynSupervisorIot.create_worker(msg)
  end

  defp remove_worker(pid) do
    DynSupervisorIot.remove_worker(pid)
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :recv, [opts]},
      type: :worker,
      restart: :permanent
    }
  end
end
