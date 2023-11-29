defmodule ExHomeassistant do
  use Supervisor

  alias ExHomeassistant.MQTTClient

  @doc """
  Starts the supervisor, add this to your application supervisor.

  Options:
    - mqtt_host: string [default: "localhost"]
    - mqtt_port: integer [default: 1883]
    - client_id: string [default: "homeassistant"]
    - username: string [default: "homeassistant"]
    - password: string [default: ""]
  """
  def start_link(nil), do: :ignore

  def start_link(opts) do
    mqtt_state = %MQTTClient.State{
      mqtt_host: Keyword.get(opts, :mqtt_host, "localhost"),
      mqtt_port: Keyword.get(opts, :mqtt_port, 1883),
      client_id: Keyword.get(opts, :client_id, "homeassistant"),
      username: Keyword.get(opts, :username, "homeassistant"),
      password: Keyword.get(opts, :password, "")
    }

    Supervisor.start_link(__MODULE__, mqtt_state)
  end

  def init(mqtt_state) do
    children = [{ExHomeassistant.MQTTClient, mqtt_state}]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
