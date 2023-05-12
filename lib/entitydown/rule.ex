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

        if String.at(src, pos) == unquote(mark) && !prev_escapes? do
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
        else
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
            # loop(List.delete_at(chars, i), i + 1, :text, deleted + 1)

            loop(chars, i + 2, :text, deleted)

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
