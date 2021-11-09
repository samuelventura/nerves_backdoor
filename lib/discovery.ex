defmodule NervesBackdoor.Discovery do
  use GenServer

  # {:ok, pid} = NervesBackdoor.Discovery.start_link 31680
  # :ok = GenServer.stop pid
  # {:ok, socket} = :gen_udp.open(0, active: true, broadcast: true)
  # :ok = :gen_udp.send(socket, {127,0,0,1}, 31680, "id")
  # :ok = :gen_udp.send(socket, {255,255,255,255}, 31680, "id")
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
  def handle_info({:udp, socket, ip, port, message}, state) do
    case message do
      "id" ->
        name = NervesBackdoor.Environ.name()
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

        :gen_udp.send(socket, ip, port, Jason.encode!(data))

      "blink" ->
        io = NervesBackdoor.Environ.io_led()
        {:ok, gpio} = :erlang.apply(Circuits.GPIO, :open, [io, :output])
        :ok = :erlang.apply(Circuits.GPIO, :write, [gpio, 1])
        :timer.sleep(400)
        :ok = :erlang.apply(Circuits.GPIO, :write, [gpio, 0])
        :timer.sleep(400)
        :ok = :erlang.apply(Circuits.GPIO, :write, [gpio, 1])
        :timer.sleep(400)
        :ok = :erlang.apply(Circuits.GPIO, :write, [gpio, 0])
        :timer.sleep(400)
        :ok = :erlang.apply(Circuits.GPIO, :write, [gpio, 1])
        :timer.sleep(400)
        :ok = :erlang.apply(Circuits.GPIO, :write, [gpio, 0])
        :ok = :erlang.apply(Circuits.GPIO, :close, [gpio])
    end

    {:noreply, state}
  end
end
