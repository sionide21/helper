defmodule CacheCommands.PeriodicCommand.InfoTest do
  use ExUnit.Case, async: true
  alias CacheCommands.PeriodicCommand.Info
  doctest Info

  describe "display_next_refresh" do
    test "shows a pretty duration" do
      info = %Info{next_refresh: 123}
      assert Info.display_next_refresh(info) == "2 minutes, 3 seconds"
    end

    test "handles no set refresh" do
      info = %Info{next_refresh: false}
      assert Info.display_next_refresh(info) == "now"

      info = %Info{next_refresh: nil}
      assert Info.display_next_refresh(info) == "now"

      info = %Info{next_refresh: 0}
      assert Info.display_next_refresh(info) == "now"
    end
  end

  describe "display_interval" do
    test "shows pretty interval" do
      info = %Info{interval: 3600}
      assert Info.display_interval(info) == "1 hour"
    end

    test "handles no set interval" do
      info = %Info{interval: nil}
      assert Info.display_interval(info) == ""
    end
  end

  describe "display_last_refreshed" do
    test "shows formatted datetime" do
      info = %Info{last_refreshed: 1492427738}
      assert Info.display_last_refreshed(info) == "Mon Apr 17 11:15:38 2017"
    end

    test "handles never refreshed" do
      info = %Info{last_refreshed: nil}
      assert Info.display_last_refreshed(info) == "never"
    end
  end

  describe "display" do
    setup do
      {:ok, %{
        info: Info.new(
          command: ["ls", "-lh", "*.ex"],
          interval: 300,
          last_refreshed: 1492427738,
          next_refresh: 120
        )
      }}
    end

    test "prints full info", %{info: info} do
      assert Info.display(info) == "N7JFVY\tls -lh '*.ex'\t5 minutes\tMon Apr 17 11:15:38 2017\t2 minutes"
    end

    test "accepts list of infos", %{info: info} do
      info2 = %Info{info | command: ["ls"], interval: 24 * 60 * 60}
      assert Info.display([info, info2]) == "N7JFVY\tls -lh '*.ex'\t5 minutes\tMon Apr 17 11:15:38 2017\t2 minutes\nMRG7II\tls           \t1 day    \tMon Apr 17 11:15:38 2017\t2 minutes"
    end

    test "can include headers", %{info: info} do
      assert Info.display(info, headers: true) == "ID    \tCMD          \tINTERVAL \tLAST REFRESH            \tNEXT REFRESH\nN7JFVY\tls -lh '*.ex'\t5 minutes\tMon Apr 17 11:15:38 2017\t2 minutes   "
    end
  end
end
