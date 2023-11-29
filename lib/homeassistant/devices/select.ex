defmodule ExHomeassistant.Devices.Select do
  require Logger
  alias ExHomeassistant.{MQTTClient, Helper}

  defstruct [:name, :options]

  def configure(%__MODULE__{} = select) do
    payload =
      %{
        name: select.name,
        options: select.options,
        command_topic: command_topic(select),
        state_topic: state_topic(select),
        unique_id: "#{entity_id(select)}_#{:erlang.phash2(select.name)}"
      }
      |> Jason.encode!()

    topic = "homeassistant/select/#{entity_id(select)}/config"

    MQTTClient.publish(topic, payload)
  end

  def set_state(%__MODULE__{} = select, option) do
    if option in select.options do
      payload = option
      topic = state_topic(select)

      MQTTClient.publish(topic, payload)
    else
      Logger.error("ExExHomeassistant: Option #{option} not in #{inspect(select.options)}")
    end
  end

  def subscribe(%__MODULE__{} = select) do
    topic = command_topic(select)
    MQTTClient.subscribe(topic, self())
  end

  defp command_topic(%__MODULE__{} = select) do
    "homeassistant/select/#{entity_id(select)}/set"
  end

  defp state_topic(%__MODULE__{} = select) do
    "homeassistant/select/#{entity_id(select)}/state"
  end

  defp entity_id(%__MODULE__{} = select) do
    select.name
    |> Helper.sanetize_entity_id()
  end
end
