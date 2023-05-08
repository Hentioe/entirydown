defmodule Entirydown.Entiry do
  @moduledoc false

  # 此处的 `entiry_type` 主要来自于 `https://core.telegram.org/bots/api#messageentity` 的 `type` 字段说明。
  @type entiry_type ::
          :bold
          | :italic
          | :underline
          | :strikethrough
          | :spoiler
          | :code
          | :pre
          | :text_link

  defstruct [:type, :offset, :length, :content, :url, :language]

  @type t :: %__MODULE__{
          type: entiry_type,
          offset: non_neg_integer,
          length: non_neg_integer,
          content: binary | nil,
          url: binary | nil,
          language: binary | nil
        }
end
