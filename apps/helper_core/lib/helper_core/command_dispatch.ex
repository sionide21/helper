defmodule HelperCore.CommandDispatch do
  use __MODULE__.Config
  alias HelperCore.Commands

  command "test", Commands.Test
  command _, Commands.NotFound
end
