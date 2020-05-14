defmodule Queue do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def push(package) do
    GenServer.cast(__MODULE__, {:push, package})
  end

  def get(topic) do
    GenServer.call(__MODULE__, {:get, topic})
  end

  def init(_) do
    queue = Map.new()

    {:ok, queue}
  end

  def handle_cast({:push, package}, state) do
    topic = package["topic"]
    
    if Map.has_key?(state, topic) do
      messages = Map.get(state, topic, [])
      messages = messages ++ [package]
      new_state = Map.put(state, topic, messages)

      {:noreply, new_state}
    else
      new_state = Map.put(state, topic, [package])

      {:noreply, new_state}
    end
  end

  def handle_call({:get, topic}, _from, state) do
    if state == %{} do
      {:reply, [], state}
    else
      messages = Map.take(state, topic)
      
      {:reply, messages, state}
    end
  end

end
