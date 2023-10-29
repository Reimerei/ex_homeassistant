defmodule Homeassistant.MQTTClient do
  use GenServer
  require Logger

  defmodule State do
    @config_keys [:mqtt_host, :mqtt_port, :client_id, :username, :password]
    @internal_keys [:emqtt_pid, connected: false, queue: []]

    @enforce_keys @config_keys
    defstruct @config_keys ++ @internal_keys
  end

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @doc """
  Publish a message to a topic.

  Opts:
    - retain: boolean [default: false]
  """
  def publish(topic, payload, opts \\ []) when is_binary(topic) and is_binary(payload) do
    GenServer.cast(__MODULE__, {:publish, topic, payload, opts})
  end

  def init(state = %State{}) do
    Process.flag(:trap_exit, true)

    :timer.send_interval(5_000, self(), :connect)
    send(self(), :connect)

    {:ok, state}
  end

  # all ok, do nothing
  def handle_info(:connect, %State{connected: true, emqtt_pid: emqtt_pid} = state)
      when is_pid(emqtt_pid) do
    {:noreply, state}
  end

  # no mqtt pid, start client
  def handle_info(:connect, %State{emqtt_pid: nil} = state) do
    emqtt_opts = [
      clientid: state.client_id,
      host: state.mqtt_host |> String.to_charlist(),
      port: state.mqtt_port,
      proto_ver: :v5,
      username: state.username,
      password: state.password,
      name: :emqtt
    ]

    Logger.debug("ExHomeassstiant: Starting MQTT client")
    {:ok, emqtt_pid} = :emqtt.start_link(emqtt_opts)

    send(self(), :connect)

    {:noreply, %State{state | emqtt_pid: emqtt_pid, connected: false}}
  end

  # client not connected, try to connect
  def handle_info(:connect, %State{emqtt_pid: emqtt_pid} = state) do
    Logger.debug("ExHomeassstiant: Trying to connecting to MQTT broker")

    case :emqtt.connect(emqtt_pid) do
      {:ok, _props} ->
        Logger.info("ExHomeassstiant: MQTT Connected")

        Logger.debug(
          "ExHomeassstiant: There are #{length(state.queue)} messages in the queue. Sending..."
        )

        for {topic, payload} <- Enum.reverse(state.queue) do
          :emqtt.publish(emqtt_pid, topic, payload)
        end

        {:noreply, %State{state | connected: true}}

      {:error, reason} ->
        Logger.warning("ExHomeassstiant: MQTT connection failed: #{inspect(reason)}")
        {:noreply, %State{state | connected: false}}
    end
  end

  def handle_info({:EXIT, _pid, reason}, state) do
    Logger.warning("ExHomeassstiant: MQTT client died #{inspect(reason)}")
    {:noreply, %State{state | connected: false, emqtt_pid: nil}}
  end

  def handle_info({:disconnected, _, _}, %State{} = state) do
    Logger.warning("ExHomeassstiant: MQTT client disconnected")
    {:noreply, %State{state | connected: false}}
  end

  def handle_cast(
        {:publish, topic, payload, opts},
        %State{connected: true, emqtt_pid: emqtt_pid} = state
      )
      when is_pid(emqtt_pid) do
    Logger.debug("ExHomeassstiant: Sending MQTT message to #{topic}: #{inspect(payload)}")

    :emqtt.publish(emqtt_pid, topic, payload, opts)
    {:noreply, state}
  end

  def handle_cast({:publish, topic, payload}, %State{} = state) do
    Logger.debug("ExHomeassstiant: MQTT not connected, message to #{topic} queued.")
    {:noreply, %State{state | queue: [{topic, payload} | state.queue]}}
  end
end
