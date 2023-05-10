defmodule Entitydown.TextLinkRule do
  @moduledoc false

  use Entitydown.Rule

  @spec match(State.t()) :: {:match, State.t()} | {:nomatch, State.t()}
  def match(state) do
    %{line: %{src: src, len: len}, pos: pos} = state

    prev_char = String.at(src, pos - 1)

    if String.at(src, pos) == "[" && !escapes_char?(prev_char) do
      chars = String.graphemes(String.slice(src, pos + 1, len))

      with {:ok, cs_pos} <- find_close_square_pos(chars),
           {:ok, cp_pos} <- find_close_parentheses(Enum.slice(chars, (cs_pos + 2)..-1)) do
        text = chars |> Enum.slice(0..(cs_pos - 1)) |> Enum.join()

        url =
          chars
          |> Enum.slice((cs_pos + 2)..(cs_pos + 2 + cp_pos - 1))
          |> Enum.join()

        entity = %Entity{
          type: :text_link,
          content: text,
          url: url
        }

        # 后面继续 +1 是因为 `chars` 不包含起始字符
        state = state |> add_entity(entity) |> update_pos(pos + cs_pos + 2 + cp_pos + 1 + 1)

        {:match, state}
      else
        :none ->
          {:nomatch, state}
      end
    else
      {:nomatch, state}
    end
  end

  defp find_close_square_pos(chars) do
    _find_close_square_pos(chars, length(chars), 0)
  end

  defp _find_close_square_pos(_chars, len, start_pos) when len == start_pos do
    :none
  end

  defp _find_close_square_pos(chars, len, start_pos) do
    find_r =
      Enum.slice(chars, start_pos..-1)
      |> Enum.with_index()
      |> Enum.find(fn {char, _i} ->
        char == "]"
      end)

    case find_r do
      {"]", i} ->
        next_char = Enum.at(chars, start_pos + i + 1)
        pos = i + start_pos

        # pos > 0 是为了防止空值
        if pos > 0 && next_char == "(" do
          {:ok, pos}
        else
          _find_close_square_pos(chars, len, start_pos + i + 1)
        end

      _ ->
        :none
    end
  end

  def find_close_parentheses(chars) do
    _find_close_parentheses(chars, length(chars), 0)
  end

  defp _find_close_parentheses(_chars, len, start_pos) when len == start_pos do
    :none
  end

  defp _find_close_parentheses(chars, len, start_pos) do
    find_r =
      Enum.slice(chars, start_pos..-1)
      |> Enum.with_index()
      |> Enum.find(fn {char, _i} ->
        char == ")"
      end)

    case find_r do
      {")", i} ->
        prev_char = Enum.at(chars, start_pos + i - 1)
        pos = i + start_pos

        # pos > 0 是为了防止空值
        if pos > 0 && !escapes_char?(prev_char) do
          {:ok, pos}
        else
          _find_close_parentheses(chars, len, start_pos + i + 1)
        end

      _ ->
        :none
    end
  end
end
