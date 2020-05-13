defmodule Queue do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def add(package) do
    GenServer.cast(__MODULE__, {:push, package})
  end

  def get(topic) do
    GenServer.call(__MODULE__, {:pop, topic})
  end

  def init(_) do
    queue = Map.new()

    {:ok, queue}
  end

  def handle_cast({:push, package}, state) do
    topic = package["topic"]
    message = Map.delete(package, "topic")

    if Map.has_key?(state, topic) do
      messages = Map.get(state, topic)
      messages = messages ++ [message]
      new_state = Map.put(state, topic, messages)

      {:noreply, new_state}
    else
      new_state = Map.put(state, topic, [message])

      {:noreply, new_state}
    end
  end

  def handle_call({:pop, topic}, _from, state) do
    if state == %{} do
      {:reply, [], state}
    else
      messages = Map.get(state, topic)
      new_state = Map.put(state, topic, [])

      {:reply, messages, new_state}
    end
  end

end
