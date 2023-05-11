defmodule EntitydownTest do
  use ExUnit.Case
  doctest Entitydown

  import Entitydown

  test "nested" do
    markdown = """
    [*_~我是加粗的斜体链接文字~_*](https://t.me/)
    `[我是链接文本](我是链接地址)`
    [`我是链接文本`](我是链接地址)
    """

    {text, entities} = extract(markdown)

    assert text == """
           我是加粗的斜体链接文字
           [我是链接文本](我是链接地址)
           `我是链接文本`

           """

    assert entities == [
             %Entitydown.Entity{
               type: :text_link,
               offset: 0,
               length: 11,
               url: "https://t.me/"
             },
             %Entitydown.Entity{
               type: :bold,
               offset: 0,
               length: 11
             },
             %Entitydown.Entity{
               type: :italic,
               offset: 0,
               length: 11
             },
             %Entitydown.Entity{
               type: :strikethrough,
               offset: 0,
               length: 11
             },
             %Entitydown.Entity{
               type: :code,
               offset: 12,
               length: 16
             },
             %Entitydown.Entity{
               type: :text_link,
               offset: 29,
               length: 8,
               url: "我是链接地址"
             }
           ]
  end
end
