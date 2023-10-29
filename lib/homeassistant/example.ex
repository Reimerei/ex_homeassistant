defmodule Homeassistant.Example do
  alias Homeassistant.Devices.BinarySensor

  @some_sensor %BinarySensor{
    name: "Moep Test",
    device_class: "door"
  }

  def setup() do
    BinarySensor.setup(@some_sensor)
  end

  def off() do
    BinarySensor.send_state(@some_sensor, false)
  end

  def on() do
    BinarySensor.send_state(@some_sensor, true)
  end
end
