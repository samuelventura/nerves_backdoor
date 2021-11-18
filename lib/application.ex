defmodule NervesBackdoor.Application do
  use Application

  @impl true
  def start(_type, _args) do
    # create folder
    NervesBackdoor.Environ.port()
    port = NervesBackdoor.Environ.port()

    children = [
      {NervesBackdoor.GPIO, []},
      {NervesBackdoor.Vintage, []},
      {NervesBackdoor.Discovery, port},
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: NervesBackdoor.Endpoint,
        options: [port: port]
      )
    ]

    opts = [strategy: :one_for_one, name: NervesBackdoor.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
