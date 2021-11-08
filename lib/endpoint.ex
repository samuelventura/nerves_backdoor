defmodule NervesBackdoor.Endpoint do
  use Plug.Router

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  get "/" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(%{hello: "world"}))
  end

  plug(:dispatch)

  match _ do
    send_resp(conn, 404, Poison.encode!(%{not: "found"}))
  end
end
