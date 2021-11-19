#mix run discover.exs --no-start

cmd = Jason.encode! %{action: "id", name: "nerves"}
{:ok, socket} = :gen_udp.open(0, active: false, broadcast: true, multicast_ttl: 4, multicast_loop: false)
:ok = :gen_udp.send(socket, {255, 255, 255, 255}, 31680, cmd)
msg = :gen_udp.recv(socket, 1024, 1000)
:ok = :gen_udp.close(socket)

IO.inspect(msg)
