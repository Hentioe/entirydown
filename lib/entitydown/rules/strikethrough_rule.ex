defmodule Entitydown.StrikethroughRule do
  @moduledoc false

  use Entitydown.Rule,
    signal_marker: "~",
    node_type: :strikethrough,
    children_exclude: [Entitydown.CodeRule]
end
