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
    state = parse(@markdown)

    assert length(state.entities) == 34
  end
end
