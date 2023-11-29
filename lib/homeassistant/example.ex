defmodule ExHomeassistant.Example do
  alias ExHomeassistant.Devices.{BinarySensor, Select}

  @binary_sensor %BinarySensor{
    name: "Moep Test",
    device_class: "door"
  }

  @select %Select{
    name: "Moep Select",
    options: ["Option 1", "Option 2", "Option 3"]
  }

  def sensor_setup() do
    BinarySensor.configure(@binary_sensor)
  end

  def sensor_off() do
    BinarySensor.set_state(@binary_sensor, false)
  end

  def sensor_on() do
    BinarySensor.set_state(@binary_sensor, true)
  end

  def select_setup() do
    Select.configure(@select)
  end

  def select_send_state(option) do
    Select.set_state(@select, option)
  end

  def select_subscribe() do
    Select.subscribe(@select)
  end
end
