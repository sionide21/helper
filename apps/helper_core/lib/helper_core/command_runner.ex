defmodule HelperCore.CommandRunner do
  alias HelperCore.Commands

  def dispatch("test", context) do
    Commands.Test.handle_command(context)
  end

  def dispatch(_, context) do
    Commands.NotFound.handle_command(context)
  end
end
