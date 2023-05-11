defmodule Entitydown.Node do
  @moduledoc false

  defstruct [:type, :children, :url, :language]

  @type node_type ::
          :bold
          | :italic
          | :underline
          | :strikethrough
          | :spoiler
          | :code
          | :pre
          | :text_link

  @type t :: %__MODULE__{
          type: node_type | nil,
          children: binary | [t],
          url: binary | nil,
          language: binary | nil
        }
end
