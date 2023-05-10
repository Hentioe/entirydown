defmodule Entitydown.ParserTest do
  use ExUnit.Case
  doctest Entitydown

  import Entitydown.Parser

  @markdown """
  我是第一行[Google 官网](https://www.google.com)
  点击[这里](https://www.google.com)访问 Telegram 官网！
  --结束--
  """

  test "parse/1" do
    nodes = parse(@markdown)

    assert length(nodes) == 34
  end
end
