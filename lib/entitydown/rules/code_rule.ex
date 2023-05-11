defmodule Entitydown.CodeRule do
  @moduledoc false

  use Entitydown.Rule, signal_marker: "`", node_type: :code, children_rules: []
end
