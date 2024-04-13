defmodule ExHomeassistant.Devices.Switch do
  require Logger
  alias ExHomeassistant.{MQTTClient, Helper}

  # https://www.home-assistant.io/integrations/switch
  defstruct [:name]

  def configure(%__MODULE__{} = switch) do
    payload =
      %{
        name: switch.name,
        device_class: "switch",
        state_topic: state_topic(switch),
        command_topic: command_topic(switch),
        unique_id: "#{entity_id(switch)}_#{:erlang.phash2(switch.name)}"
      }
      |> Jason.encode!()

    topic = "homeassistant/switch/#{entity_id(switch)}/config"

    MQTTClient.publish(topic, payload)
  end

  def set_state(%__MODULE__{} = switch, state) when is_boolean(state) do
    payload = if state, do: "ON", else: "OFF"
    topic = state_topic(switch)

    MQTTClient.publish(topic, payload)
  end

  def subscribe(%__MODULE__{} = switch) do
    topic = command_topic(switch)
    MQTTClient.subscribe(topic, self())
  end

  def parse_event(%__MODULE__{} = switch, event) do
    topic = command_topic(switch)

    case event do
      {:homeassistant_command, ^topic, "ON"} ->
        true

      {:homeassistant_command, ^topic, "OFF"} ->
        false

      _ ->
        Logger.error("Unknown event for switch: #{inspect(event)}")
        nil
    end
  end

  defp command_topic(%__MODULE__{} = switch) do
    "homeassistant/switch/#{entity_id(switch)}/set"
  end

  defp state_topic(%__MODULE__{} = switch) do
    "homeassistant/switch/#{entity_id(switch)}/state"
  end

  defp entity_id(%__MODULE__{} = switch) do
    switch.name
    |> Helper.sanetize_entity_id()
  end
end
