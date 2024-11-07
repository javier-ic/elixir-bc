defmodule ProgramTest do
  use ExUnit.Case
  doctest Program

  test "greets the world" do
    assert Program.hello() == :world
  end
end
