defmodule EntitydownTest do
  use ExUnit.Case
  doctest Entitydown

  import Entitydown

  test "nested" do
    markdown = """
    [*_~我是加粗的斜体链接文字~_*](https://t.me/)
    """

    {text, entities} = extract(markdown)

    assert text == """
           我是加粗的斜体链接文字

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
             }
           ]
  end
end
