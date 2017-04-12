defmodule HelperCore.Context do
  require Logger
  @type t :: %__MODULE__{
            name: String.t,
            args: [String.t],
            socket: :socket,
            assigns: Map.t}

  defstruct name: nil,
            socket: nil,
            args: [],
            assigns: %{}

  def new(command, socket) do
    context = %__MODULE__{socket: socket}
    {name, args} = parse_line(command, context)
    %__MODULE__{context | name: name, args: OptionParser.split(args)}
  end

  def read_value(ctx) do
    ctx
    |> read_line
    |> parse_line(ctx)
  end

  def execute(ctx, cmd, args) when is_list(args) do
    execute(ctx, cmd, Enum.join(args, " "))
  end
  def execute(ctx, cmd, args) when cmd in [:query, :exit] do
    send_client(ctx, "#{cmd} #{args}\n")
  end
  def execute(ctx, :quit, args) do
    # Alias quit to exit because exit is an Elixir.Kernel method
    # and I don't want to override it for a helper method.
    execute(ctx, :exit, args)
  end
  def execute(ctx, cmd, raw_message) when cmd in [:echo, :error, :print] do
    send_client(ctx, "#{cmd} #{byte_size(raw_message)}\n")
    send_client(ctx, raw_message)
  end

  def echo(ctx, value) do
    execute(ctx, :echo, value)
  end

  def error(ctx, value) do
    execute(ctx, :error, value)
  end

  def die(ctx, message, status \\ 1) do
    ctx
    |> error(message)
    |> quit(status)
  end

  def quit(ctx, status \\ 0) do
    execute(ctx, :exit, to_string(status))
  end

  def parse_head(ctx, opts) do
    OptionParser.parse_head(ctx.args, opts)
  end

  def print(ctx, value) do
    execute(ctx, :print, value)
  end

  def query(ctx, cmd) do
    execute(ctx, :query, cmd)
    {"status", status} = read_value(ctx)
    {"result", result} = read_value(ctx)

    case String.to_integer(status) do
      0 -> {:ok, result}
      e -> {:error, e}
    end
  end

  defp send_client(ctx=%__MODULE__{socket: socket}, value) do
    Logger.debug(inspect({:send_client, value}))
    :gen_tcp.send(socket, value)
    ctx
  end

  defp read_line(%__MODULE__{socket: socket}) do
    {:ok, line} = :gen_tcp.recv(socket, 0)
    line
  end

  defp parse_line(line, context) do
    Logger.debug(inspect({:parse_line, line}))
    line
    |> String.trim
    |> String.split(" ")
    |> case do
      ["raw", name, length] ->
        {name, read_raw(context, String.to_integer(length))}
      [name | rest] ->
        {name, Enum.join(rest, " ")}
    end
  end

  defp read_raw(_, 0), do: ""
  defp read_raw(%__MODULE__{socket: socket}, length) do
    :inet.setopts(socket, packet: :raw)
    {:ok, result} = :gen_tcp.recv(socket, length)
    :inet.setopts(socket, packet: :line)
    result
  end

  defimpl String.Chars, for: __MODULE__ do
    def to_string(%{args: []}=context), do: context.name
    def to_string(context), do: "#{context.name} #{Enum.join(context.args, " ")}"
  end
end
