defmodule SubscriberServer do
  use GenServer
  require Logger

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def subscribe(data, package) do
    GenServer.cast(__MODULE__, {:subscribe, data, package})
  end

  def unsubscribe(data, package) do
    GenServer.cast(__MODULE__, {:unsubscribe, data, package})
  end

  def broadcast_messages(socket) do
    GenServer.cast(__MODULE__, {:broadcast_messages, socket})
   end

  def init(_) do
    subscriber_registry = Map.new()

    {:ok, subscriber_registry}
  end

  def handle_cast({:subscribe, data, package}, subscriber_state) do
    subscriber = {elem(data, 0), elem(data, 1)}
    topic = package["topic"]
    Map.delete(package, "topic")

    topics = get_topics(topic)

    subscriber_new_state =  Enum.reduce(topics, subscriber_state, fn topic, acc ->
      if Map.has_key?(subscriber_state, topic) do
        subscribers = Map.get(subscriber_state, topic)
        subscribers = subscribers ++ [subscriber]
        Map.put(acc, topic, subscribers)
      else
        Map.put(acc, topic, [subscriber])
      end
    end)

    {:noreply, subscriber_new_state}
  end

  def handle_cast({:unsubscribe, data, package}, subscriber_state) do
    subscriber = {elem(data, 0), elem(data, 1)}
    topic = package["topic"]
    Map.delete(package, "topic")
    
    topics = get_topics(topic)

    subscriber_new_state =  Enum.reduce(topics, subscriber_state, fn topic, acc ->
      if Map.has_key?(subscriber_state, topic) do
        subscribers = Map.get(subscriber_state, topic)
        if Enum.member?(subscribers, subscriber) do
          subscribers = List.delete(subscribers, subscriber)
          Map.put(acc, topic, subscribers)
        else
          Logger.info("Error! Not subscribed to topic #{topic}")
          subscriber_state
        end
      else
        Logger.info("Error! Not such topic #{topic}")
        subscriber_state
      end
    end)

      {:noreply, subscriber_new_state}
  end

  def handle_cast({:broadcast_messages, socket}, subscriber_state) do
    topics = Map.keys(subscriber_state)

    Enum.each(topics, fn topic ->
      hosts = Map.get(subscriber_state, topic)
      messages = Queue.get(topics)

      if messages != nil do
        if length(messages) != 0 do
          IO.inspect(messages)
          Enum.each(messages, fn message ->
            message = Map.put(message, "topic", topic)
            encoded_message = Poison.encode!(message)
            Enum.each(hosts, fn host ->
            IO.inspect(host)
              address = elem(host, 0)
              port = elem(host, 1)
              case :gen_udp.send(socket, address, port, encoded_message) do
                :ok ->
                  Logger.info("Message sent to #{port} topic: #{topic}")
                {:error, reason} ->
                  Logger.info("Could not send packet! Reasaon: #{reason}")
              end
            end)
          end)
        end
      else
        Logger.info("Error! Not such topic #{topic}")
      end
    end)
    {:noreply, subscriber_state}
  end

  defp get_topics(topic) do
    topics =
      if String.contains?(topic, "/") do
        String.split(topic, "/", trim: true)
      else
        [topic]
      end

      topics
  end

end
