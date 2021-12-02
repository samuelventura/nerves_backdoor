defmodule NervesBackdoor.Discovery do
  use GenServer

  def start_link(_opts \\ []) do
    port = NervesBackdoor.env_port()
    GenServer.start_link(__MODULE__, port)
  end

  @impl true
  def init(port) do
    {:ok, socket} =
      :gen_udp.open(port, active: true, mode: :binary, reuseaddr: true, ip: {0, 0, 0, 0})

    {:ok, {socket, port}}
  end

  @impl true
  def terminate(_reason, _state = {socket, _port}) do
    :ok = :gen_udp.close(socket)
  end

  @impl true
  def handle_info({:udp, socket, ip, port, data}, state) do
    IO.inspect({ip, port, data})
    name = NervesBackdoor.env_name()
    color = NervesBackdoor.env_blink_color()
    message = Jason.decode!(data)

    case message do
      %{"action" => "id", "name" => ^name} ->
        version = NervesBackdoor.env_version()
        ifname = NervesBackdoor.env_ifname()
        macaddr = NervesBackdoor.get_mac()
        hostname = NervesBackdoor.env_hostname()

        data = %{
          name: name,
          version: version,
          hostname: hostname,
          ifname: ifname,
          macaddr: macaddr
        }

        message = Map.put(message, :data, data)

        :ok = :gen_udp.send(socket, ip, port, Jason.encode!(message))

      %{"action" => "blink", "name" => ^name} ->
        NervesBackdoor.io_blink(color)
        :ok = :gen_udp.send(socket, ip, port, Jason.encode!(message))
    end

    {:noreply, state}
  end
end
