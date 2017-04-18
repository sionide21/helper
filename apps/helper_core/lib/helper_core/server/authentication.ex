defmodule HelperCore.Server.Authentication do
  use GenServer

  def start_link(name: name) do
    GenServer.start_link(__MODULE__, [], name: name)
  end

  def init([]) do
    {:ok, rotate_code()}
  end

  def verify(code, opts \\ []) do
    pid = Keyword.get(opts, :pid, __MODULE__)
    GenServer.call(pid, {:verify, code})
  end

  def handle_call({:verify, code}, _from, code) do
    {:reply, :ok, rotate_code()}
  end
  def handle_call({:verify, _code}, _from, code) do
    {:reply, {:error, "invalid auth code"}, code}
  end

  defp rotate_code() do
    code = generate_code()
    write_code(code)
    code
  end

  defp generate_code() do
    :crypto.strong_rand_bytes(32)
    |> Base.encode64
  end

  defp write_code(code) do
    {:ok, auth_file} = HelperCore.Config.file("auth")
    :ok = File.write(auth_file, [code, "\n"])
    :ok = File.chmod(auth_file, 0o600)
  end
end
