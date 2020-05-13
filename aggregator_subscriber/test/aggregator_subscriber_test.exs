defmodule AggregatorSubscriberTest do
  use ExUnit.Case
  doctest AggregatorSubscriber

  test "greets the world" do
    assert AggregatorSubscriber.hello() == :world
  end
end
