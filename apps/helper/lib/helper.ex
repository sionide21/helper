defmodule Helper do
  use HelperCore.DispatchConfig
  alias Helper.Commands

  command "ls",       Commands.TestServerSide
  command "maintain", CacheCommands.Commands.Maintain
  command "test",     Commands.Test
  command _,          Commands.NotFound
end
