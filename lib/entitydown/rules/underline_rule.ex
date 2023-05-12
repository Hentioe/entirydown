defmodule Entitydown.UnderlineRule do
  @moduledoc false

  use Entitydown.Rule

  alias Entitydown.{State, Parser, CodeRule}

  @children_exclude [CodeRule]

  @spec match(State.t()) :: {:match, State.t()} | {:nomatch, State.t()}
  def match(state) do
    %{line: %{src: src, len: len}, pos: pos} = state

    prev_char = String.at(src, pos - 1)

    if [String.at(src, pos), String.at(src, pos + 1)] == ["_", "_"] && !escapes?(prev_char) do
      chars = String.graphemes(String.slice(src, pos + 2, len))

      case loop(chars, 0, :text, 0) do
        {:ok, {chars, epos, deleted}} ->
          text = chars |> Enum.slice(pos..(pos + epos - 2)) |> Enum.join()

          children =
            Parser.parse_node(
              %State{line: State.Line.new(text), pos: 0},
              Parser.rules() -- [__MODULE__ | @children_exclude],
              true
            ).nodes

          node = %Node{
            type: :underline,
            children: children
          }

          state =
            state
            |> add_node(node)
            # +2: 跳过了前两个字符
            # +1: 跳下一个将要匹配的字符
            |> update_pos(pos + 2 + epos + deleted + 1)

          {:match, state}

        :none ->
          {:nomatch, state}
      end
    else
      {:nomatch, state}
    end
  end

  defp loop(chars, i, :text, deleted) do
    ch = Enum.at(chars, i)

    cond do
      ch == nil ->
        :none

      [ch, Enum.at(chars, i + 1)] == ["\\", "_"] ->
        # 删除转义字符后，下标已经减去一（原本应该 +2），组合 `children` 文本时无需再修正下标。
        # loop(List.delete_at(chars, i), i + 1, :text, deleted + 1)

        loop(chars, i + 2, :text, deleted)

      [ch, Enum.at(chars, i + 1)] == ["_", "_"] ->
        loop(chars, i, :ended, deleted)

      true ->
        loop(chars, i + 1, :text, deleted)
    end
  end

  # 当结束时下标没有移动，表示空内容，将视作不匹配
  defp loop(_chars, 0, :ended, _deleted) do
    :none
  end

  defp loop(chars, i, :ended, deleted) do
    {:ok, {chars, i + 1, deleted}}
  end
end
