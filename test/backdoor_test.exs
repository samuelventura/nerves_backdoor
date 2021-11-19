defmodule NervesBackdoorTest do
  use ExUnit.Case
  use Plug.Test

  alias NervesBackdoor.Endpoint, as: EP
  @opts EP.init([])

  test "ping pong" do
    conn = conn(:get, "/ping")
    conn = basic_auth(conn)
    conn = EP.call(conn, @opts)
    assert conn.state == :sent
    assert conn.status == 200
    assert Jason.decode!(conn.resp_body) == %{"message" => %{"ping" => "pong"}, "result" => "ok"}
  end

  test "upload to /tmp" do
    File.rm("/tmp/upload2.txt")
    File.write!("/tmp/upload1.txt", "upload-test")
    upload = %Plug.Upload{path: "/tmp/upload1.txt", filename: "upload1.txt"}
    conn = conn(:post, "/upload?path=/tmp/upload2.txt", %{:file => upload})
    conn = basic_auth(conn)
    conn = EP.call(conn, @opts)
    assert conn.state == :sent
    assert conn.status == 200
    assert Jason.decode!(conn.resp_body) == %{"message" => 11, "result" => "ok"}
    assert "upload-test" == File.read!("/tmp/upload2.txt")
  end

  test "download from /tmp" do
    File.write!("/tmp/download1.txt", "download-test")
    conn = conn(:get, "/tmp/download1.txt")
    conn = basic_auth(conn)
    conn = EP.call(conn, @opts)
    assert conn.state == :file
    assert conn.status == 200
    assert conn.resp_body == "download-test"
  end

  test "delete from /tmp" do
    File.write!("/tmp/delete1.txt", "delete-test")
    conn = conn(:delete, "/delete?path=/tmp/delete1.txt")
    conn = basic_auth(conn)
    conn = EP.call(conn, @opts)
    assert conn.state == :sent
    assert conn.status == 200
    assert false == File.exists?("/tmp/delete1.txt")
  end

  test "start app" do
    Application.stop(:public_key)
    conn = conn(:post, "/app/start/public_key")
    conn = basic_auth(conn)
    conn = EP.call(conn, @opts)
    assert conn.state == :sent
    assert conn.status == 200
    assert Jason.decode!(conn.resp_body) == %{"result" => "ok"}
  end

  test "stop app" do
    conn = conn(:post, "/app/stop/public_key")
    conn = basic_auth(conn)
    conn = EP.call(conn, @opts)
    assert conn.state == :sent
    assert conn.status == 200
    assert Jason.decode!(conn.resp_body) == %{"result" => "ok"}
    :ok = Application.start(:public_key)
  end

  test "net all" do
    conn = conn(:get, "/net/all")
    conn = basic_auth(conn)
    conn = EP.call(conn, @opts)
    assert conn.state == :sent
    assert conn.status == 200
    assert Jason.decode!(conn.resp_body) == %{
             "result" => "ok",
             "message" => ["eth0", "usb0", "lo"]
           }
  end

  test "net config eth0" do
    conn = conn(:post, "/net/setup/eth0", %{method: "dhcp"})
    conn = basic_auth(conn)
    conn = EP.call(conn, @opts)
    assert conn.state == :sent
    assert conn.status == 200
    assert Jason.decode!(conn.resp_body) == %{"result" => "ok"}

    conn = conn(:get, "/net/state/eth0")
    conn = basic_auth(conn)
    conn = EP.call(conn, @opts)
    assert conn.state == :sent
    assert conn.status == 200
    assert Jason.decode!(conn.resp_body) == %{"message" =>
      %{"config" => %{"method" => "dhcp"}, "connection" => "disconnected",
      "interface" => "eth0", "state" => "configured"}, "result" => "ok"}

    conn = conn(:post, "/net/setup/eth0", %{method: "static", address: "10.77.4.100",
      prefix_length: 8, gateway: "10.77.0.1", name_servers: ["10.77.0.1"]})
      conn = basic_auth(conn)
      conn = EP.call(conn, @opts)
    assert conn.state == :sent
    assert conn.status == 200
    assert Jason.decode!(conn.resp_body) == %{"result" => "ok"}

    conn = conn(:get, "/net/state/eth0")
    conn = basic_auth(conn)
    conn = EP.call(conn, @opts)
    assert conn.state == :sent
    assert conn.status == 200
    assert Jason.decode!(conn.resp_body) == %{"message" =>
      %{"config" => %{"method" => "static", "address" => "10.77.4.100", "gateway" => "10.77.0.1",
      "name_servers" => ["10.77.0.1"], "prefix_length" => 8}, "connection" => "disconnected",
      "interface" => "eth0", "state" => "configured"}, "result" => "ok"}
  end

  test "discovery id" do
    name = NervesBackdoor.name()
    cmd = Jason.encode! %{action: "id", name: name}
    port = NervesBackdoor.port()
    {:ok, socket} = :gen_udp.open(0, active: false, broadcast: true)
    :ok = :gen_udp.send(socket, {127,0,0,1}, port, cmd)
    msg = :gen_udp.recv(socket, 1024, 1000)
    {:ok, {{127,0,0,1}, ^port, packet}} = msg
    assert Jason.decode!(packet) ==  %{"name" => "nerves", "action" => "id", "data" =>
    %{"hostname" => "test", "ifname" => "ethx", "macaddr" => "000000000000",
    "name" => "nerves", "version" => "0.1.1"}}
  end

  test "discovery blink" do
    name = NervesBackdoor.name()
    cmd = Jason.encode! %{action: "blink", name: name}
    port = NervesBackdoor.port()
    {:ok, socket} = :gen_udp.open(0, active: false, broadcast: true)
    :ok = :gen_udp.send(socket, {127,0,0,1}, port, cmd)
    msg = :gen_udp.recv(socket, 1024, 1000)
    {:ok, {{127,0,0,1}, ^port, packet}} = msg
    assert Jason.decode!(packet) ==  %{"action" => "blink", "name" => "nerves"}
  end

  test "http basic auth" do
    conn = conn(:get, "/ping")
    conn = EP.call(conn, @opts)
    assert conn.state == :set
    assert conn.status == 401

    #disable password check
    File.mkdir_p("/tmp/backdoor")
    File.write!("/tmp/backdoor/password.txt", "")
    conn = conn(:get, "/ping")
    conn = EP.call(conn, @opts)
    assert conn.state == :sent
    assert conn.status == 200

    #reenable password check
    password = "otherpass"
    File.write!("/tmp/backdoor/password.txt", password)
    conn = conn(:get, "/ping")
    conn = EP.call(conn, @opts)
    assert conn.state == :set
    assert conn.status == 401

    assert NervesBackdoor.password(:current) == password
    username = NervesBackdoor.name()
    auth = "Basic " <> Base.encode64(username <> ":" <> password)
    conn = conn(:get, "/ping")
      |> put_req_header("authorization", auth)
    conn = EP.call(conn, @opts)
    assert conn.state == :sent
    assert conn.status == 200
    File.rm("/tmp/backdoor/password.txt")
  end

  def basic_auth(conn) do
    value = "Basic " <> Base.encode64("nerves:000000000000")
    put_req_header(conn, "authorization", value)
  end
end
