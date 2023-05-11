defmodule Entitydown.StrikethroughRuleTest do
  use ExUnit.Case
  doctest Entitydown

  alias Entitydown.{State, Node}

  import Entitydown.StrikethroughRule

  test "match/1" do
    state = %State{
      line: %State.Line{
        src: "\\~欢迎光临~",
        len: 1
      },
      pos: 0
    }

    assert match?({:nomatch, _}, match(state))

    src = "~欢迎光临~"

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
               type: :strikethrough,
               children: [%Node{children: "欢迎光临"}]
             }
           ]

    src = "~~欢迎光临\\~~"

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
               type: :strikethrough,
               children: [%Node{children: "~欢迎光临\\~"}]
             }
           ]
  end

  test "match empty" do
    src = "~~"

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
