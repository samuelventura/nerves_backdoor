defmodule NervesBackdoor.Client do

  #needs a flush() aftewards
  def id(dest \\ :localhost, to \\ 1000) do
    name = NervesBackdoor.Environ.name()
    cmd = Jason.encode! %{action: "id", name: name}
    discovery(cmd, dest, to)
  end

  def blink(dest \\ :localhost, to \\ 1000) do
    name = NervesBackdoor.Environ.name()
    cmd = Jason.encode! %{action: "blink", name: name}
    discovery(cmd, dest, to)
  end

  def discovery(cmd, dest \\ :localhost, to \\ 1000) do
    port = NervesBackdoor.Environ.port()
    {:ok, socket} = :gen_udp.open(0, active: false, broadcast: true)
    tip = case dest do
      :broadcast -> {255,255,255,255}
      :localhost -> {127,0,0,1}
      ip -> ip
    end
    :ok = :gen_udp.send(socket, tip, port, cmd)
    recv(socket, to)
    :ok = :gen_udp.close(socket)
  end

  def recv(socket, to \\ 1000) do
    case :gen_udp.recv(socket, 1024, to) do
      {:ok, {address, port, packet}} ->
        IO.inspect {address, port, Jason.decode! packet}
        recv(socket)
      {:error, message} ->
        IO.inspect message
    end
  end
end
