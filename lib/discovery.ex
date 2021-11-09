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
    IO.inspect({"init", port})
    {:ok, socket} = :gen_udp.open(port, active: true, mode: :binary)
    IO.inspect({"state", {socket, port}})
    {:ok, {socket, port}}
  end

  @impl true
  def terminate(reason, state = {socket, _port}) do
    IO.inspect({"terminate", reason, state})
    :ok = :gen_udp.close(socket)
  end

  @impl true
  def handle_info({:udp, socket, ip, port, message}, state) do
    IO.inspect({state, ip, port, message})

    case message do
      "id" ->
        name = Application.get_env(:nerves_backdoor, :name)
        version = Application.get_env(:nerves_backdoor, :version)
        :gen_udp.send(socket, ip, port, "#{name}:#{version}")
    end

    {:noreply, state}
  end
end
