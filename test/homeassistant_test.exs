defmodule HomeassistantTest do
  use ExUnit.Case
  doctest Homeassistant

  test "greets the world" do
    assert Homeassistant.hello() == :world
  end
end
