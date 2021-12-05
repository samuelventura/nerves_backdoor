defmodule NervesBackdoor.Reset do
  use GenServer

  def start_link(_opts \\ []) do
    init_args = []
    GenServer.start_link(__MODULE__, init_args, name: :nbd_reset)
  end

  @impl true
  def init(_args) do
    io = NervesBackdoor.env_push()
    {:ok, gpio} = NervesBackdoor.Gpio.io_input(io)
    :ok = NervesBackdoor.Gpio.io_both(gpio)
    {:ok, %{gpio: gpio}}
  end

  @impl true
  def terminate(_reason, %{gpio: gpio}) do
    :ok = NervesBackdoor.Gpio.io_close(gpio)
  end

  @impl true
  def handle_info({:circuits_gpio, io, _, value}, state) do
    IO.inspect({"Edge", io, value})

    state =
      case value do
        1 ->
          ms = NervesBackdoor.env_reset_ms()
          {:ok, timer} = :timer.send_after(ms, :reset_timer)
          IO.inspect({"Reset timer setup", ms})
          Map.put(state, :timer, timer)

        0 ->
          {timer, state} = Map.pop(state, :timer)
          cancel_timer(timer)
          state
      end

    {:noreply, state}
  end

  @impl true
  def handle_info(:reset_timer, state) do
    color = NervesBackdoor.env_reset_color()
    IO.inspect("Password reset")
    NervesBackdoor.reset_pass()
    NervesBackdoor.io_blink(color)
    {timer, state} = Map.pop(state, :timer)
    cancel_timer(timer)
    {:noreply, state}
  end

  defp cancel_timer(nil), do: nil

  defp cancel_timer(timer) do
    result = :timer.cancel(timer)
    IO.inspect({"Reset timer cancel", result})
  end
end
