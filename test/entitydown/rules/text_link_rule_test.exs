defmodule Entitydown.TextLinkRuleTest do
  use ExUnit.Case
  doctest Entitydown

  alias Entitydown.{State, Node}

  import Entitydown.TextLinkRule

  test "match/1" do
    state = %State{
      line: %State.Line{
        src: "\\[",
        len: 1
      },
      pos: 0
    }

    {:nomatch, _} = match(state)

    src = "[我是链接文本][]]]]](我是链接地址)"

    state = %State{
      line: %State.Line{
        src: src,
        len: String.length(src)
      },
      pos: 0
    }

    {:match, state} = match(state)

    assert state.pos == String.length(src)

    assert state.nodes == [
             %Node{
               type: :text_link,
               children: [%Node{children: "我是链接文本][]]]]"}],
               url: "我是链接地址"
             }
           ]

    src = "[我是链接文本][]]]]\\()](我是链接地址\\))"

    state = %State{
      line: State.Line.new(src),
      pos: 0
    }

    {:match, state} = match(state)

    assert state.pos == String.length(src)

    assert state.nodes == [
             %Node{
               type: :text_link,
               children: [%Node{children: "我是链接文本][]]]]()"}],
               url: "我是链接地址)"
             }
           ]

    src = "[Telegram 的主页](https://t.me/)"

    state = %State{
      line: %State.Line{
        src: src,
        len: String.length(src)
      },
      pos: 0
    }

    {:match, state} = match(state)

    assert state.pos == String.length(src)

    assert state.nodes == [
             %Node{
               type: :text_link,
               children: [%Node{children: "Telegram 的主页"}],
               url: "https://t.me/"
             }
           ]
  end

  test "match empty" do
    src = "[]()"

    state = %State{
      line: %State.Line{
        src: src,
        len: String.length(src)
      },
      pos: 0
    }

    assert match?({:nomatch, _}, match(state))

    src = "[我是链接文本]()"

    state = %State{
      line: %State.Line{
        src: src,
        len: String.length(src)
      },
      pos: 0
    }

    assert match?({:nomatch, _}, match(state))
  end
end
