defmodule ExHomeassistantTest do
  use ExUnit.Case
  doctest ExHomeassistant

  test "greets the world" do
    assert ExHomeassistant.hello() == :world
  end
end
