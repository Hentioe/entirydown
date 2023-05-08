defmodule Entirydown.State do
  @moduledoc false

  alias Entirydown.Entiry

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
          entiries: [Entiry.t()]
        }

  def add_entiry(state, entiry) do
    entiries = state.entiries ++ [entiry]

    %{state | entiries: entiries}
  end

  def update_pos(state, pos) do
    %{state | pos: pos}
  end
end
