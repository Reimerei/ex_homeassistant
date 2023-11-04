defmodule Homeassistant.Devices.BinarySensor do
  alias Homeassistant.{MQTTClient, Helper}

  # see here for device classes: https://www.home-assistant.io/integrations/binary_sensor/
  defstruct [:name, :device_class]

  def setup(%__MODULE__{} = binary_sensor) do
    payload =
      %{
        name: binary_sensor.name,
        device_class: binary_sensor.device_class,
        state_topic: state_topic(binary_sensor),
        unique_id: "#{entity_id(binary_sensor)}_#{:erlang.phash2(binary_sensor.name)}"
      }
      |> Jason.encode!()

    topic = "homeassistant/binary_sensor/#{entity_id(binary_sensor)}/config"

    MQTTClient.publish(topic, payload)
  end

  def send_state(%__MODULE__{} = binary_sensor, state) when is_boolean(state) do
    payload = if state, do: "ON", else: "OFF"
    topic = state_topic(binary_sensor)

    MQTTClient.publish(topic, payload)
  end

  defp state_topic(%__MODULE__{} = binary_sensor) do
    "homeassistant/binary_sensor/#{entity_id(binary_sensor)}/state"
  end

  defp entity_id(%__MODULE__{} = binary_sensor) do
    binary_sensor.name
    |> Helper.sanetize_entity_id()
  end
end
