defmodule Entitydown.Entity do
  @moduledoc false

  # 此处的 `entity_type` 主要来自于 `https://core.telegram.org/bots/api#messageentity` 的 `type` 字段说明。
  @type entity_type ::
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
          type: entity_type,
          offset: non_neg_integer,
          length: non_neg_integer,
          content: binary | nil,
          url: binary | nil,
          language: binary | nil
        }
end
