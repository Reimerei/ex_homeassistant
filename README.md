# ExHomeassistant

Connect to homeassistant via MQTT. Supports autodiscovery, devices will appear automatically in homeassisstant.

## Add to your project

Add dependency

```elixir
def deps do
  [
    {:ex_homeassistant, "~> 0.1.0"}
  ]
end
```

Add to your supervision tree. See [here](lib/homeassistant.ex) for more config options.
```elixir
  mqtt_config = [
    mqtt_host: "your_host",
    password: "password",
    client_id: "client_id"
  ]

  children = [
    # ...
    {ExHomeassistant, mqtt_config}
  ]
```


## Usage

```elixir
defmodule Example do
  alias ExHomeassistant.Devices.BinarySensor

  @sensor %BinarySensor{
    name: "Moep Test",
    device_class: "door"
  }

  # sends the config of the sensor to homeassistant and triggers the autodiscovery
  def setup() do
    BinarySensor.configure(@some_sensor)
  end

  def off() do
    BinarySensor.set_state(@some_sensor, false)
  end

  def on() do
    BinarySensor.set_state(@some_sensor, true)
  end
end
```

See [here](lib/example.ex) for more examples.