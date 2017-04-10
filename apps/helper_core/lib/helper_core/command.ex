defmodule HelperCore.Command do
  @type packet :: {String.t, String.t}

  @callback handle_command(HelperCore.Context.t) :: HelperCore.Context.t

  defmacro __using__(_) do
    quote location: :keep do
      @behaviour HelperCore.Command
      import HelperCore.Context
    end
  end
end
