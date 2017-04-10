defmodule HelperCore.Commands.Dispatch do
  use HelperCore.DispatchConfig
  alias HelperCore.Commands

  command "test", Commands.Test
  command "ls",   Commands.TestServerSide
  command _,      Commands.NotFound
end
