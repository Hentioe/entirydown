defmodule Entitydown.Renderer do
  @moduledoc false

  alias Entitydown.{Node, Entity}

  @spec render([Node.t()]) :: {String.t(), [Entity.t()]}
  def render(nodes) do
    Enum.reduce(nodes, {"", []}, fn node, {text, entities} ->
      render_node(node, text, entities, 0)
    end)
  end

  @spec render_node(Node.t(), String.t(), [Entity.t()], integer) :: {String.t(), [Entity.t()]}

  # 渲染普通字符
  def render_node(%{type: nil, children: children}, text, entities, _offset) do
    text = text <> children

    {text, entities}
  end

  # 渲染并添加文本链接实体
  def render_node(%{type: type, children: children} = node, text, entities, offset)
      when is_binary(children) do
    length = String.length(children)
    offset = offset + String.length(text)

    text = text <> children

    entities =
      entities ++
        [
          %Entity{
            type: type,
            offset: offset,
            length: length,
            url: node.url
          }
        ]

    {text, entities}
  end

  # 渲染并添加文本链接实体
  def render_node(%{type: type, children: children} = node, text, entities, offset)
      when is_list(children) do
    children_offset = String.length(text)
    # 因为 `children_offset` 等同于 `text` 长度，所以直接与 `children_offset` 相加
    offset = offset + children_offset

    {children_text, children_entities} = flatten_children(children, children_offset)

    length = String.length(children_text)

    text = text <> children_text

    entities =
      entities ++
        [
          %Entity{
            type: type,
            offset: offset,
            length: length,
            url: node.url
          }
        ] ++ children_entities

    {text, entities}
  end

  def flatten_children(children, offset, i \\ 0, text \\ "", entities \\ []) do
    case Enum.at(children, i) do
      nil ->
        {text, entities}

      node ->
        {text, entities} = render_node(node, text, entities, offset)

        flatten_children(children, offset, i + 1, text, entities)
    end
  end
end
