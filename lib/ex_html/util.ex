defmodule ExHTML.Util do
  @moduledoc false

  @doc false
  def children({:__block__, _, children}), do: children
  def children(child), do: [child]
end
