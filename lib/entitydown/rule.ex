defmodule Entitydown.Rule do
  @moduledoc false

  defmacro __using__([]) do
    quote do
      alias Entitydown.State
      alias Entitydown.Node

      import Entitydown.State
      import unquote(__MODULE__)
    end
  end

  defmacro __using__([{:signal_marker, mark}, {:node_type, node_type} | opts]) do
    children_exclude = Keyword.get(opts, :children_exclude, [])

    rules =
      if rules = Keyword.get(opts, :children_rules) do
        rules
      else
        quote do: Parser.rules() -- [__MODULE__ | unquote(children_exclude)]
      end

    quote do
      alias Entitydown.State
      alias Entitydown.Node

      import Entitydown.State
      import unquote(__MODULE__)

      alias Entitydown.Parser

      @spec match(State.t()) :: {:match, State.t()} | {:nomatch, State.t()}
      def match(state) do
        %{line: %{src: src, len: len}, pos: pos} = state

        prev_escapes? =
          if pos > 0 do
            src |> String.at(pos - 1) |> escapes?()
          else
            false
          end

        start_matched? = String.at(src, pos) == unquote(mark)

        cond do
          !prev_escapes? && start_matched? ->
            chars = String.graphemes(String.slice(src, pos + 1, len))

            case loop(chars, 0, :text, 0) do
              {:ok, {chars, epos, deleted}} ->
                text = chars |> Enum.slice(0..(epos - 1)) |> Enum.join()

                children =
                  Parser.parse_node(
                    %State{line: State.Line.new(text), pos: 0},
                    unquote(rules),
                    true
                  ).nodes

                node = %Node{
                  type: unquote(node_type),
                  children: children
                }

                state =
                  state
                  |> add_node(node)
                  # +1: 跳过了前面一个字符
                  # +1: 跳下一个将要匹配的字符
                  |> update_pos(pos + 1 + epos + deleted + 1)

                {:match, state}

              :none ->
                {:nomatch, state}
            end

          prev_escapes? && start_matched? ->
            # 此处处理未匹配上，因为左边存在转义字符的情况。
            # 删除原始 `src` 当前座标的前一个转义字符
            # 删除最后一个节点 `children` 字符串的尾部转义字符（因为此时未匹配的文本已被追加到 `children` 中作为普通字符串）
            # 更新状态中新的 `line` 和节点列表，并偏移坐标（回溯 1 个坐标）

            chars = String.graphemes(String.slice(src, 0, len))
            nsrc = chars |> List.delete_at(pos - 1) |> Enum.join()

            if last_node = List.last(state.nodes) do
              last_node = %{last_node | children: String.slice(last_node.children, 0..-2)}

              nodes = List.update_at(state.nodes, -1, fn _node -> last_node end)

              {:nomatch, %{state | line: State.Line.new(nsrc), pos: pos - 1, nodes: nodes}}
            end

          true ->
            {:nomatch, state}
        end
      end

      defp loop(chars, i, :text, deleted) do
        ch = Enum.at(chars, i)

        cond do
          ch == nil ->
            :none

          [ch, Enum.at(chars, i + 1)] == ["\\", unquote(mark)] ->
            # 删除转义字符后，下标已经减去一（原本应该 +2），组合 `children` 文本时无需再修正下标。
            loop(List.delete_at(chars, i), i + 1, :text, deleted + 1)

          ch == unquote(mark) && i > 0 ->
            loop(chars, i, :ended, deleted)

          true ->
            loop(chars, i + 1, :text, deleted)
        end
      end

      defp loop(chars, i, :ended, deleted) do
        {:ok, {chars, i, deleted}}
      end
    end
  end

  @doc ~S"""
  iex> Entitydown.Rule.escapes_char?("\\")
  true
  """
  @spec escapes?(binary) :: boolean
  def escapes?(<<92>>), do: true
  def escapes?(_), do: false
end
