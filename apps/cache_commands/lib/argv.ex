defmodule ARGV do
  def to_string(argv) do
    argv
    |> Enum.map(&escape_arg/1)
    |> Enum.join(" ")
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
    Regex.match?(~r/[^\w\s"'\-]/i, arg)
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
