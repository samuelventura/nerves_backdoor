defmodule NervesBackdoor.Reset do
  use GenServer

  def start_link(_opts \\ []) do
    init_args = []
    GenServer.start_link(__MODULE__, init_args, name: :nbd_gpio)
  end

  @impl true
  def init(_args) do
    io = NervesBackdoor.Environ.io_btn()
    {:ok, gpio} = NervesBackdoor.GPIO.io_input(io)
    :ok = NervesBackdoor.GPIO.io_rising(gpio)
    {:ok, gpio}
  end

  @impl true
  def terminate(_reason, gpio) do
    :ok = NervesBackdoor.GPIO.io_input(gpio)
  end

  @impl true
  def handle_info({:circuits_gpio, _, _, _}, gpio) do
    NervesBackdoor.Environ.passreset()
    {:noreply, gpio}
  end
end
