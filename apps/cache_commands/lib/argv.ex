defmodule ARGV do
  @doc """
  Convert an args list back into the original command for nicer display.

  *note* This is intended to make display nice, not to sanitize commands for
         execution. It may not always properly escape inputs.

  ## Examples

      iex> ARGV.to_string(["ls", "-lh", "/usr/local"])
      "ls -lh /usr/local"

      iex> ARGV.to_string(["echo", "Hello World"])
      ~s{echo "Hello World"}

      iex> ARGV.to_string(["sh", "-c", ~s{cd /tmp && ls "*.txt"}])
      ~s{sh -c 'cd /tmp && ls "*.txt"'}

  """
  def to_string(argv) do
    argv
    |> Enum.map(&escape_arg/1)
    |> Enum.join(" ")
  end

  @doc """
  Produce a 6 character name that can be used to refer to this list of arguments.

  The same ARGV will always produce the same name, so there is no need to store them.

  These names are fairly unique for small numbers of commands, but collision are
  possible and must be handled in your own code.

  ## Examples

      iex> ARGV.to_identifier(["ls", "-lh", "/usr/local"])
      "SXHE7A"

      iex> ARGV.to_identifier(["echo", "Hello", "World"])
      "G6M52I"

  """
  def to_identifier(argv) do
    :erlang.phash2(argv)
    |> (fn b -> <<b::27, 0::5>> end).()
    |> Base.encode32(padding: false)
    |> String.slice(0, 6)
  end

  defp escape_arg("") do
    ~S{""}
  end
  defp escape_arg(arg) do
    cond do
      has_special_chars?(arg) -> single_quote(arg)
      has_whitespace?(arg)    -> double_quote(arg)
      has_single_quote?(arg)  -> double_quote(arg)
      has_double_quote?(arg)  -> escape(arg, "\"")
      true -> arg
    end
  end

  defp single_quote(arg) do
    arg
    |> String.replace("'", "'\\''")
    |> wrap("'")
  end

  defp double_quote(arg) do
    arg
    |> escape("\"")
    |> wrap("\"")
  end

  defp escape(string, char) do
    String.replace(string, char, "\\#{char}")
  end

  defp wrap(s, char) do
    Enum.join([char, char], s)
  end

  defp has_special_chars?(arg) do
    Regex.match?(~r/[^\w\s"'\-\/]/i, arg)
  end

  defp has_whitespace?(arg) do
    Regex.match?(~r/\s/, arg)
  end

  defp has_double_quote?(arg) do
    Regex.match?(~r/"/, arg)
  end

  defp has_single_quote?(arg) do
    Regex.match?(~r/'/, arg)
  end
end
