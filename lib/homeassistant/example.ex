defmodule Homeassistant.Example do
  alias Homeassistant.Devices.{BinarySensor, Select}

  @binary_sensor %BinarySensor{
    name: "Moep Test",
    device_class: "door"
  }

  @select %Select{
    name: "Moep Select",
    options: ["Option 1", "Option 2", "Option 3"]
  }

  def sensor_setup() do
    BinarySensor.setup(@binary_sensor)
  end

  def sensor_off() do
    BinarySensor.send_state(@binary_sensor, false)
  end

  def sensor_on() do
    BinarySensor.send_state(@binary_sensor, true)
  end

  def select_setup() do
    Select.setup(@select)
  end

  def select_send_state(option) do
    Select.send_state(@select, option)
  end

  def select_subscribe(reply_to) do
    Select.subscribe(@select, reply_to)
  end
end
