ExUnit.start()

defmodule NervesBackdoor.TestGPIO do
  use GenServer

  def start_link(_opts \\ []) do
    init_args = []
    GenServer.start_link(__MODULE__, init_args, name: :nbd_gpio)
  end

  @impl true
  def init(_args) do
    {:ok, %{}}
  end

  @impl true
  def handle_call(req, _from, state) do
    case req do
      {:output, port} ->
        {:reply, {:ok, port}, state}

      {:input, port} ->
        {:reply, {:ok, port}, state}

      {:write, gpio, value} ->
        state = Map.put(state, gpio, value)
        {:reply, :ok, state}

      {:read, gpio} ->
        {:reply, Map.get(state, gpio), state}

      {:close, _gpio} ->
        {:reply, :ok, state}
    end
  end
end

defmodule NervesBackdoor.TestVintageNet do
  use GenServer

  def start_link(_opts \\ []) do
    init_args = []
    GenServer.start_link(__MODULE__, init_args, name: :nbd_vnet)
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
      case req do
        {:all_interfaces} ->
          res = ["eth0", "usb0", "lo"]
          {:reply, {:ok, res}, state}

        {:configure, interface, params} ->
          state = Map.put(state, interface, params)
          {:reply, :ok, state}

        {:get_configuration, interface} ->
          config = Map.get(state, interface, %{method: "dhcp"})
          res = %{interface: interface, state: "configured", connection: "disconnected", config: config}
          {:reply, {:ok, res}, state}
        end
  end
end

Application.start(:telemetry)
Application.put_env(:nerves_backdoor, :blink_ms, 0)
Application.put_env(:nerves_backdoor, :ifname, "ethx")
Application.put_env(:nerves_backdoor, :hostname, "test")
Application.put_env(:nerves_backdoor, :home, "/tmp/backdoor")
File.rm("/tmp/backdoor/password.txt")
NervesBackdoor.Discovery.start_link()
NervesBackdoor.TestGPIO.start_link()
NervesBackdoor.TestVintageNet.start_link()
