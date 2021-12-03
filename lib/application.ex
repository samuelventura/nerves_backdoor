defmodule NervesBackdoor.Application do
  use Application

  @impl true
  def start(_type, _args) do
    port = NervesBackdoor.env_port()
    home = NervesBackdoor.env_home()
    File.mkdir_p(home)
    off(NervesBackdoor.env_red())
    off(NervesBackdoor.env_green())
    off(NervesBackdoor.env_blue())

    children = [
      {NervesBackdoor.Reset, []},
      {NervesBackdoor.Gpio, []},
      {NervesBackdoor.Vintage, []},
      {NervesBackdoor.Discovery, []},
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: NervesBackdoor.Endpoint,
        options: [port: port]
      )
    ]

    opts = [strategy: :one_for_one, name: NervesBackdoor.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp off(port) do
    {:ok, gpio} = NervesBackdoor.Gpio.io_output(port)
    :ok = NervesBackdoor.Gpio.io_write(gpio, 0)
    :ok = NervesBackdoor.Gpio.io_close(gpio)
  end
end
