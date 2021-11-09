# NervesBackdoor

This RESTish API covers the following basic needs:

- Network setup (eth0)
- Database backup and restore
- Password reset (thru file upload) 

## API

```bash
curl http://nerves.local:31680/ping
curl http://nerves.local:31680/data/$DB.db3 --output /tmp/$DB.db3
curl -F 'data=@/tmp/$DB.db3' http://nerves.local:31680/upload?path=/data/$DB.db3
curl http://nerves.local:31680/net/state/eth0
curl http://nerves.local:31680/net/setup/eth0 -H "Content-Type: application/json" -X POST -d '{"method":"dhcp"}'
curl http://nerves.local:31680/net/setup/eth0 -H "Content-Type: application/json" -X POST -d '{"method":"static", "address":"10.77.4.100", "prefix_length":8, "gateway":"10.77.0.1", "name_servers":["10.77.0.1"]}'
curl http://nerves.local:31680/app/start/$APP
curl http://nerves.local:31680/app/stop/$APP
```

## Helpers

```bash
Application.started_applications
Application.loaded_applications
Application.get_all_env :nss
ls "/data"
VintageNet.info
VintageNet.get_configuration("eth0")
VintageNet.get(["interface", "eth0", "type"])
VintageNet.get(["interface", "eth0", "state"])
VintageNet.get(["interface", "eth0", "connection"])
VintageNet.configure("eth0", %{type: VintageNetEthernet, ipv4: %{method: :dhcp}})
VintageNet.configure("eth0", %{type: VintageNetEthernet, ipv4: %{method: :static, address: "10.77.4.100", prefix_length: 8, gateway: "10.77.0.1", name_servers: ["10.77.0.1"]}})
```

## Installation

Install into nerves project as described at https://hexdocs.pm/nerves/user-interfaces.html

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `nerves_backdoor` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:nerves_backdoor, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/nerves_backdoor](https://hexdocs.pm/nerves_backdoor).

## Research

- Restrict cowboy listener to usb0 interface
- Device discovery