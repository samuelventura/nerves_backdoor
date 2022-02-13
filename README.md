# NervesBackdoor

Setup and Maintenance Tools with Web API:

- Network setup (eth0)
- Device discovery (UDP broadcast)
- Database backup and restore
- Password reset (thru file upload) 

## API

```bash
curl http://nerves.local:31680/ping -u nerves:MAC
curl http://nerves.local:31680/ping
curl http://nerves.local:31680/data/$DB.db3 --output /tmp/$DB.db3
curl http://nerves.local:31680/upload?path=/data/$DB.db3 -F 'file=@/tmp/$DB.db3'
curl http://nerves.local:31680/net/state/eth0
curl http://nerves.local:31680/net/setup/eth0 -H "Content-Type: application/json" -X POST -d '{"method":"dhcp"}'
curl http://nerves.local:31680/net/setup/eth0 -H "Content-Type: application/json" -X POST -d '{"method":"static", "address":"10.77.4.100", "prefix_length":8, "gateway":"10.77.0.1", "name_servers":["10.77.0.1"]}'
curl http://nerves.local:31680/app/start/$APP -X POST
curl http://nerves.local:31680/app/stop/$APP -X POST
curl http://nerves.local:31680/pass/set -X POST --data "pass=secret64"
curl http://nerves.local:31680/pass/disabled
curl http://nerves.local:31680/pass/reset
```

## Helpers

```bash
mix run discover.exs --no-start
NervesBackdoor.get_pass :current|:default
NervesBackdoor.set_pass "secret"
NervesBackdoor.reset_pass
NervesBackdoor.disable_pass
NervesBackdoor.io_blink :red|:green|:blue|<int>, :env|<int>
NervesBackdoor.io_output :red|:green|:blue|<int>, 0|1
NervesBackdoor.io_input :push|:env|<int>
Application.started_applications
Application.loaded_applications
Application.start :nerves_backdoor
Application.stop :nerves_backdoor
Application.get_all_env :nerves_backdoor
Application.ensure_all_started :nerves_backdoor
ls "/data"
ls "/data/backdoor"
ifconfig
cmd "reboot"
cmd "poweroff"
cmd "cat /data/backdoor/password.txt"
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
- Restrict discovery broadcast to eth0
- VintageNet unrecoverable ETS error after setting invalid config
- Customize and broadcast nerves-% hostname
- Nerves environ emulator for testing and trying out
- Compile/load app from remote filesystem (dev workstation)
- Run tests against live system
- Minimize web response to ___code error|json___
- Custom Jason encoder for erlang strings
- Circuits.GPIO multiple references and closing
