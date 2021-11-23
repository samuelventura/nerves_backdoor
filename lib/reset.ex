defmodule NervesBackdoor.Reset do
  use GenServer

  def start_link(_opts \\ []) do
    init_args = []
    GenServer.start_link(__MODULE__, init_args, name: :nbd_reset)
  end

  @impl true
  def init(_args) do
    io = NervesBackdoor.env_iobtn()
    {:ok, gpio} = NervesBackdoor.Gpio.io_input(io)
    :ok = NervesBackdoor.Gpio.io_rising(gpio)
    {:ok, gpio}
  end

  @impl true
  def terminate(_reason, gpio) do
    :ok = NervesBackdoor.Gpio.io_close(gpio)
  end

  @impl true
  def handle_info({:circuits_gpio, _, _, _}, gpio) do
    NervesBackdoor.reset_pass()
    {:noreply, gpio}
  end
end
