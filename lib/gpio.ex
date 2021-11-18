defmodule NervesBackdoor.GPIO do
  use GenServer

  def start_link(_opts \\ []) do
    init_args = []
    GenServer.start_link(__MODULE__, init_args, name: :nbd_gpio)
  end

  def stop() do
    GenServer.stop(:nbd_gpio)
  end

  def output(port) do
    GenServer.call(:nbd_gpio, {:output, port})
  end

  def input(port) do
    GenServer.call(:nbd_gpio, {:input, port})
  end

  def write(gpio, value) do
    GenServer.call(:nbd_gpio, {:write, gpio, value})
  end

  def read(gpio) do
    GenServer.call(:nbd_gpio, {:read, gpio})
  end

  def close(gpio) do
    GenServer.call(:nbd_gpio, {:close, gpio})
  end

  @impl true
  def init(_args) do
    {:ok, %{}}
  end

  @impl true
  def handle_call(req, _from, state) do
    res =
      case req do
        {:output, port} -> io_output(port)
        {:input, port} -> io_input(port)
        {:write, gpio, value} -> io_write(gpio, value)
        {:read, gpio} -> io_read(gpio)
        {:close, gpio} -> io_close(gpio)
      end

    {:reply, res, state}
  end

  def io_output(port) do
    :erlang.apply(Circuits.GPIO, :open, [port, :output])
  end

  def io_input(port) do
    :erlang.apply(Circuits.GPIO, :open, [port, :input])
  end

  def io_write(gpio, value) do
    :erlang.apply(Circuits.GPIO, :write, [gpio, value])
  end

  def io_read(gpio) do
    :erlang.apply(Circuits.GPIO, :read, [gpio])
  end

  def io_rising(gpio) do
    :erlang.apply(Circuits.GPIO, :set_interrupts, [gpio, :rising])
  end

  def io_close(gpio) do
    :erlang.apply(Circuits.GPIO, :close, [gpio])
  end
end
