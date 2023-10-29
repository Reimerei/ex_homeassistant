defmodule Homeassistant.Application do
  use Application

  def start(_type, _args) do
    children =
      case Application.fetch_env(:homeassistant, :test_config) do
        {:ok, config} -> [{Homeassistant, config}]
        :error -> []
      end

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
