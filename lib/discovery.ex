defmodule NervesBackdoor.Discovery do
  use GenServer

  # {:ok, pid} = NervesBackdoor.Discovery.start_link 31680
  # :ok = GenServer.stop pid
  # {:ok, socket} = :gen_udp.open(0, active: true, broadcast: true)
  # id_cmd = Jason.encode! %{action: "id", name: "nerves"}
  # blink_cmd = Jason.encode! %{action: "id", name: "nerves"}
  # :ok = :gen_udp.send(socket, {127,0,0,1}, 31680, id_cmd)
  # :ok = :gen_udp.send(socket, {127,0,0,1}, 31680, blink_cmd)
  # :ok = :gen_udp.send(socket, {255,255,255,255}, 31680, id_cmd)
  # :ok = :gen_udp.close(socket)
  # flush()
  def start_link(port) do
    GenServer.start_link(__MODULE__, port)
  end

  @impl true
  def init(port) do
    {:ok, socket} = :gen_udp.open(port, active: true, mode: :binary)
    {:ok, {socket, port}}
  end

  @impl true
  def terminate(_reason, _state = {socket, _port}) do
    :ok = :gen_udp.close(socket)
  end

  @impl true
  def handle_info({:udp, socket, ip, port, data}, state) do
    name = NervesBackdoor.Environ.name()
    message = Jason.decode!(data)
    case message do
      %{"action"=> "id", "name"=> ^name} ->
        version = NervesBackdoor.Environ.version()
        ifname = NervesBackdoor.Environ.ifname()
        macaddr = NervesBackdoor.Environ.mac()
        hostname = NervesBackdoor.Environ.hostname()

        data = %{
          name: name,
          version: version,
          hostname: hostname,
          ifname: ifname,
          macaddr: macaddr
        }

        :ok = :gen_udp.send(socket, ip, port, Jason.encode!(data))

        %{"action"=> "blink", "name"=> ^name} ->
          NervesBackdoor.Environ.blink()
    end

    {:noreply, state}
  end
end
