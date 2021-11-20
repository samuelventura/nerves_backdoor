defmodule NervesBackdoor.Vintage do
  use GenServer

  def start_link(_opts \\ []) do
    init_args = []
    GenServer.start_link(__MODULE__, init_args, name: :nbd_vnet)
  end

  def stop() do
    GenServer.stop(:nbd_vnet)
  end

  def all_interfaces() do
    GenServer.call(:nbd_vnet, {:all_interfaces})
  end

  def configure(interface, params) do
    GenServer.call(:nbd_vnet, {:configure, interface, params})
  end

  def get_configuration(interface) do
    GenServer.call(:nbd_vnet, {:get_configuration, interface})
  end

  @impl true
  def init(_args) do
    {:ok, %{}}
  end

  @impl true
  def handle_call(req, _from, state) do
    res =
      case req do
        {:all_interfaces} ->
          :erlang.apply(VintageNet, :all_interfaces, [])

        {:configure, interface, params} ->
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

        {:get_configuration, interface} ->
          state = :erlang.apply(VintageNet, :get, [["interface", interface, "state"]])
          connection = :erlang.apply(VintageNet, :get, [["interface", interface, "connection"]])
          config = :erlang.apply(VintageNet, :get_configuration, [interface])
          {:ok, %{interface: interface, state: state, connection: connection, config: config}}
      end

    {:reply, res, state}
  end
end
