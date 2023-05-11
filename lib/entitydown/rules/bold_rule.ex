defmodule Entitydown.BoldRule do
  @moduledoc false

  use Entitydown.Rule

  @spec match(State.t()) :: {:match, State.t()} | {:nomatch, State.t()}
  def match(state) do
    %{line: %{src: src, len: len}, pos: pos} = state

    prev_char = String.at(src, pos - 1)

    if String.at(src, pos) == "*" && !escapes_char?(prev_char) do
      chars = String.graphemes(String.slice(src, pos + 1, len))

      case find_end_asterisk_pos(chars) do
        {:ok, ea_pos} ->
          children = chars |> Enum.slice(0..(ea_pos - 1)) |> Enum.join()

          node = %Node{
            type: :bold,
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
        char == "*"
      end)

    case find_r do
      {"*", i} ->
        prev_char = Enum.at(chars, start_pos + i - 1)
        pos = i + start_pos

        # pos > 0 是为了防止空值
        if pos > 0 && !escapes_char?(prev_char) do
          {:ok, pos}
        else
          _find_end_asterisk_pos(chars, len, start_pos + i + 1)
        end

      _ ->
        :none
    end
  end
end
