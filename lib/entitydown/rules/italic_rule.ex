defmodule Entitydown.ItalicRule do
  @moduledoc false

  use Entitydown.Rule,
    signal_marker: "_",
    node_type: :italic,
    children_exclude: [Entitydown.CodeRule]
end
