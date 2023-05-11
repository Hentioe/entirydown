defmodule Entitydown.Parser do
  @moduledoc false

  alias Entitydown.{Node, State, TextLinkRule, BoldRule}
  alias Entitydown.State.Line

  @rules [
    TextLinkRule,
    BoldRule
  ]

  @spec parse(String.t()) :: [Node.t()]
  def parse(text) do
    state =
      text
      |> String.split("\n")
      |> Enum.map(&Line.new/1)
      |> Enum.reduce(%State{}, fn line, state ->
        parse_node(%{state | line: line, pos: 0})
      end)

    state.nodes
  end

  @spec parse_node(State.t()) :: State.t()

  # 行已结束
  def parse_node(%{line: %{len: len}, pos: pos} = state) when len < pos + 1 do
    State.add_line_break(state)
  end

  def parse_node(state) do
    case Enum.reduce_while(@rules, {:nomatch, state}, &rule_parse/2) do
      {:match, state} ->
        parse_node(state)

      {:nomatch, state} ->
        state = State.read_normal_char(state)

        parse_node(state)
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
