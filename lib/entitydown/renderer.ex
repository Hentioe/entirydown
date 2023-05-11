defmodule Entitydown.Renderer do
  @moduledoc false

  alias Entitydown.{Node, Entity}

  @spec render([Node.t()]) :: {String.t(), [Entity.t()]}
  def render(nodes) do
    Enum.reduce(nodes, {"", []}, fn node, {text, entities} ->
      render_node(node, text, entities)
    end)
  end

  @spec render_node(Node.t(), String.t(), [Entity.t()]) :: {String.t(), [Entity.t()]}

  # 渲染普通字符
  def render_node(%{type: nil, children: children}, text, entities) do
    text = text <> children

    {text, entities}
  end

  # 渲染并添加文本链接实体
  def render_node(%{type: :text_link, children: children} = node, text, entities)
      when is_binary(children) do
    length = String.length(children)
    offset = String.length(text)

    text = text <> children

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

  # 渲染并添加粗体实体
  def render_node(%{type: :bold, children: children} = _node, text, entities)
      when is_binary(children) do
    length = String.length(children)
    offset = String.length(text)

    text = text <> children

    entities =
      entities ++
        [
          %Entity{
            type: :bold,
            offset: offset,
            length: length
          }
        ]

    {text, entities}
  end
end
