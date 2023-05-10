defmodule Entitydown do
  @moduledoc false

  alias Entitydown.{Entity, Parser, Renderer}

  @type markdown_text :: String.t()
  @type plain_text :: String.t()
  @type entities :: [Entity.t()]

  @spec extract(markdown_text) :: {plain_text, entities}
  def extract(markdown_text) do
    markdown_text |> Parser.parse() |> Renderer.render()
  end
end
