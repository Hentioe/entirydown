defmodule Entitydown.UnderlineRuleTest do
  use ExUnit.Case
  doctest Entitydown

  alias Entitydown.{State, Node}

  import Entitydown.UnderlineRule

  test "match/1" do
    state = %State{
      line: State.Line.new("\\__欢迎光临__"),
      pos: 0
    }

    assert match?({:nomatch, _}, match(state))

    src = "__欢迎\\__光临\\_\\___"

    state = %State{
      line: State.Line.new(src),
      pos: 0
    }

    {:match, state} = match(state)

    assert state.pos == String.length(src)

    assert state.nodes == [
             %Node{
               type: :underline,
               children: [%Node{children: "欢迎__光临__"}]
             }
           ]
  end

  test "match empty" do
    src = "____"

    state = %State{
      line: State.Line.new(src),
      pos: 0
    }

    assert match?({:nomatch, _}, match(state))
  end
end
