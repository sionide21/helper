defmodule HelperCore.Config do
  @doc """
  The path to the config file `file`.

  If the file doesn't exist, it will not be created, but the directory
  will be such that you can immediately open the file for writing.

  See `dir` for possible error conditions.
  """
  @spec file(binary) :: {:ok, Path.t} | {:error, :file.posix()}
  def file(file) do
    dir()
    |> try_join(file)
  end

  @doc """
  The system wide configuration path for H.E.L.P.eR.

  Defaults to `~/.helper`

  If the directory is missing, it will be created.

  If the directory cannot be created, the posix error will be returned.
  """
  @spec dir :: {:ok, Path.t} | {:error, :file.posix()}
  def dir do
    Path.expand("~/.helper")
    |> ensure_directory()
  end

  defp try_join({:ok, base}, path), do: {:ok, Path.join(base, path)}
  defp try_join(e, _), do: e

  defp ensure_directory(dir) do
    dir
    |> File.mkdir()
    |> case do
      :ok -> {:ok, dir}
      {:error, :eexist} -> {:ok, dir}
      e -> e
    end
  end
end
