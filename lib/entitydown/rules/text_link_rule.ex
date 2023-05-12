defmodule Entitydown.TextLinkRule do
  @moduledoc false

  use Entitydown.Rule

  alias Entitydown.{Parser, State, CodeRule}

  @children_exclude [CodeRule]

  @spec match(State.t()) :: {:match, State.t()} | {:nomatch, State.t()}
  def match(state) do
    %{line: %{src: src, len: len}, pos: pos} = state

    prev_escapes? =
      if pos > 0 do
        src |> String.at(pos - 1) |> escapes?()
      else
        false
      end

    start_matched? = String.at(src, pos) == "["

    cond do
      !prev_escapes? && start_matched? ->
        chars = String.graphemes(String.slice(src, pos + 1, len))

        with {:ok, {chars, espos, deleted}} <- find_end_square(chars, 0, :text, 0),
             {:ok, {chars, eepos, deleted}} <-
               find_end_parentheses(chars, 0, :url, deleted, espos + 2) do
          text = chars |> Enum.slice(0..(espos - 1)) |> Enum.join()
          url = chars |> Enum.slice((espos + 2)..(eepos - 1 + espos + 2)) |> Enum.join()

          children =
            Parser.parse_node(
              %State{line: State.Line.new(text), pos: 0},
              Parser.rules() -- [__MODULE__ | @children_exclude],
              true
            ).nodes

          node = %Node{
            type: :text_link,
            children: children,
            url: url
          }

          state =
            state
            |> add_node(node)
            # espos + 2: 文本内容到 url 首字符长度，因为 eepos 不包含这个长度
            |> update_pos(pos + 1 + eepos + deleted + 1 + espos + 2)

          {:match, state}
        else
          :none ->
            {:nomatch, state}
        end

      prev_escapes? && start_matched? ->
        state = remove_prev(state)

        {:nomatch, state}

      true ->
        {:nomatch, state}
    end
  end

  defp find_end_square(chars, i, :text, deleted) do
    ch = Enum.at(chars, i)

    cond do
      ch == nil ->
        :none

      ch == "\\" && Enum.at(chars, i + 1) in ["[", "]", "(", ")"] ->
        # 删除转义字符后，下标已经减去一（原本应该 +2），组合 `children` 文本时无需再修正下标。
        find_end_square(List.delete_at(chars, i), i + 1, :text, deleted + 1)

      ch == "]" && Enum.at(chars, i + 1) == "(" && i > 0 ->
        find_end_square(chars, i, :ended, deleted)

      true ->
        find_end_square(chars, i + 1, :text, deleted)
    end
  end

  defp find_end_square(chars, i, :ended, deleted) do
    {:ok, {chars, i, deleted}}
  end

  defp find_end_parentheses(chars, i, :url, deleted, start_pos) do
    ch = Enum.at(chars, start_pos + i)

    cond do
      ch == nil ->
        :none

      ch == "\\" && Enum.at(chars, start_pos + i + 1) in ["(", ")"] ->
        # 删除转义字符后，下标已经减去一（原本应该 +2），组合 `children` 文本时无需再修正下标。
        find_end_parentheses(
          List.delete_at(chars, start_pos + i),
          i + 1,
          :url,
          deleted + 1,
          start_pos
        )

      ch == ")" && i > 0 ->
        find_end_parentheses(chars, i, :ended, deleted, start_pos)

      true ->
        find_end_parentheses(chars, i + 1, :url, deleted, start_pos)
    end
  end

  defp find_end_parentheses(chars, i, :ended, deleted, _start_pos) do
    {:ok, {chars, i, deleted}}
  end
end
