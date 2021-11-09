defmodule NervesBackdoor.Vintage do
  def all_interfaces() do
    :erlang.apply(VintageNet, :all_interfaces, [])
  end

  def configure(interface, params) do
    method = Map.fetch!(params, "method")

    config =
      case method do
        "dhcp" ->
          %{type: VintageNetEthernet, ipv4: %{method: :dhcp}}

        "static" ->
          address = Map.fetch!(params, "address")
          prefix_length = Map.fetch!(params, "prefix_length")
          gateway = Map.fetch!(params, "gateway")
          name_servers = Map.fetch!(params, "name_servers")

          %{
            type: VintageNetEthernet,
            ipv4: %{
              method: :static,
              # string
              address: address,
              # integer
              prefix_length: prefix_length,
              # string
              gateway: gateway,
              # list of strings
              name_servers: name_servers
            }
          }
      end

    :erlang.apply(VintageNet, :configure, [interface, config])
  end

  def get_configuration(interface) do
    state = :erlang.apply(VintageNet, :get, [["interface", interface, "state"]])
    connection = :erlang.apply(VintageNet, :get, [["interface", interface, "connection"]])
    config = :erlang.apply(VintageNet, :get_configuration, [interface])
    {:ok, %{interface: interface, state: state, connection: connection, config: config}}
  end
end
