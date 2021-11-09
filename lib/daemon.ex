defmodule NervesBackdoor.Daemon do
  use GenServer

  @spawn_opts [:stderr_to_stdout, :binary, :stream, {:line, 255}]

  # {:ok, pid} = NervesBackdoor.Daemon.start_link "/bin/daemon"
  # :ok = GenServer.stop pid
  def start_link(path) do
    GenServer.start_link(__MODULE__, path)
  end

  @impl true
  def init(path) do
    IO.inspect({"init", path})
    port = run(path)
    IO.inspect({"state", {path, port}})
    {:ok, {path, port}}
  end

  @impl true
  def terminate(reason, state = {_path, port}) do
    IO.inspect({"terminate", reason, state})
    true = Port.close(port)
  end

  @impl true
  def handle_info({_port, {:data, data}}, state) do
    IO.inspect({state, data})
    {:noreply, state}
  end

  @impl true
  def handle_info({:DOWN, _ref, :port, port, reason}, state = {path, _}) do
    IO.inspect({state, "down", port, reason})
    port = run(path)
    IO.inspect({"state", {path, port}})
    {:noreply, {path, port}}
  end

  defp run(path) do
    env = {:env, env(path)}
    opts = [env | @spawn_opts]
    IO.inspect({"run", path, env})
    port = Port.open({:spawn_executable, path}, opts)
    _ref = Port.monitor(port)
    port
  end

  defp env(path) do
    case File.read(path <> ".env") do
      {:ok, data} ->
        data
        |> String.split("\n")
        |> Enum.filter(&filter/1)
        |> Enum.map(&tuple/1)

      _ ->
        []
    end
  end

  defp filter(line) do
    String.contains?(line, "=")
  end

  defp tuple(line) do
    trimmed = String.trim(line)
    [n, v] = String.split(trimmed, "=", parts: 2)
    {String.to_charlist(n), String.to_charlist(v)}
  end
end
