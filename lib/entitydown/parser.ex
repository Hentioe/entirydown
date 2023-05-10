defmodule Entitydown.Parser do
  @moduledoc false

  alias Entitydown.{State, TextLinkRule}
  alias Entitydown.State.Line

  @spec parse(String.t()) :: State.t()
  def parse(text) do
    text
    |> String.split("\n")
    |> Enum.map(&Line.new/1)
    |> Enum.reduce(%State{}, fn line, state ->
      parse_node(%{state | line: line, pos: 0})
    end)
  end

  def parse_node(%{line: %{len: len}, pos: pos} = state) when len < pos + 1 do
    State.add_line_break(state)
  end

  def parse_node(state) do
    case TextLinkRule.match(state) do
      {:match, state} ->
        parse_node(state)

      {:nomatch, state} ->
        state = State.read_normal_char(state)

        parse_node(state)
    end
  end
end
