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

        prev_char = String.at(src, pos - 1)

        if String.at(src, pos) == unquote(mark) && !escapes?(prev_char) do
          chars = String.graphemes(String.slice(src, pos + 1, len))

          case find_end_asterisk_pos(chars) do
            {:ok, ea_pos} ->
              text = chars |> Enum.slice(0..(ea_pos - 1)) |> Enum.join()

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

              # 后面继续 +1 是因为 `chars` 不包含起始字符
              state = state |> add_node(node) |> update_pos(pos + ea_pos + 1 + 1)

              {:match, state}

            :none ->
              {:nomatch, state}
          end
        else
          {:nomatch, state}
        end
      end

      defp find_end_asterisk_pos(chars) do
        _find_end_asterisk_pos(chars, length(chars), 0)
      end

      defp _find_end_asterisk_pos(_chars, len, start_pos) when len == start_pos do
        :none
      end

      defp _find_end_asterisk_pos(chars, len, start_pos) do
        find_r =
          Enum.slice(chars, start_pos..-1)
          |> Enum.with_index()
          |> Enum.find(fn {char, _i} ->
            char == unquote(mark)
          end)

        case find_r do
          {unquote(mark), i} ->
            prev_char = Enum.at(chars, start_pos + i - 1)
            pos = i + start_pos

            # pos > 0 是为了防止空值
            if pos > 0 && !escapes?(prev_char) do
              {:ok, pos}
            else
              _find_end_asterisk_pos(chars, len, start_pos + i + 1)
            end

          _ ->
            :none
        end
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
