defmodule NervesBackdoorTest do
  use ExUnit.Case
  doctest NervesBackdoor

  test "greets the world" do
    assert NervesBackdoor.hello() == :world
  end
end
