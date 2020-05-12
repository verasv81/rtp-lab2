defmodule DataFetching.Application do
  use Application

  def start(_type, _args) do
      children = [
      %{
        id: DataFlow,
        start: {DataFlow, :start_link, [""]}
      },
      %{
        id: DataFlowIot,
        start: {DataFlow, :start_link, [""]}
      },
      %{
        id: DataFlowLegacy,
        start: {DataFlow, :start_link, [""]}
      },
      %{
        id: Distributor,
        start: {Distributor, :start_link, [""]}
      },
      %{
        id: DistributorIot,
        start: {Distributor, :start_link, [""]}
      },
      %{
        id: DistributorLegacy,
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
      }
    ]

    opts = [strategy: :one_for_one, name: MainSupervisor]
    Supervisor.start_link(children, opts)

    receive do
    end
    
  end
end
