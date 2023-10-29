# homeassistant

Connect to homeassistant via MQTT. Supports autodiscovery so devices will appear automatically in homeassisstant.

## Usage

Add dependency

```elixir
def deps do
  [
    {:homeassistant, "~> 0.1.0"}
  ]
end
```

Add to your supervision tree
```elixir
  ha_config = [
    mqtt_host: "your_host",
    password: "password"
  ]

  children = [
    # ...
    {Homeassistant, ha_config}
  ]
```

See [lib/homeassistant.ex] for more config options.
