defmodule ARGVTest do
  use ExUnit.Case, async: true
  doctest ARGV

  test "joins arguments together" do
    assert ARGV.to_string(["echo", "hello", "world"]) == "echo hello world"
  end

  test "quotes arguments with spaces" do
    assert ARGV.to_string(["echo", "hello world"])  == ~s{echo "hello world"}
    assert ARGV.to_string(["echo", "hello\tworld"]) == ~s{echo "hello\tworld"}
    assert ARGV.to_string(["echo", "hello\nworld"]) == ~s{echo "hello\nworld"}
  end

  test "quotes arguments with single quotes" do
    assert ARGV.to_string(["echo", "It's working"])  == ~s{echo "It's working"}
  end

  test "quotes empty arguments" do
    assert ARGV.to_string(["cat", ""]) == ~s{cat ""}
  end

  test "quotes arguments with special characters" do
    assert ARGV.to_string(["echo", "$$", "!"])  == ~s{echo '$$' '!'}
    assert ARGV.to_string(["echo", "It's working!"])  == ~S{echo 'It'\''s working!'}
  end

  test "allows flags" do
    assert ARGV.to_string(["sh", "-c", "ls -l | grep $1"])  == ~s{sh -c 'ls -l | grep $1'}
  end

  test "escapes quotes" do
    assert ARGV.to_string(["echo", "hello\" world", "test\"", "\""]) == ~S{echo "hello\" world" test\" \"}
  end
end
