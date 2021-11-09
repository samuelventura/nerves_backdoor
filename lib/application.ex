defmodule NervesBackdoor.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {NervesBackdoor.Discovery, Application.get_env(:nerves_backdoor, :port)},
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: NervesBackdoor.Endpoint,
        options: [port: Application.get_env(:nerves_backdoor, :port)]
      )
    ]

    opts = [strategy: :one_for_one, name: NervesBackdoor.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
