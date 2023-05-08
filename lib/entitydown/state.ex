defmodule Entitydown.State do
  @moduledoc false

  alias Entitydown.Entity

  defmodule Line do
    @moduledoc false

    defstruct [:src, :len]

    @type t :: %__MODULE__{
            src: binary,
            len: non_neg_integer
          }
  end

  defstruct [:line, :pos, entiries: []]

  @type t :: %__MODULE__{
          line: Line.t(),
          pos: non_neg_integer,
          entiries: [Entity.t()]
        }

  def add_entity(state, entity) do
    entiries = state.entiries ++ [entity]

    %{state | entiries: entiries}
  end

  def update_pos(state, pos) do
    %{state | pos: pos}
  end
end
