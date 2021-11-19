defmodule NervesBackdoor.Discovery do
  use GenServer

  def start_link(_opts \\ []) do
    port = NervesBackdoor.port()
    GenServer.start_link(__MODULE__, port)
  end

  @impl true
  def init(port) do
    {:ok, socket} = :gen_udp.open(port, active: true,
      mode: :binary, reuseaddr: true, ip: {0, 0, 0, 0})
    {:ok, {socket, port}}
  end

  @impl true
  def terminate(_reason, _state = {socket, _port}) do
    :ok = :gen_udp.close(socket)
  end

  @impl true
  def handle_info({:udp, socket, ip, port, data}, state) do
    name = NervesBackdoor.name()
    message = Jason.decode!(data)
    case message do
      %{"action"=> "id", "name"=> ^name} ->
        version = NervesBackdoor.version()
        ifname = NervesBackdoor.ifname()
        macaddr = NervesBackdoor.mac()
        hostname = NervesBackdoor.hostname()

        data = %{
          name: name,
          version: version,
          hostname: hostname,
          ifname: ifname,
          macaddr: macaddr
        }
        message = Map.put(message, :data, data)

        :ok = :gen_udp.send(socket, ip, port, Jason.encode!(message))

        %{"action"=> "blink", "name"=> ^name} ->
          NervesBackdoor.blink()
          :ok = :gen_udp.send(socket, ip, port, Jason.encode!(message))
    end

    {:noreply, state}
  end
end
