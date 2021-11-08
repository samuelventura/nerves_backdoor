defmodule NervesBackdoor do
  def net_setup(interface, params) do
    method = Map.fetch!(params, "method")
    config = case method do
      "dhcp" -> %{type: VintageNetEthernet, ipv4: %{method: :dhcp}}
      "static" ->
        address = Map.fetch!(params, "address")
        prefix_length = Map.fetch!(params, "prefix_length")
        gateway = Map.fetch!(params, "gateway")
        name_servers = Map.fetch!(params, "name_servers")
        %{type: VintageNetEthernet,
          ipv4: %{
            method: :static,
            address: address,               #string
            prefix_length: prefix_length,   #integer
            gateway: gateway,               #string
            name_servers: name_servers}}    #list of strings
    end
    :erlang.apply(VintageNet, :configure, [interface, config])
  end

  def net_state(interface) do
    state = :erlang.apply(VintageNet, :get, [["interface", interface, "state"]])
    connection = :erlang.apply(VintageNet, :get, [["interface", interface, "connection"]])
    config = :erlang.apply(VintageNet, :get_configuration, [interface])
    {:ok, %{interface: interface, state: state, connection: connection, config: config}}
  end
end
