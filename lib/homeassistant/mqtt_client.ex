defmodule ExHomeassistant.MQTTClient do
  use GenServer
  require Logger

  defmodule State do
    @config_keys [:mqtt_host, :mqtt_port, :client_id, :username, :password]
    @internal_keys [:emqtt_pid, connected: false, queue: [], subscriptions: %{}]

    @enforce_keys @config_keys
    defstruct @config_keys ++ @internal_keys
  end

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @doc """
  Publish a message to a topic.

  Opts:
    - retain: boolean [default: true]
  """
  def publish(topic, payload, opts \\ []) when is_binary(topic) and is_binary(payload) do
    opts = Keyword.put_new(opts, :retain, true)

    GenServer.cast(__MODULE__, {:publish, topic, payload, opts})
  end

  def subscribe(topic, reply_to) when is_binary(topic) and is_pid(reply_to) do
    GenServer.cast(__MODULE__, {:subscribe, topic, reply_to})
  end

  # GenServer callbacks

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

    Logger.debug("ExHomeasstiant: Starting MQTT client")
    {:ok, emqtt_pid} = :emqtt.start_link(emqtt_opts)

    send(self(), :connect)

    {:noreply, %State{state | emqtt_pid: emqtt_pid, connected: false}}
  end

  # client not connected, try to connect
  def handle_info(:connect, %State{emqtt_pid: emqtt_pid} = state) do
    Logger.debug("ExHomeasstiant: Trying to connecting to MQTT broker")

    case :emqtt.connect(emqtt_pid) do
      {:ok, _props} ->
        Logger.info("ExHomeasstiant: MQTT Connected")

        Logger.debug(
          "ExHomeasstiant: There are #{length(state.queue)} messages in the queue. Sending..."
        )

        for msg <- Enum.reverse(state.queue) do
          GenServer.cast(__MODULE__, msg)
        end

        {:noreply, %State{state | connected: true}}

      {:error, reason} ->
        Logger.warning("ExHomeasstiant: MQTT connection failed: #{inspect(reason)}")
        {:noreply, %State{state | connected: false}}
    end
  end

  def handle_info({:publish, %{payload: payload, topic: topic}}, %State{} = state) do
    case Map.fetch(state.subscriptions, topic) do
      {:ok, reply_to} ->
        send(reply_to, {:homeassistant_command, topic, payload})

      :error ->
        Logger.warning("ExHomeasstiant: No subscriber for #{topic}. Ignoring message.")
    end

    {:noreply, state}
  end

  def handle_info({:EXIT, _pid, reason}, state) do
    Logger.warning("ExHomeasstiant: MQTT client died #{inspect(reason)}")
    {:noreply, %State{state | connected: false, emqtt_pid: nil}}
  end

  def handle_info({:disconnected, _, _}, %State{} = state) do
    Logger.warning("ExHomeasstiant: MQTT client disconnected")
    {:noreply, %State{state | connected: false}}
  end

  def handle_cast(
        {:publish, topic, payload, opts},
        %State{connected: true, emqtt_pid: emqtt_pid} = state
      )
      when is_pid(emqtt_pid) do
    :emqtt.publish(emqtt_pid, topic, payload, opts)
    {:noreply, state}
  end

  def handle_cast(
        {:subscribe, topic, reply_to},
        %State{connected: true, emqtt_pid: emqtt_pid} = state
      )
      when is_pid(emqtt_pid) do
    :emqtt.subscribe(emqtt_pid, topic)
    {:noreply, %State{state | subscriptions: Map.put(state.subscriptions, topic, reply_to)}}
  end

  def handle_cast(msg, %State{} = state) do
    Logger.debug("ExHomeasstiant: MQTT not connected, queueing msg #{inspect(msg)}")
    {:noreply, %State{state | queue: [msg | state.queue]}}
  end
end
