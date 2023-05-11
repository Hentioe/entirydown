defmodule EntitydownTest do
  use ExUnit.Case
  doctest Entitydown

  import Entitydown

  test "nested combination" do
    markdown = """
    [*_我是加粗的斜体链接文字_*](https://t.me/)
    `[我是链接文本](我是链接地址)`
    [`我是链接文本`](我是链接地址)
    [_*~我是一个斜体并加粗和删除后的链接文本~*_](https://t.me/)
    ~我是删除线，_我在删除的同时倾斜*加粗*_我又正了~
    """

    {text, entities} = extract(markdown)

    assert text == """
           我是加粗的斜体链接文字
           [我是链接文本](我是链接地址)
           `我是链接文本`
           我是一个斜体并加粗和删除后的链接文本
           我是删除线，我在删除的同时倾斜加粗我又正了

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
               type: :code,
               offset: 12,
               length: 16
             },
             %Entitydown.Entity{
               type: :text_link,
               offset: 29,
               length: 8,
               url: "我是链接地址"
             },
             %Entitydown.Entity{
               type: :text_link,
               offset: 38,
               length: 18,
               url: "https://t.me/"
             },
             %Entitydown.Entity{
               type: :italic,
               offset: 38,
               length: 18
             },
             %Entitydown.Entity{
               type: :bold,
               offset: 38,
               length: 18
             },
             %Entitydown.Entity{
               type: :strikethrough,
               offset: 38,
               length: 18
             },
             %Entitydown.Entity{
               type: :strikethrough,
               offset: 57,
               length: 21
             },
             %Entitydown.Entity{
               type: :italic,
               offset: 63,
               length: 11
             },
             %Entitydown.Entity{
               type: :bold,
               offset: 72,
               length: 2
             }
           ]
  end
end
