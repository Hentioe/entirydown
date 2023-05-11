defmodule EntitydownTest do
  use ExUnit.Case
  doctest Entitydown

  import Entitydown

  test "nested" do
    markdown = """
    [*_我是加粗链接文字_*](https://t.me/)
    """

    {text, entities} = extract(markdown)

    assert text == """
           我是加粗链接文字

           """

    assert entities == [
             %Entitydown.Entity{
               type: :text_link,
               offset: 0,
               length: 8,
               url: "https://t.me/"
             },
             %Entitydown.Entity{
               type: :bold,
               offset: 0,
               length: 8
             },
             %Entitydown.Entity{
               type: :italic,
               offset: 0,
               length: 8
             }
           ]
  end
end
