defmodule HelperCore.CommandDispatch.Config do
  defmacro __using__(_) do
    quote do
      use HelperCore.Command
      import HelperCore.CommandDispatch.Config

      def handle_command(command) do
        command.name
        |> String.downcase
        |> dispatch(command)
      end
    end
  end

  defmacro command(name, module) do
    quote do
      defp dispatch(unquote(name), command) do
        apply(unquote(module), :handle_command, [command])
      end
    end
  end
end
