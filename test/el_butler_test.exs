defmodule ElButlerTest do
  use ExUnit.Case
  doctest ElButler

  test "greets the world" do
    assert ElButler.hello() == :world
  end
end
