defmodule NervesBackdoor.Environ do
  def name() do
    Application.get_env(:nerves_backdoor, :name)
  end

  def hostname() do
    Application.get_env(:nerves_backdoor, :hostname, gethostname())
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

  def blink_ms() do
    Application.get_env(:nerves_backdoor, :blink_ms)
  end

  def folder() do
    data = case File.mkdir_p("/data/backdoor") do
      :ok ->
        "/data"

      _ ->
        File.mkdir_p!("/tmp/data/backdoor")
        "/tmp/data"
    end
    Path.join(data, "backdoor")
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
      :default -> mac()

      :current ->
        path = Path.join(folder(), "password.txt")

        case File.read(path) do
          {:ok, data} -> String.trim(data)
          _ -> mac()
        end
    end
  end

  def gethostname() do
    {:ok, hostname} = :inet.gethostname()
    hostname |> to_string
  end

  def ask_pwd?() do
    io = io_sw()
    {:ok, gpio} = NervesBackdoor.GPIO.input(io)
    state = NervesBackdoor.GPIO.read(gpio)
    :ok = NervesBackdoor.GPIO.close(gpio)
    state == 1
  end

  def ask_pwd(value) do
    io = io_sw()
    {:ok, gpio} = NervesBackdoor.GPIO.input(io)
    :ok = NervesBackdoor.GPIO.write(gpio, value)
    :ok = NervesBackdoor.GPIO.close(gpio)
  end

  def blink() do
    io = NervesBackdoor.Environ.io_led()
    ms = NervesBackdoor.Environ.blink_ms()
    {:ok, gpio} = NervesBackdoor.GPIO.output(io)
    :ok = NervesBackdoor.GPIO.write(gpio, 1)
    :timer.sleep(ms)
    :ok = NervesBackdoor.GPIO.write(gpio, 0)
    :timer.sleep(ms)
    :ok = NervesBackdoor.GPIO.write(gpio, 1)
    :timer.sleep(ms)
    :ok = NervesBackdoor.GPIO.write(gpio, 0)
    :timer.sleep(ms)
    :ok = NervesBackdoor.GPIO.write(gpio, 1)
    :timer.sleep(ms)
    :ok = NervesBackdoor.GPIO.write(gpio, 0)
    :ok = NervesBackdoor.GPIO.close(gpio)
  end
end
