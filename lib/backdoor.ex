defmodule NervesBackdoor do
  def home() do
    Application.get_env(:nerves_backdoor, :home)
  end

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

  def io_btn() do
    Application.get_env(:nerves_backdoor, :io_btn)
  end

  def blink_ms() do
    Application.get_env(:nerves_backdoor, :blink_ms)
  end

  def mac() do
    case MACAddress.mac_address(ifname()) do
      {:ok, mac} -> mac |> MACAddress.to_hex(case: :upper)
      _ -> "00:00:00:00:00:00"
    end
    |> String.replace(":", "")
  end

  def password(type \\ :current) do
    case type do
      :default -> mac()

      :current ->
        path = passpath()

        case File.read(path) do
          {:ok, data} -> String.trim(data)
          _ -> mac()
        end
    end
  end

  def passreset() do
    File.mkdir_p(home())
    File.rm(passpath())
  end

  def passset(password) do
    File.write(passpath(), password)
  end

  def passpath() do
    Path.join(home(), "password.txt")
  end

  def gethostname() do
    {:ok, hostname} = :inet.gethostname()
    hostname |> to_string
  end

  def blink() do
    io = NervesBackdoor.io_led()
    ms = NervesBackdoor.blink_ms()
    {:ok, gpio} = NervesBackdoor.Gpio.output(io)
    :ok = NervesBackdoor.Gpio.write(gpio, 1)
    :timer.sleep(ms)
    :ok = NervesBackdoor.Gpio.write(gpio, 0)
    :timer.sleep(ms)
    :ok = NervesBackdoor.Gpio.write(gpio, 1)
    :timer.sleep(ms)
    :ok = NervesBackdoor.Gpio.write(gpio, 0)
    :timer.sleep(ms)
    :ok = NervesBackdoor.Gpio.write(gpio, 1)
    :timer.sleep(ms)
    :ok = NervesBackdoor.Gpio.write(gpio, 0)
    :ok = NervesBackdoor.Gpio.close(gpio)
  end
end
