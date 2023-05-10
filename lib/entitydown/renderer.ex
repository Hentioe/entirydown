defmodule Entitydown.Renderer do
  @moduledoc false

  alias Entitydown.Entity

  @spec render(Entity.t()) :: {String.t(), [Entity.t()]}
  def render(nodes) do
    Enum.reduce(nodes, {"", []}, fn node, {text, entities} ->
      render_node(node, text, entities)
    end)
  end

  @spec render_node(Entity.t(), String.t(), [Entity.t()]) :: {String.t(), [Entity.t()]}

  # 渲染普通字符
  def render_node(%{type: nil, content: content}, text, entities) do
    text = text <> content

    {text, entities}
  end

  # 渲染并添加文本链接实体
  def render_node(%{type: :text_link, content: content} = node, text, entities) do
    length = String.length(content)
    offset = String.length(text)

    text = text <> content

    entities =
      entities ++
        [
          %Entity{
            type: :text_link,
            offset: offset,
            length: length,
            url: node.url
          }
        ]

    {text, entities}
  end
end
