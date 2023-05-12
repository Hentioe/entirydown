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
    __我是_斜体部分_的下划线__
    """

    {text, entities} = extract(markdown)

    assert text == """
           我是加粗的斜体链接文字
           [我是链接文本](我是链接地址)
           `我是链接文本`
           我是一个斜体并加粗和删除后的链接文本
           我是删除线，我在删除的同时倾斜加粗我又正了
           我是斜体部分的下划线

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
             },
             %Entitydown.Entity{
               type: :underline,
               offset: 79,
               length: 10
             },
             %Entitydown.Entity{
               type: :italic,
               offset: 81,
               length: 4
             }
           ]
  end

  test "escapes" do
    markdown = """
    __欢迎\\__光临\\_\\___
    *\\~欢迎光临\\~*
    \\`欢迎光临`
    """

    {text, entities} = extract(markdown)

    assert text == """
           欢迎__光临__
           ~欢迎光临~
           `欢迎光临`

           """

    assert entities == [
             %Entitydown.Entity{
               type: :underline,
               offset: 0,
               length: 8
             },
             %Entitydown.Entity{
               type: :bold,
               offset: 9,
               length: 6
             }
           ]
  end
end
