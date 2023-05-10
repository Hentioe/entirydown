defmodule Entitydown.RenderTest do
  use ExUnit.Case
  doctest Entitydown

  alias Entitydown.Entity

  import Entitydown.Renderer

  @markdown """
  我是第一行[Google 官网](https://www.google.com)
  点击[这里](https://t.me)访问 Telegram 官网！
  --结束--
  """

  @plain_text """
  我是第一行Google 官网
  点击这里访问 Telegram 官网！
  --结束--

  """

  @entity1 %Entity{
    type: :text_link,
    offset: 5,
    length: 9,
    url: "https://www.google.com"
  }

  @entity2 %Entity{
    type: :text_link,
    offset: 17,
    length: 2,
    url: "https://t.me"
  }

  test "render/1" do
    nodes = Entitydown.Parser.parse(@markdown)

    {text, entites} = render(nodes)

    assert text == @plain_text
    assert Enum.at(entites, 0) == @entity1
    assert Enum.at(entites, 1) == @entity2
  end
end
