defmodule Queue do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE_)
  end

  def add_data(queue, data) do
    GenServer.cast(queue, {:add, data})
  end

  def get_messages(topic) do
    GenServer.call(__MODULE__, {:get_messages, topic})
  end

  @impl true
  def handle_cast({:add, recieved_data}, state) do
    topic = recieved_data["topic"]
    data = Map.get(state, topic, [])
    next_state = Map.put(state, topic, current_data ++ [recieved_data])

    {:noreply, next_state}
  end

  @impl true 
  def handle_call({:get_messages, topic}, _from, state) do
    {
      :reply,
      Map.get(state, topic)
      Map.put(state, topic)
    }
  end
end