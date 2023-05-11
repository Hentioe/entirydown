defmodule Entitydown.BoldRule do
  @moduledoc false

  use Entitydown.Rule,
    signal_marker: "*",
    node_type: :bold,
    children_exclude: [Entitydown.CodeRule]
end
