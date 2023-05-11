defmodule Entitydown.Rule do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      alias Entitydown.State
      alias Entitydown.Node

      import Entitydown.State
      import Entitydown.Rule
    end
  end

  @doc ~S"""
  iex> Entitydown.Rule.escapes_char?("\\")
  true
  """
  @spec escapes_char?(String.t()) :: boolean()
  def escapes_char?(<<92>>), do: true
  def escapes_char?(_), do: false
end
