defmodule Entitydown.Parser do
  @moduledoc false

  alias Entitydown.{Node, State, CodeRule, TextLinkRule, BoldRule, ItalicRule, StrikethroughRule}
  alias Entitydown.State.Line

  @rules [
    CodeRule,
    TextLinkRule,
    BoldRule,
    ItalicRule,
    StrikethroughRule
  ]

  def rules, do: @rules

  @spec parse(String.t()) :: [Node.t()]
  def parse(text) do
    state =
      text
      |> String.split("\n")
      |> Enum.map(&Line.new/1)
      |> Enum.reduce(%State{}, fn line, state ->
        parse_node(%{state | line: line, pos: 0}, @rules, false)
      end)

    state.nodes
  end

  @spec parse_node(State.t(), [module], boolean) :: State.t()

  # 行已结束，非子节点需要换行
  def parse_node(%{line: %{len: len}, pos: pos} = state, _rules, false)
      when len < pos + 1 do
    State.add_line_break(state)
  end

  # 行已结束，子节点无需插入换行
  def parse_node(%{line: %{len: len}, pos: pos} = state, _rules, true)
      when len < pos + 1 do
    state
  end

  def parse_node(state, rules, in_children) do
    case Enum.reduce_while(rules, {:nomatch, state}, &rule_parse/2) do
      {:match, state} ->
        parse_node(state, rules, in_children)

      {:nomatch, state} ->
        state = State.read_normal_char(state)

        parse_node(state, rules, in_children)
    end
  end

  defp rule_parse(rule, {_, state}) do
    case rule.match(state) do
      {:match, state} ->
        {:halt, {:match, state}}

      {:nomatch, state} ->
        {:cont, {:nomatch, state}}
    end
  end
end
