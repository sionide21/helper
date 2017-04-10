defmodule Helper do
  use HelperCore.DispatchConfig
  alias Helper.Commands

  command "test", Commands.Test
  command "ls",   Commands.TestServerSide
  command _,      Commands.NotFound
end
