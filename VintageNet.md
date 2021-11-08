# VintageNET

## API

```elixir
#https://hexdocs.pm/vintage_net/0.6.0/VintageNet.html
iex(2)> VintageNet.get(["interface", "eth0", "connection"])
:internet
iex(3)> VintageNet.get(["interface", "eth0", "state"])     
:configured
iex(4)> VintageNet.get(["interface", "eth0", "type"]) 
VintageNetEthernet
iex(6)> VintageNet.get(["interface", "usb0", "connection"])
:disconnected
iex(7)> VintageNet.get(["interface", "usb0", "state"])     
:configured
iex(8)> VintageNet.get(["interface", "usb0", "type"])      
VintageNetDirect
iex(9)> VintageNet.get_configuration("eth0")          
%{ipv4: %{method: :dhcp}, type: VintageNetEthernet}
iex(10)> VintageNet.get_configuration("usb0")
%{type: VintageNetDirect}
iex(12)> VintageNet.configure("eth0", %{type: VintageNetEthernet, ipv4: %{method: :dhcp}})
:ok
iex(23)> VintageNet.configure("eth0", %{type: VintageNetEthernet, ipv4: %{ method: :static, address: "10.77.4.165", prefix_length: 8, gateway: "10.77.0.1", name_servers: ["10.77.0.1"]}})
:ok
iex(11)> VintageNet.info                               
VintageNet 0.11.2

All interfaces:       ["eth0", "lo", "usb0"]
Available interfaces: ["eth0"]

Interface eth0
  Type: VintageNetEthernet
  Present: true
  State: :configured (21:49:10)
  Connection: :internet (1:18:38)
  Addresses: fe80::aae7:7dff:feed:22e8/64, 10.77.3.167/8
  Configuration:
    %{ipv4: %{method: :dhcp}, type: VintageNetEthernet}

Interface usb0
  Type: VintageNetDirect
  Present: true
  State: :configured (21:49:10)
  Connection: :disconnected (21:49:10)
  Addresses: 172.31.195.245/30
  Configuration:
    %{type: VintageNetDirect}

Interface wlan0
  Type: VintageNetWiFi
  Present: false
  Configuration:
    %{type: VintageNetWiFi}

:ok
```
