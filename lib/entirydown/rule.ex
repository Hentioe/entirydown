defmodule Entirydown.Rule do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      alias Entirydown.State
      alias Entirydown.Entiry

      import Entirydown.State
      import Entirydown.Rule
    end
  end

  @doc ~S"""
  iex> Entirydown.Rule.escapes_char?("\\")
  true
  """
  @spec escapes_char?(String.t()) :: boolean()
  def escapes_char?(<<92>>), do: true
  def escapes_char?(_), do: false
end
