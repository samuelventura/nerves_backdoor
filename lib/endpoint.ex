defmodule NervesBackdoor.Endpoint do
  use Plug.Router

  plug(:match)

  #curl http://localhost:31680/tmp/test.txt
  plug Plug.Static, at: "/tmp", from: "/tmp"
  #curl http://localhost:31680/data/test.txt
  #curl http://nerves.local:31680/data/lvnbe.db3 --output /tmp/lvnbe.db3
  plug Plug.Static, at: "/data", from: "/data"

  plug Plug.Parsers, parsers: [:urlencoded, :multipart], pass: ["*/*"]
  plug Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder: Jason

  #curl http://localhost:31680/ping
  #curl http://nerves.local:31680/ping
  get "/ping" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(%{ping: "pong"}))
  end

  #curl -F 'data=@/tmp/test.txt' http://localhost:31680/upload?path=/tmp/testup.txt
  post "/upload" do
    {:ok, upload} = Map.fetch conn.params, "data"
    {:ok, path} = Map.fetch conn.query_params, "path"
    result = File.copy upload.path, path
    File.rm upload.path
    respond(conn, result)
  end

  #curl http://localhost:31680/net/state/eth0
  #curl http://nerves.local:31680/net/state/eth0
  get "/net/state/:interface" do
    {:ok, interface} = Map.fetch conn.path_params, "interface"
    result = NervesBackdoor.net_state interface
    respond(conn, result)
  end

  #curl http://localhost:31680/net/setup/eth0 -H "Content-Type: application/json" -X POST -d '{"method":"dhcp"}'
  #curl http://nerves.local:31680/net/setup/eth0 -H "Content-Type: application/json" -X POST -d '{"method":"dhcp"}'
  post "/net/setup/:interface" do
    {:ok, interface} = Map.fetch conn.path_params, "interface"
    result = NervesBackdoor.net_setup interface, conn.body_params
    respond(conn, result)
  end

  #curl http://localhost:31680/app/start/nss
  get "/app/start/:app" do
    {:ok, app} = Map.fetch conn.path_params, "app"
    result = case app_loaded(app) do
      nil -> {:error, "App not found #{app}"}
      {appa, _desc} -> Application.start appa, :permanent
    end
    respond(conn, result)
  end

  #curl http://localhost:31680/app/stop/nss
  get "/app/stop/:app" do
    {:ok, app} = Map.fetch conn.path_params, "app"
    result = case app_loaded(app) do
      nil -> {:error, "App not found #{app}"}
      {appa, _desc, _ver} -> Application.stop appa
    end
    respond(conn, result)
  end

  defp app_loaded(app) do
    Enum.find Application.loaded_applications, fn tuple ->
      {atom, _desc, _ver} = tuple
      Atom.to_string(atom) == app
    end
  end

  defp respond(conn, result) do
    case result do
      :ok -> send_resp(conn, 200, Jason.encode!(%{result: "ok"}))
      {:ok, message} -> send_resp(conn, 200, Jason.encode!(%{result: "ok", message: message}))
      {:error, message} -> send_resp(conn, 500, Jason.encode!(%{result: "error", message: message}))
      end
  end

  plug(:dispatch)

  match _ do
    send_resp(conn, 404, Jason.encode!(%{result: "error", message: "not found"}))
  end
end
