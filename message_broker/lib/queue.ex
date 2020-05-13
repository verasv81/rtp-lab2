defmodule Queue do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def add(package) do
    GenServer.cast(__MODULE__, {:add_message, package})
  end

  def get(topic) do
    GenServer.call(__MODULE__, {:get_message, topic})
  end

  def init(_) do
    registry = Map.new()

    {:ok, registry}
  end

  def handle_cast({:add_message, package}, state) do
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

  def handle_call({:get_message, topic}, _from, state) do
    if state == %{} do
      {:reply, [], state}
    else
      messages = Map.get(state, topic)
      new_state = Map.put(state, topic, [])

      {:reply, messages, new_state}
    end
  end

end
