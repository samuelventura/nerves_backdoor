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
    assert conn.resp_body == "world"
  end
end
