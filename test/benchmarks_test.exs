defmodule BenchmarksTest do
  use ExUnit.Case
  doctest Benchmarks

  test "greets the world" do
    assert Benchmarks.hello() == :world
  end
end
