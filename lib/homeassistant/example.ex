defmodule ExHomeassistant.Example do
  alias ExHomeassistant.Devices.{BinarySensor, Select, Switch}

  @binary_sensor %BinarySensor{
    name: "Moep Sensor",
    device_class: "door"
  }

  @select %Select{
    name: "Moep Select",
    options: ["Option 1", "Option 2", "Option 3"]
  }

  @switch %Switch{
    name: "Moep Switch"
  }

  def sensor_configure() do
    BinarySensor.configure(@binary_sensor)
  end

  def sensor_off() do
    BinarySensor.set_state(@binary_sensor, false)
  end

  def sensor_on() do
    BinarySensor.set_state(@binary_sensor, true)
  end

  def select_configure() do
    Select.configure(@select)
  end

  def select_send_state(option) do
    Select.set_state(@select, option)
  end

  def switch_configure() do
    Switch.configure(@switch)
  end

  def switch_subscribe() do
    Switch.subscribe(@switch)
  end

  def switch_receive() do
    receive do
      event ->
        Switch.parse_event(@switch, event)
    end
  end

  def switch_off() do
    Switch.set_state(@switch, false)
  end

  def switch_on() do
    Switch.set_state(@switch, true)
  end
end
