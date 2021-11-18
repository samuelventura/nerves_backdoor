defmodule NervesBackdoor.GPIO do
  def output(port) do
    :erlang.apply(Circuits.GPIO, :open, [port, :output])
  end

  def input(port) do
    :erlang.apply(Circuits.GPIO, :open, [port, :input])
  end

  def write(gpio, value) do
    :erlang.apply(Circuits.GPIO, :write, [gpio, value])
  end

  def read(gpio) do
    :erlang.apply(Circuits.GPIO, :read, [gpio])
  end

  def close(gpio) do
    :erlang.apply(Circuits.GPIO, :close, [gpio])
  end
end
