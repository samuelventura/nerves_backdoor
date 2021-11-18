defmodule NervesBackdoorTest do
  use ExUnit.Case
  use Plug.Test

  alias NervesBackdoor.Endpoint, as: EP
  @opts EP.init([])

  test "ping pong" do
    conn = conn(:get, "/ping")
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
    conn = EP.call(conn, @opts)
    assert conn.state == :sent
    assert conn.status == 200
    assert Jason.decode!(conn.resp_body) == %{"message" => 11, "result" => "ok"}
    assert "upload-test" == File.read!("/tmp/upload2.txt")
  end

  test "download from /tmp" do
    File.write!("/tmp/download1.txt", "download-test")
    conn = conn(:get, "/tmp/download1.txt")
    conn = EP.call(conn, @opts)
    assert conn.state == :file
    assert conn.status == 200
    assert conn.resp_body == "download-test"
  end

  test "delete from /tmp" do
    File.write!("/tmp/delete1.txt", "delete-test")
    conn = conn(:delete, "/delete?path=/tmp/delete1.txt")
    conn = EP.call(conn, @opts)
    assert conn.state == :sent
    assert conn.status == 200
    assert false == File.exists?("/tmp/delete1.txt")
  end

  test "start app" do
    Application.stop(:public_key)
    conn = conn(:post, "/app/start/public_key")
    conn = EP.call(conn, @opts)
    assert conn.state == :sent
    assert conn.status == 200
    assert Jason.decode!(conn.resp_body) == %{"result" => "ok"}
  end

  test "stop app" do
    conn = conn(:post, "/app/stop/public_key")
    conn = EP.call(conn, @opts)
    assert conn.state == :sent
    assert conn.status == 200
    assert Jason.decode!(conn.resp_body) == %{"result" => "ok"}
    :ok = Application.start(:public_key)
  end

  test "net all" do
    conn = conn(:get, "/net/all")
    conn = EP.call(conn, @opts)
    assert conn.state == :sent
    assert conn.status == 200

    assert Jason.decode!(conn.resp_body) == %{
             "result" => "ok",
             "message" => ["eth0", "usb0", "lo"]
           }
  end
end
