defmodule DataFetching.Application do
  use Application

  def start(_type, _args) do
      children = [
      %{
        id: DataFlowSensors,
        start: {DataFlowSensors, :start_link, [""]}
      },
      %{
        id: DataFlowIot,
        start: {DataFlowIot, :start_link, [""]}
      },
      %{
        id: DataFlowLegacy,
        start: {DataFlowLegacy, :start_link, [""]}
      },
      %{
        id: Distributor,
        start: {Distributor, :start_link, [""]}
      },
      {
        DynSupervisor,
        []
      },
      {
        DynSupervisorIot,
        []
      },
      {
        DynSupervisorLegacy,
        []
      },
      %{
        id: Request,
        start: {Request, :start_link, ["http://localhost:4000/sensors"]}
      },
      %{
        id: RequestIot,
        start: {Request, :start_link, ["http://localhost:4000/iot"]}
      },
      %{
        id: RequestLegacy,
        start: {Request, :start_link, ["http://localhost:4000/legacy_sensors"]}
      },
      %{
        id: Publisher,
        start: {Publisher, :start_link, [2002]}
      },
      %{
        id: PublisherIot,
        start: {PublisherIot, :start_link, [2003]}
      },
      %{
        id: PublisherLegacy,
        start: {PublisherLegacy, :start_link, [2004]}
      }
    ]

    opts = [strategy: :one_for_one, name: MainSupervisor]
    Supervisor.start_link(children, opts)
    IO.puts("Data fetching started!")
    receive do
    end
  end
end
