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

    def new(src) do
      %__MODULE__{
        src: src,
        len: String.length(src)
      }
    end
  end

  defstruct [:line, :pos, entities: []]

  @type t :: %__MODULE__{
          line: Line.t(),
          pos: non_neg_integer,
          entities: [Entity.t()]
        }

  def add_entity(state, entity) do
    entities = state.entities ++ [entity]

    %{state | entities: entities}
  end

  def read_normal_char(state) do
    entities = state.entities ++ [%Entity{content: String.slice(state.line.src, state.pos, 1)}]

    %{state | entities: entities, pos: state.pos + 1}
  end

  def add_line_break(state) do
    entities = state.entities ++ [%Entity{content: "\n"}]

    %{state | entities: entities, pos: state.pos + 1}
  end

  def update_pos(state, pos) do
    %{state | pos: pos}
  end
end
