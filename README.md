# homeassistant

Connect to homeassistant via MQTT. Supports autodiscovery so devices will appear automatically in homeassisstant.

## Add to your project

Add dependency

```elixir
def deps do
  [
    {:ex_homeassistant, "~> 0.1.0"}
  ]
end
```

Add to your supervision tree
```elixir
  mqtt_config = [
    mqtt_host: "your_host",
    password: "password"
  ]

  children = [
    # ...
    {Homeassistant, mqtt_config}
  ]
```

See [here](lib/homeassistant.ex) for more config options.

## Usage

```elixir
defmodule Example do
  alias Homeassistant.Devices.BinarySensor

  @sensor %BinarySensor{
    name: "Moep Test",
    device_class: "door"
  }

  # sends the config of the sensor to homeasssistant and triggers the autodiscovery
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

```

