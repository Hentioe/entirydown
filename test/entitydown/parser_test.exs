defmodule Entitydown.ParserTest do
  use ExUnit.Case
  doctest Entitydown

  alias Entitydown.Node

  import Entitydown.Parser

  @markdown """
  [Google 官网](https://www.google.com/)
  点击[这里](https://t.me/)访问 Telegram 官网！
  *我是一段加粗文字*
  你好，*你叫什么名字？*
  --结束--
  """

  test "parse/1" do
    nodes = parse(@markdown)

    assert length(nodes) == 11

    text_link_nodes = Enum.filter(nodes, &(&1.type == :text_link))

    assert length(text_link_nodes) == 2

    assert Enum.at(text_link_nodes, 0) == %Node{
             type: :text_link,
             children: [%Node{children: "Google 官网"}],
             url: "https://www.google.com/"
           }

    assert Enum.at(text_link_nodes, 1) == %Node{
             type: :text_link,
             children: [%Node{children: "这里"}],
             url: "https://t.me/"
           }

    bold_nodes = Enum.filter(nodes, &(&1.type == :bold))

    assert length(bold_nodes) == 2

    assert Enum.at(bold_nodes, 0) == %Node{
             type: :bold,
             children: [%Node{children: "我是一段加粗文字"}]
           }

    assert Enum.at(bold_nodes, 1) == %Node{
             type: :bold,
             children: [%Node{children: "你叫什么名字？"}]
           }
  end
end
