defmodule NervesBackdoor.Environ do
  def name() do
    Application.get_env(:nerves_backdoor, :name)
  end

  def version() do
    Application.get_env(:nerves_backdoor, :version)
  end

  def port() do
    Application.get_env(:nerves_backdoor, :port)
  end

  def ifname() do
    Application.get_env(:nerves_backdoor, :ifname)
  end

  def io_led() do
    Application.get_env(:nerves_backdoor, :io_led)
  end

  def io_sw() do
    Application.get_env(:nerves_backdoor, :io_sw)
  end

  def folder() do
    Path.join(data(), "backdoor")
  end

  def data() do
    case File.mkdir_p("/data/backdoor") do
      :ok ->
        "/data"

      _ ->
        File.mkdir_p!("/tmp/data/backdoor")
        "/tmp/data"
    end
  end

  def mac() do
    case MACAddress.mac_address(ifname()) do
      {:ok, mac} -> mac |> MACAddress.to_hex(case: :upper)
      _ -> "00:00:00:00:00:00"
    end
    |> String.replace(":", "")
  end

  def password(type) do
    case type do
      :default ->
        mac() |> String.replace(":", "")

      :current ->
        path = Path.join(folder(), "password.txt")

        case File.read(path) do
          {:ok, data} -> String.trim(data)
          _ -> password(:default)
        end
    end
  end

  def hostname() do
    {:ok, hostname} = :inet.gethostname()
    hostname |> to_string
  end

  def safe?() do
    io = io_sw()
    {:ok, gpio} = :erlang.apply(Circuits.GPIO, :open, [io, :input])
    state = :erlang.apply(Circuits.GPIO, :read, [gpio])
    :ok = :erlang.apply(Circuits.GPIO, :close, [gpio])
    state == 1
  end

  def blink() do
    io = NervesBackdoor.Environ.io_led()
    {:ok, gpio} = :erlang.apply(Circuits.GPIO, :open, [io, :output])
    :ok = :erlang.apply(Circuits.GPIO, :write, [gpio, 1])
    :timer.sleep(200)
    :ok = :erlang.apply(Circuits.GPIO, :write, [gpio, 0])
    :timer.sleep(200)
    :ok = :erlang.apply(Circuits.GPIO, :write, [gpio, 1])
    :timer.sleep(200)
    :ok = :erlang.apply(Circuits.GPIO, :write, [gpio, 0])
    :timer.sleep(200)
    :ok = :erlang.apply(Circuits.GPIO, :write, [gpio, 1])
    :timer.sleep(200)
    :ok = :erlang.apply(Circuits.GPIO, :write, [gpio, 0])
    :ok = :erlang.apply(Circuits.GPIO, :close, [gpio])
  end
end